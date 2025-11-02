# 🌊 AION Flow Smart Contracts (Cadence)

<div align="center">

[![Flow Testnet](https://img.shields.io/badge/Flow-Testnet%20Live-00EF8B?style=flat-square&logo=flow)](https://testnet.flowdiver.io/account/0xc7a34c80e6f3235b)
[![Cadence](https://img.shields.io/badge/Cadence-1.0-00EF8B?style=flat-square)](https://docs.onflow.org/cadence/)

**Native Flow Smart Contracts for AION DeFi Vault**

**Deployed:** ✅ Live on Flow Testnet | **Address:** `0xc7a34c80e6f3235b`

</div>

---

## 🎯 Overview

AION's **native Flow implementation** using Cadence - Flow's resource-oriented programming language. These contracts enable:

- 🏦 **DeFi Vault** - Deposit and earn yield on Flow
- ⚙️ **Action Registry** - Automated DeFi actions (FLIP-338)
- 🔐 **Resource Safety** - Flow's built-in security guarantees

**Deployed Contracts:**
- **AIONVault.cdc** (472 lines) - Main vault contract
- **ActionRegistry.cdc** (306 lines) - Action management

---

## 🚀 Quick Start

### Installation

```bash
# Install Flow CLI
sh -ci "$(curl -fsSL https://raw.githubusercontent.com/onflow/flow-cli/master/install.sh)"

# Verify installation
flow version
```

### Deploy to Flow Testnet

```bash
cd cadence

# Deploy contracts (already deployed ✅)
flow project deploy --network=testnet

# Verify deployment
flow scripts execute scripts/get_vault_stats.cdc --network testnet
flow scripts execute scripts/get_actions.cdc --network testnet
```

### Query Deployed Contracts

```bash
# Get vault statistics
flow scripts execute scripts/get_vault_stats.cdc --network testnet

# Get registered actions
flow scripts execute scripts/get_actions.cdc --network testnet

# Get user balance
flow scripts execute scripts/get_balance.cdc 0xc7a34c80e6f3235b --network testnet
```

### Execute Transactions

```bash
# Deposit FLOW
flow transactions send transactions/deposit.cdc 1.0 --network testnet --signer testnet-account

# Withdraw
flow transactions send transactions/withdraw.cdc 0.5 --network testnet --signer testnet-account

# Register action
flow transactions send transactions/register_action.cdc \
  "auto_optimize" \
  "AI-powered yield optimization" \
  5 \
  --network testnet --signer testnet-account
```

---

## 📜 Deployed Contracts

### AIONVault.cdc

**Main DeFi vault contract**

**Contract Address:** `0xc7a34c80e6f3235b`  
**Network:** Flow Testnet  
**Status:** ✅ LIVE  
**Explorer:** [View Contract](https://testnet.flowdiver.io/account/0xc7a34c80e6f3235b)

**Key Functions:**
```cadence
// Deposit FLOW tokens
pub fun deposit(from: Address, amount: UFix64): UFix64

// Withdraw FLOW tokens
pub fun withdraw(from: Address, shares: UFix64): UFix64

// Get vault statistics
pub fun getVaultStats(): {String: UFix64}

// Get user balance
pub fun balanceOf(user: Address): UFix64
```

**Statistics:**
- Lines of Code: 472
- Public Functions: 12
- Events: 8
- Resources: 2

### ActionRegistry.cdc

**Automated action management (FLIP-338 compatible)**

**Contract Address:** `0xc7a34c80e6f3235b`  
**Network:** Flow Testnet  
**Status:** ✅ LIVE

**Key Functions:**
```cadence
// Register new action
pub fun registerAction(id: String, description: String, riskLevel: UInt8)

// Get all actions
pub fun getAllActions(): {String: ActionMeta}

// Get action statistics
pub fun getActionStats(actionId: String): ActionStats
```

**Registered Actions:**
1. `auto_optimize` - AI-powered yield optimization
2. `harvest_rewards` - Automatic reward compounding

**Statistics:**
- Lines of Code: 306
- Public Functions: 8
- Events: 4
- Total Actions Registered: 2 ✅

---

## 📊 Real Transaction Evidence

### Verified Transactions on Flow Testnet

| Date | Type | Amount | Block | TX Hash | Status |
|------|------|--------|-------|---------|--------|
| Nov 1, 2025 | Deposit | 10.0 FLOW | 287,951,714 | [57b16311...](https://testnet.flowscan.io/tx/57b1631173d2be3915fa46d25df4a82fb9f266f934f0dec6bc5401da083c109b) | ✅ Sealed |
| Nov 1, 2025 | Register Action | auto_optimize | 287,954,902 | [592c2c6a...](https://testnet.flowscan.io) | ✅ Sealed |
| Nov 1, 2025 | Register Action | harvest_rewards | 287,954,963 | [6cc7b7c1...](https://testnet.flowscan.io) | ✅ Sealed |

**Total: 3 sealed transactions on Flow Testnet** ✅

**Verify on Explorer:**
https://testnet.flowdiver.io/account/0xc7a34c80e6f3235b

---

## 🏗️ Architecture

### Contract Interaction Flow

```
┌─────────────────────────────────────────────────────────┐
│                    User Layer                           │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐   │
│  │   Web    │  │  Mobile  │  │  Flow Wallet       │   │
│  │   App    │  │   App    │  │  (FCL)             │   │
│  └────┬─────┘  └────┬─────┘  └──────┬─────────────┘   │
└───────┼─────────────┼────────────────┼─────────────────┘
        │             │                │
        ▼             ▼                ▼
┌─────────────────────────────────────────────────────────┐
│              Flow Cadence Testnet                       │
│  ┌────────────────────────────────────────────────┐    │
│  │        AIONVault.cdc (0xc7a34c80e6f3235b)      │    │
│  │  ┌──────────────┐  ┌──────────────────────┐   │    │
│  │  │  Resources   │  │  Public Functions    │   │    │
│  │  │  - VaultData │  │  - deposit()         │   │    │
│  │  │  - Shares    │  │  - withdraw()        │   │    │
│  │  └──────────────┘  │  - getVaultStats()   │   │    │
│  │                    │  - balanceOf()       │   │    │
│  │                    └──────────────────────┘   │    │
│  └────────────────────────────────────────────────┘    │
│                                                         │
│  ┌────────────────────────────────────────────────┐    │
│  │    ActionRegistry.cdc (0xc7a34c80e6f3235b)     │    │
│  │  ┌──────────────┐  ┌──────────────────────┐   │    │
│  │  │  Actions     │  │  Public Functions    │   │    │
│  │  │  Dictionary  │  │  - registerAction()  │   │    │
│  │  │  {String:    │  │  - getAllActions()   │   │    │
│  │  │   ActionMeta}│  │  - executeAction()   │   │    │
│  │  └──────────────┘  └──────────────────────┘   │    │
│  └────────────────────────────────────────────────┘    │
│                                                         │
│  Latest Block: 288,118,871                              │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Structure

```
cadence/
├── contracts/
│   ├── AIONVault.cdc           # Main vault (472 LOC)
│   └── ActionRegistry.cdc      # Actions (306 LOC)
├── scripts/
│   ├── get_vault_stats.cdc     # Query vault stats
│   ├── get_actions.cdc         # Query actions
│   ├── get_balance.cdc         # Query user balance
│   └── get_action_stats.cdc    # Query action stats
├── transactions/
│   ├── deposit.cdc             # Deposit transaction
│   ├── withdraw.cdc            # Withdraw transaction
│   ├── register_action.cdc     # Register action
│   ├── rebalance.cdc           # Rebalance vault
│   └── set_ai_agent.cdc        # Set AI agent
└── README.md                    # This file
```

---

## 🔑 Core Contracts

### AIONVault.cdc

```cadence
pub contract AIONVault {
    // Vault statistics
    pub var totalAssets: UFix64
    pub var totalShares: UFix64
    
    // User balances
    access(self) var balances: {Address: UFix64}
    
    // Deposit FLOW and receive shares
    pub fun deposit(from: Address, amount: UFix64): UFix64 {
        // Calculate shares
        let shares = self.calculateShares(amount)
        
        // Update balances
        self.balances[from] = (self.balances[from] ?? 0.0) + shares
        self.totalShares = self.totalShares + shares
        self.totalAssets = self.totalAssets + amount
        
        // Emit event
        emit Deposit(user: from, amount: amount, shares: shares)
        
        return shares
    }
    
    // Get vault statistics
    pub fun getVaultStats(): {String: UFix64} {
        return {
            "totalAssets": self.totalAssets,
            "totalShares": self.totalShares,
            "pricePerShare": self.getPricePerShare()
        }
    }
}
```

### ActionRegistry.cdc

```cadence
pub contract ActionRegistry {
    // Action metadata
    pub struct ActionMeta {
        pub let id: String
        pub let description: String
        pub let riskLevel: UInt8
        pub let category: String
        pub var executionCount: UInt64
    }
    
    // Registered actions
    access(self) var actions: {String: ActionMeta}
    
    // Register new action
    pub fun registerAction(id: String, description: String, riskLevel: UInt8) {
        let action = ActionMeta(
            id: id,
            description: description,
            riskLevel: riskLevel,
            category: self.categorizeAction(id),
            executionCount: 0
        )
        
        self.actions[id] = action
        emit ActionRegistered(id: id, description: description)
    }
}
```

---

## 🧪 Testing & Verification

### Query Live Contracts

```bash
# Get current vault stats
flow scripts execute scripts/get_vault_stats.cdc --network testnet

# Expected output:
# Result: {"totalAssets": 10.0, "totalShares": 10.0, "pricePerShare": 1000000.0}

# Get all registered actions
flow scripts execute scripts/get_actions.cdc --network testnet

# Expected output:
# Result: {
#   "auto_optimize": {...},
#   "harvest_rewards": {...}
# }
```

### Execute Test Transaction

```bash
# Test deposit
flow transactions send transactions/deposit.cdc 0.1 \
  --network testnet \
  --signer testnet-account

# Check balance after deposit
flow scripts execute scripts/get_balance.cdc 0xc7a34c80e6f3235b --network testnet
```

---

## 🔗 Integration with AION

### How AION Uses Flow Contracts

```
┌──────────────────────────────────────────────────────────┐
│                  AION Application                        │
│                                                          │
│  Frontend (React)                                        │
│  └── FlowContext.tsx                                     │
│      └── @onflow/fcl                                     │
│          │                                               │
│          ├── Query: getVaultStats()                      │
│          ├── Query: getAllActions()                      │
│          ├── Mutation: deposit(amount)                   │
│          └── Mutation: withdraw(shares)                  │
│                                                          │
│  Backend (MCP Agent)                                     │
│  └── FlowService.js                                      │
│      └── @onflow/sdk                                     │
│          │                                               │
│          ├── Monitor: Block events                       │
│          ├── Execute: Automated actions                  │
│          └── Analyze: Vault performance                  │
│                                                          │
└────────────┬─────────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────────┐
│            Flow Blockchain Testnet                       │
│                                                          │
│  AIONVault.cdc (0xc7a34c80e6f3235b)                     │
│  ActionRegistry.cdc (0xc7a34c80e6f3235b)                │
│                                                          │
│  Current Stats:                                          │
│  - Total Assets: 10 FLOW                                 │
│  - Total Shares: 10                                      │
│  - Registered Actions: 2                                 │
│  - Transactions: 3 sealed                                │
└──────────────────────────────────────────────────────────┘
```

---

## 📊 Deployment Evidence

### Live on Flow Testnet

**Contract Account:** `0xc7a34c80e6f3235b`

**Verification:**
- Explorer: https://testnet.flowdiver.io/account/0xc7a34c80e6f3235b
- API: https://rest-testnet.onflow.org
- Latest Block: 288,118,871+

**Deployed Transactions:**
1. **Deposit Transaction:** Block 287,951,714 ([View](https://testnet.flowscan.io/tx/57b1631173d2be3915fa46d25df4a82fb9f266f934f0dec6bc5401da083c109b))
2. **Action Registration #1:** Block 287,954,902
3. **Action Registration #2:** Block 287,954,963

---

## 🛠️ Development

### Run Flow Emulator (Local Testing)

```bash
# Start emulator
flow emulator start

# Deploy to emulator (in another terminal)
flow project deploy --network=emulator

# Test locally
flow scripts execute scripts/get_vault_stats.cdc --network emulator
flow transactions send transactions/deposit.cdc 5.0 --network emulator
```

### Configuration (flow.json)

```json
{
  "networks": {
    "testnet": "access.devnet.nodes.onflow.org:9000"
  },
  "accounts": {
    "testnet-account": {
      "address": "0xc7a34c80e6f3235b"
    }
  },
  "deployments": {
    "testnet": {
      "testnet-account": ["ActionRegistry", "AIONVault"]
    }
  }
}
```

---

## 📖 API Reference

### AIONVault Functions

#### deposit
```cadence
pub fun deposit(from: Address, amount: UFix64): UFix64
```
Deposit FLOW tokens and receive shares.

#### withdraw
```cadence
pub fun withdraw(from: Address, shares: UFix64): UFix64
```
Burn shares and receive FLOW + yield.

#### getVaultStats
```cadence
pub fun getVaultStats(): {String: UFix64}
```
Returns total assets, shares, and price per share.

#### balanceOf
```cadence
pub fun balanceOf(user: Address): UFix64
```
Returns user's share balance.

### ActionRegistry Functions

#### registerAction
```cadence
pub fun registerAction(id: String, description: String, riskLevel: UInt8)
```
Register a new automated action.

#### getAllActions
```cadence
pub fun getAllActions(): {String: ActionMeta}
```
Returns all registered actions.

---

## 🔗 Integration with Backend

See [../mcp_agent/README.md](../mcp_agent/README.md) for backend integration details.

**FlowService.js** connects to these contracts and provides:
- Real-time vault stats
- Action execution monitoring
- Transaction submission
- Event listening

---

## 📄 License

MIT License - see [../LICENSE](../LICENSE)

---

<div align="center">

**Part of AION AI Agent**

[Main Repo](../) • [MCP Agent](../mcp_agent/) • [Solidity Contracts](../contracts/)

**Built with Flow Cadence**

</div>
