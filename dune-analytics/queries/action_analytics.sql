-- Action Registry Analytics
-- Track all registered and executed actions

WITH registered_actions AS (
    SELECT 
        block_timestamp AS registered_at,
        JSON_EXTRACT_SCALAR(event_data, '$.id') AS action_id,
        JSON_EXTRACT_SCALAR(event_data, '$.name') AS action_name,
        JSON_EXTRACT_SCALAR(event_data, '$.contractAddress') AS contract_address,
        JSON_EXTRACT_SCALAR(event_data, '$.method') AS method_name,
        JSON_EXTRACT_SCALAR(event_data, '$.category') AS category,
        CAST(JSON_EXTRACT_SCALAR(event_data, '$.riskLevel') AS INTEGER) AS risk_level
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'ActionRegistered'
),
executed_actions AS (
    SELECT 
        block_timestamp AS executed_at,
        JSON_EXTRACT_SCALAR(event_data, '$.id') AS action_id,
        JSON_EXTRACT_SCALAR(event_data, '$.executor') AS executor,
        CAST(JSON_EXTRACT_SCALAR(event_data, '$.success') AS BOOLEAN) AS success,
        CAST(JSON_EXTRACT_SCALAR(event_data, '$.gasUsed') AS BIGINT) AS gas_used,
        JSON_EXTRACT_SCALAR(event_data, '$.payload') AS payload
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'ActionExecuted'
        AND block_timestamp >= NOW() - INTERVAL '30' DAY
)
SELECT 
    ra.action_id,
    ra.action_name,
    ra.category,
    ra.risk_level,
    ra.registered_at,
    COUNT(ea.action_id) AS total_executions,
    SUM(CASE WHEN ea.success = TRUE THEN 1 ELSE 0 END) AS successful_executions,
    SUM(CASE WHEN ea.success = FALSE THEN 1 ELSE 0 END) AS failed_executions,
    ROUND(100.0 * SUM(CASE WHEN ea.success = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(ea.action_id), 0), 2) AS success_rate,
    AVG(ea.gas_used) AS avg_gas_used,
    MAX(ea.executed_at) AS last_execution,
    COUNT(DISTINCT ea.executor) AS unique_executors
FROM registered_actions ra
LEFT JOIN executed_actions ea ON ra.action_id = ea.action_id
GROUP BY ra.action_id, ra.action_name, ra.category, ra.risk_level, ra.registered_at
ORDER BY total_executions DESC NULLS LAST;

-- Metrics:
-- 1. Action usage patterns
-- 2. Success rates by action type
-- 3. Gas efficiency
-- 4. Popular actions

