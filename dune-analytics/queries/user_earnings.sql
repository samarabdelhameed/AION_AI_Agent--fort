-- User Earnings & Performance Analysis
-- Track individual user deposits, withdrawals, and profit/loss

WITH user_deposits AS (
    SELECT 
        JSON_EXTRACT_SCALAR(event_data, '$.user') AS user_address,
        SUM(CAST(JSON_EXTRACT_SCALAR(event_data, '$.amount') AS DECIMAL(38,8))) AS total_deposited,
        SUM(CAST(JSON_EXTRACT_SCALAR(event_data, '$.shares') AS DECIMAL(38,8))) AS total_shares_minted,
        MIN(block_timestamp) AS first_deposit_time,
        MAX(block_timestamp) AS last_deposit_time,
        COUNT(*) AS deposit_count
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'Deposit'
    GROUP BY user_address
),
user_withdrawals AS (
    SELECT 
        JSON_EXTRACT_SCALAR(event_data, '$.user') AS user_address,
        SUM(CAST(JSON_EXTRACT_SCALAR(event_data, '$.amount') AS DECIMAL(38,8))) AS total_withdrawn,
        SUM(CAST(JSON_EXTRACT_SCALAR(event_data, '$.shares') AS DECIMAL(38,8))) AS total_shares_burned,
        COUNT(*) AS withdrawal_count
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'Withdraw'
    GROUP BY user_address
),
user_yields AS (
    SELECT 
        JSON_EXTRACT_SCALAR(event_data, '$.user') AS user_address,
        SUM(CAST(JSON_EXTRACT_SCALAR(event_data, '$.amount') AS DECIMAL(38,8))) AS total_yield_realized,
        COUNT(*) AS yield_claim_count
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'YieldRealized'
    GROUP BY user_address
)
SELECT 
    d.user_address,
    d.total_deposited,
    COALESCE(w.total_withdrawn, 0) AS total_withdrawn,
    d.total_deposited - COALESCE(w.total_withdrawn, 0) AS net_position,
    COALESCE(y.total_yield_realized, 0) AS total_yield_earned,
    d.total_shares_minted AS shares_minted,
    COALESCE(w.total_shares_burned, 0) AS shares_burned,
    d.total_shares_minted - COALESCE(w.total_shares_burned, 0) AS current_shares,
    -- Calculate ROI
    CASE 
        WHEN d.total_deposited > 0 THEN
            ROUND(100.0 * (COALESCE(w.total_withdrawn, 0) + COALESCE(y.total_yield_realized, 0) - d.total_deposited) / d.total_deposited, 2)
        ELSE 0
    END AS roi_percentage,
    d.first_deposit_time,
    d.last_deposit_time,
    d.deposit_count,
    COALESCE(w.withdrawal_count, 0) AS withdrawal_count,
    COALESCE(y.yield_claim_count, 0) AS yield_claim_count,
    -- Calculate days active
    EXTRACT(DAY FROM (COALESCE(w.last_withdrawal_time, NOW()) - d.first_deposit_time)) AS days_active
FROM user_deposits d
LEFT JOIN user_withdrawals w ON d.user_address = w.user_address
LEFT JOIN user_yields y ON d.user_address = y.user_address
WHERE d.total_deposited > 0
ORDER BY d.total_deposited DESC
LIMIT 100;

-- Top performers, loyal users, profitability analysis

