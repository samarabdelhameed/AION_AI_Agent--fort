// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/AIONVault.sol";

/**
 * @title PopulateRealData
 * @notice Populate vault with REAL transactions and data
 * @dev This creates actual deposits, not mock data
 */
contract PopulateRealData is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Get vault address from environment or argument
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        AIONVault vault = AIONVault(payable(vaultAddress));
        
        console.log("========================================");
        console.log("Populating Real Data to AION Vault");
        console.log("========================================");
        console.log("Vault Address:", vaultAddress);
        console.log("Executor:", deployer);
        console.log("Balance:", deployer.balance);
        console.log("========================================\n");

        vm.startBroadcast(deployerPrivateKey);

        // Check if vault is deployed
        require(address(vault).code.length > 0, "Vault not deployed at this address");
        
        // Get current stats
        uint256 minDeposit = vault.minDeposit();
        console.log("Min Deposit Required:", minDeposit);
        
        // Perform REAL deposits
        console.log("\nPerforming real deposits...");
        
        // Deposit 1: Small test deposit
        uint256 deposit1 = minDeposit;
        console.log("\nDeposit 1: Testing minimum deposit");
        console.log("Amount:", deposit1);
        vault.deposit{value: deposit1}();
        console.log("Shares received:", vault.sharesOf(deployer));
        console.log("Total vault shares:", vault.totalShares());
        
        // Deposit 2: Medium deposit
        uint256 deposit2 = minDeposit * 10;
        if (deployer.balance >= deposit2) {
            console.log("\nDeposit 2: Medium deposit");
            console.log("Amount:", deposit2);
            vault.deposit{value: deposit2}();
            console.log("Shares received:", vault.sharesOf(deployer));
            console.log("Total vault shares:", vault.totalShares());
        } else {
            console.log("\nSkipping deposit 2 - insufficient balance");
        }
        
        // Deposit 3: Larger deposit
        uint256 deposit3 = minDeposit * 50;
        if (deployer.balance >= deposit3) {
            console.log("\nDeposit 3: Large deposit");
            console.log("Amount:", deposit3);
            vault.deposit{value: deposit3}();
            console.log("Shares received:", vault.sharesOf(deployer));
            console.log("Total vault shares:", vault.totalShares());
        } else {
            console.log("\nSkipping deposit 3 - insufficient balance");
        }

        // Final stats
        console.log("\n========================================");
        console.log("Final Vault Statistics");
        console.log("========================================");
        console.log("Total Deposits:", vault.totalAssets());
        console.log("Total Shares:", vault.totalShares());
        console.log("Your Shares:", vault.sharesOf(deployer));
        console.log("Your Principal:", vault.principalOf(deployer));
        console.log("Price Per Share:", vault.pricePerShare());
        console.log("Vault Balance:", address(vault).balance);
        console.log("========================================\n");

        vm.stopBroadcast();

        // Save transaction data for analytics
        string memory dataLog = string(
            abi.encodePacked(
                "{\n",
                '  "vaultAddress": "', vm.toString(vaultAddress), '",\n',
                '  "totalAssets": "', vm.toString(vault.totalAssets()), '",\n',
                '  "totalShares": "', vm.toString(vault.totalShares()), '",\n',
                '  "pricePerShare": "', vm.toString(vault.pricePerShare()), '",\n',
                '  "depositor": "', vm.toString(deployer), '",\n',
                '  "depositorShares": "', vm.toString(vault.sharesOf(deployer)), '",\n',
                '  "timestamp": ', vm.toString(block.timestamp), '\n',
                "}"
            )
        );
        
        vm.writeFile("real-data-log.json", dataLog);
        console.log("Transaction log saved to: real-data-log.json");
    }
}

