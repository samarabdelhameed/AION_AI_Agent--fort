/**
 * Flow EVM Context - Integration with Flow EVM (Solidity contracts)
 * Provides access to Ethereum-compatible contracts on Flow
 */

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { ethers } from 'ethers';

const FLOW_EVM_CONFIG = {
  rpcUrl: "https://testnet.evm.nodes.onflow.org",
  chainId: 545,
  chainName: "Flow EVM Testnet",
  explorerUrl: "https://evm-testnet.flowscan.io",
  vaultAddress: "0x0000000000000000000000000000000000000000" // To be deployed
};

interface FlowEVMContextType {
  provider: any;
  isConnected: boolean;
  chainId: number;
  blockNumber: number | null;
  vaultDeployed: boolean;
  loading: boolean;
  error: string | null;
  refreshData: () => Promise<void>;
}

const FlowEVMContext = createContext<FlowEVMContextType | undefined>(undefined);

export const useFlowEVM = () => {
  const context = useContext(FlowEVMContext);
  if (!context) {
    throw new Error('useFlowEVM must be used within FlowEVMProvider');
  }
  return context;
};

export const FlowEVMProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [provider, setProvider] = useState<any>(null);
  const [blockNumber, setBlockNumber] = useState<number | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    initializeProvider();
  }, []);

  const initializeProvider = async () => {
    try {
      console.log("🟣 Initializing Flow EVM integration...");
      
      const evmProvider = new ethers.JsonRpcProvider(FLOW_EVM_CONFIG.rpcUrl);
      setProvider(evmProvider);
      
      const network = await evmProvider.getNetwork();
      const block = await evmProvider.getBlockNumber();
      
      setBlockNumber(block);
      
      console.log("✅ Flow EVM initialized");
      console.log(`   Chain ID: ${network.chainId}`);
      console.log(`   Block: ${block}`);
      
    } catch (err: any) {
      console.error("Flow EVM initialization failed:", err);
      setError(err.message);
    }
  };

  const refreshData = async () => {
    try {
      setLoading(true);
      if (provider) {
        const block = await provider.getBlockNumber();
        setBlockNumber(block);
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const value: FlowEVMContextType = {
    provider,
    isConnected: !!provider,
    chainId: FLOW_EVM_CONFIG.chainId,
    blockNumber,
    vaultDeployed: FLOW_EVM_CONFIG.vaultAddress !== "0x0000000000000000000000000000000000000000",
    loading,
    error,
    refreshData
  };

  return (
    <FlowEVMContext.Provider value={value}>
      {children}
    </FlowEVMContext.Provider>
  );
};

