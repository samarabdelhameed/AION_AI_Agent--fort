/**
 * get_action_stats.cdc
 * 
 * Script to get execution statistics from ActionRegistry
 * ✅ Updated for Cadence 1.0 (September 2024)
 */

import ActionRegistry from "../contracts/ActionRegistry.cdc"

access(all) fun main(): {String: UInt64} {
    return ActionRegistry.getStats()
}

