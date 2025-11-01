# 📊 Dune Analytics Integration for AION Vault

## 🎯 Quick Setup (10 minutes)

### Step 1: Create Dune Account
Visit: https://dune.com/auth/register

### Step 2: Upload Queries

Copy each SQL file and create queries:

1. **TVL Over Time** (`tvl_over_time.sql`)
2. **Rebalance History** (`rebalance_history.sql`)  
3. **AI Recommendations** (`ai_recommendations.sql`)
4. **Action Analytics** (`action_analytics.sql`)
5. **User Earnings** (`user_earnings.sql`)

### Step 3: Update Contract Address

In each query, replace:
```sql
{{aion_vault_address}} → 0xc7a34c80e6f3235b
{{action_registry_address}} → 0xc7a34c80e6f3235b
```

### Step 4: Create Dashboard

1. New Dashboard → "AION AI Vault - Flow Analytics"
2. Add all 5 queries
3. Arrange visualizations
4. Publish

### 📸 Dashboard Preview:

**Metrics to Show:**
- Total Value Locked (TVL)
- Rebalance frequency
- AI recommendation accuracy
- User earnings
- Action execution stats

### 🔗 After Publishing:

Share dashboard link in README:
```markdown
**Dune Dashboard:** https://dune.com/your-username/aion-vault
```

---

## ✅ Ready for Dune Track Submission!
