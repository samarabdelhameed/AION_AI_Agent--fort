-- AI Recommendations Analysis
-- Track AI suggestions, confidence levels, and actual execution

WITH recommendations AS (
    SELECT 
        block_timestamp AS rec_timestamp,
        block_number AS rec_block,
        transaction_hash AS rec_tx,
        JSON_EXTRACT_SCALAR(event_data, '$.aiAgent') AS ai_agent,
        JSON_EXTRACT(event_data, '$.recommendedStrategies') AS recommended_strategies,
        JSON_EXTRACT(event_data, '$.apys') AS expected_apys,
        CAST(JSON_EXTRACT_SCALAR(event_data, '$.riskScore') AS DECIMAL(10,2)) AS risk_score,
        CAST(JSON_EXTRACT_SCALAR(event_data, '$.confidence') AS DECIMAL(10,2)) AS confidence,
        JSON_EXTRACT_SCALAR(event_data, '$.metadataCID') AS metadata_cid,
        CAST(JSON_EXTRACT_SCALAR(event_data, '$.timestamp') AS BIGINT) AS rec_event_timestamp
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'StrategyRecommendation'
        AND block_timestamp >= NOW() - INTERVAL '30' DAY
),
rebalances AS (
    SELECT 
        block_timestamp AS rebalance_timestamp,
        JSON_EXTRACT_SCALAR(event_data, '$.executor') AS executor,
        JSON_EXTRACT_SCALAR(event_data, '$.toStrategy') AS executed_strategy,
        CAST(JSON_EXTRACT_SCALAR(event_data, '$.amount') AS DECIMAL(38,8)) AS amount,
        JSON_EXTRACT_SCALAR(event_data, '$.reason') AS reason
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'Rebalance'
        AND block_timestamp >= NOW() - INTERVAL '30' DAY
)
SELECT 
    r.rec_timestamp,
    r.rec_block,
    r.ai_agent,
    r.recommended_strategies,
    r.expected_apys,
    r.risk_score,
    r.confidence,
    r.metadata_cid,
    rb.rebalance_timestamp,
    rb.executed_strategy,
    rb.amount AS executed_amount,
    rb.reason AS execution_reason,
    -- Calculate if recommendation was followed
    CASE 
        WHEN rb.rebalance_timestamp IS NOT NULL 
            AND rb.rebalance_timestamp BETWEEN r.rec_timestamp AND r.rec_timestamp + INTERVAL '1' HOUR
        THEN 'Executed'
        WHEN rb.rebalance_timestamp IS NULL
        THEN 'Not Executed'
        ELSE 'Delayed Execution'
    END AS execution_status,
    -- Calculate time to execution
    EXTRACT(EPOCH FROM (rb.rebalance_timestamp - r.rec_timestamp)) / 60 AS minutes_to_execution
FROM recommendations r
LEFT JOIN rebalances rb 
    ON rb.rebalance_timestamp >= r.rec_timestamp 
    AND rb.rebalance_timestamp <= r.rec_timestamp + INTERVAL '2' HOUR
ORDER BY r.rec_timestamp DESC;

-- Insights:
-- 1. AI recommendation accuracy
-- 2. Confidence vs execution rate correlation
-- 3. Average time from recommendation to execution
-- 4. Most recommended strategies

