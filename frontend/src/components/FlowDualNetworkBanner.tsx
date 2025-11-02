/**
 * Flow Dual Network Banner - Shows both Flow Cadence & Flow EVM status
 * Professional multi-chain integration display
 */

import React from 'react';
import { motion } from 'framer-motion';
import { CheckCircle, Activity, Code, Zap } from 'lucide-react';
import { useFlow } from '../contexts/FlowContext';
import { useFlowEVM } from '../contexts/FlowEVMContext';

export function FlowDualNetworkBanner() {
  const { vaultStats, registeredActions, isConnected: cadenceConnected } = useFlow();
  const { isConnected: evmConnected, blockNumber: evmBlock, chainId } = useFlowEVM();

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-gradient-to-r from-purple-500/10 via-blue-500/10 to-cyan-500/10 border border-purple-500/30 rounded-xl p-4 mb-6"
    >
      <div className="mb-3">
        <h3 className="text-lg font-bold text-white flex items-center gap-2">
          <Zap className="w-5 h-5 text-purple-400" />
          Flow Multi-Chain Integration
          <span className="text-xs bg-green-500/20 text-green-400 px-2 py-0.5 rounded-full">LIVE</span>
        </h3>
        <p className="text-xs text-gray-400 mt-1">
          Dual deployment: Cadence (native Flow) + EVM (Ethereum compatible)
        </p>
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        {/* Flow Cadence */}
        <div className="bg-blue-500/5 border border-blue-500/20 rounded-lg p-3">
          <div className="flex items-center gap-2 mb-2">
            <Code className="w-4 h-4 text-blue-400" />
            <h4 className="font-semibold text-blue-400">Flow Cadence</h4>
            <span className="text-xs bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full">
              {cadenceConnected ? 'Connected' : 'Available'}
            </span>
          </div>
          
          {vaultStats ? (
            <div className="space-y-1 text-xs">
              <div className="flex justify-between">
                <span className="text-gray-400">Contract:</span>
                <span className="text-cyan-400 font-mono">0xc7a34...235b</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Total Assets:</span>
                <span className="text-white font-semibold">{vaultStats.totalAssets?.toFixed(2) || '0'} FLOW</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Total Shares:</span>
                <span className="text-white">{vaultStats.totalShares?.toFixed(2) || '0'}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Actions:</span>
                <span className="text-purple-400 font-semibold">{registeredActions?.length || 0} registered</span>
              </div>
            </div>
          ) : (
            <p className="text-xs text-gray-500">Loading Cadence data...</p>
          )}
        </div>

        {/* Flow EVM */}
        <div className="bg-purple-500/5 border border-purple-500/20 rounded-lg p-3">
          <div className="flex items-center gap-2 mb-2">
            <Activity className="w-4 h-4 text-purple-400" />
            <h4 className="font-semibold text-purple-400">Flow EVM</h4>
            <span className="text-xs bg-purple-500/20 text-purple-400 px-2 py-0.5 rounded-full">
              {evmConnected ? 'Connected' : 'Available'}
            </span>
          </div>
          
          {evmConnected ? (
            <div className="space-y-1 text-xs">
              <div className="flex justify-between">
                <span className="text-gray-400">Chain ID:</span>
                <span className="text-purple-400 font-mono">{chainId}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Latest Block:</span>
                <span className="text-white font-semibold">{evmBlock?.toLocaleString() || 'N/A'}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">RPC:</span>
                <span className="text-cyan-400 font-mono text-[10px]">testnet.evm.nodes.onflow.org</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Vault:</span>
                <span className="text-yellow-400">Ready for deployment</span>
              </div>
            </div>
          ) : (
            <p className="text-xs text-gray-500">Initializing EVM connection...</p>
          )}
        </div>
      </div>

      <div className="mt-3 pt-3 border-t border-purple-500/20">
        <div className="flex items-center justify-between text-xs">
          <p className="text-purple-400">
            🔵 Cadence (native Flow) + 🟣 EVM (Ethereum compatible)
          </p>
          <p className="text-gray-400">
            Data source: <span className="font-mono text-cyan-400">REAL_FLOW_TESTNET</span>
          </p>
        </div>
      </div>
    </motion.div>
  );
}

