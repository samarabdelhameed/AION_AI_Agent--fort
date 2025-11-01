# 🚀 Deploy to BOTH Flow Networks - Step by Step

## Overview: Two Separate Deployments

1. **Flow Cadence** → For `.cdc` contracts (ActionRegistry, AIONVault)
2. **Flow EVM** → For `.sol` contracts (AIONVault.sol)

---

## 🔵 DEPLOYMENT 1: Flow Cadence (Testnet)

### Step 1: Get Flow Cadence Account

**Visit:** https://testnet-faucet.onflow.org/fund-account

**Paste this Public Key:**
```
b21419930aeaef0885b18121fe7496dba89719ce16bfdf2c3dbd0478d740830709591d4bb28f57b7b1846a0683a29c599a9b7389e0cbfa97f310779ad0794af3
```

**You'll get:** Flow address (16 chars) like `0x123abc456def7890`

---

### Step 2: Update flow.json

**Copy the address you got, then run:**
```bash
cd "/Users/s/ming-template/base hack/AION_AI_Agent -fort"

# Replace YOUR_FLOW_ADDRESS with what you got
FLOW_ADDR="0xYOUR_FLOW_ADDRESS"

# Update flow.json
cat > flow.json << EOF
{
  "contracts": {
    "ActionRegistry": "./cadence/contracts/ActionRegistry.cdc",
    "AIONVault": "./cadence/contracts/AIONVault.cdc"
  },
  "networks": {
    "emulator": "127.0.0.1:3569",
    "testnet": "access.devnet.nodes.onflow.org:9000"
  },
  "accounts": {
    "emulator-account": {
      "address": "f8d6e0586b0a20c7",
      "key": {
        "type": "hex",
        "index": 0,
        "signatureAlgorithm": "ECDSA_P256",
        "hashAlgorithm": "SHA3_256",
        "privateKey": "dd72967fd2bd75234ae9037dd4694c1f00baad63a10c35172bf65fbb8ad74b47"
      }
    },
    "testnet-account": {
      "address": "$FLOW_ADDR",
      "key": {
        "type": "hex",
        "index": 0,
        "signatureAlgorithm": "ECDSA_P256",
        "hashAlgorithm": "SHA3_256",
        "privateKey": "d39a017b4559ad472cd1803c3c5af9bba588d3e773c24c5c6a0d30fc69794342"
      }
    }
  },
  "deployments": {
    "emulator": {
      "emulator-account": [
        "ActionRegistry",
        "AIONVault"
      ]
    },
    "testnet": {
      "testnet-account": [
        "ActionRegistry",
        "AIONVault"
      ]
    }
  }
}
EOF
```

---

### Step 3: Deploy Cadence Contracts

```bash
cd "/Users/s/ming-template/base hack/AION_AI_Agent -fort"

# Deploy to testnet
flow project deploy --network testnet --update

# Verify deployment
flow accounts get $FLOW_ADDR --network testnet
```

**Expected output:**
```
✅ ActionRegistry -> 0xYOUR_ADDRESS
✅ AIONVault -> 0xYOUR_ADDRESS
🎉 All contracts deployed successfully
```

---

### Step 4: Test Cadence Deployment

```bash
# Test deposit
flow transactions send cadence/transactions/deposit.cdc 5.0 \
  --signer testnet-account \
  --network testnet

# Check vault stats
flow scripts execute cadence/scripts/get_vault_stats.cdc \
  --network testnet

# View events
flow events get A.$FLOW_ADDR.AIONVault.Deposit \
  --network testnet \
  --last 5
```

---

## 🟡 DEPLOYMENT 2: Flow EVM (Testnet)

### Step 1: Get Flow EVM Testnet Tokens

**Option A: Using deployer address**
```
Address: 0x53D92C6D56075D80e44c4f6b047eB411bAA15f02
Visit: https://testnet-faucet.onflow.org/
Request: 1 FLOW
```

**Option B: Using your MetaMask**
```
Address: 0xdafee25f98ff62504c1086eacbb406190f3110d5
Already in MetaMask - just request from faucet
```

---

### Step 2: Deploy Solidity Contract

```bash
cd "/Users/s/ming-template/base hack/AION_AI_Agent -fort/contracts"

# Deploy to Flow EVM
forge script script/DeployAndVerify.s.sol \
  --rpc-url https://testnet.evm.nodes.onflow.org \
  --broadcast \
  --legacy \
  -vvvv
```

**Expected output:**
```
AIONVault deployed at: 0xabc123...
Owner: 0x53D92C...
✅ Deployment successful
```

---

### Step 3: Verify Flow EVM Deployment

```bash
# Get deployed address from output
VAULT_ADDR="0xYOUR_DEPLOYED_ADDRESS"

# Check contract
cast call $VAULT_ADDR "owner()(address)" \
  --rpc-url https://testnet.evm.nodes.onflow.org

cast call $VAULT_ADDR "totalAssets()(uint256)" \
  --rpc-url https://testnet.evm.nodes.onflow.org
```

**Explorer:** https://evm-testnet.flowscan.io/address/$VAULT_ADDR

---

### Step 4: Test Flow EVM Deployment

```bash
# Deposit
cast send $VAULT_ADDR "deposit()" \
  --value 0.01ether \
  --private-key 0xd39a017b4559ad472cd1803c3c5af9bba588d3e773c24c5c6a0d30fc69794342 \
  --rpc-url https://testnet.evm.nodes.onflow.org \
  --legacy

# Check balance
cast call $VAULT_ADDR "balanceOf(address)(uint256)" \
  0x53D92C6D56075D80e44c4f6b047eB411bAA15f02 \
  --rpc-url https://testnet.evm.nodes.onflow.org
```

---

## ✅ After Both Deployments

### Update README:
```markdown
## Deployments

### Flow Cadence (Testnet)
- ActionRegistry: 0xYOUR_FLOW_ADDR
- AIONVault: 0xYOUR_FLOW_ADDR
- Network: Flow Testnet

### Flow EVM (Testnet)
- AIONVault: 0xYOUR_EVM_ADDR
- Network: Flow EVM Testnet
- Explorer: https://evm-testnet.flowscan.io
```

---

## 🎯 Quick Summary:

**What you need to do:**

1. **Flow Cadence:**
   - Visit faucet with PUBLIC KEY
   - Get Flow address (16 chars)
   - Tell me the address
   - I deploy automatically

2. **Flow EVM:**
   - Get testnet tokens for your address
   - I deploy automatically
   - Check on explorer

**Estimated time:** 10 minutes total

---

## 💡 EASIEST PATH:

Do Flow Cadence first (already have keys), then Flow EVM.

**Ready? Get the Flow Cadence address and tell me!** 🚀

