/**
 * rebalance.cdc
 * 
 * Transaction to rebalance funds between strategies
 * Only callable by AI Agent
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import AIONVault from "../contracts/AIONVault.cdc"
import ActionRegistry from "../contracts/ActionRegistry.cdc"

transaction(
    fromStrategy: String,
    toStrategy: String,
    amount: UFix64,
    reason: String
) {
    
    let executorAddress: Address
    
    prepare(signer: &Account) {
        self.executorAddress = signer.address
    }
    
    execute {
        // Execute rebalance
        AIONVault.rebalance(
            executor: self.executorAddress,
            fromStrategy: fromStrategy,
            toStrategy: toStrategy,
            amount: amount,
            reason: reason
        )
        
        // Log action execution in registry
        let payload = "{"
            .concat("\"from\":\"").concat(fromStrategy).concat("\",")
            .concat("\"to\":\"").concat(toStrategy).concat("\",")
            .concat("\"amount\":\"").concat(amount.toString()).concat("\",")
            .concat("\"reason\":\"").concat(reason).concat("\"")
            .concat("}")
        
        ActionRegistry.logExecution(
            id: "rebalance",
            executor: self.executorAddress,
            payload: payload,
            success: true,
            gasUsed: 0
        )
        
        log("Rebalanced ".concat(amount.toString()).concat(" from ").concat(fromStrategy).concat(" to ").concat(toStrategy))
    }
}

