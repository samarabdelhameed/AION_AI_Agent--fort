/**
 * ActionRegistry.cdc
 * 
 * Flow Actions Registry - Registers and manages all available Actions for execution
 * Compatible with FLIP-338 Flow Actions standard
 * 
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

access(all) contract ActionRegistry {

    // Action metadata resource
    access(all) struct ActionMeta {
        access(all) let id: String
        access(all) let name: String
        access(all) let description: String
        access(all) let contractAddress: Address
        access(all) let method: String
        access(all) let schema: String // JSON schema for payload
        access(all) let category: String // "rebalance", "claim", "optimize"
        access(all) let riskLevel: UInt8 // 1-10 risk rating
        
        init(
            _id: String, 
            _name: String, 
            _desc: String, 
            _addr: Address, 
            _method: String, 
            _schema: String,
            _category: String,
            _riskLevel: UInt8
        ) {
            self.id = _id
            self.name = _name
            self.description = _desc
            self.contractAddress = _addr
            self.method = _method
            self.schema = _schema
            self.category = _category
            self.riskLevel = _riskLevel
        }
    }

    // Action execution log entry
    access(all) struct ActionLog {
        access(all) let actionId: String
        access(all) let executor: Address
        access(all) let timestamp: UFix64
        access(all) let success: Bool
        access(all) let payload: String
        access(all) let gasUsed: UInt64
        
        init(
            _actionId: String,
            _executor: Address,
            _timestamp: UFix64,
            _success: Bool,
            _payload: String,
            _gasUsed: UInt64
        ) {
            self.actionId = _actionId
            self.executor = _executor
            self.timestamp = _timestamp
            self.success = _success
            self.payload = _payload
            self.gasUsed = _gasUsed
        }
    }

    // Storage
    access(all) var actions: {String: ActionMeta}
    access(all) var executionLogs: [ActionLog]
    access(all) var totalExecutions: UInt64
    access(all) var successfulExecutions: UInt64
    
    // Admin control
    access(account) var adminAddress: Address

    // Events for Dune Analytics tracking
    access(all) event ActionRegistered(
        id: String, 
        name: String, 
        contractAddress: Address, 
        method: String,
        category: String,
        riskLevel: UInt8,
        timestamp: UFix64
    )
    
    access(all) event ActionExecuted(
        id: String, 
        executor: Address, 
        payload: String, 
        success: Bool,
        gasUsed: UInt64,
        timestamp: UFix64
    )
    
    access(all) event ActionFailed(
        id: String,
        executor: Address,
        reason: String,
        timestamp: UFix64
    )
    
    access(all) event ActionUpdated(
        id: String,
        newName: String,
        timestamp: UFix64
    )

    init() {
        self.actions = {}
        self.executionLogs = []
        self.totalExecutions = 0
        self.successfulExecutions = 0
        self.adminAddress = self.account.address
    }

    /// Register a new action (admin only)
    /// @param id Unique action identifier
    /// @param name Human-readable action name
    /// @param desc Action description
    /// @param addr Contract address where action is implemented
    /// @param method Function name to call
    /// @param schema JSON schema for action parameters
    /// @param category Action category (rebalance, claim, optimize)
    /// @param riskLevel Risk rating 1-10
    access(all) fun registerAction(
        id: String, 
        name: String, 
        desc: String, 
        addr: Address, 
        method: String, 
        schema: String,
        category: String,
        riskLevel: UInt8
    ) {
        pre {
            self.actions[id] == nil: "Action already registered"
            riskLevel >= 1 && riskLevel <= 10: "Risk level must be 1-10"
        }
        
        let meta = ActionMeta(
            _id: id, 
            _name: name, 
            _desc: desc, 
            _addr: addr, 
            _method: method, 
            _schema: schema,
            _category: category,
            _riskLevel: riskLevel
        )
        
        self.actions[id] = meta
        
        emit ActionRegistered(
            id: id, 
            name: name, 
            contractAddress: addr, 
            method: method,
            category: category,
            riskLevel: riskLevel,
            timestamp: getCurrentBlock().timestamp
        )
    }

    /// Log action execution (called by executor or contract)
    /// @param id Action ID
    /// @param executor Address that executed the action
    /// @param payload Execution parameters (JSON string)
    /// @param success Whether execution succeeded
    /// @param gasUsed Gas consumed by execution
    access(all) fun logExecution(
        id: String, 
        executor: Address, 
        payload: String, 
        success: Bool,
        gasUsed: UInt64
    ) {
        pre {
            self.actions[id] != nil: "Action not registered"
        }
        
        let executionLog = ActionLog(
            _actionId: id,
            _executor: executor,
            _timestamp: getCurrentBlock().timestamp,
            _success: success,
            _payload: payload,
            _gasUsed: gasUsed
        )
        
        self.executionLogs.append(executionLog)
        self.totalExecutions = self.totalExecutions + 1
        
        if success {
            self.successfulExecutions = self.successfulExecutions + 1
        }
        
        emit ActionExecuted(
            id: id, 
            executor: executor, 
            payload: payload, 
            success: success,
            gasUsed: gasUsed,
            timestamp: getCurrentBlock().timestamp
        )
    }

    /// Get action metadata by ID
    /// @param id Action identifier
    /// @return ActionMeta or nil if not found
    access(all) fun getAction(id: String): ActionMeta? {
        return self.actions[id]
    }

    /// Get all registered actions
    /// @return Dictionary of all actions
    access(all) fun getAllActions(): {String: ActionMeta} {
        return self.actions
    }

    /// Get execution logs (last N entries)
    /// @param count Number of logs to retrieve
    /// @return Array of execution logs
    access(all) fun getRecentExecutions(count: Int): [ActionLog] {
        let totalLogs = self.executionLogs.length
        if totalLogs == 0 {
            return []
        }
        
        let startIdx = totalLogs > count ? totalLogs - count : 0
        return self.executionLogs.slice(from: startIdx, upTo: totalLogs)
    }

    /// Get execution statistics
    /// @return total Total executions
    /// @return successful Successful executions
    /// @return successRate Success rate (0-100)
    access(all) fun getStats(): {String: UInt64} {
        let successRate: UInt64 = self.totalExecutions > 0 
            ? (self.successfulExecutions * 100) / self.totalExecutions
            : 0
            
        return {
            "total": self.totalExecutions,
            "successful": self.successfulExecutions,
            "failed": self.totalExecutions - self.successfulExecutions,
            "successRate": successRate
        }
    }

    /// Check if action exists
    /// @param id Action identifier
    /// @return True if action is registered
    access(all) fun actionExists(id: String): Bool {
        return self.actions[id] != nil
    }

    /// Get actions by category
    /// @param category Category filter
    /// @return Array of matching actions
    access(all) fun getActionsByCategory(category: String): [ActionMeta] {
        let result: [ActionMeta] = []
        for actionId in self.actions.keys {
            let action = self.actions[actionId]!
            if action.category == category {
                result.append(action)
            }
        }
        return result
    }

    /// Update action metadata (admin only)
    /// @param id Action ID to update
    /// @param newName New action name
    /// @param newDesc New description
    access(all) fun updateAction(id: String, newName: String, newDesc: String) {
        pre {
            self.actions[id] != nil: "Action not found"
        }
        
        let oldAction = self.actions[id]!
        let updatedAction = ActionMeta(
            _id: id,
            _name: newName,
            _desc: newDesc,
            _addr: oldAction.contractAddress,
            _method: oldAction.method,
            _schema: oldAction.schema,
            _category: oldAction.category,
            _riskLevel: oldAction.riskLevel
        )
        
        self.actions[id] = updatedAction
        
        emit ActionUpdated(
            id: id,
            newName: newName,
            timestamp: getCurrentBlock().timestamp
        )
    }
}

