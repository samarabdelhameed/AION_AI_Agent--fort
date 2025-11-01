/**
 * Event Listener for AION Flow Contracts
 * Monitors blockchain events and emits local events
 */

import * as fcl from "@onflow/fcl";
import EventEmitter from 'eventemitter3';

export class EventListener extends EventEmitter {
    constructor(config) {
        super();
        this.config = config;
        this.isRunning = false;
        this.currentBlock = null;
        this.pollTimer = null;
        this.totalEvents = 0;
        this.eventCache = new Set();
    }

    /**
     * Start listening for events
     */
    async start() {
        if (this.isRunning) {
            console.log('⚠️  Event listener already running');
            return;
        }

        console.log('👂 Starting event listener...');
        
        // Get current block height
        this.currentBlock = await this.getCurrentBlockHeight();
        
        if (this.config.START_FROM_BLOCK !== 'latest' && !isNaN(this.config.START_FROM_BLOCK)) {
            this.currentBlock = parseInt(this.config.START_FROM_BLOCK, 10);
        }
        
        console.log(`   Starting from block: ${this.currentBlock}`);
        
        this.isRunning = true;
        this.startPolling();
        
        console.log(`✅ Event listener started (polling every ${this.config.POLL_INTERVAL}ms)`);
    }

    /**
     * Stop listening
     */
    async stop() {
        if (!this.isRunning) return;
        
        console.log('🛑 Stopping event listener...');
        
        if (this.pollTimer) {
            clearTimeout(this.pollTimer);
            this.pollTimer = null;
        }
        
        this.isRunning = false;
        console.log('✅ Event listener stopped');
    }

    /**
     * Start polling for events
     */
    startPolling() {
        this.pollTimer = setTimeout(async () => {
            try {
                await this.checkForEvents();
            } catch (error) {
                console.error('❌ Error polling events:', error.message);
            }
            
            if (this.isRunning) {
                this.startPolling(); // Continue polling
            }
        }, this.config.POLL_INTERVAL);
    }

    /**
     * Check for new events
     */
    async checkForEvents() {
        const latestBlock = await this.getCurrentBlockHeight();
        
        if (!latestBlock || latestBlock <= this.currentBlock) {
            return; // No new blocks
        }

        // Query events from current block to latest
        const fromBlock = this.currentBlock + 1;
        const toBlock = latestBlock;

        // Fetch events from AIONVault
        await this.fetchContractEvents(
            this.config.AION_VAULT_ADDRESS,
            'AIONVault',
            fromBlock,
            toBlock
        );

        // Fetch events from ActionRegistry
        await this.fetchContractEvents(
            this.config.ACTION_REGISTRY_ADDRESS,
            'ActionRegistry',
            fromBlock,
            toBlock
        );

        // Update current block
        this.currentBlock = toBlock;
    }

    /**
     * Fetch events from a specific contract
     */
    async fetchContractEvents(contractAddress, contractName, fromBlock, toBlock) {
        const eventTypes = this.getEventTypesForContract(contractName);
        
        for (const eventType of eventTypes) {
            try {
                const events = await fcl.send([
                    fcl.getEventsAtBlockHeightRange(
                        `A.${contractAddress.replace('0x', '')}.${contractName}.${eventType}`,
                        fromBlock,
                        toBlock
                    )
                ]).then(fcl.decode);

                if (events && events.length > 0) {
                    this.processEvents(events, eventType);
                }
            } catch (error) {
                // Event type might not exist or no events - that's ok
                if (this.config.LOG_LEVEL === 'debug') {
                    console.debug(`No ${eventType} events in blocks ${fromBlock}-${toBlock}`);
                }
            }
        }
    }

    /**
     * Process fetched events
     */
    processEvents(events, eventType) {
        for (const event of events) {
            const eventId = `${event.transactionId}-${event.eventIndex}`;
            
            // Skip duplicates
            if (this.eventCache.has(eventId)) continue;
            
            this.eventCache.add(eventId);
            this.totalEvents++;
            
            // Parse event data
            const eventData = {
                ...event.data,
                transactionId: event.transactionId,
                blockHeight: event.blockHeight,
                eventIndex: event.eventIndex
            };

            // Emit local event
            this.emit(eventType, eventData);
            
            if (this.config.LOG_LEVEL === 'debug') {
                console.log(`📨 Event: ${eventType}`, eventData);
            }
        }
        
        // Cleanup old cache entries (keep last 10000)
        if (this.eventCache.size > 10000) {
            const entries = Array.from(this.eventCache);
            this.eventCache = new Set(entries.slice(-5000));
        }
    }

    /**
     * Get event types for a contract
     */
    getEventTypesForContract(contractName) {
        if (contractName === 'AIONVault') {
            return [
                'Deposit',
                'Withdraw',
                'Rebalance',
                'StrategyRecommendation',
                'YieldRealized',
                'StrategyAllocationUpdated',
                'AIAgentUpdated',
                'VaultLockStatusChanged',
                'VaultSnapshot'
            ];
        }
        
        if (contractName === 'ActionRegistry') {
            return [
                'ActionRegistered',
                'ActionExecuted',
                'ActionFailed',
                'ActionUpdated'
            ];
        }
        
        return [];
    }

    /**
     * Get current block height
     */
    async getCurrentBlockHeight() {
        try {
            const block = await fcl.send([fcl.getBlock(true)]).then(fcl.decode);
            return block.height;
        } catch (error) {
            console.error('Failed to get current block:', error.message);
            return null;
        }
    }

    /**
     * Get current block
     */
    getCurrentBlock() {
        return this.currentBlock;
    }

    /**
     * Get statistics
     */
    getStats() {
        return {
            isRunning: this.isRunning,
            currentBlock: this.currentBlock,
            totalEvents: this.totalEvents,
            cacheSize: this.eventCache.size
        };
    }
}

export default EventListener;

