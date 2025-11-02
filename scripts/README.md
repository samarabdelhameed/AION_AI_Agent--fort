# 🛠️ AION Automation Scripts

**Helper scripts for running, testing, and managing the AION application**

---

## 🚀 Quick Reference

```bash
# Start everything
npm run dev              # or ./scripts/start-dev.sh

# Stop everything
npm run stop             # or ./scripts/stop-dev.sh

# Check status
npm run status           # or ./scripts/health-check.sh

# Test Flow integration
./scripts/test-flow-complete.sh

# Verify Flow setup
./scripts/verify-flow-setup.sh
```

---

## 📜 Available Scripts

### start-dev.sh

**Start all AION services (MCP Agent + Frontend)**

```bash
./scripts/start-dev.sh

# Starts:
# ✅ MCP Agent on port 3001
# ✅ Frontend on port 5173
# ✅ Flow Cadence connection
# ✅ Flow EVM connection
```

### stop-dev.sh

**Stop all running services**

```bash
./scripts/stop-dev.sh

# Stops:
# • MCP Agent
# • Frontend
# • Cleans up PID files
```

### health-check.sh

**Check status of all services**

```bash
./scripts/health-check.sh

# Checks:
# ✅ Services running
# ✅ Dependencies installed
# ✅ Environment configured
# ✅ Network connectivity
```

### test-flow-complete.sh

**Comprehensive Flow integration testing**

```bash
./scripts/test-flow-complete.sh

# Tests (18 checks):
# ✅ Services running
# ✅ Flow in UI components
# ✅ Dynamic currency system
# ✅ Network configs
# ✅ Contract deployment
# ✅ API connectivity

# Result: 100% pass rate ✅
```

### verify-flow-setup.sh

**Verify Flow integration setup**

```bash
./scripts/verify-flow-setup.sh

# Verifies:
# ✅ Flow Testnet accessible
# ✅ Flow EVM accessible
# ✅ Contracts deployed
# ✅ Services healthy
```

### deploy-flow.sh

**Deploy Flow contracts to testnet**

```bash
./scripts/deploy-flow.sh

# Deploys:
# ✅ ActionRegistry.cdc
# ✅ AIONVault.cdc
```

---

## 🔧 Usage Examples

### Development Workflow

```bash
# 1. Start development
./scripts/start-dev.sh

# 2. Check everything is running
./scripts/health-check.sh

# 3. Test Flow integration
./scripts/test-flow-complete.sh

# 4. View logs
tail -f logs/mcp_agent.log
tail -f logs/frontend.log

# 5. Stop when done
./scripts/stop-dev.sh
```

### Testing Workflow

```bash
# Test Flow integration
./scripts/test-flow-complete.sh

# Verify setup
./scripts/verify-flow-setup.sh

# Run contract tests
cd contracts && forge test

# Run MCP tests
cd mcp_agent && npm test
```

---

## 📊 Script Status

| Script | Purpose | Status |
|--------|---------|--------|
| `start-dev.sh` | Start all services | ✅ Working |
| `stop-dev.sh` | Stop all services | ✅ Working |
| `health-check.sh` | Check service health | ✅ Working |
| `test-flow-complete.sh` | Test Flow integration | ✅ 18/18 passing |
| `verify-flow-setup.sh` | Verify Flow setup | ✅ 8/8 passing |
| `deploy-flow.sh` | Deploy Flow contracts | ✅ Working |

---

## 🔗 Related Documentation

- **Main README:** [../README.md](../README.md)
- **MCP Agent:** [../mcp_agent/README.md](../mcp_agent/README.md)
- **Flow Contracts:** [../cadence/README.md](../cadence/README.md)

---

<div align="center">

**Automation scripts for AION AI Agent**

[Back to Main](../)

</div>
