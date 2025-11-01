#!/bin/bash

# Quick script to update flow.json with your testnet credentials

echo "🔧 Flow Configuration Updater"
echo "================================"
echo ""

read -p "Enter your Testnet Address (0x...): " ADDRESS
read -p "Enter your Private Key: " PRIVATE_KEY

cat > flow.json << EOF
{
  "contracts": {
    "ActionRegistry": "./cadence/contracts/ActionRegistry.cdc",
    "AIONVault": "./cadence/contracts/AIONVault.cdc"
  },
  "networks": {
    "emulator": "127.0.0.1:3569",
    "mainnet": "access.mainnet.nodes.onflow.org:9000",
    "testnet": "access.devnet.nodes.onflow.org:9000"
  },
  "accounts": {
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
echo "✅ flow.json updated!"
echo ""
echo "Now run:"
echo "  ./DEPLOY_NOW.sh"

