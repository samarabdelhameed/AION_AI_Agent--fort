-- TVL Over Time for AION Vault on Flow
-- Shows total value locked trending over time

WITH deposits AS (
    SELECT 
        DATE_TRUNC('day', block_timestamp) AS day,
        SUM(CAST(JSON_EXTRACT_SCALAR(event_data, '$.amount') AS DECIMAL(38,8))) AS deposit_amount
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'Deposit'
        AND block_timestamp >= NOW() - INTERVAL '30' DAY
    GROUP BY 1
),
withdrawals AS (
    SELECT 
        DATE_TRUNC('day', block_timestamp) AS day,
        SUM(CAST(JSON_EXTRACT_SCALAR(event_data, '$.amount') AS DECIMAL(38,8))) AS withdraw_amount
    FROM flow.events
    WHERE contract_address = '0xc7a34c80e6f3235b'
        AND event_name = 'Withdraw'
        AND block_timestamp >= NOW() - INTERVAL '30' DAY
    GROUP BY 1
),
daily_flow AS (
    SELECT 
        COALESCE(d.day, w.day) AS day,
        COALESCE(d.deposit_amount, 0) AS deposits,
        COALESCE(w.withdraw_amount, 0) AS withdrawals,
        COALESCE(d.deposit_amount, 0) - COALESCE(w.withdraw_amount, 0) AS net_flow
    FROM deposits d
    FULL OUTER JOIN withdrawals w ON d.day = w.day
    ORDER BY day
)
SELECT 
    day,
    deposits,
    withdrawals,
    net_flow,
    SUM(net_flow) OVER (ORDER BY day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_tvl
FROM daily_flow
ORDER BY day DESC;

-- Query parameters:
-- 0xc7a34c80e6f3235b - Replace with your deployed AIONVault contract address

