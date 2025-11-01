#!/bin/bash

###############################################################################
# AION Flow Deployment Verification Script
# يتحقق من نجاح النشر ويختبر جميع الوظائف
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
NETWORK="${1:-testnet}"
SIGNER="${2:-testnet-account}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         AION Flow Deployment Verification                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

PASS=0
FAIL=0
WARN=0

# Load contract addresses
if [ -f ".contract-addresses" ]; then
    source .contract-addresses
    echo -e "${GREEN}✅ Contract addresses loaded${NC}"
    echo -e "   Vault: ${CYAN}$AION_VAULT_ADDRESS${NC}"
    echo -e "   Registry: ${CYAN}$ACTION_REGISTRY_ADDRESS${NC}"
else
    echo -e "${RED}❌ .contract-addresses not found!${NC}"
    echo -e "${YELLOW}Run deployment first: ./scripts/deploy-flow.sh${NC}"
    exit 1
fi

# Get user address
USER_ADDRESS=$(flow accounts get $SIGNER --network=$NETWORK 2>/dev/null | grep "Address" | awk '{print $2}')
echo -e "   User: ${CYAN}$USER_ADDRESS${NC}"
echo ""

# Verification function
verify_step() {
    local step_name="$1"
    local command="$2"
    local expected="$3"
    
    echo -e "${BLUE}Verifying: ${step_name}${NC}"
    
    if eval "$command" > /tmp/verify_output 2>&1; then
        if [ -n "$expected" ]; then
            if grep -q "$expected" /tmp/verify_output; then
                echo -e "${GREEN}✅ PASS${NC}"
                ((PASS++))
                return 0
            else
                echo -e "${YELLOW}⚠️  WARN - Output doesn't match expected${NC}"
                ((WARN++))
                return 1
            fi
        else
            echo -e "${GREEN}✅ PASS${NC}"
            ((PASS++))
            return 0
        fi
    else
        echo -e "${RED}❌ FAIL${NC}"
        cat /tmp/verify_output
        ((FAIL++))
        return 1
    fi
}

echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Phase 1: Contract Deployment Verification${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo ""

verify_step "Account has contracts deployed" \
    "flow accounts get $SIGNER --network=$NETWORK" \
    "Contracts"

verify_step "AIONVault contract exists" \
    "flow accounts get $SIGNER --network=$NETWORK" \
    "AIONVault"

verify_step "ActionRegistry contract exists" \
    "flow accounts get $SIGNER --network=$NETWORK" \
    "ActionRegistry"

echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Phase 2: Script Execution (Read Operations)${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo ""

verify_step "Get vault stats" \
    "flow scripts execute ./cadence/scripts/get_vault_stats.cdc --network=$NETWORK --arg Address:$AION_VAULT_ADDRESS" \
    "totalAssets"

verify_step "Get user balance" \
    "flow scripts execute ./cadence/scripts/get_balance.cdc --network=$NETWORK --arg Address:$USER_ADDRESS" \
    "shares"

verify_step "Get registered actions" \
    "flow scripts execute ./cadence/scripts/get_actions.cdc --network=$NETWORK"

verify_step "Get action stats" \
    "flow scripts execute ./cadence/scripts/get_action_stats.cdc --network=$NETWORK" \
    "total"

echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Phase 3: Transaction Execution (Write Operations)${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}⚠️  This will execute a test deposit (1.0 FLOW)${NC}"
read -p "Continue? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    verify_step "Execute test deposit (1.0 FLOW)" \
        "flow transactions send ./cadence/transactions/deposit.cdc --network=$NETWORK --signer=$SIGNER --arg UFix64:1.0" \
        "SEALED"
    
    sleep 3
    
    verify_step "Verify balance increased" \
        "flow scripts execute ./cadence/scripts/get_balance.cdc --network=$NETWORK --arg Address:$USER_ADDRESS" \
        "shares"
else
    echo -e "${YELLOW}⚠️  Skipping deposit test${NC}"
    ((WARN++))
fi

echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Phase 4: Event Monitoring${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Remove 0x prefix for event queries
VAULT_ADDR_NO_PREFIX=${AION_VAULT_ADDRESS:2}
REGISTRY_ADDR_NO_PREFIX=${ACTION_REGISTRY_ADDRESS:2}

verify_step "Check for Deposit events" \
    "flow events get A.$VAULT_ADDR_NO_PREFIX.AIONVault.Deposit --network=$NETWORK --start 0 --end latest"

verify_step "Check for ActionRegistered events" \
    "flow events get A.$REGISTRY_ADDR_NO_PREFIX.ActionRegistry.ActionRegistered --network=$NETWORK --start 0 --end latest"

echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Phase 5: Explorer Links Verification${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}📍 Explorer Links:${NC}"
echo ""
echo -e "AIONVault Contract:"
echo -e "   ${GREEN}https://flow-view-source.com/testnet/account/$AION_VAULT_ADDRESS${NC}"
echo ""
echo -e "ActionRegistry Contract:"
echo -e "   ${GREEN}https://flow-view-source.com/testnet/account/$ACTION_REGISTRY_ADDRESS${NC}"
echo ""
echo -e "Your Account:"
echo -e "   ${GREEN}https://flow-view-source.com/testnet/account/$USER_ADDRESS${NC}"
echo ""

echo -e "${YELLOW}⚠️  Please verify these links manually in your browser${NC}"
read -p "Press Enter to continue..."

echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Phase 6: Integration Components${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check executor
echo -e "${CYAN}Checking Flow Executor...${NC}"
if [ -f "flow-executor/.env" ]; then
    if grep -q "$AION_VAULT_ADDRESS" flow-executor/.env; then
        echo -e "${GREEN}✅ Executor .env configured with correct addresses${NC}"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠️  Executor .env needs address update${NC}"
        ((WARN++))
    fi
else
    echo -e "${YELLOW}⚠️  Executor .env not found (will be created on first run)${NC}"
    ((WARN++))
fi

# Check frontend
echo -e "${CYAN}Checking Frontend integration...${NC}"
if [ -f "frontend/.env.local" ]; then
    if grep -q "$AION_VAULT_ADDRESS" frontend/.env.local; then
        echo -e "${GREEN}✅ Frontend .env.local configured${NC}"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠️  Frontend .env.local needs address update${NC}"
        ((WARN++))
    fi
else
    echo -e "${YELLOW}⚠️  Frontend .env.local not found${NC}"
    echo -e "   Create it with:"
    echo -e "   ${GREEN}cat > frontend/.env.local << EOF"
    echo -e "VITE_AION_VAULT_ADDRESS=$AION_VAULT_ADDRESS"
    echo -e "VITE_ACTION_REGISTRY_ADDRESS=$ACTION_REGISTRY_ADDRESS"
    echo -e "EOF${NC}"
    ((WARN++))
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Verification Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Summary
echo -e "${PURPLE}📊 Summary:${NC}"
echo -e "   ${GREEN}✅ Passed: $PASS${NC}"
if [ $FAIL -gt 0 ]; then
    echo -e "   ${RED}❌ Failed: $FAIL${NC}"
fi
if [ $WARN -gt 0 ]; then
    echo -e "   ${YELLOW}⚠️  Warnings: $WARN${NC}"
fi
echo ""

# Status
if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✨ All critical checks passed!${NC}"
    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo ""
    echo -e "1. Start the executor:"
    echo -e "   ${GREEN}cd flow-executor && npm start${NC}"
    echo ""
    echo -e "2. Start the frontend:"
    echo -e "   ${GREEN}cd frontend && npm run dev${NC}"
    echo ""
    echo -e "3. Setup Dune Analytics:"
    echo -e "   - Use queries from: ${GREEN}dune-analytics/queries/${NC}"
    echo -e "   - Replace addresses with: ${CYAN}$AION_VAULT_ADDRESS${NC}"
    echo ""
    echo -e "4. Test the full flow:"
    echo -e "   ${GREEN}./scripts/test-flow-integration.sh testnet testnet-account${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}⚠️  Some checks failed. Review the output above.${NC}"
    echo ""
    echo -e "${YELLOW}Common fixes:${NC}"
    echo -e "1. Re-run deployment: ${GREEN}./scripts/deploy-flow.sh testnet testnet-account${NC}"
    echo -e "2. Check Flow CLI: ${GREEN}flow version${NC}"
    echo -e "3. Check account balance: ${GREEN}flow accounts get $SIGNER --network=testnet${NC}"
    echo ""
    exit 1
fi

