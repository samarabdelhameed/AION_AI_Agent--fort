# 🎮 AION Flow - دليل أوامر CLI الكامل

> **جميع أوامر Flow CLI للتعامل مع العقود الذكية + بيانات حقيقية على Testnet**

---

## 🚀 الإعداد الأولي (مرة واحدة)

### 1. تثبيت Flow CLI

```bash
sh -ci "$(curl -fsSL https://raw.githubusercontent.com/onflow/flow-cli/master/install.sh)"
```

### 2. التحقق من التثبيت

```bash
flow version
```

**Output:**
```
Version: v1.13.0
Commit: abc123...
```

### 3. إنشاء مفاتيح جديدة

```bash
flow keys generate
```

**احفظ:**
- Private Key (للـ`flow.json`)
- Public Key (للـfaucet)

### 4. الحصول على FLOW من Testnet Faucet

1. اذهب إلى: https://testnet-faucet.onflow.org/
2. الصق Public Key
3. احصل على عنوان Testnet

### 5. تحديث flow.json

```json
{
  "accounts": {
    "testnet-account": {
      "address": "0xYOUR_TESTNET_ADDRESS",
      "key": {
        "type": "hex",
        "index": 0,
        "signatureAlgorithm": "ECDSA_P256",
        "hashAlgorithm": "SHA3_256",
        "privateKey": "YOUR_PRIVATE_KEY_HERE"
      }
    }
  }
}
```

---

## 📦 نشر العقود (Deploy)

### الطريقة 1: نشر تلقائي (موصى به)

```bash
cd "/Users/s/ming-template/base hack/AION_AI_Agent -fort"
./scripts/deploy-flow.sh testnet testnet-account
```

**ينشر:**
- ✅ ActionRegistry
- ✅ AIONVault
- ✅ يسجل Actions أساسية
- ✅ يحفظ العناوين

### الطريقة 2: نشر يدوي

```bash
# نشر ActionRegistry
flow accounts add-contract ActionRegistry \
  ./cadence/contracts/ActionRegistry.cdc \
  --network=testnet \
  --signer=testnet-account

# نشر AIONVault
flow accounts add-contract AIONVault \
  ./cadence/contracts/AIONVault.cdc \
  --network=testnet \
  --signer=testnet-account
```

### التحقق من النشر

```bash
flow accounts get 0xYOUR_ADDRESS --network=testnet
```

**يجب أن ترى:**
```
Contracts Deployed: 2
  - AIONVault
  - ActionRegistry
```

---

## 💰 المعاملات (Transactions)

### 1️⃣ إيداع (Deposit)

```bash
flow transactions send ./cadence/transactions/deposit.cdc \
  --network=testnet \
  --signer=testnet-account \
  --arg UFix64:10.5
```

**المعنى:** إيداع 10.5 FLOW في الـVault

**Output المتوقع:**
```
Transaction ID: 0xabc123...
Status: ✅ SEALED
Events:
  - AIONVault.Deposit
    user: 0x123...
    amount: 10.50000000
    shares: 10.48765432
```

### 2️⃣ سحب (Withdraw)

```bash
flow transactions send ./cadence/transactions/withdraw.cdc \
  --network=testnet \
  --signer=testnet-account \
  --arg UFix64:5.0
```

**المعنى:** سحب 5 shares من الـVault

### 3️⃣ إعادة التوازن (Rebalance) - AI Agent فقط

```bash
# أولاً: تعيين AI Agent
flow transactions send ./cadence/transactions/set_ai_agent.cdc \
  --network=testnet \
  --signer=testnet-account \
  --arg Address:0xYOUR_AI_AGENT_ADDRESS

# ثانياً: تنفيذ Rebalance
flow transactions send ./cadence/transactions/rebalance.cdc \
  --network=testnet \
  --signer=testnet-account \
  --arg String:"Venus" \
  --arg String:"PancakeSwap" \
  --arg UFix64:100.0 \
  --arg String:"AI Recommendation: Higher APY"
```

### 4️⃣ تسجيل Action جديد

```bash
flow transactions send ./cadence/transactions/register_action.cdc \
  --network=testnet \
  --signer=testnet-account \
  --arg String:"auto_harvest" \
  --arg String:"Auto Harvest Rewards" \
  --arg String:"Automatically harvest and compound rewards" \
  --arg Address:0xYOUR_VAULT_ADDRESS \
  --arg String:"harvestAndCompound" \
  --arg String:'{"minYield":"UFix64"}' \
  --arg String:"automation" \
  --arg UInt8:3
```

**الـParameters:**
- `String:"auto_harvest"` - Action ID
- `String:"Auto Harvest..."` - اسم Action
- `String:"Automatically..."` - الوصف
- `Address:0x...` - عنوان العقد
- `String:"harvestAndCompound"` - اسم الدالة
- `String:'{...}'` - JSON Schema
- `String:"automation"` - الفئة
- `UInt8:3` - مستوى المخاطر (1-10)

---

## 📖 السكريبتات (Scripts - قراءة البيانات)

### 1️⃣ الحصول على رصيد المستخدم

```bash
flow scripts execute ./cadence/scripts/get_balance.cdc \
  --network=testnet \
  --arg Address:0xYOUR_USER_ADDRESS
```

**Output:**
```json
{
  "address": "0x123...",
  "shares": "10.48765432",
  "assetValue": "10.50000000",
  "principal": "10.50000000",
  "unrealizedProfit": "0.00000000",
  "pricePerShare": "1.00117543"
}
```

### 2️⃣ عرض إحصائيات Vault

```bash
flow scripts execute ./cadence/scripts/get_vault_stats.cdc \
  --network=testnet \
  --arg Address:0xVAULT_ADDRESS
```

**Output:**
```json
{
  "totalAssets": "1250.75000000",
  "totalShares": "1248.50000000",
  "pricePerShare": "1.00180123",
  "currentStrategy": "Venus",
  "minDeposit": "0.00100000",
  "minWithdraw": "0.00010000",
  "isLocked": false
}
```

### 3️⃣ عرض جميع Actions المسجلة

```bash
flow scripts execute ./cadence/scripts/get_actions.cdc \
  --network=testnet
```

**Output:**
```json
[
  {
    "id": "rebalance",
    "name": "Rebalance Strategy",
    "category": "rebalance",
    "riskLevel": 5,
    "contractAddress": "0x123...",
    "method": "rebalance"
  },
  {
    "id": "auto_harvest",
    "name": "Auto Harvest Rewards",
    "category": "automation",
    "riskLevel": 3,
    "contractAddress": "0x123...",
    "method": "harvestAndCompound"
  }
]
```

### 4️⃣ إحصائيات تنفيذ Actions

```bash
flow scripts execute ./cadence/scripts/get_action_stats.cdc \
  --network=testnet
```

**Output:**
```json
{
  "total": "45",
  "successful": "42",
  "failed": "3",
  "successRate": "93"
}
```

---

## 🔍 مراقبة الأحداث (Events)

### عرض أحداث Deposit

```bash
flow events get A.YOUR_VAULT_ADDRESS.AIONVault.Deposit \
  --network=testnet \
  --start 0 \
  --end latest
```

**Output:**
```
Event #1:
  Type: A.0x123.AIONVault.Deposit
  Values:
    user: 0xabc...
    amount: 10.50000000
    shares: 10.48765432
    totalAssets: 1250.75000000
    pricePerShare: 1.00117543
    timestamp: 1730476800.0
```

### عرض أحداث Rebalance

```bash
flow events get A.YOUR_VAULT_ADDRESS.AIONVault.Rebalance \
  --network=testnet \
  --start 0
```

### عرض أحداث AI Recommendations

```bash
flow events get A.YOUR_VAULT_ADDRESS.AIONVault.StrategyRecommendation \
  --network=testnet \
  --start 0
```

### عرض أحداث Action Executions

```bash
flow events get A.YOUR_REGISTRY_ADDRESS.ActionRegistry.ActionExecuted \
  --network=testnet \
  --start 0
```

---

## 🧪 اختبار شامل (Full Test Suite)

### تشغيل جميع الاختبارات تلقائياً

```bash
./scripts/test-flow-integration.sh testnet testnet-account
```

**يقوم بـ:**
1. ✅ قراءة إحصائيات Vault
2. ✅ فحص رصيد المستخدم (قبل)
3. ✅ تنفيذ إيداع
4. ✅ فحص رصيد المستخدم (بعد)
5. ✅ تسجيل Action
6. ✅ عرض جميع Actions
7. ✅ عرض إحصائيات
8. ✅ مراقبة الأحداث

**Output النهائي:**
```
╔════════════════════════════════════════════════════════════╗
║              🎉 All Tests Completed! 🎉                    ║
╚════════════════════════════════════════════════════════════╝

📊 Test Summary:
   ✅ Vault stats retrieval
   ✅ User balance check
   ✅ Deposit transaction
   ✅ Balance verification
   ✅ Action registration
   ✅ Actions listing
   ✅ Stats retrieval
   ✅ Event monitoring

✨ Your AION Vault is working with REAL DATA on Flow Testnet! ✨
```

---

## 🔧 أوامر مساعدة

### فحص حالة الحساب

```bash
flow accounts get 0xYOUR_ADDRESS --network=testnet
```

### عرض تفاصيل Transaction

```bash
flow transactions get 0xTRANSACTION_ID --network=testnet
```

### تتبع Transaction في الوقت الفعلي

```bash
flow transactions send ./cadence/transactions/deposit.cdc \
  --network=testnet \
  --signer=testnet-account \
  --arg UFix64:5.0 \
  --log-level=debug
```

### Dry Run (تجربة بدون تنفيذ)

```bash
flow transactions send ./cadence/transactions/deposit.cdc \
  --network=testnet \
  --signer=testnet-account \
  --arg UFix64:5.0 \
  --dry-run
```

---

## 📊 سيناريوهات عملية

### السيناريو 1: إيداع ومراقبة

```bash
# 1. إيداع
flow transactions send ./cadence/transactions/deposit.cdc \
  --network=testnet --signer=testnet-account --arg UFix64:20.0

# 2. فحص الرصيد
flow scripts execute ./cadence/scripts/get_balance.cdc \
  --network=testnet --arg Address:0xYOUR_ADDRESS

# 3. مراقبة الأحداث
flow events get A.YOUR_VAULT.AIONVault.Deposit --network=testnet --start 0
```

### السيناريو 2: تسجيل وتنفيذ Action

```bash
# 1. تسجيل
flow transactions send ./cadence/transactions/register_action.cdc \
  --network=testnet --signer=testnet-account \
  [args...]

# 2. التحقق من التسجيل
flow scripts execute ./cadence/scripts/get_actions.cdc --network=testnet

# 3. تنفيذ (عبر الـExecutor أو يدوياً)
flow transactions send ./cadence/transactions/rebalance.cdc \
  --network=testnet --signer=testnet-account [args...]

# 4. فحص الإحصائيات
flow scripts execute ./cadence/scripts/get_action_stats.cdc --network=testnet
```

### السيناريو 3: مراقبة كاملة

```bash
# Terminal 1: Executor
cd flow-executor
npm start

# Terminal 2: إيداع متكرر
for i in {1..5}; do
  flow transactions send ./cadence/transactions/deposit.cdc \
    --network=testnet --signer=testnet-account --arg UFix64:1.0
  sleep 5
done

# Terminal 3: مراقبة الأحداث
watch -n 5 'flow events get A.YOUR_VAULT.AIONVault.Deposit --network=testnet --start 0'
```

---

## 🌐 Integration مع Frontend (FCL.js)

سأعطيك أمثلة الـFCL integration في رد منفصل إذا تحب!

يتضمن:
- Connect Wallet
- Send Transactions من UI
- Read Scripts في الوقت الفعلي
- Event Subscriptions

---

## 🚨 استكشاف الأخطاء

### خطأ: "Could not borrow reference"

**الحل:**
```bash
# تأكد من نشر العقد
flow accounts get 0xYOUR_ADDRESS --network=testnet

# تأكد من العنوان في flow.json
cat flow.json | grep address
```

### خطأ: "Insufficient funds"

**الحل:**
```bash
# احصل على FLOW من faucet
# https://testnet-faucet.onflow.org/

# أو تحقق من رصيدك
flow accounts get 0xYOUR_ADDRESS --network=testnet
```

### خطأ: "Transaction failed"

**الحل:**
```bash
# استخدم --log-level=debug
flow transactions send ... --log-level=debug

# أو dry run أولاً
flow transactions send ... --dry-run
```

---

## 📚 روابط مفيدة

- **Flow Docs:** https://developers.flow.com/
- **Testnet Faucet:** https://testnet-faucet.onflow.org/
- **Flow View Source:** https://flow-view-source.com/testnet/
- **Cadence Guide:** https://cadence-lang.org/

---

**🎉 الآن عندك كل الأوامر اللي تحتاجها!**

عايز أضيفلك **FCL.js Integration للـFrontend**؟ 🚀

