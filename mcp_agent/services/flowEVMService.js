/**
 * Flow EVM Service - Integration with Flow's EVM (Ethereum-compatible layer)
 * Connects to Solidity contracts on Flow EVM Testnet
 */

import { ethers } from 'ethers';
import fs from 'fs';
import path from 'path';

class FlowEVMService {
  constructor(configManager, errorManager) {
    this.configManager = configManager;
    this.errorManager = errorManager;
    this.isInitialized = false;
    
    // Flow EVM Testnet configuration
    this.network = {
      name: 'Flow EVM Testnet',
      chainId: 545, // Flow EVM Testnet
      rpcUrl: 'https://testnet.evm.nodes.onflow.org',
      explorer: 'https://evm-testnet.flowscan.io'
    };
    
    // Contract addresses (will be set after deployment)
    this.contracts = {
      AION_VAULT: process.env.FLOW_EVM_VAULT_ADDRESS || null
    };
    
    this.provider = null;
    this.vaultContract = null;
  }

  async initialize() {
    try {
      console.log("🔷 Initializing Flow EVM Service...");
      
      // Create provider for Flow EVM Testnet
      this.provider = new ethers.JsonRpcProvider(this.network.rpcUrl);
      
      // Test connection
      const network = await this.provider.getNetwork();
      const blockNumber = await this.provider.getBlockNumber();
      
      // Load contract ABI if available
      if (this.contracts.AION_VAULT) {
        try {
          const abiPath = path.resolve(process.cwd(), '../contracts/out/AIONVault.sol/AIONVault.json');
          if (fs.existsSync(abiPath)) {
            const contractJson = JSON.parse(fs.readFileSync(abiPath, 'utf8'));
            this.vaultContract = new ethers.Contract(
              this.contracts.AION_VAULT,
              contractJson.abi,
              this.provider
            );
            console.log(`   Vault contract loaded: ${this.contracts.AION_VAULT}`);
          }
        } catch (abiError) {
          console.log("   Note: Contract ABI not loaded (deploy first)");
        }
      }
      
      this.isInitialized = true;
      console.log(`✅ Flow EVM Service initialized`);
      console.log(`   Network: ${this.network.name}`);
      console.log(`   ChainId: ${this.network.chainId}`);
      console.log(`   Latest block: ${blockNumber}`);
      
      return true;
    } catch (error) {
      console.error("❌ Flow EVM Service initialization failed:", error.message);
      this.errorManager.handleError(error, 'FlowEVMService.initialize');
      return false;
    }
  }

  /**
   * Get vault statistics from Flow EVM
   */
  async getVaultStats() {
    try {
      if (!this.vaultContract) {
        throw new Error("Vault contract not loaded - deploy to Flow EVM first");
      }

      const [totalAssets, totalShares, pricePerShare] = await Promise.all([
        this.vaultContract.totalAssets(),
        this.vaultContract.totalShares(),
        this.vaultContract.pricePerShare()
      ]);

      return {
        totalAssets: ethers.formatEther(totalAssets),
        totalShares: ethers.formatEther(totalShares),
        pricePerShare: pricePerShare.toString(),
        network: 'Flow EVM Testnet',
        chainId: this.network.chainId
      };
    } catch (error) {
      console.error("Failed to get vault stats from Flow EVM:", error);
      throw error;
    }
  }

  /**
   * Get user balance from Flow EVM vault
   */
  async getUserBalance(address) {
    try {
      if (!this.vaultContract) {
        throw new Error("Vault contract not loaded");
      }

      const balance = await this.vaultContract.balanceOf(address);
      return ethers.formatEther(balance);
    } catch (error) {
      console.error("Failed to get user balance from Flow EVM:", error);
      throw error;
    }
  }

  /**
   * Health check
   */
  async healthCheck() {
    try {
      const blockNumber = await this.provider.getBlockNumber();
      return {
        status: 'healthy',
        network: this.network.name,
        chainId: this.network.chainId,
        latestBlock: blockNumber,
        contracts: this.contracts,
        rpcUrl: this.network.rpcUrl
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message
      };
    }
  }

  /**
   * Get network info
   */
  getNetworkInfo() {
    return {
      name: this.network.name,
      chainId: this.network.chainId,
      rpcUrl: this.network.rpcUrl,
      explorer: this.network.explorer,
      contracts: this.contracts
    };
  }
}

export default FlowEVMService;

