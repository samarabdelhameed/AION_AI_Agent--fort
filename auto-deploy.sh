#!/bin/bash

# AION Auto-Deploy Script for Flow Testnet
# This script will help you deploy AION contracts to Flow Testnet

echo "🌊 AION - Flow Testnet Auto-Deploy Script"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flow CLI is installed
if ! command -v flow &> /dev/null; then
    echo -e "${RED}❌ Flow CLI not found. Please install it first.${NC}"
    echo "Install: sh -ci \"\$(curl -fsSL https://raw.githubusercontent.com/onflow/flow-cli/master/install.sh)\""
    exit 1
fi

echo -e "${GREEN}✅ Flow CLI found: $(flow version)${NC}"
echo ""

# Public key (already generated)
PUBLIC_KEY="01c90670b2d8535dcdb72dec69ff8b7d34b3419615da706e092a86bb3fa5448d2ba01cf89f0e7dd734d0e7e6976fc8cdef75e28884aa1cb31aa107943a4dcdfb"

echo "🔑 Your Public Key:"
echo "$PUBLIC_KEY"
echo ""

# Check if testnet account exists in flow.json
CURRENT_ADDRESS=$(grep -A 10 '"testnet-account"' flow.json | grep '"address"' | cut -d'"' -f4)

if [ "$CURRENT_ADDRESS" == "SERVICE_ACCOUNT" ]; then
    echo -e "${YELLOW}⚠️  Testnet account not configured yet.${NC}"
    echo ""
    echo "Please do ONE of the following:"
    echo ""
    echo "Option 1 (Easiest):"
    echo "  1. Go to: https://testnet-faucet.onflow.org/"
    echo "  2. Paste this public key: $PUBLIC_KEY"
    echo "  3. Click 'Create Account'"
    echo "  4. Copy the generated address"
    echo "  5. Run this script again with: ./auto-deploy.sh <YOUR_ADDRESS>"
    echo ""
    echo "Option 2 (Manual):"
    echo "  1. Get testnet FLOW from faucet"
    echo "  2. Update flow.json manually"
    echo "  3. Run: flow project deploy --network=testnet"
    echo ""
    
    # Check if address provided as argument
    if [ -z "$1" ]; then
        exit 0
    else
        TESTNET_ADDRESS=$1
        echo -e "${GREEN}✅ Using provided address: $TESTNET_ADDRESS${NC}"
        
        # Update flow.json
        sed -i.bak "s/SERVICE_ACCOUNT/$TESTNET_ADDRESS/g" flow.json
        echo -e "${GREEN}✅ Updated flow.json with testnet address${NC}"
    fi
else
    echo -e "${GREEN}✅ Testnet account configured: $CURRENT_ADDRESS${NC}"
    TESTNET_ADDRESS=$CURRENT_ADDRESS
fi

echo ""
echo "🚀 Deploying contracts to Flow Testnet..."
echo ""

# Deploy contracts
flow project deploy --network=testnet

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 SUCCESS! Contracts deployed to Flow Testnet!${NC}"
    echo ""
    echo "📊 Contract Addresses:"
    echo "  ActionRegistry: $TESTNET_ADDRESS"
    echo "  AIONVault: $TESTNET_ADDRESS"
    echo ""
    echo "🧪 Testing deposit transaction..."
    
    # Test deposit
    flow transactions send ./cadence/transactions/deposit.cdc 0.1 --network=testnet --signer=testnet-account
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Deposit test successful!${NC}"
        echo ""
        echo "📈 Getting vault stats..."
        flow scripts execute ./cadence/scripts/get_vault_stats.cdc --network=testnet
        
        echo ""
        echo -e "${GREEN}🎯 All done! Your contracts are live on Flow Testnet!${NC}"
        echo ""
        echo "🔗 Next steps:"
        echo "  1. Verify on FlowDiver: https://testnet.flowdiver.io/account/$TESTNET_ADDRESS"
        echo "  2. Update README.md with contract addresses"
        echo "  3. Create Dune Analytics dashboard"
        echo "  4. Submit to hackathon!"
        echo ""
    else
        echo -e "${YELLOW}⚠️  Deposit test failed, but contracts are deployed.${NC}"
    fi
else
    echo ""
    echo -e "${RED}❌ Deployment failed. Check the error above.${NC}"
    exit 1
fi

