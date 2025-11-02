# ⚡ Flow Executor Service

**Node.js service for monitoring and executing Flow blockchain actions**

---

## 🎯 Overview

The **Flow Executor** monitors Flow blockchain events and automatically executes registered actions from the ActionRegistry contract.

**Status:** ✅ Integrated with MCP Agent

---

## 🚀 Quick Start

```bash
cd flow-executor

# Install dependencies
npm install

# Configure .env
cat > .env << EOF
FLOW_NETWORK=testnet
FLOW_ACCESS_NODE=https://rest-testnet.onflow.org
VAULT_ADDRESS=0xc7a34c80e6f3235b
EOF

# Run executor
npm start
```

---

## 🏗️ Architecture

```
Flow Executor monitors ActionRegistry events
→ Detects new registered actions
→ Executes actions based on triggers
→ Reports results back to blockchain
```

**Integration:**
- Monitors: `ActionRegistry.cdc` events
- Executes: Automated DeFi operations
- Reports: Transaction results

---

## 📖 Documentation

See [../mcp_agent/README.md](../mcp_agent/README.md) for full integration details.

---

<div align="center">

[Back to Main](../)

</div>
