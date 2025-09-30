# 🌍 Language Exchange Pairing System

A decentralized language exchange platform built on the Stacks blockchain using Clarity smart contracts. Match with language partners, track progress through on-chain milestones, and earn rewards for your language learning journey! 🎯

## 📋 Overview

The Language Exchange Pairing System enables global language practice without centralized apps by providing:

- 👥 **Decentralized Partner Matching**: Find language partners based on native and learning languages
- 🏆 **Milestone Tracking**: Set and complete learning milestones with on-chain verification
- 💎 **Rewards System**: Earn reputation points and track achievements
- 📊 **Progress Analytics**: Monitor sessions, milestones, and overall progress

## ✨ Features

### User Management
- 📝 Register with native language, learning language, and proficiency level
- 🔍 Browse and discover potential language partners
- ⭐ Build reputation through active participation

### Partner Matching
- 🎯 Smart matching algorithm based on complementary languages
- 💬 Support for bidirectional language exchange
- 📈 Track session history and activity

### Milestone System
- 🎯 Create custom learning milestones
- ✅ Complete and verify achievements
- 🏅 Earn rewards for milestone completion
- 📊 Track progress over time

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://docs.hiro.so/stacks/clarinet) installed
- [Node.js](https://nodejs.org/) for running tests

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Language-Exchange-Pairing-System
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Check contract compilation**
   ```bash
   clarinet check
   ```

4. **Run tests**
   ```bash
   npm test
   ```

## 📖 Usage Guide

### 1. Register as a User 👤

```clarity
(contract-call? .Language-Exchange-Pairing-System register-user "English" "Spanish" u3)
```

Parameters:
- `native-lang`: Your native language (string-ascii 20)
- `learning-lang`: Language you want to learn (string-ascii 20)  
- `proficiency`: Your proficiency level 1-5 (uint)

### 2. Find a Language Partner 🔍

```clarity
(contract-call? .Language-Exchange-Pairing-System find-language-partner u2)
```

Parameters:
- `target-user-id`: ID of the user you want to pair with (uint)

### 3. Create Learning Milestones 🎯

```clarity
(contract-call? .Language-Exchange-Pairing-System create-milestone u1 "conversation" "Complete 10 conversations" u100)
```

Parameters:
- `pairing-id`: ID of your language pairing (uint)
- `milestone-type`: Type of milestone (string-ascii 20)
- `description`: Milestone description (string-ascii 100)
- `reward`: Reward amount for completion (uint)

### 4. Complete Milestones ✅

```clarity
(contract-call? .Language-Exchange-Pairing-System complete-milestone u1)
```

Parameters:
- `milestone-id`: ID of the milestone to complete (uint)

### 5. Record Practice Sessions 📝

```clarity
(contract-call? .Language-Exchange-Pairing-System record-session u1 u60)
```

Parameters:
- `pairing-id`: ID of your language pairing (uint)
- `duration`: Session duration in minutes (uint)

## 📊 Read-Only Functions

### Get User Information
```clarity
(contract-call? .Language-Exchange-Pairing-System get-user u1)
(contract-call? .Language-Exchange-Pairing-System get-user-by-wallet 'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

### Get Pairing Details
```clarity
(contract-call? .Language-Exchange-Pairing-System get-pairing u1)
(contract-call? .Language-Exchange-Pairing-System get-user-pairings u1)
```

### Get Milestone Information  
```clarity
(contract-call? .Language-Exchange-Pairing-System get-milestone u1)
(contract-call? .Language-Exchange-Pairing-System get-pairing-milestones u1)
```

### Get Platform Statistics
```clarity
(contract-call? .Language-Exchange-Pairing-System get-total-users)
(contract-call? .Language-Exchange-Pairing-System get-total-pairings)
(contract-call? .Language-Exchange-Pairing-System get-total-milestones)
(contract-call? .Language-Exchange-Pairing-System get-total-rewards)
```

## 🏗️ Contract Architecture

### Data Maps
- **users**: Store user profiles with language preferences and stats
- **user-wallet-to-id**: Map wallet addresses to user IDs
- **language-pairings**: Track active language partnerships
- **user-pairings**: List of active pairings per user
- **milestones**: Store milestone definitions and completion status
- **pairing-milestones**: Link milestones to specific pairings

### Key Features
- 🔒 **Access Control**: Users can only modify their own data
- ✅ **Input Validation**: Comprehensive validation for all user inputs
- 🎯 **Smart Matching**: Language compatibility verification
- 📈 **Reputation System**: Points-based reputation building
- 🏆 **Achievement Tracking**: Milestone completion and rewards

## 🧪 Testing

Run the test suite to verify contract functionality:

```bash
npm test
```

Tests cover:
- User registration and validation
- Partner matching logic
- Milestone creation and completion
- Session recording
- Data retrieval functions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🌟 Impact

This decentralized language exchange system enables:
- 🌍 **Global Access**: No geographic restrictions or centralized control
- 💪 **User Ownership**: Complete control over learning data and achievements  
- 🎯 **Incentivized Learning**: On-chain rewards for consistent practice
- 🔄 **Community Building**: Direct peer-to-peer language exchange

---

Built with ❤️ using Clarity smart contracts on Stacks blockchain 🔗

