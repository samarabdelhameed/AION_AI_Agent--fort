/**
 * get_actions.cdc
 * 
 * Script to retrieve all registered actions from ActionRegistry
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import ActionRegistry from "../contracts/ActionRegistry.cdc"

access(all) struct ActionInfo {
    access(all) let id: String
    access(all) let name: String
    access(all) let description: String
    access(all) let contractAddress: Address
    access(all) let method: String
    access(all) let category: String
    access(all) let riskLevel: UInt8
    access(all) let schema: String
    
    init(meta: ActionRegistry.ActionMeta) {
        self.id = meta.id
        self.name = meta.name
        self.description = meta.description
        self.contractAddress = meta.contractAddress
        self.method = meta.method
        self.category = meta.category
        self.riskLevel = meta.riskLevel
        self.schema = meta.schema
    }
}

access(all) fun main(): [ActionInfo] {
    let actions: [ActionInfo] = []
    let allActions = ActionRegistry.getAllActions()
    
    for actionId in allActions.keys {
        let actionMeta = allActions[actionId]!
        actions.append(ActionInfo(meta: actionMeta))
    }
    
    return actions
}

