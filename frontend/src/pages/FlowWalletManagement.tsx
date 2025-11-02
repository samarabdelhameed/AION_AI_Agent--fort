/**
 * Flow Wallet Management Page
 * صفحة إدارة محفظة Flow الكاملة
 */

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { 
  Wallet, CheckCircle, XCircle, ExternalLink, Copy, 
  RefreshCw, Download, Upload, Clock, TrendingUp,
  Activity, DollarSign, Zap, AlertTriangle, Info
} from 'lucide-react';
import { Page } from '../App';
import { useFlow } from '../contexts/FlowContext';

interface FlowWalletManagementProps {
  onNavigate: (page: Page) => void;
}

export function FlowWalletManagement({ onNavigate }: FlowWalletManagementProps) {
  const {
    user,
    isConnected,
    vaultStats,
    userBalance,
    loading,
    error,
    logIn,
    logOut,
    refreshData
  } = useFlow();

  const [copied, setCopied] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  const handleCopyAddress = () => {
    if (user?.addr) {
      navigator.clipboard.writeText(user.addr);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await refreshData();
    setTimeout(() => setRefreshing(false), 1000);
  };

  return (
    <div className="max-w-7xl mx-auto p-6 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-white mb-2">
            🌊 Flow Wallet Management
          </h1>
          <p className="text-gray-400">
            Manage your Flow blockchain wallet and view balances
          </p>
        </div>
        <Button
          variant="secondary"
          onClick={handleRefresh}
          disabled={refreshing}
        >
          <RefreshCw className={`w-4 h-4 ${refreshing ? 'animate-spin' : ''}`} />
          <span className="ml-2">Refresh</span>
        </Button>
      </div>

      {/* Connection Status */}
      {!isConnected ? (
        <Card className="border-2 border-blue-500/30">
          <div className="text-center py-12">
            <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-full mx-auto mb-6 flex items-center justify-center">
              <Wallet className="w-10 h-10 text-white" />
            </div>
            <h2 className="text-2xl font-bold text-white mb-3">
              Connect Your Flow Wallet
            </h2>
            <p className="text-gray-400 mb-6 max-w-md mx-auto">
              Connect your Flow wallet to access the AION DeFi platform on Flow blockchain
            </p>
            <Button
              variant="primary"
              size="lg"
              onClick={logIn}
              disabled={loading}
              className="bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600"
            >
              <Wallet className="w-5 h-5" />
              <span className="ml-2">{loading ? 'Connecting...' : 'Connect Flow Wallet'}</span>
            </Button>
            
            <div className="mt-8 p-4 bg-blue-500/10 border border-blue-500/30 rounded-xl max-w-md mx-auto">
              <p className="text-sm text-blue-300 flex items-start gap-2">
                <Info className="w-4 h-4 mt-0.5 flex-shrink-0" />
                <span>
                  Make sure you have Flow Wallet extension installed and unlocked
                </span>
              </p>
            </div>

            <div className="mt-6 space-y-2 text-sm text-gray-400">
              <p>Don't have a Flow wallet?</p>
              <a
                href="https://chrome.google.com/webstore/detail/flow-wallet/hpclkefagolihohboafpheddmmgdffjm"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-400 hover:text-blue-300 inline-flex items-center gap-1"
              >
                Get Flow Wallet Extension
                <ExternalLink className="w-3 h-3" />
              </a>
            </div>
          </div>
        </Card>
      ) : (
        <>
          {/* Wallet Info Card */}
          <Card className="border-2 border-green-500/30">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center">
                  <CheckCircle className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-white">Wallet Connected</h3>
                  <p className="text-sm text-green-400">Flow Testnet</p>
                </div>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={logOut}
              >
                Disconnect
              </Button>
            </div>

            <div className="space-y-4">
              {/* Address */}
              <div className="p-4 bg-dark-700/50 rounded-xl">
                <label className="text-xs text-gray-400 mb-2 block">Wallet Address</label>
                <div className="flex items-center justify-between gap-3">
                  <code className="text-white font-mono text-sm">
                    {user?.addr}
                  </code>
                  <div className="flex gap-2">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={handleCopyAddress}
                      className="text-xs"
                    >
                      {copied ? (
                        <>
                          <CheckCircle className="w-3 h-3" />
                          <span className="ml-1">Copied!</span>
                        </>
                      ) : (
                        <>
                          <Copy className="w-3 h-3" />
                          <span className="ml-1">Copy</span>
                        </>
                      )}
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => window.open(`https://testnet.flowdiver.io/account/${user?.addr}`, '_blank')}
                      className="text-xs"
                    >
                      <ExternalLink className="w-3 h-3" />
                      <span className="ml-1">Explorer</span>
                    </Button>
                  </div>
                </div>
              </div>

              {/* Balance */}
              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 bg-gradient-to-br from-blue-500/10 to-cyan-500/10 border border-blue-500/30 rounded-xl">
                  <label className="text-xs text-gray-400 mb-1 block">FLOW Balance</label>
                  <p className="text-2xl font-bold text-white">
                    {userBalance.toFixed(4)} <span className="text-sm text-gray-400">FLOW</span>
                  </p>
                  <p className="text-xs text-gray-400 mt-1">≈ ${(userBalance * 2.5).toFixed(2)} USD</p>
                </div>
                
                <div className="p-4 bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/30 rounded-xl">
                  <label className="text-xs text-gray-400 mb-1 block">Vault Shares</label>
                  <p className="text-2xl font-bold text-white">
                    {vaultStats?.totalShares || 0} <span className="text-sm text-gray-400">Shares</span>
                  </p>
                  <p className="text-xs text-gray-400 mt-1">≈ ${vaultStats?.totalAssets || 0} USD</p>
                </div>
              </div>
            </div>
          </Card>

          {/* Quick Actions */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Card>
              <div className="flex flex-col items-center text-center p-4">
                <div className="w-12 h-12 bg-green-500/20 rounded-full flex items-center justify-center mb-3">
                  <Download className="w-6 h-6 text-green-400" />
                </div>
                <h4 className="font-semibold text-white mb-2">Deposit</h4>
                <p className="text-xs text-gray-400 mb-4">
                  Add FLOW to earn yield
                </p>
                <Button
                  variant="primary"
                  size="sm"
                  onClick={() => onNavigate('execute')}
                  className="w-full"
                >
                  Deposit FLOW
                </Button>
              </div>
            </Card>

            <Card>
              <div className="flex flex-col items-center text-center p-4">
                <div className="w-12 h-12 bg-blue-500/20 rounded-full flex items-center justify-center mb-3">
                  <Upload className="w-6 h-6 text-blue-400" />
                </div>
                <h4 className="font-semibold text-white mb-2">Withdraw</h4>
                <p className="text-xs text-gray-400 mb-4">
                  Remove funds from vault
                </p>
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => onNavigate('execute')}
                  className="w-full"
                >
                  Withdraw FLOW
                </Button>
              </div>
            </Card>

            <Card>
              <div className="flex flex-col items-center text-center p-4">
                <div className="w-12 h-12 bg-purple-500/20 rounded-full flex items-center justify-center mb-3">
                  <Activity className="w-6 h-6 text-purple-400" />
                </div>
                <h4 className="font-semibold text-white mb-2">Activity</h4>
                <p className="text-xs text-gray-400 mb-4">
                  View transaction history
                </p>
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => onNavigate('activity-timeline')}
                  className="w-full"
                >
                  View Activity
                </Button>
              </div>
            </Card>
          </div>

          {/* Vault Stats */}
          {vaultStats && (
            <Card>
              <h3 className="text-xl font-bold text-white mb-4">Vault Statistics</h3>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="p-4 bg-dark-700/50 rounded-xl">
                  <label className="text-xs text-gray-400 mb-1 block">Total Assets</label>
                  <p className="text-lg font-semibold text-white">
                    {vaultStats.totalAssets?.toFixed(2) || '0.00'} FLOW
                  </p>
                </div>
                <div className="p-4 bg-dark-700/50 rounded-xl">
                  <label className="text-xs text-gray-400 mb-1 block">Total Shares</label>
                  <p className="text-lg font-semibold text-white">
                    {vaultStats.totalShares?.toFixed(2) || '0.00'}
                  </p>
                </div>
                <div className="p-4 bg-dark-700/50 rounded-xl">
                  <label className="text-xs text-gray-400 mb-1 block">Price Per Share</label>
                  <p className="text-lg font-semibold text-white">
                    {(vaultStats.pricePerShare / 1000000).toFixed(6) || '1.000000'}
                  </p>
                </div>
                <div className="p-4 bg-dark-700/50 rounded-xl">
                  <label className="text-xs text-gray-400 mb-1 block">Min Deposit</label>
                  <p className="text-lg font-semibold text-white">
                    {vaultStats.minDeposit || '0.001'} FLOW
                  </p>
                </div>
              </div>
            </Card>
          )}

          {/* Getting Started Guide */}
          <Card className="bg-gradient-to-br from-blue-500/5 to-cyan-500/5 border-blue-500/20">
            <h3 className="text-xl font-bold text-white mb-4 flex items-center gap-2">
              <Zap className="w-5 h-5 text-yellow-400" />
              Quick Start Guide
            </h3>
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                  <span className="text-white text-xs font-bold">1</span>
                </div>
                <div>
                  <p className="text-white font-medium">Get FLOW Testnet Tokens</p>
                  <p className="text-sm text-gray-400">
                    Visit{' '}
                    <a
                      href="https://testnet-faucet.onflow.org/"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-blue-400 hover:text-blue-300"
                    >
                      Flow Faucet
                    </a>
                    {' '}to get free testnet FLOW
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                  <span className="text-white text-xs font-bold">2</span>
                </div>
                <div>
                  <p className="text-white font-medium">Deposit to Vault</p>
                  <p className="text-sm text-gray-400">
                    Go to Execute page and deposit FLOW to start earning yield
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="w-6 h-6 bg-purple-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                  <span className="text-white text-xs font-bold">3</span>
                </div>
                <div>
                  <p className="text-white font-medium">Monitor Performance</p>
                  <p className="text-sm text-gray-400">
                    Track your earnings in real-time on the Dashboard
                  </p>
                </div>
              </div>
            </div>
          </Card>
        </>
      )}

      {/* Error Display */}
      {error && (
        <Card className="border-2 border-red-500/30 bg-red-500/5">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-red-400 flex-shrink-0 mt-0.5" />
            <div>
              <h4 className="font-semibold text-red-400 mb-1">Connection Error</h4>
              <p className="text-sm text-gray-300">{error}</p>
            </div>
          </div>
        </Card>
      )}
    </div>
  );
}

