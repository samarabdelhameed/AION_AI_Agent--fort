/**
 * Configuration for AION Flow Executor
 */

import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

// Load environment variables
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: join(__dirname, '..', '.env') });

// Network endpoints
const NETWORK_ENDPOINTS = {
    emulator: 'http://localhost:8888',
    testnet: 'https://rest-testnet.onflow.org',
    mainnet: 'https://rest-mainnet.onflow.org'
};

const WALLET_DISCOVERY = {
    emulator: 'https://fcl-discovery.onflow.org/local/authn',
    testnet: 'https://fcl-discovery.onflow.org/testnet/authn',
    mainnet: 'https://fcl-discovery.onflow.org/authn'
};

// Validate required environment variables
function validateConfig() {
    const required = [
        'FLOW_NETWORK'
    ];

    const missing = required.filter(key => !process.env[key]);
    
    if (missing.length > 0) {
        console.error('❌ Missing required environment variables:');
        missing.forEach(key => console.error(`   - ${key}`));
        console.error('\n💡 Copy .env.example to .env and fill in your values');
        process.exit(1);
    }

    // Warn about deployment-specific variables if not in emulator mode
    if (process.env.FLOW_NETWORK !== 'emulator') {
        const deploymentVars = [
            'AION_VAULT_ADDRESS',
            'ACTION_REGISTRY_ADDRESS',
            'EXECUTOR_PRIVATE_KEY'
        ];

        const missingDeployment = deploymentVars.filter(key => !process.env[key]);
        
        if (missingDeployment.length > 0) {
            console.warn('⚠️  Missing deployment variables (required for testnet/mainnet):');
            missingDeployment.forEach(key => console.warn(`   - ${key}`));
            console.warn('');
        }
    }
}

validateConfig();

// Export configuration
export const config = {
    // Network
    FLOW_NETWORK: process.env.FLOW_NETWORK || 'emulator',
    FLOW_ACCESS_NODE: process.env.FLOW_ACCESS_NODE || NETWORK_ENDPOINTS[process.env.FLOW_NETWORK || 'emulator'],
    FLOW_WALLET: process.env.FLOW_WALLET || WALLET_DISCOVERY[process.env.FLOW_NETWORK || 'emulator'],

    // Contracts
    AION_VAULT_ADDRESS: process.env.AION_VAULT_ADDRESS || '0xf8d6e0586b0a20c7', // Default to emulator
    ACTION_REGISTRY_ADDRESS: process.env.ACTION_REGISTRY_ADDRESS || '0xf8d6e0586b0a20c7',

    // Executor
    EXECUTOR_PRIVATE_KEY: process.env.EXECUTOR_PRIVATE_KEY || '',
    EXECUTOR_ADDRESS: process.env.EXECUTOR_ADDRESS || '0xf8d6e0586b0a20c7',

    // AI Settings
    AUTO_EXECUTE_RECOMMENDATIONS: process.env.AUTO_EXECUTE_RECOMMENDATIONS === 'true',
    MIN_CONFIDENCE: parseInt(process.env.MIN_CONFIDENCE || '80'),
    REBALANCE_PERCENTAGE: parseInt(process.env.REBALANCE_PERCENTAGE || '50'),

    // Scheduling
    USE_SCHEDULED_TX: process.env.USE_SCHEDULED_TX === 'true',
    EXECUTION_DELAY: parseInt(process.env.EXECUTION_DELAY || '300'),

    // Monitoring
    POLL_INTERVAL: parseInt(process.env.POLL_INTERVAL || '5000'),
    START_BLOCK_HEIGHT: process.env.START_BLOCK_HEIGHT ? parseInt(process.env.START_BLOCK_HEIGHT) : null,

    // Analytics
    ANALYTICS_WEBHOOK: process.env.ANALYTICS_WEBHOOK || '',
    DUNE_API_KEY: process.env.DUNE_API_KEY || '',

    // Logging
    LOG_LEVEL: process.env.LOG_LEVEL || 'info',
    LOG_FILE: process.env.LOG_FILE || './logs/executor.log',

    // Security
    MAX_GAS_LIMIT: parseInt(process.env.MAX_GAS_LIMIT || '9999'),
    EMERGENCY_PAUSE_THRESHOLD: parseInt(process.env.EMERGENCY_PAUSE_THRESHOLD || '10'),

    // Development
    DEBUG: process.env.DEBUG === 'true',
    DRY_RUN: process.env.DRY_RUN === 'true'
};

// Log configuration on startup (without sensitive data)
export function logConfig() {
    console.log('\n⚙️  Configuration:');
    console.log(`   Network: ${config.FLOW_NETWORK}`);
    console.log(`   Access Node: ${config.FLOW_ACCESS_NODE}`);
    console.log(`   Vault Address: ${config.AION_VAULT_ADDRESS}`);
    console.log(`   Registry Address: ${config.ACTION_REGISTRY_ADDRESS}`);
    console.log(`   Auto Execute: ${config.AUTO_EXECUTE_RECOMMENDATIONS}`);
    console.log(`   Min Confidence: ${config.MIN_CONFIDENCE}%`);
    console.log(`   Dry Run: ${config.DRY_RUN}`);
    console.log('');
}

export default config;
