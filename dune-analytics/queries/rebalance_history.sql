-- Rebalance History - Complete tracking of all strategy rebalances
-- Shows when, why, and how much was rebalanced

SELECT 
    block_timestamp,
    block_number,
    transaction_hash,
    JSON_EXTRACT_SCALAR(event_data, '$.executor') AS executor,
    JSON_EXTRACT_SCALAR(event_data, '$.fromStrategy') AS from_strategy,
    JSON_EXTRACT_SCALAR(event_data, '$.toStrategy') AS to_strategy,
    CAST(JSON_EXTRACT_SCALAR(event_data, '$.amount') AS DECIMAL(38,8)) AS amount_rebalanced,
    CAST(JSON_EXTRACT_SCALAR(event_data, '$.totalAssetsBefore') AS DECIMAL(38,8)) AS tvl_before,
    CAST(JSON_EXTRACT_SCALAR(event_data, '$.totalAssetsAfter') AS DECIMAL(38,8)) AS tvl_after,
    JSON_EXTRACT_SCALAR(event_data, '$.reason') AS rebalance_reason,
    CAST(JSON_EXTRACT_SCALAR(event_data, '$.timestamp') AS BIGINT) AS event_timestamp
FROM flow.events
WHERE contract_address = '{{aion_vault_address}}'
    AND event_name = 'Rebalance'
    AND block_timestamp >= NOW() - INTERVAL '90' DAY
ORDER BY block_timestamp DESC
LIMIT 500;

-- Query parameters:
-- {{aion_vault_address}} - Your AIONVault contract address

-- Analytics:
-- 1. Track rebalancing frequency
-- 2. Identify most common strategy switches
-- 3. Analyze executor patterns (AI agent vs manual)
-- 4. Measure TVL impact of rebalances

