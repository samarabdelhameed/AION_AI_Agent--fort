/**
 * get_vault_stats.cdc
 * 
 * Script to retrieve comprehensive vault statistics
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import AIONVault from "../contracts/AIONVault.cdc"

access(all) struct VaultStats {
    access(all) let totalAssets: UFix64
    access(all) let totalShares: UFix64
    access(all) let pricePerShare: UFix64
    access(all) let currentStrategy: String
    access(all) let minDeposit: UFix64
    access(all) let minWithdraw: UFix64
    access(all) let isLocked: Bool
    
    init(
        _totalAssets: UFix64,
        _totalShares: UFix64,
        _pricePerShare: UFix64,
        _currentStrategy: String,
        _minDeposit: UFix64,
        _minWithdraw: UFix64,
        _isLocked: Bool
    ) {
        self.totalAssets = _totalAssets
        self.totalShares = _totalShares
        self.pricePerShare = _pricePerShare
        self.currentStrategy = _currentStrategy
        self.minDeposit = _minDeposit
        self.minWithdraw = _minWithdraw
        self.isLocked = _isLocked
    }
}

access(all) fun main(): VaultStats {
    // In Cadence 1.0, access contract state directly
    let stats = AIONVault.getVaultStats()
    
    return VaultStats(
        _totalAssets: stats["totalAssets"]!,
        _totalShares: stats["totalShares"]!,
        _pricePerShare: stats["pricePerShare"]!,
        _currentStrategy: AIONVault.currentStrategy,
        _minDeposit: stats["minDeposit"]!,
        _minWithdraw: stats["minWithdraw"]!,
        _isLocked: AIONVault.isLocked
    )
}

