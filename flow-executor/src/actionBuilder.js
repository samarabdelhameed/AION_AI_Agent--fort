/**
 * Action Builder for AION Flow Executor
 * Constructs Cadence transactions for execution
 */

import * as t from "@onflow/types";
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export class ActionBuilder {
    constructor(config) {
        this.config = config;
        this.transactionsPath = join(__dirname, '../../cadence/transactions');
    }

    /**
     * Build a rebalance action
     */
    async buildRebalanceAction({ fromStrategy, toStrategy, amount, reason }) {
        const cadenceCode = this.loadTransaction('rebalance.cdc');
        
        return {
            name: 'Rebalance Strategy',
            type: 'rebalance',
            cadenceCode,
            args: [
                { value: fromStrategy, type: t.String },
                { value: toStrategy, type: t.String },
                { value: amount.toFixed(8), type: t.UFix64 },
                { value: reason, type: t.String }
            ],
            metadata: {
                fromStrategy,
                toStrategy,
                amount,
                reason
            }
        };
    }

    /**
     * Build a deposit action
     */
    async buildDepositAction({ amount }) {
        const cadenceCode = this.loadTransaction('deposit.cdc');
        
        return {
            name: 'Deposit Funds',
            type: 'deposit',
            cadenceCode,
            args: [
                { value: amount.toFixed(8), type: t.UFix64 }
            ],
            metadata: {
                amount
            }
        };
    }

    /**
     * Build a withdraw action
     */
    async buildWithdrawAction({ shares }) {
        const cadenceCode = this.loadTransaction('withdraw.cdc');
        
        return {
            name: 'Withdraw Funds',
            type: 'withdraw',
            cadenceCode,
            args: [
                { value: shares.toFixed(8), type: t.UFix64 }
            ],
            metadata: {
                shares
            }
        };
    }

    /**
     * Build register action transaction
     */
    async buildRegisterActionAction(actionData) {
        const cadenceCode = this.loadTransaction('register_action.cdc');
        
        return {
            name: 'Register Action',
            type: 'register_action',
            cadenceCode,
            args: [
                { value: actionData.id, type: t.String },
                { value: actionData.name, type: t.String },
                { value: actionData.description, type: t.String },
                { value: actionData.contractAddress, type: t.Address },
                { value: actionData.method, type: t.String },
                { value: actionData.schema, type: t.String },
                { value: actionData.category, type: t.String },
                { value: actionData.riskLevel, type: t.UInt8 }
            ],
            metadata: actionData
        };
    }

    /**
     * Build AI recommendation transaction
     */
    async buildRecommendationAction({
        strategies,
        apys,
        riskScore,
        metadataCID,
        confidence
    }) {
        // This would use a transaction that calls postRecommendation
        // For now, we'll create a custom transaction
        const cadenceCode = `
import AIONVault from ${this.config.AION_VAULT_ADDRESS}

transaction(
    strategies: [String],
    apys: [UFix64],
    riskScore: UFix64,
    metadataCID: String,
    confidence: UFix64
) {
    prepare(signer: &Account) {}
    
    execute {
        AIONVault.postRecommendation(
            aiAgent: signer.address,
            strategies: strategies,
            apys: apys,
            riskScore: riskScore,
            metadataCID: metadataCID,
            confidence: confidence
        )
    }
}
`;

        return {
            name: 'Post AI Recommendation',
            type: 'recommendation',
            cadenceCode,
            args: [
                { value: strategies, type: t.Array(t.String) },
                { value: apys.map(a => a.toFixed(2)), type: t.Array(t.UFix64) },
                { value: riskScore.toFixed(2), type: t.UFix64 },
                { value: metadataCID, type: t.String },
                { value: confidence.toFixed(2), type: t.UFix64 }
            ],
            metadata: {
                strategies,
                apys,
                riskScore,
                metadataCID,
                confidence
            }
        };
    }

    /**
     * Build set AI agent transaction
     */
    async buildSetAIAgentAction({ agentAddress }) {
        const cadenceCode = this.loadTransaction('set_ai_agent.cdc');
        
        return {
            name: 'Set AI Agent',
            type: 'set_ai_agent',
            cadenceCode,
            args: [
                { value: agentAddress, type: t.Address }
            ],
            metadata: {
                agentAddress
            }
        };
    }

    /**
     * Load transaction code from file
     */
    loadTransaction(filename) {
        try {
            const filePath = join(this.transactionsPath, filename);
            return readFileSync(filePath, 'utf8');
        } catch (error) {
            console.error(`Failed to load transaction ${filename}:`, error.message);
            throw new Error(`Transaction file not found: ${filename}`);
        }
    }

    /**
     * Build custom action from raw Cadence code
     */
    async buildCustomAction({ name, cadenceCode, args, metadata = {} }) {
        return {
            name,
            type: 'custom',
            cadenceCode,
            args,
            metadata
        };
    }
}

export default ActionBuilder;
