/**
 * AION Flow Executor - Main Entry Point
 * 
 * يستمع للأحداث من عقود Flow وينفذ Actions تلقائياً
 */

import * as fcl from "@onflow/fcl";
import * as t from "@onflow/types";
import { config } from './config.js';
import { EventListener } from './eventListener.js';
import { ActionBuilder } from './actionBuilder.js';
import { Scheduler } from './scheduler.js';

class AIONFlowExecutor {
    constructor() {
        this.eventListener = null;
        this.actionBuilder = null;
        this.scheduler = null;
        this.isRunning = false;
    }

    /**
     * Initialize Flow FCL configuration
     */
    async initialize() {
        console.log('🚀 Initializing AION Flow Executor...');
        
        // Configure FCL
        fcl.config()
            .put("accessNode.api", config.FLOW_ACCESS_NODE)
            .put("discovery.wallet", config.FLOW_WALLET)
            .put("app.detail.title", "AION AI Agent")
            .put("app.detail.icon", "https://aion.ai/logo.png");

        // Initialize components
        this.eventListener = new EventListener(config);
        this.actionBuilder = new ActionBuilder(config);
        this.scheduler = new Scheduler(config);

        // Setup event handlers
        this.setupEventHandlers();

        console.log('✅ Executor initialized successfully');
        console.log(`📡 Connected to: ${config.FLOW_ACCESS_NODE}`);
        console.log(`📝 Monitoring contracts:`);
        console.log(`   - AIONVault: ${config.AION_VAULT_ADDRESS}`);
        console.log(`   - ActionRegistry: ${config.ACTION_REGISTRY_ADDRESS}`);
    }

    /**
     * Setup event handlers for different event types
     */
    setupEventHandlers() {
        // Handle strategy recommendations from AI
        this.eventListener.on('StrategyRecommendation', async (event) => {
            await this.handleStrategyRecommendation(event);
        });

        // Handle rebalance events
        this.eventListener.on('Rebalance', async (event) => {
            await this.handleRebalanceEvent(event);
        });

        // Handle deposit events (for analytics)
        this.eventListener.on('Deposit', async (event) => {
            await this.handleDepositEvent(event);
        });

        // Handle withdraw events
        this.eventListener.on('Withdraw', async (event) => {
            await this.handleWithdrawEvent(event);
        });

        // Handle action executions
        this.eventListener.on('ActionExecuted', async (event) => {
            await this.handleActionExecution(event);
        });
    }

    /**
     * Handle AI strategy recommendation
     */
    async handleStrategyRecommendation(event) {
        console.log('\n🤖 AI Strategy Recommendation Received:');
        console.log(`   Agent: ${event.aiAgent}`);
        console.log(`   Strategies: ${event.recommendedStrategies.join(', ')}`);
        console.log(`   APYs: ${event.apys.join(', ')}%`);
        console.log(`   Risk Score: ${event.riskScore}/100`);
        console.log(`   Confidence: ${event.confidence}%`);
        console.log(`   Metadata CID: ${event.metadataCID}`);

        // Check if we should auto-execute
        if (config.AUTO_EXECUTE_RECOMMENDATIONS && event.confidence >= config.MIN_CONFIDENCE) {
            console.log('🎯 Confidence threshold met - preparing auto-execution...');
            
            // Build rebalance action
            const action = await this.actionBuilder.buildRebalanceAction({
                fromStrategy: 'current',
                toStrategy: event.recommendedStrategies[0], // Best strategy
                amount: await this.calculateRebalanceAmount(event),
                reason: `AI Recommendation (confidence: ${event.confidence}%)`
            });

            // Schedule or execute immediately
            if (config.USE_SCHEDULED_TX) {
                await this.scheduler.scheduleAction(action, config.EXECUTION_DELAY);
                console.log(`⏰ Action scheduled for execution in ${config.EXECUTION_DELAY}s`);
            } else {
                await this.executeAction(action);
            }
        } else {
            console.log('⏸️  Confidence below threshold - manual approval required');
        }
    }

    /**
     * Handle rebalance event (for tracking)
     */
    async handleRebalanceEvent(event) {
        console.log('\n💱 Rebalance Executed:');
        console.log(`   Executor: ${event.executor}`);
        console.log(`   ${event.fromStrategy} → ${event.toStrategy}`);
        console.log(`   Amount: ${event.amount} FLOW`);
        console.log(`   Reason: ${event.reason}`);
        console.log(`   Assets Before: ${event.totalAssetsBefore} FLOW`);
        console.log(`   Assets After: ${event.totalAssetsAfter} FLOW`);

        // Update internal state or send to analytics
        await this.sendToAnalytics('rebalance', event);
    }

    /**
     * Handle deposit event
     */
    async handleDepositEvent(event) {
        console.log(`\n💰 Deposit: ${event.user} deposited ${event.amount} FLOW (${event.shares} shares)`);
        await this.sendToAnalytics('deposit', event);
    }

    /**
     * Handle withdraw event
     */
    async handleWithdrawEvent(event) {
        console.log(`\n💸 Withdraw: ${event.user} withdrew ${event.amount} FLOW (${event.shares} shares)`);
        await this.sendToAnalytics('withdraw', event);
    }

    /**
     * Handle action execution log
     */
    async handleActionExecution(event) {
        const status = event.success ? '✅' : '❌';
        console.log(`\n${status} Action Executed: ${event.id}`);
        console.log(`   Executor: ${event.executor}`);
        console.log(`   Success: ${event.success}`);
        console.log(`   Gas Used: ${event.gasUsed}`);
    }

    /**
     * Execute an action
     */
    async executeAction(action) {
        console.log(`\n⚡ Executing Action: ${action.name}`);
        
        try {
            const txId = await fcl.send([
                fcl.transaction(action.cadenceCode),
                fcl.args(action.args),
                fcl.proposer(fcl.authz),
                fcl.payer(fcl.authz),
                fcl.authorizations([fcl.authz]),
                fcl.limit(1000)
            ]).then(fcl.decode);

            console.log(`📤 Transaction submitted: ${txId}`);

            // Wait for transaction to seal
            const result = await fcl.tx(txId).onceSealed();
            
            if (result.status === 4) { // SEALED
                console.log(`✅ Transaction sealed successfully`);
                return { success: true, txId, result };
            } else {
                console.log(`⚠️  Transaction status: ${result.status}`);
                return { success: false, txId, result };
            }

        } catch (error) {
            console.error(`❌ Action execution failed:`, error.message);
            return { success: false, error: error.message };
        }
    }

    /**
     * Calculate optimal rebalance amount based on recommendation
     */
    async calculateRebalanceAmount(recommendation) {
        // Get current vault stats
        const vaultStats = await this.getVaultStats();
        const totalAssets = parseFloat(vaultStats.totalAssets);
        
        // Use configured rebalance percentage or full amount
        const percentage = config.REBALANCE_PERCENTAGE || 100;
        const amount = (totalAssets * percentage) / 100;
        
        return amount.toFixed(8);
    }

    /**
     * Get current vault statistics
     */
    async getVaultStats() {
        try {
            const result = await fcl.send([
                fcl.script`
                    import AIONVault from ${config.AION_VAULT_ADDRESS}
                    
                    pub fun main(): {String: UFix64} {
                        return AIONVault.getVaultStats()
                    }
                `
            ]).then(fcl.decode);

            return result;
        } catch (error) {
            console.error('Failed to get vault stats:', error);
            return { totalAssets: "0.0", totalShares: "0.0" };
        }
    }

    /**
     * Send event data to analytics (Dune, etc.)
     */
    async sendToAnalytics(eventType, eventData) {
        if (config.ANALYTICS_WEBHOOK) {
            try {
                await fetch(config.ANALYTICS_WEBHOOK, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        type: eventType,
                        data: eventData,
                        timestamp: new Date().toISOString()
                    })
                });
            } catch (error) {
                console.error('Analytics webhook failed:', error.message);
            }
        }
    }

    /**
     * Start the executor
     */
    async start() {
        if (this.isRunning) {
            console.log('⚠️  Executor is already running');
            return;
        }

        await this.initialize();
        
        console.log('\n🎬 Starting event monitoring...\n');
        await this.eventListener.start();
        
        this.isRunning = true;
        console.log('✅ AION Flow Executor is now running');
        console.log('   Press Ctrl+C to stop\n');
    }

    /**
     * Stop the executor
     */
    async stop() {
        if (!this.isRunning) return;

        console.log('\n🛑 Stopping executor...');
        await this.eventListener.stop();
        this.isRunning = false;
        console.log('✅ Executor stopped');
    }
}

// Main execution
const executor = new AIONFlowExecutor();

// Handle graceful shutdown
process.on('SIGINT', async () => {
    await executor.stop();
    process.exit(0);
});

process.on('SIGTERM', async () => {
    await executor.stop();
    process.exit(0);
});

// Start executor
executor.start().catch(error => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
});

export default AIONFlowExecutor;

