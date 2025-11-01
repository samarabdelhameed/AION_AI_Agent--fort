/**
 * get_balance.cdc
 * 
 * Script to get user balance and shares in the vault
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import AIONVault from "../contracts/AIONVault.cdc"

access(all) struct UserBalance {
    access(all) let address: Address
    access(all) let shares: UFix64
    access(all) let assetValue: UFix64
    access(all) let principal: UFix64
    access(all) let unrealizedProfit: Fix64
    access(all) let pricePerShare: UFix64
    
    init(
        _address: Address,
        _shares: UFix64,
        _assetValue: UFix64,
        _principal: UFix64,
        _unrealizedProfit: Fix64,
        _pricePerShare: UFix64
    ) {
        self.address = _address
        self.shares = _shares
        self.assetValue = _assetValue
        self.principal = _principal
        self.unrealizedProfit = _unrealizedProfit
        self.pricePerShare = _pricePerShare
    }
}

access(all) fun main(userAddress: Address): UserBalance {
    // Get user shares
    let shares = AIONVault.balanceOf(user: userAddress)
    
    // Get asset value
    let assetValue = AIONVault.valueOf(user: userAddress)
    
    // Get principal
    let principal = AIONVault.principalOf[userAddress] ?? 0.0
    
    // Get unrealized profit
    let unrealizedProfit = AIONVault.getUnrealizedProfit(user: userAddress)
    
    // Get price per share
    let pricePerShare = AIONVault.getPricePerShare()
    
    return UserBalance(
        _address: userAddress,
        _shares: shares,
        _assetValue: assetValue,
        _principal: principal,
        _unrealizedProfit: unrealizedProfit,
        _pricePerShare: pricePerShare
    )
}

