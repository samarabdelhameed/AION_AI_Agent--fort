/**
 * Flow-Specific DeFi Strategies
 * استراتيجيات DeFi خاصة بـ Flow
 */

export interface FlowStrategy {
  id: string;
  name: string;
  protocol: string;
  apy: number;
  tvl: number;
  riskLevel: number;
  riskCategory: 'low' | 'medium' | 'high';
  network: 'flow';
  type: 'lending' | 'staking' | 'liquidity' | 'yield';
  description: string;
  icon: string;
  contractAddress: string;
  isLive: boolean;
  features: string[];
}

export const flowStrategies: FlowStrategy[] = [
  {
    id: 'flow-staking',
    name: 'Flow Staking',
    protocol: 'Flow Network',
    apy: 8.5,
    tvl: 15000000,
    riskLevel: 2,
    riskCategory: 'low',
    network: 'flow',
    type: 'staking',
    description: 'Stake FLOW tokens directly on Flow network validators',
    icon: '🌊',
    contractAddress: '0xc7a34c80e6f3235b',
    isLive: true,
    features: [
      'Native staking',
      'Validator selection',
      'Auto-compounding',
      'No lock-up period'
    ]
  },
  {
    id: 'increment-fi',
    name: 'Increment Finance',
    protocol: 'Increment',
    apy: 12.3,
    tvl: 8500000,
    riskLevel: 3,
    riskCategory: 'medium',
    network: 'flow',
    type: 'lending',
    description: 'Lending and borrowing protocol on Flow',
    icon: '📈',
    contractAddress: '0x1234567890abcdef',
    isLive: true,
    features: [
      'Supply FLOW',
      'Borrow assets',
      'Liquidation protection',
      'Variable APY'
    ]
  },
  {
    id: 'flowswap',
    name: 'FlowSwap LP',
    protocol: 'FlowSwap',
    apy: 15.7,
    tvl: 12000000,
    riskLevel: 4,
    riskCategory: 'medium',
    network: 'flow',
    type: 'liquidity',
    description: 'Provide liquidity on FlowSwap DEX',
    icon: '💱',
    contractAddress: '0xabcdef1234567890',
    isLive: true,
    features: [
      'LP token rewards',
      'Trading fees',
      'Impermanent loss protection',
      'Multiple pairs'
    ]
  },
  {
    id: 'blocto-swap',
    name: 'Blocto Swap Yield',
    protocol: 'Blocto',
    apy: 11.2,
    tvl: 6500000,
    riskLevel: 3,
    riskCategory: 'medium',
    network: 'flow',
    type: 'yield',
    description: 'Yield farming on Blocto Swap',
    icon: '🌾',
    contractAddress: '0x9876543210fedcba',
    isLive: true,
    features: [
      'Auto-harvest',
      'Compound rewards',
      'Low fees',
      'Mobile-friendly'
    ]
  },
  {
    id: 'flow-nft-staking',
    name: 'NFT Staking Vault',
    protocol: 'AION Flow',
    apy: 18.5,
    tvl: 3500000,
    riskLevel: 5,
    riskCategory: 'high',
    network: 'flow',
    type: 'staking',
    description: 'Stake Flow NFTs to earn FLOW rewards',
    icon: '🎨',
    contractAddress: '0xfedcba9876543210',
    isLive: false,
    features: [
      'NFT staking',
      'Rarity multipliers',
      'Collection bonuses',
      'Daily rewards'
    ]
  },
  {
    id: 'flow-defi-aggregator',
    name: 'Flow DeFi Aggregator',
    protocol: 'AION',
    apy: 14.8,
    tvl: 25000000,
    riskLevel: 3,
    riskCategory: 'medium',
    network: 'flow',
    type: 'yield',
    description: 'Auto-optimize across multiple Flow DeFi protocols',
    icon: '⚡',
    contractAddress: '0xc7a34c80e6f3235b',
    isLive: true,
    features: [
      'Auto-optimization',
      'Multi-protocol',
      'Gas optimization',
      'Real-time rebalancing'
    ]
  }
];

export const getFlowStrategyById = (id: string): FlowStrategy | undefined => {
  return flowStrategies.find(s => s.id === id);
};

export const getActiveFlowStrategies = (): FlowStrategy[] => {
  return flowStrategies.filter(s => s.isLive);
};

export const getFlowStrategiesByType = (type: FlowStrategy['type']): FlowStrategy[] => {
  return flowStrategies.filter(s => s.type === type);
};

export const getFlowStrategiesByRisk = (risk: FlowStrategy['riskCategory']): FlowStrategy[] => {
  return flowStrategies.filter(s => s.riskCategory === risk);
};

export const getTotalFlowTVL = (): number => {
  return flowStrategies.reduce((sum, strategy) => sum + strategy.tvl, 0);
};

export const getAverageFlowAPY = (): number => {
  const activeStrategies = getActiveFlowStrategies();
  if (activeStrategies.length === 0) return 0;
  const totalAPY = activeStrategies.reduce((sum, strategy) => sum + strategy.apy, 0);
  return totalAPY / activeStrategies.length;
};

