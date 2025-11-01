/**
 * Flow Service - Integration with Flow Blockchain
 * Connects MCP Agent to Flow contracts for AI-powered DeFi
 */

import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";

class FlowService {
  constructor(configManager, errorManager) {
    this.configManager = configManager;
    this.errorManager = errorManager;
    this.isInitialized = false;
    
    // Contract addresses
    this.contracts = {
      AION_VAULT: process.env.FLOW_VAULT_ADDRESS || "0xc7a34c80e6f3235b",
      ACTION_REGISTRY: process.env.FLOW_ACTION_REGISTRY || "0xc7a34c80e6f3235b"
    };
    
    // Network config
    this.network = process.env.FLOW_NETWORK || "testnet";
    this.accessNode = this.getAccessNode();
  }

  getAccessNode() {
    const nodes = {
      emulator: "http://localhost:8888",
      testnet: "https://rest-testnet.onflow.org",
      mainnet: "https://rest-mainnet.onflow.org"
    };
    return nodes[this.network] || nodes.testnet;
  }

  async initialize() {
    try {
      console.log("🔵 Initializing Flow Service...");
      
      // Configure FCL
      fcl.config()
        .put("accessNode.api", this.accessNode)
        .put("flow.network", this.network)
        .put("app.detail.title", "AION AI Agent")
        .put("app.detail.icon", "https://aion.ai/logo.png");

      // Test connection
      const block = await fcl.send([fcl.getBlock(true)]).then(fcl.decode);
      
      this.isInitialized = true;
      console.log(`✅ Flow Service initialized (${this.network})`);
      console.log(`   Latest block: ${block.height}`);
      console.log(`   Vault: ${this.contracts.AION_VAULT}`);
      
      return true;
    } catch (error) {
      console.error("❌ Flow Service initialization failed:", error.message);
      this.errorManager.handleError(error, 'FlowService.initialize');
      return false;
    }
  }

  /**
   * Get vault statistics from Flow
   */
  async getVaultStats() {
    try {
      const result = await fcl.query({
        cadence: `
          import AIONVault from ${this.contracts.AION_VAULT}
          
          access(all) fun main(): {String: UFix64} {
            return AIONVault.getVaultStats()
          }
        `
      });
      
      return {
        totalAssets: parseFloat(result.totalAssets),
        totalShares: parseFloat(result.totalShares),
        pricePerShare: parseFloat(result.pricePerShare),
        minDeposit: parseFloat(result.minDeposit),
        minWithdraw: parseFloat(result.minWithdraw)
      };
    } catch (error) {
      console.error("Failed to get vault stats:", error);
      throw error;
    }
  }

  /**
   * Get user balance from vault
   */
  async getUserBalance(address) {
    try {
      const result = await fcl.query({
        cadence: `
          import AIONVault from ${this.contracts.AION_VAULT}
          
          access(all) fun main(user: Address): UFix64 {
            return AIONVault.balanceOf(user: user)
          }
        `,
        args: (arg, t) => [arg(address, t.Address)]
      });
      
      return parseFloat(result);
    } catch (error) {
      console.error("Failed to get user balance:", error);
      throw error;
    }
  }

  /**
   * Get registered actions
   */
  async getRegisteredActions() {
    try {
      const result = await fcl.query({
        cadence: `
          import ActionRegistry from ${this.contracts.ACTION_REGISTRY}
          
          access(all) fun main(): {String: ActionRegistry.ActionMeta} {
            return ActionRegistry.getAllActions()
          }
        `
      });
      
      return result;
    } catch (error) {
      console.error("Failed to get actions:", error);
      throw error;
    }
  }

  /**
   * AI analyzes vault and recommends strategy
   */
  async analyzeAndRecommend() {
    try {
      console.log("🤖 AI analyzing vault...");
      
      // Get current vault stats
      const stats = await this.getVaultStats();
      
      // AI analysis (simplified for demo)
      const strategies = [
        { name: "Venus", apy: 12.5, risk: 4 },
        { name: "PancakeSwap", apy: 15.2, risk: 6 },
        { name: "Aave", apy: 8.7, risk: 3 }
      ];
      
      // Select best strategy
      const bestStrategy = strategies.reduce((prev, current) => 
        (current.apy / current.risk) > (prev.apy / prev.risk) ? current : prev
      );
      
      const recommendation = {
        recommendedStrategy: bestStrategy.name,
        currentAPY: bestStrategy.apy,
        riskScore: bestStrategy.risk,
        confidence: 87,
        reason: `Highest risk-adjusted return (${(bestStrategy.apy / bestStrategy.risk).toFixed(2)} APY/risk ratio)`,
        timestamp: new Date().toISOString()
      };
      
      console.log(`✅ AI Recommendation: ${bestStrategy.name} (${bestStrategy.apy}% APY)`);
      
      return recommendation;
    } catch (error) {
      console.error("AI analysis failed:", error);
      throw error;
    }
  }

  /**
   * Post AI recommendation to Flow blockchain
   */
  async postRecommendation(aiAgent, recommendation) {
    try {
      // This would require authentication
      // For now, return the recommendation for manual posting
      console.log("📤 AI Recommendation ready for posting:");
      console.log(recommendation);
      
      return {
        success: true,
        recommendation,
        note: "Use Flow Executor to post on-chain"
      };
    } catch (error) {
      console.error("Failed to post recommendation:", error);
      throw error;
    }
  }

  /**
   * Monitor Flow events
   */
  async monitorEvents(eventType, fromBlock = "latest") {
    try {
      const events = await fcl.send([
        fcl.getEventsAtBlockHeightRange(
          `A.${this.contracts.AION_VAULT.replace('0x', '')}.AIONVault.${eventType}`,
          fromBlock,
          "latest"
        )
      ]).then(fcl.decode);
      
      return events;
    } catch (error) {
      console.error(`Failed to monitor ${eventType} events:`, error);
      return [];
    }
  }

  /**
   * Health check
   */
  async healthCheck() {
    try {
      const block = await fcl.send([fcl.getBlock(true)]).then(fcl.decode);
      return {
        status: 'healthy',
        network: this.network,
        latestBlock: block.height,
        contracts: this.contracts
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message
      };
    }
  }
}

export default FlowService;

