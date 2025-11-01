/**
 * set_ai_agent.cdc
 * 
 * Transaction to set the AI Agent address (admin only)
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import AIONVault from "../contracts/AIONVault.cdc"

transaction(aiAgentAddress: Address) {
    
    prepare(signer: &Account) {
        // In Cadence 1.0, we call contract functions directly
    }
    
    execute {
        // Set AI Agent address
        AIONVault.setAIAgent(newAgent: aiAgentAddress)
        
        log("AI Agent set to: ".concat(aiAgentAddress.toString()))
    }
}

