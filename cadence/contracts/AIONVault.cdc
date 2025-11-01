/**
 * AIONVault.cdc
 * 
 * AION AI-Powered Vault on Flow Blockchain
 * Manages deposits, withdrawals, and intelligent rebalancing with full event tracking
 * 
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

access(all) contract AIONVault {

    // ========== Storage ==========
    access(all) var totalAssets: UFix64
    access(all) var totalShares: UFix64
    access(all) var sharesOf: {Address: UFix64}
    access(all) var principalOf: {Address: UFix64}
    
    // Strategy management
    access(all) var currentStrategy: String
    access(all) var strategyAllocations: {String: UFix64} // strategy name -> amount allocated
    
    // AI Agent management
    access(all) var aiAgentAddress: Address?
    access(all) var isLocked: Bool
    
    // Minimum amounts
    access(all) var minDeposit: UFix64
    access(all) var minWithdraw: UFix64
    
    // Constants
    access(all) let PRECISION: UFix64
    
    // ========== Events for Dune Analytics ==========
    
    /// Emitted when user deposits funds
    access(all) event Deposit(
        user: Address, 
        amount: UFix64, 
        shares: UFix64, 
        totalAssets: UFix64,
        pricePerShare: UFix64,
        timestamp: UFix64
    )
    
    /// Emitted when user withdraws funds
    access(all) event Withdraw(
        user: Address, 
        shares: UFix64, 
        amount: UFix64, 
        totalAssets: UFix64,
        pricePerShare: UFix64,
        timestamp: UFix64
    )
    
    /// Emitted when strategy rebalance occurs
    access(all) event Rebalance(
        executor: Address, 
        fromStrategy: String, 
        toStrategy: String, 
        amount: UFix64, 
        totalAssetsBefore: UFix64, 
        totalAssetsAfter: UFix64,
        reason: String,
        timestamp: UFix64
    )
    
    /// Emitted when AI makes a recommendation
    access(all) event StrategyRecommendation(
        aiAgent: Address, 
        recommendedStrategies: [String], 
        apys: [UFix64], 
        riskScore: UFix64, 
        metadataCID: String,
        confidence: UFix64,
        timestamp: UFix64
    )
    
    /// Emitted when yield is realized
    access(all) event YieldRealized(
        user: Address,
        strategy: String,
        amount: UFix64,
        totalYield: UFix64,
        timestamp: UFix64
    )
    
    /// Emitted when strategy allocation changes
    access(all) event StrategyAllocationUpdated(
        strategy: String,
        oldAllocation: UFix64,
        newAllocation: UFix64,
        totalAssets: UFix64,
        timestamp: UFix64
    )
    
    /// Emitted when AI agent is updated
    access(all) event AIAgentUpdated(
        oldAgent: Address?,
        newAgent: Address,
        timestamp: UFix64
    )
    
    /// Emitted when vault is locked/unlocked
    access(all) event VaultLockStatusChanged(
        isLocked: Bool,
        executor: Address,
        timestamp: UFix64
    )
    
    /// Emitted for important vault statistics
    access(all) event VaultSnapshot(
        totalAssets: UFix64,
        totalShares: UFix64,
        pricePerShare: UFix64,
        activeUsers: UInt64,
        currentStrategy: String,
        timestamp: UFix64
    )

    init() {
        self.totalAssets = 0.0
        self.totalShares = 0.0
        self.sharesOf = {}
        self.principalOf = {}
        self.currentStrategy = "none"
        self.strategyAllocations = {}
        self.aiAgentAddress = nil
        self.isLocked = false
        self.minDeposit = 0.001 // 0.001 FLOW minimum
        self.minWithdraw = 0.0001
        self.PRECISION = 1000000.0 // 1e6 for UFix64
    }

    // ========== Core Functions ==========

    /// Deposit funds into vault
    /// @param amount Amount to deposit
    /// @return shares Shares minted to user
    access(all) fun deposit(from: Address, amount: UFix64): UFix64 {
        pre {
            amount >= self.minDeposit: "Amount below minimum deposit"
            !self.isLocked: "Vault is locked"
        }
        
        let user = from
        
        // Calculate shares to mint
        let shares = self.calculateSharesForDeposit(amount: amount)
        
        // Update user balances
        if self.sharesOf[user] == nil {
            self.sharesOf[user] = shares
            self.principalOf[user] = amount
        } else {
            self.sharesOf[user] = self.sharesOf[user]! + shares
            self.principalOf[user] = self.principalOf[user]! + amount
        }
        
        // Update totals
        self.totalShares = self.totalShares + shares
        self.totalAssets = self.totalAssets + amount
        
        let pricePerShare = self.getPricePerShare()
        
        // Emit event
        emit Deposit(
            user: user,
            amount: amount,
            shares: shares,
            totalAssets: self.totalAssets,
            pricePerShare: pricePerShare,
            timestamp: getCurrentBlock().timestamp
        )
        
        return shares
    }

    /// Withdraw funds from vault
    /// @param shares Number of shares to burn
    /// @return amount Amount withdrawn
    access(all) fun withdraw(from: Address, shares: UFix64): UFix64 {
        pre {
            shares > 0.0: "Invalid shares amount"
            !self.isLocked: "Vault is locked"
        }
        
        let user = from
        let userShares = self.sharesOf[user] ?? panic("No shares found")
        
        assert(userShares >= shares, message: "Insufficient shares")
        
        // Calculate amount to withdraw
        let amount = self.calculateAssetsForShares(shares: shares)
        
        assert(amount >= self.minWithdraw, message: "Amount below minimum withdrawal")
        
        // Update user balances
        self.sharesOf[user] = userShares - shares
        
        // Update principal proportionally
        if self.sharesOf[user]! == 0.0 {
            self.principalOf[user] = 0.0
        } else {
            let principalReduction = (self.principalOf[user]! * shares) / userShares
            self.principalOf[user] = self.principalOf[user]! - principalReduction
        }
        
        // Update totals
        self.totalShares = self.totalShares - shares
        self.totalAssets = self.totalAssets - amount
        
        let pricePerShare = self.getPricePerShare()
        
        // Emit event
        emit Withdraw(
            user: user,
            shares: shares,
            amount: amount,
            totalAssets: self.totalAssets,
            pricePerShare: pricePerShare,
            timestamp: getCurrentBlock().timestamp
        )
        
        return amount
    }

    /// Rebalance funds between strategies (AI Agent only)
    /// @param executor Address executing the rebalance
    /// @param fromStrategy Source strategy
    /// @param toStrategy Target strategy
    /// @param amount Amount to rebalance
    /// @param reason Reason for rebalance
    access(all) fun rebalance(
        executor: Address, 
        fromStrategy: String, 
        toStrategy: String, 
        amount: UFix64,
        reason: String
    ) {
        pre {
            self.aiAgentAddress != nil: "AI Agent not set"
            executor == self.aiAgentAddress!: "Only AI Agent can rebalance"
            !self.isLocked: "Vault is locked"
            amount > 0.0: "Invalid amount"
        }
        
        let totalAssetsBefore = self.totalAssets
        
        // Update allocations
        let fromAllocation = self.strategyAllocations[fromStrategy] ?? 0.0
        assert(fromAllocation >= amount, message: "Insufficient allocation in source strategy")
        
        self.strategyAllocations[fromStrategy] = fromAllocation - amount
        
        let toAllocation = self.strategyAllocations[toStrategy] ?? 0.0
        self.strategyAllocations[toStrategy] = toAllocation + amount
        
        // Update current strategy if needed
        if amount == fromAllocation && toStrategy != fromStrategy {
            self.currentStrategy = toStrategy
        }
        
        let totalAssetsAfter = self.totalAssets
        
        // Emit rebalance event
        emit Rebalance(
            executor: executor,
            fromStrategy: fromStrategy,
            toStrategy: toStrategy,
            amount: amount,
            totalAssetsBefore: totalAssetsBefore,
            totalAssetsAfter: totalAssetsAfter,
            reason: reason,
            timestamp: getCurrentBlock().timestamp
        )
        
        // Emit allocation updates
        emit StrategyAllocationUpdated(
            strategy: fromStrategy,
            oldAllocation: fromAllocation,
            newAllocation: self.strategyAllocations[fromStrategy]!,
            totalAssets: self.totalAssets,
            timestamp: getCurrentBlock().timestamp
        )
        
        emit StrategyAllocationUpdated(
            strategy: toStrategy,
            oldAllocation: toAllocation,
            newAllocation: self.strategyAllocations[toStrategy]!,
            totalAssets: self.totalAssets,
            timestamp: getCurrentBlock().timestamp
        )
    }

    /// Post AI recommendation (AI Agent only)
    /// @param aiAgent AI agent address
    /// @param strategies Recommended strategies
    /// @param apys Expected APYs for each strategy
    /// @param riskScore Overall risk score
    /// @param metadataCID IPFS CID with detailed analysis
    /// @param confidence AI confidence level (0-100)
    access(all) fun postRecommendation(
        aiAgent: Address, 
        strategies: [String], 
        apys: [UFix64], 
        riskScore: UFix64,
        metadataCID: String,
        confidence: UFix64
    ) {
        pre {
            self.aiAgentAddress != nil: "AI Agent not set"
            aiAgent == self.aiAgentAddress!: "Only AI Agent can post recommendations"
            strategies.length == apys.length: "Strategies and APYs length mismatch"
            confidence <= 100.0: "Confidence must be <= 100"
        }
        
        emit StrategyRecommendation(
            aiAgent: aiAgent,
            recommendedStrategies: strategies,
            apys: apys,
            riskScore: riskScore,
            metadataCID: metadataCID,
            confidence: confidence,
            timestamp: getCurrentBlock().timestamp
        )
    }

    /// Record yield realization for user
    /// @param user User address
    /// @param strategy Strategy that generated yield
    /// @param amount Yield amount
    access(all) fun recordYield(user: Address, strategy: String, amount: UFix64) {
        let userPrincipal = self.principalOf[user] ?? 0.0
        let userShares = self.sharesOf[user] ?? 0.0
        let currentValue = self.calculateAssetsForShares(shares: userShares)
        let totalYield = currentValue > userPrincipal ? currentValue - userPrincipal : 0.0
        
        emit YieldRealized(
            user: user,
            strategy: strategy,
            amount: amount,
            totalYield: totalYield,
            timestamp: getCurrentBlock().timestamp
        )
    }

    // ========== Admin Functions ==========

    /// Set AI Agent address
    /// @param newAgent New AI agent address
    access(all) fun setAIAgent(newAgent: Address) {
        let oldAgent = self.aiAgentAddress
        self.aiAgentAddress = newAgent
        
        emit AIAgentUpdated(
            oldAgent: oldAgent,
            newAgent: newAgent,
            timestamp: getCurrentBlock().timestamp
        )
    }

    /// Lock/unlock vault
    /// @param locked Lock status
    /// @param executor Address executing the lock
    access(all) fun setLockStatus(locked: Bool, executor: Address) {
        self.isLocked = locked
        
        emit VaultLockStatusChanged(
            isLocked: locked,
            executor: executor,
            timestamp: getCurrentBlock().timestamp
        )
    }

    /// Take vault snapshot for analytics
    access(all) fun takeSnapshot(activeUsers: UInt64) {
        emit VaultSnapshot(
            totalAssets: self.totalAssets,
            totalShares: self.totalShares,
            pricePerShare: self.getPricePerShare(),
            activeUsers: activeUsers,
            currentStrategy: self.currentStrategy,
            timestamp: getCurrentBlock().timestamp
        )
    }

    // ========== View Functions ==========

    /// Calculate shares for deposit amount
    /// @param amount Deposit amount
    /// @return shares Number of shares to mint
    access(all) fun calculateSharesForDeposit(amount: UFix64): UFix64 {
        if self.totalShares == 0.0 || self.totalAssets == 0.0 {
            return amount
        }
        return (amount * self.totalShares) / self.totalAssets
    }

    /// Calculate assets for shares amount
    /// @param shares Number of shares
    /// @return amount Asset amount
    access(all) fun calculateAssetsForShares(shares: UFix64): UFix64 {
        if self.totalShares == 0.0 {
            return 0.0
        }
        return (shares * self.totalAssets) / self.totalShares
    }

    /// Get price per share
    /// @return price Price per share
    access(all) fun getPricePerShare(): UFix64 {
        if self.totalShares == 0.0 {
            return self.PRECISION
        }
        return (self.totalAssets * self.PRECISION) / self.totalShares
    }

    /// Get user balance (shares)
    /// @param user User address
    /// @return shares User's share balance
    access(all) fun balanceOf(user: Address): UFix64 {
        return self.sharesOf[user] ?? 0.0
    }

    /// Get user's asset value
    /// @param user User address
    /// @return value User's current asset value
    access(all) fun valueOf(user: Address): UFix64 {
        let shares = self.sharesOf[user] ?? 0.0
        return self.calculateAssetsForShares(shares: shares)
    }

    /// Get user's unrealized profit/loss
    /// @param user User address
    /// @return profit Unrealized profit (can be negative)
    access(all) fun getUnrealizedProfit(user: Address): Fix64 {
        let principal = self.principalOf[user] ?? 0.0
        let currentValue = self.valueOf(user: user)
        
        // Convert UFix64 to Fix64 for signed math
        let principalSigned = Fix64(principal)
        let valueSigned = Fix64(currentValue)
        
        return valueSigned - principalSigned
    }

    /// Get strategy allocation
    /// @param strategy Strategy name
    /// @return allocation Amount allocated to strategy
    access(all) fun getStrategyAllocation(strategy: String): UFix64 {
        return self.strategyAllocations[strategy] ?? 0.0
    }

    /// Get all strategy allocations
    /// @return allocations Dictionary of all allocations
    access(all) fun getAllAllocations(): {String: UFix64} {
        return self.strategyAllocations
    }

    /// Get vault statistics
    /// @return stats Dictionary with vault stats
    access(all) fun getVaultStats(): {String: UFix64} {
        return {
            "totalAssets": self.totalAssets,
            "totalShares": self.totalShares,
            "pricePerShare": self.getPricePerShare(),
            "minDeposit": self.minDeposit,
            "minWithdraw": self.minWithdraw
        }
    }
}

