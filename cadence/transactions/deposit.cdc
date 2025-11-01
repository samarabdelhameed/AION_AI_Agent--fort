/**
 * deposit.cdc
 * 
 * Transaction to deposit funds into AION Vault
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import AIONVault from "../contracts/AIONVault.cdc"

transaction(amount: UFix64) {
    
    let signerAddress: Address
    
    prepare(signer: &Account) {
        self.signerAddress = signer.address
    }
    
    execute {
        // Deposit funds and get shares
        let shares = AIONVault.deposit(from: self.signerAddress, amount: amount)
        
        log("Deposited ".concat(amount.toString()).concat(" and received ").concat(shares.toString()).concat(" shares"))
    }
}

