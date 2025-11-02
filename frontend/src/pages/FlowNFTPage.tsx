/**
 * Flow NFT Integration Page
 * صفحة NFTs على Flow
 */

import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import {
  Image, TrendingUp, Zap, ExternalLink, Star,
  Award, Lock, Unlock, Clock, DollarSign
} from 'lucide-react';
import { Page } from '../App';
import { useFlow } from '../contexts/FlowContext';

interface FlowNFTPageProps {
  onNavigate: (page: Page) => void;
}

interface NFTCollection {
  id: string;
  name: string;
  description: string;
  image: string;
  floorPrice: number;
  volume24h: number;
  owners: number;
  items: number;
  stakingAPY?: number;
  canStake: boolean;
}

const mockCollections: NFTCollection[] = [
  {
    id: 'flovatar',
    name: 'Flovatars',
    description: 'Unique avatars on Flow blockchain',
    image: '🎭',
    floorPrice: 25.5,
    volume24h: 1250,
    owners: 3420,
    items: 10000,
    stakingAPY: 12.5,
    canStake: true
  },
  {
    id: 'nba-topshot',
    name: 'NBA Top Shot',
    description: 'Official NBA collectibles',
    image: '🏀',
    floorPrice: 15.0,
    volume24h: 5600,
    owners: 12500,
    items: 50000,
    stakingAPY: 8.2,
    canStake: true
  },
  {
    id: 'versus',
    name: 'VersusNFT Art',
    description: 'Curated digital art marketplace',
    image: '🎨',
    floorPrice: 50.0,
    volume24h: 2100,
    owners: 856,
    items: 2500,
    stakingAPY: 15.8,
    canStake: true
  },
  {
    id: 'evolution',
    name: 'Evolution',
    description: 'Evolving NFT collectibles',
    image: '🦎',
    floorPrice: 8.5,
    volume24h: 890,
    owners: 4100,
    items: 8888,
    stakingAPY: 10.5,
    canStake: false
  }
];

export function FlowNFTPage({ onNavigate }: FlowNFTPageProps) {
  const { isConnected, user } = useFlow();
  const [selectedCollection, setSelectedCollection] = useState<string | null>(null);
  const [view, setView] = useState<'collections' | 'staking'>('collections');

  return (
    <div className="max-w-7xl mx-auto p-6 space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-white mb-2">
          🎨 Flow NFT Marketplace
        </h1>
        <p className="text-gray-400">
          Explore, trade, and stake NFTs on Flow blockchain
        </p>
      </div>

      {/* View Selector */}
      <div className="flex gap-2">
        <Button
          variant={view === 'collections' ? 'primary' : 'secondary'}
          onClick={() => setView('collections')}
        >
          <Image className="w-4 h-4" />
          <span className="ml-2">Collections</span>
        </Button>
        <Button
          variant={view === 'staking' ? 'primary' : 'secondary'}
          onClick={() => setView('staking')}
        >
          <Zap className="w-4 h-4" />
          <span className="ml-2">NFT Staking</span>
        </Button>
      </div>

      {/* Collections View */}
      {view === 'collections' && (
        <>
          {/* Stats Banner */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <Card className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 border-purple-500/30">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-purple-500/20 rounded-lg flex items-center justify-center">
                  <TrendingUp className="w-5 h-5 text-purple-400" />
                </div>
                <div>
                  <p className="text-xs text-gray-400">Total Volume</p>
                  <p className="text-lg font-bold text-white">
                    {mockCollections.reduce((sum, c) => sum + c.volume24h, 0).toLocaleString()} FLOW
                  </p>
                </div>
              </div>
            </Card>

            <Card className="bg-gradient-to-br from-blue-500/10 to-cyan-500/10 border-blue-500/30">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-500/20 rounded-lg flex items-center justify-center">
                  <Image className="w-5 h-5 text-blue-400" />
                </div>
                <div>
                  <p className="text-xs text-gray-400">Collections</p>
                  <p className="text-lg font-bold text-white">{mockCollections.length}</p>
                </div>
              </div>
            </Card>

            <Card className="bg-gradient-to-br from-green-500/10 to-emerald-500/10 border-green-500/30">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-green-500/20 rounded-lg flex items-center justify-center">
                  <DollarSign className="w-5 h-5 text-green-400" />
                </div>
                <div>
                  <p className="text-xs text-gray-400">Avg Floor</p>
                  <p className="text-lg font-bold text-white">
                    {(mockCollections.reduce((sum, c) => sum + c.floorPrice, 0) / mockCollections.length).toFixed(1)} FLOW
                  </p>
                </div>
              </div>
            </Card>

            <Card className="bg-gradient-to-br from-yellow-500/10 to-orange-500/10 border-yellow-500/30">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-yellow-500/20 rounded-lg flex items-center justify-center">
                  <Star className="w-5 h-5 text-yellow-400" />
                </div>
                <div>
                  <p className="text-xs text-gray-400">Stakeable</p>
                  <p className="text-lg font-bold text-white">
                    {mockCollections.filter(c => c.canStake).length}
                  </p>
                </div>
              </div>
            </Card>
          </div>

          {/* Collections Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {mockCollections.map((collection) => (
              <motion.div
                key={collection.id}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <Card className="cursor-pointer hover:border-gold-500/50 transition-all">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <div className="w-16 h-16 bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-xl flex items-center justify-center text-4xl">
                        {collection.image}
                      </div>
                      <div>
                        <h3 className="font-bold text-white">{collection.name}</h3>
                        <p className="text-xs text-gray-400">{collection.items.toLocaleString()} items</p>
                      </div>
                    </div>
                    {collection.canStake && (
                      <div className="px-2 py-1 bg-green-500/20 border border-green-500/30 rounded text-xs text-green-400">
                        Stakeable
                      </div>
                    )}
                  </div>

                  <p className="text-sm text-gray-400 mb-4">{collection.description}</p>

                  <div className="grid grid-cols-2 gap-3 mb-4">
                    <div className="p-2 bg-dark-700/50 rounded">
                      <p className="text-xs text-gray-400">Floor</p>
                      <p className="text-sm font-semibold text-white">{collection.floorPrice} FLOW</p>
                    </div>
                    <div className="p-2 bg-dark-700/50 rounded">
                      <p className="text-xs text-gray-400">24h Vol</p>
                      <p className="text-sm font-semibold text-white">{collection.volume24h} FLOW</p>
                    </div>
                  </div>

                  {collection.stakingAPY && (
                    <div className="p-3 bg-gradient-to-r from-gold-500/10 to-yellow-500/10 border border-gold-500/30 rounded-xl mb-3">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <Zap className="w-4 h-4 text-gold-400" />
                          <span className="text-sm text-white">Staking APY</span>
                        </div>
                        <span className="text-lg font-bold text-gold-400">
                          {collection.stakingAPY}%
                        </span>
                      </div>
                    </div>
                  )}

                  <div className="flex gap-2">
                    <Button
                      variant="primary"
                      size="sm"
                      className="flex-1"
                      onClick={() => window.open(`https://nft.flowverse.co/collection/${collection.id}`, '_blank')}
                    >
                      <ExternalLink className="w-3 h-3" />
                      <span className="ml-1">View</span>
                    </Button>
                    {collection.canStake && (
                      <Button
                        variant="secondary"
                        size="sm"
                        className="flex-1"
                        onClick={() => {
                          setSelectedCollection(collection.id);
                          setView('staking');
                        }}
                      >
                        <Lock className="w-3 h-3" />
                        <span className="ml-1">Stake</span>
                      </Button>
                    )}
                  </div>
                </Card>
              </motion.div>
            ))}
          </div>
        </>
      )}

      {/* Staking View */}
      {view === 'staking' && (
        <div className="space-y-6">
          {!isConnected ? (
            <Card className="border-2 border-blue-500/30">
              <div className="text-center py-12">
                <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-full mx-auto mb-6 flex items-center justify-center">
                  <Lock className="w-10 h-10 text-white" />
                </div>
                <h2 className="text-2xl font-bold text-white mb-3">
                  Connect Wallet to Stake NFTs
                </h2>
                <p className="text-gray-400 mb-6 max-w-md mx-auto">
                  Connect your Flow wallet to start staking your NFTs and earn rewards
                </p>
                <Button
                  variant="primary"
                  size="lg"
                  onClick={() => onNavigate('dashboard')}
                >
                  Connect Wallet
                </Button>
              </div>
            </Card>
          ) : (
            <>
              <Card className="bg-gradient-to-br from-gold-500/5 to-yellow-500/5 border-gold-500/30">
                <div className="flex items-center gap-4 mb-6">
                  <div className="w-12 h-12 bg-gold-500/20 rounded-lg flex items-center justify-center">
                    <Award className="w-6 h-6 text-gold-400" />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-white">NFT Staking Rewards</h2>
                    <p className="text-sm text-gray-400">Earn FLOW by staking your NFTs</p>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="p-4 bg-dark-700/50 rounded-xl">
                    <p className="text-xs text-gray-400 mb-1">Staked NFTs</p>
                    <p className="text-2xl font-bold text-white">0</p>
                  </div>
                  <div className="p-4 bg-dark-700/50 rounded-xl">
                    <p className="text-xs text-gray-400 mb-1">Total Rewards</p>
                    <p className="text-2xl font-bold text-white">0 <span className="text-sm text-gray-400">FLOW</span></p>
                  </div>
                  <div className="p-4 bg-dark-700/50 rounded-xl">
                    <p className="text-xs text-gray-400 mb-1">Avg APY</p>
                    <p className="text-2xl font-bold text-gold-400">12.5%</p>
                  </div>
                </div>
              </Card>

              <Card>
                <h3 className="text-lg font-bold text-white mb-4">Your NFTs</h3>
                <div className="text-center py-12 text-gray-400">
                  <Image className="w-16 h-16 mx-auto mb-4 opacity-50" />
                  <p>No NFTs found in your wallet</p>
                  <p className="text-sm mt-2">Get some Flow NFTs to start staking</p>
                </div>
              </Card>
            </>
          )}
        </div>
      )}
    </div>
  );
}

