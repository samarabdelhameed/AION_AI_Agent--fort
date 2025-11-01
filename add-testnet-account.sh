#!/bin/bash

# Quick script to add testnet account to flow.json

echo "🔧 Add Testnet Account to flow.json"
echo "====================================="
echo ""

if [ ! -f "flow.json" ]; then
    echo "❌ flow.json not found!"
    exit 1
fi

echo "First, generate keys if you haven't:"
echo "  flow keys generate"
echo ""
echo "Then get testnet FLOW from:"
echo "  https://testnet-faucet.onflow.org/"
echo ""

read -p "Enter your Testnet Address (0x...): " ADDRESS
read -p "Enter your Private Key: " PRIVATE_KEY

# Backup original
cp flow.json flow.json.backup

# Create new flow.json with testnet account
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
      "address": "$ADDRESS",
      "key": {
        "type": "hex",
        "index": 0,
        "signatureAlgorithm": "ECDSA_P256",
        "hashAlgorithm": "SHA3_256",
        "privateKey": "$PRIVATE_KEY"
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
echo "✅ flow.json updated with testnet account!"
echo ""
echo "Verify with:"
echo "  flow accounts get testnet-account --network=testnet"
echo ""
echo "Then deploy:"
echo "  ./DEPLOY_NOW.sh"

