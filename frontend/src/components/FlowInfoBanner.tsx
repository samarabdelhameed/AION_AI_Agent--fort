/**
 * Flow Info Banner - Shows Flow connection status
 * Displays REAL data from Flow Testnet
 */

import React from 'react';
import { motion } from 'framer-motion';
import { CheckCircle, Activity, TrendingUp, Zap } from 'lucide-react';
import { useFlow } from '../contexts/FlowContext';

export function FlowInfoBanner() {
  const { vaultStats, isConnected, user, registeredActions } = useFlow();

  if (!vaultStats) return null;

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-gradient-to-r from-blue-500/10 to-cyan-500/10 border border-blue-500/30 rounded-xl p-4 mb-6"
    >
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-500/20 rounded-lg flex items-center justify-center">
            <CheckCircle className="w-6 h-6 text-blue-400" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-white flex items-center gap-2">
              Flow Testnet Connected
              <span className="text-xs bg-green-500/20 text-green-400 px-2 py-0.5 rounded-full">LIVE</span>
            </h3>
            <p className="text-xs text-gray-400">
              Contract: 0xc7a34c80e6f3235b
              {isConnected && user?.addr && ` • ${user.addr.slice(0, 6)}...${user.addr.slice(-4)}`}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-6">
          <div className="text-center">
            <div className="flex items-center gap-1 text-cyan-400">
              <Activity size={16} />
              <span className="text-lg font-bold">{vaultStats.totalAssets?.toFixed(2) || '0'}</span>
              <span className="text-xs">FLOW</span>
            </div>
            <p className="text-xs text-gray-400">Total Assets</p>
          </div>

          <div className="text-center">
            <div className="flex items-center gap-1 text-blue-400">
              <TrendingUp size={16} />
              <span className="text-lg font-bold">{vaultStats.totalShares?.toFixed(2) || '0'}</span>
            </div>
            <p className="text-xs text-gray-400">Total Shares</p>
          </div>

          {registeredActions && registeredActions.length > 0 && (
            <div className="text-center">
              <div className="flex items-center gap-1 text-purple-400">
                <Zap size={16} />
                <span className="text-lg font-bold">{registeredActions.length}</span>
              </div>
              <p className="text-xs text-gray-400">Flow Actions</p>
            </div>
          )}
        </div>
      </div>

      <div className="mt-3 pt-3 border-t border-blue-500/20">
        <p className="text-xs text-cyan-400">
          🔵 Data source: <span className="font-mono">REAL_DATA_FROM_FLOW_TESTNET</span> • 
          Updated: {new Date().toLocaleTimeString()}
        </p>
      </div>
    </motion.div>
  );
}

