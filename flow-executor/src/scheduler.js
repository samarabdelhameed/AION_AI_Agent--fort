/**
 * Scheduler for AION Flow Executor
 * Manages delayed/scheduled transaction execution
 */

import EventEmitter from 'eventemitter3';

export class Scheduler extends EventEmitter {
    constructor(config) {
        super();
        this.config = config;
        this.schedules = new Map();
        this.nextId = 1;
        this.stats = {
            total: 0,
            pending: 0,
            completed: 0,
            failed: 0,
            cancelled: 0
        };
    }

    /**
     * Schedule an action for future execution
     * @param {Object} action - Action object from ActionBuilder
     * @param {number} delaySeconds - Delay in seconds before execution
     * @returns {string} Schedule ID
     */
    scheduleAction(action, delaySeconds) {
        const scheduleId = `schedule_${this.nextId++}`;
        const executeAt = new Date(Date.now() + delaySeconds * 1000);
        
        const schedule = {
            id: scheduleId,
            action,
            delaySeconds,
            executeAt,
            status: 'pending',
            createdAt: new Date(),
            result: null,
            error: null
        };

        // Set timeout for execution
        const timer = setTimeout(async () => {
            await this.executeScheduledAction(scheduleId);
        }, delaySeconds * 1000);

        schedule.timer = timer;
        this.schedules.set(scheduleId, schedule);
        
        this.stats.total++;
        this.stats.pending++;
        
        console.log(`⏰ Scheduled action: ${action.name}`);
        console.log(`   Execute at: ${executeAt.toLocaleString()}`);
        console.log(`   Schedule ID: ${scheduleId}`);
        
        return scheduleId;
    }

    /**
     * Execute a scheduled action
     */
    async executeScheduledAction(scheduleId) {
        const schedule = this.schedules.get(scheduleId);
        
        if (!schedule) {
            console.error(`Schedule ${scheduleId} not found`);
            return;
        }

        if (schedule.status !== 'pending') {
            console.log(`Schedule ${scheduleId} already ${schedule.status}`);
            return;
        }

        console.log(`\n⚡ Executing scheduled action: ${schedule.action.name}`);
        console.log(`   Scheduled for: ${schedule.executeAt.toLocaleString()}`);
        
        schedule.status = 'executing';
        
        try {
            // Emit event for executor to handle
            this.emit('execute', schedule.action);
            
            schedule.status = 'completed';
            schedule.result = { success: true, executedAt: new Date() };
            
            this.stats.pending--;
            this.stats.completed++;
            
            console.log(`✅ Scheduled action executed successfully`);
            
        } catch (error) {
            schedule.status = 'failed';
            schedule.error = error.message;
            
            this.stats.pending--;
            this.stats.failed++;
            
            console.error(`❌ Scheduled action failed:`, error.message);
        }
    }

    /**
     * Cancel a scheduled action
     */
    cancelSchedule(scheduleId) {
        const schedule = this.schedules.get(scheduleId);
        
        if (!schedule) {
            console.error(`Schedule ${scheduleId} not found`);
            return false;
        }

        if (schedule.status !== 'pending') {
            console.log(`Cannot cancel - schedule is ${schedule.status}`);
            return false;
        }

        // Clear timeout
        if (schedule.timer) {
            clearTimeout(schedule.timer);
        }

        schedule.status = 'cancelled';
        schedule.cancelledAt = new Date();
        
        this.stats.pending--;
        this.stats.cancelled++;
        
        console.log(`🚫 Cancelled schedule: ${scheduleId}`);
        
        return true;
    }

    /**
     * Get schedule by ID
     */
    getSchedule(scheduleId) {
        const schedule = this.schedules.get(scheduleId);
        
        if (!schedule) return null;
        
        // Return copy without timer
        const { timer, ...scheduleData } = schedule;
        return scheduleData;
    }

    /**
     * Get all pending schedules
     */
    getPendingSchedules() {
        const pending = [];
        
        for (const [id, schedule] of this.schedules) {
            if (schedule.status === 'pending') {
                const { timer, ...scheduleData } = schedule;
                pending.push(scheduleData);
            }
        }
        
        return pending.sort((a, b) => a.executeAt - b.executeAt);
    }

    /**
     * Get all schedules
     */
    getAllSchedules() {
        const all = [];
        
        for (const [id, schedule] of this.schedules) {
            const { timer, ...scheduleData } = schedule;
            all.push(scheduleData);
        }
        
        return all.sort((a, b) => b.createdAt - a.createdAt);
    }

    /**
     * Get statistics
     */
    getStats() {
        return {
            ...this.stats,
            schedules: this.schedules.size
        };
    }

    /**
     * Cleanup old completed/failed schedules
     */
    cleanup(olderThanMs = 24 * 60 * 60 * 1000) {
        const cutoff = Date.now() - olderThanMs;
        let removed = 0;
        
        for (const [id, schedule] of this.schedules) {
            if (schedule.status !== 'pending' && schedule.createdAt.getTime() < cutoff) {
                this.schedules.delete(id);
                removed++;
            }
        }
        
        if (removed > 0) {
            console.log(`🧹 Cleaned up ${removed} old schedules`);
        }
        
        return removed;
    }

    /**
     * Schedule recurring action (advanced)
     */
    scheduleRecurring(action, intervalSeconds, maxExecutions = null) {
        let executionCount = 0;
        
        const scheduleNext = () => {
            if (maxExecutions && executionCount >= maxExecutions) {
                console.log(`♻️  Recurring schedule completed (${executionCount} executions)`);
                return;
            }
            
            const scheduleId = this.scheduleAction(action, intervalSeconds);
            executionCount++;
            
            // Schedule next execution
            setTimeout(scheduleNext, intervalSeconds * 1000);
        };
        
        scheduleNext();
        
        console.log(`♻️  Scheduled recurring action: ${action.name}`);
        console.log(`   Interval: ${intervalSeconds}s`);
        if (maxExecutions) {
            console.log(`   Max executions: ${maxExecutions}`);
        }
    }
}

export default Scheduler;
