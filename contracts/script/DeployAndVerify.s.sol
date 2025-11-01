// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/AIONVault.sol";

/**
 * @title DeployAndVerify
 * @notice Deploy AIONVault to testnet/mainnet with real configuration
 * @dev Run with: forge script script/DeployAndVerify.s.sol --rpc-url $RPC_URL --broadcast --verify -vvvv
 */
contract DeployAndVerify is Script {
    
    // Configuration for different networks
    struct NetworkConfig {
        uint256 minDeposit;
        uint256 minYieldClaim;
        string name;
    }
    
    function getNetworkConfig(uint256 chainId) internal pure returns (NetworkConfig memory) {
        if (chainId == 56) {
            // BNB Mainnet
            return NetworkConfig({
                minDeposit: 0.01 ether,      // 0.01 BNB minimum
                minYieldClaim: 0.001 ether,  // 0.001 BNB minimum claim
                name: "BNB Mainnet"
            });
        } else if (chainId == 97) {
            // BNB Testnet
            return NetworkConfig({
                minDeposit: 0.001 ether,     // Lower for testing
                minYieldClaim: 0.0001 ether, // Lower for testing
                name: "BNB Testnet"
            });
        } else if (chainId == 11155111) {
            // Sepolia
            return NetworkConfig({
                minDeposit: 0.001 ether,
                minYieldClaim: 0.0001 ether,
                name: "Sepolia"
            });
        } else {
            // Default
            return NetworkConfig({
                minDeposit: 0.001 ether,
                minYieldClaim: 0.0001 ether,
                name: "Unknown Network"
            });
        }
    }
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        uint256 chainId = block.chainid;
        
        NetworkConfig memory config = getNetworkConfig(chainId);
        
        console.log("========================================");
        console.log("AION Vault Deployment");
        console.log("========================================");
        console.log("Network:", config.name);
        console.log("Chain ID:", chainId);
        console.log("Deployer:", deployer);
        console.log("Min Deposit:", config.minDeposit);
        console.log("Min Yield Claim:", config.minYieldClaim);
        console.log("========================================\n");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy AIONVault
        console.log("Deploying AIONVault...");
        AIONVault vault = new AIONVault(config.minDeposit, config.minYieldClaim);
        console.log("AIONVault deployed at:", address(vault));

        // Set AI Agent (deployer for now, can be changed later)
        console.log("\nConfiguring vault...");
        vault.setAIAgent(deployer);
        console.log("AI Agent set to:", deployer);

        // Verification
        console.log("\n========================================");
        console.log("Post-Deployment Verification");
        console.log("========================================");
        console.log("Owner:", vault.owner());
        console.log("AI Agent:", vault.aiAgent());
        console.log("Min Deposit:", vault.minDeposit());
        console.log("Min Yield Claim:", vault.minYieldClaim());
        console.log("Total Shares:", vault.totalShares());
        console.log("Strategy Locked:", vault.strategyLocked());
        console.log("Paused:", vault.paused());
        console.log("Circuit Breaker:", vault.circuitBreakerTripped());
        console.log("========================================\n");

        // Save deployment info
        string memory deploymentInfo = string(
            abi.encodePacked(
                "{\n",
                '  "network": "', config.name, '",\n',
                '  "chainId": ', vm.toString(chainId), ',\n',
                '  "vaultAddress": "', vm.toString(address(vault)), '",\n',
                '  "owner": "', vm.toString(vault.owner()), '",\n',
                '  "aiAgent": "', vm.toString(vault.aiAgent()), '",\n',
                '  "minDeposit": "', vm.toString(vault.minDeposit()), '",\n',
                '  "minYieldClaim": "', vm.toString(vault.minYieldClaim()), '",\n',
                '  "deployedAt": ', vm.toString(block.timestamp), '\n',
                "}"
            )
        );
        
        string memory filename = string(
            abi.encodePacked("deployment-", vm.toString(chainId), ".json")
        );
        vm.writeFile(filename, deploymentInfo);
        console.log("Deployment info saved to:", filename);

        vm.stopBroadcast();

        console.log("\n========================================");
        console.log("DEPLOYMENT SUCCESSFUL!");
        console.log("========================================");
        console.log("\nNext Steps:");
        console.log("1. Verify contract on explorer");
        console.log("2. Update frontend config with vault address");
        console.log("3. Fund vault for initial liquidity");
        console.log("4. Configure strategies/adapters");
        console.log("\nVerify command:");
        console.log("forge verify-contract");
        console.log("  Vault:", vm.toString(address(vault)));
        console.log("  Chain:", vm.toString(chainId));
        console.log("========================================\n");
    }
}

