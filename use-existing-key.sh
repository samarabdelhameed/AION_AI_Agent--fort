#!/bin/bash

###############################################################################
# Use Existing Private Key from .env
# يستخدم المفتاح الموجود في .env (يحوله لـFlow format)
###############################################################################

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Using Existing Key from .env${NC}"
echo ""

# Check .env
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env not found!${NC}"
    exit 1
fi

# Extract key
PRIVATE_KEY=$(grep "^PRIVATE_KEY=" .env | cut -d'=' -f2)

if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}❌ PRIVATE_KEY not found in .env!${NC}"
    exit 1
fi

# Remove 0x prefix if exists
CLEAN_KEY=${PRIVATE_KEY#0x}

echo -e "${GREEN}✅ Found private key${NC}"
echo -e "   Key (first 10 chars): ${CLEAN_KEY:0:10}..."
echo ""

# Warning
echo -e "${YELLOW}⚠️  IMPORTANT:${NC}"
echo "This will use your existing BSC/EVM key for Flow testnet."
echo "It's recommended to generate a NEW Flow key instead:"
echo "  flow keys generate"
echo ""

read -p "Continue with existing key? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled. Run 'flow keys generate' to create new key."
    exit 0
fi

# Get testnet address from faucet
echo ""
echo -e "${YELLOW}📋 Now you need to:${NC}"
echo ""
echo "1. Go to: https://testnet-faucet.onflow.org/"
echo ""
echo "2. You'll need a PUBLIC key. Generate it from private key:"
echo "   (Flow CLI can do this, but requires the key in flow.json first)"
echo ""
echo "OR better:"
echo ""
echo -e "${GREEN}Just run: flow keys generate${NC}"
echo "And use the new Flow keys instead!"
echo ""

read -p "Enter your Flow testnet address (or 'q' to quit): " TESTNET_ADDRESS

if [[ "$TESTNET_ADDRESS" == "q" ]]; then
    echo "Cancelled."
    exit 0
fi

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
      "address": "$TESTNET_ADDRESS",
      "key": {
        "type": "hex",
        "index": 0,
        "signatureAlgorithm": "ECDSA_P256",
        "hashAlgorithm": "SHA3_256",
        "privateKey": "$CLEAN_KEY"
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

echo ""
echo -e "${GREEN}✅ flow.json updated!${NC}"
echo ""
echo "Verify with:"
echo "  flow accounts get testnet-account --network=testnet"
echo ""
echo "Then deploy:"
echo "  ./DEPLOY_NOW.sh"

