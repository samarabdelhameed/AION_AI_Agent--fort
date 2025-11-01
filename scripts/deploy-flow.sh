#!/bin/bash

# ===================================
# AION Flow Deployment Script
# ===================================
# Deploys contracts to Flow blockchain
# Usage: ./scripts/deploy-flow.sh [network] [account]
#   network: emulator|testnet|mainnet
#   account: account name from flow.json

set -e

NETWORK=${1:-emulator}
ACCOUNT=${2:-emulator-account}

echo "🚀 AION Flow Deployment Script"
echo "================================"
echo "Network: $NETWORK"
echo "Account: $ACCOUNT"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flow CLI is installed
if ! command -v flow &> /dev/null; then
    echo -e "${RED}❌ Flow CLI not found${NC}"
    echo "Install it with:"
    echo "  sh -ci \"\$(curl -fsSL https://raw.githubusercontent.com/onflow/flow-cli/master/install.sh)\""
    exit 1
fi

echo -e "${GREEN}✅ Flow CLI installed: $(flow version | head -1)${NC}"
echo ""

# Start emulator if network is emulator
if [ "$NETWORK" = "emulator" ]; then
    echo -e "${BLUE}🔧 Checking for running emulator...${NC}"
    
    # Check if emulator is already running
    if ! curl -s http://localhost:8888 > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Emulator not running. Start it manually:${NC}"
        echo "  flow emulator"
        echo ""
        echo "Then run this script again."
        exit 1
    fi
    
    echo -e "${GREEN}✅ Emulator is running${NC}"
    echo ""
fi

# Deploy ActionRegistry
echo -e "${BLUE}📝 Deploying ActionRegistry...${NC}"
if [ "$NETWORK" = "emulator" ]; then
    flow accounts add-contract ActionRegistry \
        ./cadence/contracts/ActionRegistry.cdc \
        --network=$NETWORK \
        --signer=$ACCOUNT
else
    flow accounts add-contract ActionRegistry \
        ./cadence/contracts/ActionRegistry.cdc \
        --network=$NETWORK \
        --signer=$ACCOUNT
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ActionRegistry deployed${NC}"
else
    echo -e "${RED}❌ Failed to deploy ActionRegistry${NC}"
    exit 1
fi

echo ""

# Deploy AIONVault
echo -e "${BLUE}📝 Deploying AIONVault...${NC}"
if [ "$NETWORK" = "emulator" ]; then
    flow accounts add-contract AIONVault \
        ./cadence/contracts/AIONVault.cdc \
        --network=$NETWORK \
        --signer=$ACCOUNT
else
    flow accounts add-contract AIONVault \
        ./cadence/contracts/AIONVault.cdc \
        --network=$NETWORK \
        --signer=$ACCOUNT
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ AIONVault deployed${NC}"
else
    echo -e "${RED}❌ Failed to deploy AIONVault${NC}"
    exit 1
fi

echo ""

# Get account info
echo -e "${BLUE}📊 Retrieving deployed contract addresses...${NC}"

if [ "$NETWORK" = "emulator" ]; then
    ACCOUNT_ADDRESS="0xf8d6e0586b0a20c7"
else
    ACCOUNT_ADDRESS=$(flow accounts get $ACCOUNT --network=$NETWORK | grep "Address" | awk '{print $2}')
fi

echo -e "${GREEN}✅ Contract Address: $ACCOUNT_ADDRESS${NC}"
echo ""

# Save addresses to file
ADDRESSES_FILE=".contract-addresses"
echo "# Deployed Contract Addresses" > $ADDRESSES_FILE
echo "NETWORK=$NETWORK" >> $ADDRESSES_FILE
echo "AION_VAULT_ADDRESS=$ACCOUNT_ADDRESS" >> $ADDRESSES_FILE
echo "ACTION_REGISTRY_ADDRESS=$ACCOUNT_ADDRESS" >> $ADDRESSES_FILE
echo "DEPLOYED_AT=$(date)" >> $ADDRESSES_FILE

echo -e "${GREEN}✅ Addresses saved to $ADDRESSES_FILE${NC}"
echo ""

# Register initial actions
echo -e "${BLUE}📝 Registering initial actions...${NC}"

# Register rebalance action
flow transactions send ./cadence/transactions/register_action.cdc \
    --arg String:"rebalance_strategy" \
    --arg String:"Rebalance Strategy" \
    --arg String:"Move funds between DeFi strategies" \
    --arg Address:$ACCOUNT_ADDRESS \
    --arg String:"rebalance" \
    --arg String:'{"fromStrategy":"String","toStrategy":"String","amount":"UFix64","reason":"String"}' \
    --arg String:"rebalance" \
    --arg UInt8:5 \
    --network=$NETWORK \
    --signer=$ACCOUNT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Registered: rebalance_strategy${NC}"
else
    echo -e "${YELLOW}⚠️  Failed to register rebalance_strategy (might already exist)${NC}"
fi

# Register optimize action
flow transactions send ./cadence/transactions/register_action.cdc \
    --arg String:"optimize_yield" \
    --arg String:"Optimize Yield" \
    --arg String:"AI-powered yield optimization" \
    --arg Address:$ACCOUNT_ADDRESS \
    --arg String:"rebalance" \
    --arg String:'{"targetAPY":"UFix64","maxRisk":"UInt8"}' \
    --arg String:"optimize" \
    --arg UInt8:3 \
    --network=$NETWORK \
    --signer=$ACCOUNT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Registered: optimize_yield${NC}"
else
    echo -e "${YELLOW}⚠️  Failed to register optimize_yield (might already exist)${NC}"
fi

echo ""

# Create executor .env if it doesn't exist
EXECUTOR_ENV="flow-executor/.env"
if [ ! -f "$EXECUTOR_ENV" ]; then
    echo -e "${BLUE}📝 Creating executor .env file...${NC}"
    
    cat > $EXECUTOR_ENV << EOF
# AION Flow Executor Configuration
# Generated on $(date)

# Flow Network
FLOW_NETWORK=$NETWORK
FLOW_ACCESS_NODE=$([ "$NETWORK" = "emulator" ] && echo "http://localhost:8888" || echo "https://rest-$NETWORK.onflow.org")
FLOW_WALLET=https://fcl-discovery.onflow.org/$NETWORK/authn

# Contract Addresses
AION_VAULT_ADDRESS=$ACCOUNT_ADDRESS
ACTION_REGISTRY_ADDRESS=$ACCOUNT_ADDRESS

# Executor Security (UPDATE THESE!)
EXECUTOR_PRIVATE_KEY=your_private_key_here
EXECUTOR_ADDRESS=$ACCOUNT_ADDRESS

# Auto-Execution Settings
AUTO_EXECUTE_RECOMMENDATIONS=false
MIN_CONFIDENCE=80
REBALANCE_PERCENTAGE=100

# Scheduled Transactions
USE_SCHEDULED_TX=true
EXECUTION_DELAY=300

# Event Monitoring
POLL_INTERVAL=5000
BLOCK_LOOKBACK=100
START_FROM_BLOCK=latest

# Logging
LOG_LEVEL=info
LOG_TO_FILE=true
LOG_DIR=./logs
EOF
    
    echo -e "${GREEN}✅ Created $EXECUTOR_ENV${NC}"
    echo -e "${YELLOW}⚠️  Remember to update EXECUTOR_PRIVATE_KEY in $EXECUTOR_ENV${NC}"
else
    echo -e "${GREEN}✅ Executor .env already exists${NC}"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Test the deployment:"
echo "   flow scripts execute ./cadence/scripts/get_vault_stats.cdc --network=$NETWORK"
echo ""
echo "2. Try a deposit:"
echo "   flow transactions send ./cadence/transactions/deposit.cdc --arg UFix64:1.5 --network=$NETWORK --signer=$ACCOUNT"
echo ""
echo "3. Start the executor:"
echo "   cd flow-executor"
echo "   npm install"
echo "   npm start"
echo ""
echo "4. View Dune Analytics setup:"
echo "   cat dune-analytics/README.md"
echo ""
echo "Contract Addresses:"
echo "  Vault:    $ACCOUNT_ADDRESS"
echo "  Registry: $ACCOUNT_ADDRESS"
echo ""

# If testnet, show explorer link
if [ "$NETWORK" = "testnet" ]; then
    echo "🔗 View on Flow Explorer:"
    echo "   https://flow-view-source.com/testnet/account/$ACCOUNT_ADDRESS"
    echo ""
fi

if [ "$NETWORK" = "mainnet" ]; then
    echo "🔗 View on Flow Explorer:"
    echo "   https://flow-view-source.com/mainnet/account/$ACCOUNT_ADDRESS"
    echo ""
fi

echo -e "${BLUE}Happy Building! 🚀${NC}"
