/**
 * Flow Wallet Button - Connect to Flow Testnet
 * Keeps same UI style, adds Flow functionality
 */

import React from 'react';
import { motion } from 'framer-motion';
import { Wallet, CheckCircle, Loader2 } from 'lucide-react';
import { useFlow } from '../../contexts/FlowContext';
import { Button } from '../ui/Button';

interface FlowWalletButtonProps {
  className?: string;
  showLabel?: boolean;
}

export function FlowWalletButton({ className = '', showLabel = true }: FlowWalletButtonProps) {
  const { user, isConnected, logIn, logOut, loading } = useFlow();

  const handleClick = async () => {
    if (isConnected) {
      await logOut();
    } else {
      await logIn();
    }
  };

  if (loading) {
    return (
      <Button
        variant="secondary"
        size="sm"
        className={className}
        disabled
      >
        <Loader2 className="w-4 h-4 animate-spin" />
        {showLabel && <span className="ml-2">Connecting...</span>}
      </Button>
    );
  }

  if (isConnected && user?.addr) {
    return (
      <motion.button
        onClick={handleClick}
        className={`flex items-center gap-2 px-4 py-2 bg-green-500/20 border border-green-500/30 rounded-lg hover:bg-green-500/30 transition-all ${className}`}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
      >
        <CheckCircle className="w-4 h-4 text-green-400" />
        {showLabel && (
          <span className="text-green-400 font-medium text-sm">
            {user.addr.slice(0, 6)}...{user.addr.slice(-4)}
          </span>
        )}
      </motion.button>
    );
  }

  return (
    <Button
      variant="primary"
      size="sm"
      className={`${className} bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600`}
      onClick={handleClick}
    >
      <Wallet className="w-4 h-4" />
      {showLabel && <span className="ml-2">Connect Flow</span>}
    </Button>
  );
}

