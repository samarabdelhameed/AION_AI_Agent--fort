/**
 * Flow Blockchain Integration for Frontend
 * FCL.js integration for AION Vault
 */

import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";

// Configuration
const FLOW_CONFIG = {
  "accessNode.api": import.meta.env.VITE_FLOW_ACCESS_NODE || "https://rest-testnet.onflow.org",
  "discovery.wallet": import.meta.env.VITE_FLOW_WALLET || "https://fcl-discovery.onflow.org/testnet/authn",
  "app.detail.title": "AION AI Vault",
  "app.detail.icon": "https://aion.ai/logo.png",
  "app.detail.description": "AI-Powered DeFi Vault on Flow"
};

// Contract addresses (from environment or defaults)
export const CONTRACTS = {
  AIONVault: import.meta.env.VITE_AION_VAULT_ADDRESS || "0xAIONVault",
  ActionRegistry: import.meta.env.VITE_ACTION_REGISTRY_ADDRESS || "0xActionRegistry"
};

/**
 * Initialize FCL with configuration
 */
export function initFlow() {
  fcl.config(FLOW_CONFIG);
}

/**
 * Connect user wallet
 */
export async function connectWallet() {
  return await fcl.authenticate();
}

/**
 * Disconnect wallet
 */
export async function disconnectWallet() {
  return await fcl.unauthenticate();
}

/**
 * Get current user
 */
export function getCurrentUser() {
  return fcl.currentUser;
}

/**
 * Subscribe to user authentication state
 */
export function subscribeToUser(callback: (user: any) => void) {
  return fcl.currentUser.subscribe(callback);
}

// ============== Transactions ==============

/**
 * Deposit FLOW to vault
 */
export async function depositToVault(amount: string) {
  const cadence = `
    import AIONVault from ${CONTRACTS.AIONVault}
    
    transaction(amount: UFix64) {
      prepare(signer: AuthAccount) {
        AIONVault.deposit(from: signer, amount: amount)
      }
    }
  `;

  const txId = await fcl.mutate({
    cadence,
    args: (arg: any, t: any) => [
      arg(parseFloat(amount).toFixed(8), t.UFix64)
    ],
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 1000
  });

  return await fcl.tx(txId).onceSealed();
}

/**
 * Withdraw from vault
 */
export async function withdrawFromVault(shares: string) {
  const cadence = `
    import AIONVault from ${CONTRACTS.AIONVault}
    
    transaction(shares: UFix64) {
      prepare(signer: AuthAccount) {
        AIONVault.withdraw(from: signer, shares: shares)
      }
    }
  `;

  const txId = await fcl.mutate({
    cadence,
    args: (arg: any, t: any) => [
      arg(parseFloat(shares).toFixed(8), t.UFix64)
    ],
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 1000
  });

  return await fcl.tx(txId).onceSealed();
}

/**
 * Execute rebalance (AI Agent only)
 */
export async function executeRebalance(
  fromStrategy: string,
  toStrategy: string,
  amount: string,
  reason: string
) {
  const cadence = `
    import AIONVault from ${CONTRACTS.AIONVault}
    
    transaction(from: String, to: String, amount: UFix64, reason: String) {
      prepare(signer: AuthAccount) {
        AIONVault.rebalance(
          executor: signer.address,
          fromStrategy: from,
          toStrategy: to,
          amount: amount,
          reason: reason
        )
      }
    }
  `;

  const txId = await fcl.mutate({
    cadence,
    args: (arg: any, t: any) => [
      arg(fromStrategy, t.String),
      arg(toStrategy, t.String),
      arg(parseFloat(amount).toFixed(8), t.UFix64),
      arg(reason, t.String)
    ],
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 2000
  });

  return await fcl.tx(txId).onceSealed();
}

// ============== Scripts (Read Data) ==============

/**
 * Get user balance in vault
 */
export async function getUserBalance(userAddress: string) {
  const cadence = `
    import AIONVault from ${CONTRACTS.AIONVault}
    
    pub struct UserBalance {
      pub let address: Address
      pub let shares: UFix64
      pub let assetValue: UFix64
      pub let principal: UFix64
      pub let unrealizedProfit: Fix64
      pub let pricePerShare: UFix64
      
      init(addr: Address, sh: UFix64, val: UFix64, prin: UFix64, profit: Fix64, price: UFix64) {
        self.address = addr
        self.shares = sh
        self.assetValue = val
        self.principal = prin
        self.unrealizedProfit = profit
        self.pricePerShare = price
      }
    }
    
    pub fun main(userAddress: Address): UserBalance {
      let shares = AIONVault.balanceOf(user: userAddress)
      let assetValue = AIONVault.valueOf(user: userAddress)
      let principal = AIONVault.principalOf[userAddress] ?? 0.0
      let unrealizedProfit = AIONVault.getUnrealizedProfit(user: userAddress)
      let pricePerShare = AIONVault.getPricePerShare()
      
      return UserBalance(
        addr: userAddress,
        sh: shares,
        val: assetValue,
        prin: principal,
        profit: unrealizedProfit,
        price: pricePerShare
      )
    }
  `;

  return await fcl.query({
    cadence,
    args: (arg: any, t: any) => [
      arg(userAddress, t.Address)
    ]
  });
}

/**
 * Get vault statistics
 */
export async function getVaultStats() {
  const cadence = `
    import AIONVault from ${CONTRACTS.AIONVault}
    
    pub fun main(): {String: UFix64} {
      return AIONVault.getVaultStats()
    }
  `;

  return await fcl.query({ cadence });
}

/**
 * Get all registered actions
 */
export async function getAllActions() {
  const cadence = `
    import ActionRegistry from ${CONTRACTS.ActionRegistry}
    
    pub fun main(): {String: ActionRegistry.ActionMeta} {
      return ActionRegistry.getAllActions()
    }
  `;

  return await fcl.query({ cadence });
}

/**
 * Get action execution stats
 */
export async function getActionStats() {
  const cadence = `
    import ActionRegistry from ${CONTRACTS.ActionRegistry}
    
    pub fun main(): {String: UInt64} {
      return ActionRegistry.getStats()
    }
  `;

  return await fcl.query({ cadence });
}

// ============== Event Subscription ==============

/**
 * Subscribe to vault events
 */
export async function subscribeToVaultEvents(
  eventName: string,
  callback: (events: any[]) => void
) {
  const contractAddress = CONTRACTS.AIONVault.replace('0x', '');
  const eventType = `A.${contractAddress}.AIONVault.${eventName}`;
  
  // Poll for events (Flow doesn't have websocket subscriptions yet)
  const pollInterval = setInterval(async () => {
    try {
      const latestBlock = await fcl.block({ sealed: true });
      const events = await fcl.send([
        fcl.getEventsAtBlockHeightRange(
          eventType,
          latestBlock.height - 10, // Last 10 blocks
          latestBlock.height
        )
      ]).then(fcl.decode);
      
      if (events && events.length > 0) {
        callback(events);
      }
    } catch (error) {
      console.error('Error polling events:', error);
    }
  }, 5000); // Poll every 5 seconds

  return () => clearInterval(pollInterval);
}

// ============== Helpers ==============

/**
 * Format UFix64 to readable number
 */
export function formatUFix64(value: string): string {
  return parseFloat(value).toFixed(8);
}

/**
 * Convert number to UFix64 string
 */
export function toUFix64(value: number): string {
  return value.toFixed(8);
}

/**
 * Check if transaction was successful
 */
export function isTransactionSuccessful(tx: any): boolean {
  return tx.status === 4 && tx.statusCode === 0; // 4 = SEALED, 0 = SUCCESS
}

/**
 * Get transaction error message
 */
export function getTransactionError(tx: any): string {
  if (tx.errorMessage) {
    return tx.errorMessage;
  }
  if (tx.events) {
    const errorEvent = tx.events.find((e: any) => e.type.includes('Error'));
    if (errorEvent) {
      return errorEvent.data.message || 'Transaction failed';
    }
  }
  return 'Unknown error';
}

export default {
  initFlow,
  connectWallet,
  disconnectWallet,
  getCurrentUser,
  subscribeToUser,
  depositToVault,
  withdrawFromVault,
  executeRebalance,
  getUserBalance,
  getVaultStats,
  getAllActions,
  getActionStats,
  subscribeToVaultEvents,
  formatUFix64,
  toUFix64,
  isTransactionSuccessful,
  getTransactionError,
  CONTRACTS
};

