/**
 * withdraw.cdc
 * 
 * Transaction to withdraw funds from AION Vault
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import AIONVault from "../contracts/AIONVault.cdc"

transaction(shares: UFix64) {
    
    let signerAddress: Address
    
    prepare(signer: &Account) {
        self.signerAddress = signer.address
    }
    
    execute {
        // Withdraw funds
        let amount = AIONVault.withdraw(from: self.signerAddress, shares: shares)
        
        log("Withdrew ".concat(amount.toString()).concat(" by burning ").concat(shares.toString()).concat(" shares"))
    }
}

