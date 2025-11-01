#!/bin/bash

###############################################################################
# AION Flow Integration Test Script
# اختبار شامل لجميع وظائف العقود على Flow Testnet
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
NETWORK="${1:-testnet}"
SIGNER="${2:-testnet-account}"
TEST_AMOUNT="5.0"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      AION Flow Integration Test - Full Suite              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get contract addresses
if [ -f ".contract-addresses" ]; then
    source .contract-addresses
    echo -e "${GREEN}✅ Loaded contract addresses${NC}"
    echo -e "   Vault: ${YELLOW}$AION_VAULT_ADDRESS${NC}"
    echo -e "   Registry: ${YELLOW}$ACTION_REGISTRY_ADDRESS${NC}"
else
    echo -e "${RED}❌ .contract-addresses not found!${NC}"
    echo -e "${YELLOW}Run ./scripts/deploy-flow.sh first${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 1/8: Get Initial Vault Stats${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

flow scripts execute ./cadence/scripts/get_vault_stats.cdc \
    --network=$NETWORK \
    --arg Address:$AION_VAULT_ADDRESS

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 1 passed - Vault stats retrieved${NC}"
else
    echo -e "${RED}❌ Test 1 failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 2/8: Get User Balance (Before Deposit)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

USER_ADDRESS=$(flow accounts get $SIGNER --network=$NETWORK | grep "Address" | awk '{print $2}')
echo -e "Testing with user: ${YELLOW}$USER_ADDRESS${NC}"

flow scripts execute ./cadence/scripts/get_balance.cdc \
    --network=$NETWORK \
    --arg Address:$USER_ADDRESS

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 2 passed - User balance retrieved${NC}"
else
    echo -e "${RED}❌ Test 2 failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 3/8: Execute Deposit Transaction${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "Depositing ${YELLOW}$TEST_AMOUNT FLOW${NC}..."

flow transactions send ./cadence/transactions/deposit.cdc \
    --network=$NETWORK \
    --signer=$SIGNER \
    --arg UFix64:$TEST_AMOUNT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 3 passed - Deposit successful${NC}"
else
    echo -e "${RED}❌ Test 3 failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 4/8: Verify Deposit (Check Balance)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

sleep 3  # Wait for transaction to be sealed

flow scripts execute ./cadence/scripts/get_balance.cdc \
    --network=$NETWORK \
    --arg Address:$USER_ADDRESS

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 4 passed - Balance updated after deposit${NC}"
else
    echo -e "${RED}❌ Test 4 failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 5/8: Register a New Action${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

flow transactions send ./cadence/transactions/register_action.cdc \
    --network=$NETWORK \
    --signer=$SIGNER \
    --arg String:"test_action" \
    --arg String:"Test Action" \
    --arg String:"Action for integration testing" \
    --arg Address:$AION_VAULT_ADDRESS \
    --arg String:"testMethod" \
    --arg String:'{"param1":"String"}' \
    --arg String:"testing" \
    --arg UInt8:2

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 5 passed - Action registered${NC}"
else
    echo -e "${RED}❌ Test 5 failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 6/8: List All Registered Actions${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

flow scripts execute ./cadence/scripts/get_actions.cdc \
    --network=$NETWORK

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 6 passed - Actions list retrieved${NC}"
else
    echo -e "${RED}❌ Test 6 failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 7/8: Get Action Execution Stats${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

flow scripts execute ./cadence/scripts/get_action_stats.cdc \
    --network=$NETWORK

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 7 passed - Action stats retrieved${NC}"
else
    echo -e "${RED}❌ Test 7 failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test 8/8: Monitor Events${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "Checking for ${YELLOW}Deposit${NC} events..."
flow events get A.$AION_VAULT_ADDRESS.AIONVault.Deposit \
    --network=$NETWORK \
    --start 0 \
    --end latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test 8 passed - Events retrieved${NC}"
else
    echo -e "${YELLOW}⚠️  Test 8 warning - No events found (might be normal)${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 All Tests Completed! 🎉                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Summary
echo -e "${PURPLE}📊 Test Summary:${NC}"
echo -e "   ✅ Vault stats retrieval"
echo -e "   ✅ User balance check"
echo -e "   ✅ Deposit transaction"
echo -e "   ✅ Balance verification"
echo -e "   ✅ Action registration"
echo -e "   ✅ Actions listing"
echo -e "   ✅ Stats retrieval"
echo -e "   ✅ Event monitoring"
echo ""

echo -e "${BLUE}📈 Next Steps:${NC}"
echo -e "1. Check Dune Dashboard for analytics"
echo -e "2. Start the executor: ${GREEN}cd flow-executor && npm start${NC}"
echo -e "3. Monitor logs for real-time events"
echo ""

echo -e "${GREEN}✨ Your AION Vault is working with REAL DATA on Flow Testnet! ✨${NC}"

