/**
 * Flow Blockchain Integration
 * FCL (Flow Client Library) configuration and utilities
 */

import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";

// Contract addresses (update after deployment)
const CONTRACTS = {
  AION_VAULT: "0xf8d6e0586b0a20c7", // Emulator address
  ACTION_REGISTRY: "0xf8d6e0586b0a20c7", // Emulator address
};

// Network configuration
const NETWORK = process.env.VITE_FLOW_NETWORK || "emulator";

const CONFIG = {
  emulator: {
    accessNode: "http://localhost:8888",
    discoveryWallet: "http://localhost:8701/fcl/authn",
  },
  testnet: {
    accessNode: "https://rest-testnet.onflow.org",
    discoveryWallet: "https://fcl-discovery.onflow.org/testnet/authn",
  },
  mainnet: {
    accessNode: "https://rest-mainnet.onflow.org",
    discoveryWallet: "https://fcl-discovery.onflow.org/authn",
  },
};

/**
 * Initialize Flow Client Library
 */
export function initFCL() {
  const config = CONFIG[NETWORK as keyof typeof CONFIG] || CONFIG.emulator;

  fcl
    .config()
    .put("accessNode.api", config.accessNode)
    .put("discovery.wallet", config.discoveryWallet)
    .put("app.detail.title", "AION AI Agent")
    .put("app.detail.icon", "https://aion.ai/logo.png")
    .put("flow.network", NETWORK);

  console.log(`✅ FCL configured for ${NETWORK}`);
}

/**
 * Get current user
 */
export async function getCurrentUser() {
  return await fcl.currentUser.snapshot();
}

/**
 * Authenticate user
 */
export async function login() {
  await fcl.authenticate();
}

/**
 * Logout user
 */
export async function logout() {
  await fcl.unauthenticate();
}

/**
 * Get vault statistics
 */
export async function getVaultStats() {
  try {
    const result = await fcl.query({
      cadence: `
        import AIONVault from ${CONTRACTS.AION_VAULT}
        
        access(all) fun main(): {String: UFix64} {
          return AIONVault.getVaultStats()
        }
      `,
    });
    return result;
  } catch (error) {
    console.error("Failed to get vault stats:", error);
    throw error;
  }
}

/**
 * Get user balance
 */
export async function getUserBalance(address: string) {
  try {
    const result = await fcl.query({
      cadence: `
        import AIONVault from ${CONTRACTS.AION_VAULT}
        
        access(all) fun main(user: Address): UFix64 {
          return AIONVault.balanceOf(user: user)
        }
      `,
      args: (arg, t) => [arg(address, t.Address)],
    });
    return result;
  } catch (error) {
    console.error("Failed to get balance:", error);
    throw error;
  }
}

/**
 * Deposit to vault
 */
export async function deposit(amount: string) {
  const transactionId = await fcl.mutate({
    cadence: `
      import AIONVault from ${CONTRACTS.AION_VAULT}
    
    transaction(amount: UFix64) {
        let signerAddress: Address
        
        prepare(signer: &Account) {
          self.signerAddress = signer.address
        }
        
        execute {
          let shares = AIONVault.deposit(from: self.signerAddress, amount: amount)
          log("Deposited ".concat(amount.toString()).concat(" and received ").concat(shares.toString()).concat(" shares"))
        }
      }
    `,
    args: (arg, t) => [arg(amount, t.UFix64)],
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 100,
  });

  console.log("Transaction ID:", transactionId);

  // Wait for transaction to seal
  const transaction = await fcl.tx(transactionId).onceSealed();
  return transaction;
}

/**
 * Withdraw from vault
 */
export async function withdraw(shares: string) {
  const transactionId = await fcl.mutate({
    cadence: `
      import AIONVault from ${CONTRACTS.AION_VAULT}
    
    transaction(shares: UFix64) {
        let signerAddress: Address
        
        prepare(signer: &Account) {
          self.signerAddress = signer.address
        }
        
        execute {
          let amount = AIONVault.withdraw(from: self.signerAddress, shares: shares)
          log("Withdrew ".concat(amount.toString()).concat(" by burning ").concat(shares.toString()).concat(" shares"))
      }
    }
    `,
    args: (arg, t) => [arg(shares, t.UFix64)],
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 100,
  });

  const transaction = await fcl.tx(transactionId).onceSealed();
  return transaction;
}

/**
 * Subscribe to account changes
 */
export function subscribeToUser(callback: (user: any) => void) {
  return fcl.currentUser.subscribe(callback);
}

/**
 * Get events by type
 */
export async function getEvents(eventType: string, fromBlock: number = 0) {
    try {
      const events = await fcl.send([
      fcl.getEvents(eventType, fromBlock),
      ]).then(fcl.decode);
    return events;
    } catch (error) {
    console.error("Failed to get events:", error);
    throw error;
  }
}

export { CONTRACTS, NETWORK };
export default fcl;
