#!/bin/bash

# =========================================
# AION Vault - Live Deployment Script
# =========================================
# This script deploys to REAL networks with verification
# Usage: ./DEPLOY_LIVE.sh [network]
# Example: ./DEPLOY_LIVE.sh bnbTestnet

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   AION Vault - Live Deployment${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if network argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Network not specified${NC}"
    echo "Usage: ./DEPLOY_LIVE.sh [network]"
    echo ""
    echo "Available networks:"
    echo "  - bnbTestnet   (BNB Smart Chain Testnet)"
    echo "  - bnbMainnet   (BNB Smart Chain Mainnet)"
    echo "  - sepolia      (Ethereum Sepolia Testnet)"
    echo ""
    exit 1
fi

NETWORK=$1

# Change to contracts directory
cd "$(dirname "$0")/contracts"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please create .env file with:"
    echo "  PRIVATE_KEY=your_private_key"
    echo "  ETHERSCAN_API_KEY=your_api_key (for BNB)"
    echo "  BNB_MAINNET_RPC_URL=your_rpc_url"
    echo ""
    exit 1
fi

# Load environment variables
source .env

# Check if PRIVATE_KEY is set
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: PRIVATE_KEY not set in .env${NC}"
    exit 1
fi

# Set RPC URL based on network
case $NETWORK in
    bnbTestnet)
        RPC_URL="https://data-seed-prebsc-1-s1.binance.org:8545"
        EXPLORER_URL="https://testnet.bscscan.com"
        CHAIN_ID=97
        ;;
    bnbMainnet)
        if [ -z "$BNB_MAINNET_RPC_URL" ]; then
            echo -e "${RED}Error: BNB_MAINNET_RPC_URL not set${NC}"
            exit 1
        fi
        RPC_URL=$BNB_MAINNET_RPC_URL
        EXPLORER_URL="https://bscscan.com"
        CHAIN_ID=56
        ;;
    sepolia)
        if [ -z "$SEPOLIA_RPC_URL" ]; then
            RPC_URL="https://eth-sepolia.public.blastapi.io"
        else
            RPC_URL=$SEPOLIA_RPC_URL
        fi
        EXPLORER_URL="https://sepolia.etherscan.io"
        CHAIN_ID=11155111
        ;;
    *)
        echo -e "${RED}Error: Unknown network $NETWORK${NC}"
        exit 1
        ;;
esac

echo -e "${YELLOW}Network:${NC} $NETWORK"
echo -e "${YELLOW}Chain ID:${NC} $CHAIN_ID"
echo -e "${YELLOW}RPC URL:${NC} $RPC_URL"
echo -e "${YELLOW}Explorer:${NC} $EXPLORER_URL"
echo ""

# Confirm deployment
echo -e "${YELLOW}⚠️  WARNING: You are about to deploy to a LIVE network!${NC}"
echo -e "Press ${GREEN}Y${NC} to continue, any other key to cancel..."
read -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Deployment cancelled${NC}"
    exit 1
fi

echo -e "\n${BLUE}Step 1: Compiling contracts...${NC}"
forge build --force

if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Compilation successful${NC}\n"

echo -e "${BLUE}Step 2: Deploying to $NETWORK...${NC}"
forge script script/DeployAndVerify.s.sol \
    --rpc-url $RPC_URL \
    --broadcast \
    --legacy \
    -vvvv

if [ $? -ne 0 ]; then
    echo -e "${RED}Deployment failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Deployment successful${NC}\n"

# Extract vault address from deployment file
DEPLOYMENT_FILE="deployment-${CHAIN_ID}.json"
if [ -f "$DEPLOYMENT_FILE" ]; then
    VAULT_ADDRESS=$(grep -o '"vaultAddress": "[^"]*' $DEPLOYMENT_FILE | cut -d'"' -f4)
    echo -e "${GREEN}Vault deployed at: $VAULT_ADDRESS${NC}"
    echo ""
    
    # Ask if user wants to verify
    echo -e "${YELLOW}Do you want to verify the contract on block explorer? (Y/n)${NC}"
    read -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        if [ ! -z "$ETHERSCAN_API_KEY" ]; then
            echo -e "${BLUE}Step 3: Verifying contract...${NC}"
            
            # Get constructor args
            MIN_DEPOSIT=$(grep -o '"minDeposit": "[^"]*' $DEPLOYMENT_FILE | cut -d'"' -f4)
            MIN_YIELD=$(grep -o '"minYieldClaim": "[^"]*' $DEPLOYMENT_FILE | cut -d'"' -f4)
            
            CONSTRUCTOR_ARGS=$(cast abi-encode "constructor(uint256,uint256)" $MIN_DEPOSIT $MIN_YIELD)
            
            forge verify-contract \
                $VAULT_ADDRESS \
                src/AIONVault.sol:AIONVault \
                --chain $CHAIN_ID \
                --constructor-args $CONSTRUCTOR_ARGS \
                --etherscan-api-key $ETHERSCAN_API_KEY \
                --watch
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Contract verified${NC}\n"
            else
                echo -e "${YELLOW}⚠️  Verification failed (may need manual verification)${NC}\n"
            fi
        else
            echo -e "${YELLOW}⚠️  ETHERSCAN_API_KEY not set, skipping verification${NC}\n"
        fi
    fi
    
    # Ask if user wants to populate with real data
    echo -e "${YELLOW}Do you want to populate with test data? (y/N)${NC}"
    read -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Step 4: Populating with real data...${NC}"
        export VAULT_ADDRESS=$VAULT_ADDRESS
        forge script script/PopulateRealData.s.sol \
            --rpc-url $RPC_URL \
            --broadcast \
            --legacy \
            -vvvv
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Data populated${NC}\n"
        else
            echo -e "${YELLOW}⚠️  Data population failed${NC}\n"
        fi
    fi
    
    # Final summary
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}   Deployment Summary${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Network:${NC} $NETWORK (Chain ID: $CHAIN_ID)"
    echo -e "${GREEN}Vault Address:${NC} $VAULT_ADDRESS"
    echo -e "${GREEN}Explorer:${NC} $EXPLORER_URL/address/$VAULT_ADDRESS"
    echo -e "${GREEN}Deployment File:${NC} contracts/$DEPLOYMENT_FILE"
    echo -e "${BLUE}========================================${NC}\n"
    
    # Update frontend config suggestion
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Update frontend config:"
    echo "   - Edit frontend/src/lib/contractConfig.ts"
    echo "   - Set VAULT_ADDRESS to: $VAULT_ADDRESS"
    echo ""
    echo "2. Fund the vault for gas and operations"
    echo ""
    echo "3. Configure AI agent and strategies"
    echo -e "${BLUE}========================================${NC}\n"
else
    echo -e "${RED}Warning: Deployment file not found${NC}"
fi

echo -e "${GREEN}🎉 Deployment process completed!${NC}\n"

