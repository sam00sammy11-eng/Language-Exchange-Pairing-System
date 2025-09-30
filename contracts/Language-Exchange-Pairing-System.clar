(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INVALID_INPUT (err u400))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_INSUFFICIENT_BALANCE (err u402))

(define-data-var next-user-id uint u1)
(define-data-var next-pairing-id uint u1)
(define-data-var next-milestone-id uint u1)
(define-data-var total-rewards-distributed uint u0)

(define-map users 
  { user-id: uint }
  {
    wallet: principal,
    native-language: (string-ascii 20),
    learning-language: (string-ascii 20),
    proficiency-level: uint,
    active: bool,
    joined-at: uint,
    total-milestones: uint,
    reputation-score: uint
  }
)

(define-map user-wallet-to-id
  { wallet: principal }
  { user-id: uint }
)

(define-map language-pairings
  { pairing-id: uint }
  {
    user1-id: uint,
    user2-id: uint,
    shared-language1: (string-ascii 20),
    shared-language2: (string-ascii 20),
    status: (string-ascii 10),
    created-at: uint,
    last-activity: uint,
    total-sessions: uint
  }
)

(define-map user-pairings
  { user-id: uint }
  { active-pairing-ids: (list 10 uint) }
)

(define-map milestones
  { milestone-id: uint }
  {
    pairing-id: uint,
    milestone-type: (string-ascii 20),
    description: (string-ascii 100),
    reward-amount: uint,
    completed-by: uint,
    completed-at: uint,
    verified: bool
  }
)

(define-map pairing-milestones
  { pairing-id: uint }
  { milestone-ids: (list 20 uint) }
)

(define-public (register-user (native-lang (string-ascii 20)) (learning-lang (string-ascii 20)) (proficiency uint))
  (let
    (
      (current-id (var-get next-user-id))
      (current-block stacks-block-height)
    )
    (asserts! (is-none (map-get? user-wallet-to-id { wallet: tx-sender })) ERR_ALREADY_EXISTS)
    (asserts! (and (> proficiency u0) (<= proficiency u5)) ERR_INVALID_INPUT)
    (asserts! (not (is-eq native-lang learning-lang)) ERR_INVALID_INPUT)
    
    (map-set users 
      { user-id: current-id }
      {
        wallet: tx-sender,
        native-language: native-lang,
        learning-language: learning-lang,
        proficiency-level: proficiency,
        active: true,
        joined-at: current-block,
        total-milestones: u0,
        reputation-score: u100
      }
    )
    
    (map-set user-wallet-to-id { wallet: tx-sender } { user-id: current-id })
    (var-set next-user-id (+ current-id u1))
    (ok current-id)
  )
)

(define-public (find-language-partner (target-user-id uint))
  (let
    (
      (caller-user-data (unwrap! (get-user-by-wallet tx-sender) ERR_NOT_FOUND))
      (target-user-data (unwrap! (map-get? users { user-id: target-user-id }) ERR_NOT_FOUND))
      (current-pairing-id (var-get next-pairing-id))
      (current-block stacks-block-height)
    )
    (asserts! (get active caller-user-data) ERR_UNAUTHORIZED)
    (asserts! (get active target-user-data) ERR_UNAUTHORIZED)
    (asserts! (not (is-eq (get user-id caller-user-data) target-user-id)) ERR_INVALID_INPUT)
    
    (asserts! 
      (or 
        (and 
          (is-eq (get native-language caller-user-data) (get learning-language target-user-data))
          (is-eq (get learning-language caller-user-data) (get native-language target-user-data))
        )
        (is-eq (get native-language caller-user-data) (get learning-language target-user-data))
        (is-eq (get learning-language caller-user-data) (get native-language target-user-data))
      )
      ERR_INVALID_INPUT
    )
    
    (map-set language-pairings
      { pairing-id: current-pairing-id }
      {
        user1-id: (get user-id caller-user-data),
        user2-id: target-user-id,
        shared-language1: (get native-language caller-user-data),
        shared-language2: (get learning-language caller-user-data),
        status: "active",
        created-at: current-block,
        last-activity: current-block,
        total-sessions: u0
      }
    )
    
    (update-user-pairings (get user-id caller-user-data) current-pairing-id)
    (update-user-pairings target-user-id current-pairing-id)
    (var-set next-pairing-id (+ current-pairing-id u1))
    (ok current-pairing-id)
  )
)

(define-public (create-milestone (pairing-id uint) (milestone-type (string-ascii 20)) (description (string-ascii 100)) (reward uint))
  (let
    (
      (pairing-data (unwrap! (map-get? language-pairings { pairing-id: pairing-id }) ERR_NOT_FOUND))
      (caller-user-data (unwrap! (get-user-by-wallet tx-sender) ERR_NOT_FOUND))
      (current-milestone-id (var-get next-milestone-id))
    )
    (asserts! 
      (or 
        (is-eq (get user1-id pairing-data) (get user-id caller-user-data))
        (is-eq (get user2-id pairing-data) (get user-id caller-user-data))
      )
      ERR_UNAUTHORIZED
    )
    (asserts! (is-eq (get status pairing-data) "active") ERR_INVALID_INPUT)
    (asserts! (> reward u0) ERR_INVALID_INPUT)
    
    (map-set milestones
      { milestone-id: current-milestone-id }
      {
        pairing-id: pairing-id,
        milestone-type: milestone-type,
        description: description,
        reward-amount: reward,
        completed-by: u0,
        completed-at: u0,
        verified: false
      }
    )
    
    (update-pairing-milestones pairing-id current-milestone-id)
    (var-set next-milestone-id (+ current-milestone-id u1))
    (ok current-milestone-id)
  )
)

(define-public (complete-milestone (milestone-id uint))
  (let
    (
      (milestone-data (unwrap! (map-get? milestones { milestone-id: milestone-id }) ERR_NOT_FOUND))
      (pairing-data (unwrap! (map-get? language-pairings { pairing-id: (get pairing-id milestone-data) }) ERR_NOT_FOUND))
      (caller-user-data (unwrap! (get-user-by-wallet tx-sender) ERR_NOT_FOUND))
      (current-block stacks-block-height)
    )
    (asserts! 
      (or 
        (is-eq (get user1-id pairing-data) (get user-id caller-user-data))
        (is-eq (get user2-id pairing-data) (get user-id caller-user-data))
      )
      ERR_UNAUTHORIZED
    )
    (asserts! (is-eq (get completed-by milestone-data) u0) ERR_ALREADY_EXISTS)
    
    (map-set milestones
      { milestone-id: milestone-id }
      (merge milestone-data {
        completed-by: (get user-id caller-user-data),
        completed-at: current-block,
        verified: true
      })
    )
    
    (update-user-milestones (get user-id caller-user-data))
    (update-user-reputation (get user-id caller-user-data) u10)
    (var-set total-rewards-distributed (+ (var-get total-rewards-distributed) (get reward-amount milestone-data)))
    (ok true)
  )
)

(define-public (record-session (pairing-id uint) (duration uint))
  (let
    (
      (pairing-data (unwrap! (map-get? language-pairings { pairing-id: pairing-id }) ERR_NOT_FOUND))
      (caller-user-data (unwrap! (get-user-by-wallet tx-sender) ERR_NOT_FOUND))
      (current-block stacks-block-height)
    )
    (asserts! 
      (or 
        (is-eq (get user1-id pairing-data) (get user-id caller-user-data))
        (is-eq (get user2-id pairing-data) (get user-id caller-user-data))
      )
      ERR_UNAUTHORIZED
    )
    (asserts! (is-eq (get status pairing-data) "active") ERR_INVALID_INPUT)
    (asserts! (> duration u0) ERR_INVALID_INPUT)
    
    (map-set language-pairings
      { pairing-id: pairing-id }
      (merge pairing-data {
        last-activity: current-block,
        total-sessions: (+ (get total-sessions pairing-data) u1)
      })
    )
    
    (update-user-reputation (get user-id caller-user-data) u5)
    (ok true)
  )
)

(define-public (end-pairing (pairing-id uint))
  (let
    (
      (pairing-data (unwrap! (map-get? language-pairings { pairing-id: pairing-id }) ERR_NOT_FOUND))
      (caller-user-data (unwrap! (get-user-by-wallet tx-sender) ERR_NOT_FOUND))
    )
    (asserts! 
      (or 
        (is-eq (get user1-id pairing-data) (get user-id caller-user-data))
        (is-eq (get user2-id pairing-data) (get user-id caller-user-data))
      )
      ERR_UNAUTHORIZED
    )
    (asserts! (is-eq (get status pairing-data) "active") ERR_INVALID_INPUT)
    
    (map-set language-pairings
      { pairing-id: pairing-id }
      (merge pairing-data { status: "ended" })
    )
    (ok true)
  )
)

(define-read-only (get-user (user-id uint))
  (map-get? users { user-id: user-id })
)

(define-read-only (get-user-by-wallet (wallet principal))
  (match (map-get? user-wallet-to-id { wallet: wallet })
    user-data (match (map-get? users { user-id: (get user-id user-data) })
      user-info (some (merge user-info { user-id: (get user-id user-data) }))
      none
    )
    none
  )
)

(define-read-only (get-pairing (pairing-id uint))
  (map-get? language-pairings { pairing-id: pairing-id })
)

(define-read-only (get-milestone (milestone-id uint))
  (map-get? milestones { milestone-id: milestone-id })
)

(define-read-only (get-user-pairings (user-id uint))
  (default-to { active-pairing-ids: (list) } (map-get? user-pairings { user-id: user-id }))
)

(define-read-only (get-pairing-milestones (pairing-id uint))
  (default-to { milestone-ids: (list) } (map-get? pairing-milestones { pairing-id: pairing-id }))
)

(define-read-only (get-total-users)
  (- (var-get next-user-id) u1)
)

(define-read-only (get-total-pairings)
  (- (var-get next-pairing-id) u1)
)

(define-read-only (get-total-milestones)
  (- (var-get next-milestone-id) u1)
)

(define-read-only (get-total-rewards)
  (var-get total-rewards-distributed)
)

(define-private (update-user-pairings (user-id uint) (pairing-id uint))
  (let
    (
      (current-pairings (get active-pairing-ids (get-user-pairings user-id)))
      (updated-pairings (unwrap! (as-max-len? (append current-pairings pairing-id) u10) false))
    )
    (map-set user-pairings { user-id: user-id } { active-pairing-ids: updated-pairings })
  )
)

(define-private (update-pairing-milestones (pairing-id uint) (milestone-id uint))
  (let
    (
      (current-milestones (get milestone-ids (get-pairing-milestones pairing-id)))
      (updated-milestones (unwrap! (as-max-len? (append current-milestones milestone-id) u20) false))
    )
    (map-set pairing-milestones { pairing-id: pairing-id } { milestone-ids: updated-milestones })
  )
)

(define-private (update-user-milestones (user-id uint))
  (match (map-get? users { user-id: user-id })
    user-data 
    (map-set users 
      { user-id: user-id }
      (merge user-data { total-milestones: (+ (get total-milestones user-data) u1) })
    )
    false
  )
)

(define-private (update-user-reputation (user-id uint) (points uint))
  (match (map-get? users { user-id: user-id })
    user-data 
    (map-set users 
      { user-id: user-id }
      (merge user-data { reputation-score: (+ (get reputation-score user-data) points) })
    )
    false
  )
)
