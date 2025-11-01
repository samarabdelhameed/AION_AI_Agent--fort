/**
 * register_action.cdc
 * 
 * Transaction to register a new action in ActionRegistry
 * Only contract owner can register actions
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import ActionRegistry from "../contracts/ActionRegistry.cdc"

transaction(
    id: String,
    name: String,
    desc: String,
    addr: Address,
    method: String,
    schema: String,
    category: String,
    riskLevel: UInt8
) {
    
    prepare(signer: &Account) {
        // In Cadence 1.0, we call contract functions directly
    }
    
    execute {
        // Register the action
        ActionRegistry.registerAction(
            id: id,
            name: name,
            desc: desc,
            addr: addr,
            method: method,
            schema: schema,
            category: category,
            riskLevel: riskLevel
        )
        
        log("Action registered: ".concat(name))
    }
}

