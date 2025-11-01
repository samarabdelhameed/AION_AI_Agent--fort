# ⚡ Quick Deploy Guide - AION على Flow

> **دليل سريع لنشر وتشغيل AION على Flow Blockchain في 5 دقائق**

---

## 🎯 الخيار 1: اختبار محلي (Emulator) - الأسرع

### الخطوة 1: تشغيل Flow Emulator

```bash
# في terminal منفصل
flow emulator
```

**اتركه يعمل** - سيظهر:
```
INFO[0000] ⚙️   Using service account 0xf8d6e0586b0a20c7
INFO[0000] 🌱  Flow emulator running on port 3569
```

---

### الخطوة 2: نشر العقود

```bash
# في terminal جديد
cd "/Users/s/ming-template/base hack/AION_AI_Agent -fort"

# نشر تلقائي
chmod +x scripts/deploy-flow.sh
./scripts/deploy-flow.sh emulator emulator-account
```

**سترى:**
```
🚀 AION Flow Deployment Script
✅ Flow CLI installed
✅ Emulator is running
📝 Deploying ActionRegistry...
✅ ActionRegistry deployed
📝 Deploying AIONVault...
✅ AIONVault deployed
✅ Deployment Complete!
```

---

### الخطوة 3: اختبار إيداع

```bash
# جرب deposit
flow transactions send ./cadence/transactions/deposit.cdc \
  --arg UFix64:1.5 \
  --network=emulator \
  --signer=emulator-account
```

**النتيجة المتوقعة:**
```
Transaction ID: 0x123...
Status: ✅ SEALED
```

---

### الخطوة 4: تشغيل Executor

```bash
cd flow-executor

# تثبيت dependencies (أول مرة فقط)
npm install

# تشغيل
npm start
```

**Output:**
```
🚀 Initializing AION Flow Executor...
✅ Executor initialized successfully
📡 Connected to: http://localhost:8888
✅ AION Flow Executor is now running
```

---

## 🌐 الخيار 2: نشر على Flow Testnet

### المتطلبات الأساسية

1. **مفاتيح Flow**
```bash
flow keys generate
```

**احفظ الناتج!** ستحتاجه.

---

2. **حساب Testnet**

اذهب إلى: https://testnet-faucet.onflow.org/
- اتبع التعليمات للحصول على حساب
- احتفظ بالـ address والـ private key

---

3. **تحديث flow.json**

افتح `flow.json` وعدّل:

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

### نشر على Testnet

```bash
# تأكد من flow.json محدث
./scripts/deploy-flow.sh testnet testnet-account
```

**سيستغرق 1-2 دقيقة**

```
✅ ActionRegistry deployed
✅ AIONVault deployed
✅ Deployment Complete!

🔗 View on Flow Explorer:
   https://flow-view-source.com/testnet/account/0xYOUR_ADDRESS
```

---

### تحديث Executor للـTestnet

```bash
cd flow-executor

# عدّل .env
nano .env
```

**غيّر:**
```bash
FLOW_NETWORK=testnet
FLOW_ACCESS_NODE=https://rest-testnet.onflow.org
AION_VAULT_ADDRESS=0xYOUR_DEPLOYED_ADDRESS
EXECUTOR_PRIVATE_KEY=your_private_key
```

**احفظ** (Ctrl+X, Y, Enter)

```bash
# شغّل
npm start
```

---

## 📊 الخطوة التالية: Dune Analytics

### 1. إنشاء حساب Dune

- اذهب: https://dune.com
- سجل مجاناً

---

### 2. رفع Queries

لكل ملف في `dune-analytics/queries/`:

1. اذهب: https://dune.com/queries/new
2. انسخ محتوى الملف SQL
3. استبدل `{{aion_vault_address}}` بعنوانك الحقيقي
4. احفظ Query

**الـQueries:**
- `tvl_over_time.sql` → TVL Trending
- `rebalance_history.sql` → Rebalance History
- `ai_recommendations.sql` → AI Performance
- `action_analytics.sql` → Action Stats
- `user_earnings.sql` → User ROI

---

### 3. إنشاء Dashboard

1. Dashboard جديد → "AION Vault Analytics"
2. أضف Queries المحفوظة
3. اختر Visualizations:
   - TVL → Line Chart
   - Rebalances → Table
   - AI Recs → Bar Chart

---

## 🧪 التأكد من أن كل شيء يعمل

### اختبار 1: قراءة إحصائيات Vault

```bash
flow scripts execute ./cadence/scripts/get_vault_stats.cdc \
  --network=emulator
```

**النتيجة:**
```json
{
  "totalAssets": "0.00000000",
  "totalShares": "0.00000000",
  "pricePerShare": "1000000.00000000"
}
```

---

### اختبار 2: إيداع

```bash
flow transactions send ./cadence/transactions/deposit.cdc \
  --arg UFix64:10.0 \
  --network=emulator \
  --signer=emulator-account
```

---

### اختبار 3: قراءة الرصيد

```bash
flow scripts execute ./cadence/scripts/get_balance.cdc \
  --arg Address:0xf8d6e0586b0a20c7 \
  --network=emulator
```

**النتيجة:**
```
10.00000000
```

---

### اختبار 4: Executor يلتقط الحدث

في terminal الـExecutor، يجب أن ترى:

```
📨 Event: Deposit
💰 Deposit: 0xf8d6e0586b0a20c7 deposited 10.0 FLOW (10.0 shares)
```

---

## 🐛 حل المشاكل الشائعة

### المشكلة: "Could not borrow reference"

**الحل:**
```bash
# تأكد من نشر العقد
flow accounts get 0xf8d6e0586b0a20c7 --network=emulator
```

---

### المشكلة: "Transaction failed"

**الحل:**
```bash
# شاهد logs مفصلة
flow transactions send ... --log-level=debug
```

---

### المشكلة: Executor لا يعمل

**الحل:**
```bash
# تحقق من .env
cat flow-executor/.env

# تحقق من الاتصال
curl http://localhost:8888  # للemulator
```

---

## 📁 الملفات المهمة

| الملف | الوصف |
|------|-------|
| `flow.json` | إعدادات Flow CLI |
| `cadence/contracts/` | العقود الذكية |
| `cadence/transactions/` | معاملات التنفيذ |
| `flow-executor/.env` | إعدادات Executor |
| `.contract-addresses` | عناوين العقود المنشورة |

---

## 🎯 Quick Commands Reference

```bash
# نشر على emulator
./scripts/deploy-flow.sh emulator emulator-account

# نشر على testnet
./scripts/deploy-flow.sh testnet testnet-account

# إيداع
flow tx send ./cadence/transactions/deposit.cdc --arg UFix64:5.0 --network=emulator

# سحب
flow tx send ./cadence/transactions/withdraw.cdc --arg UFix64:2.5 --network=emulator

# قراءة stats
flow scripts execute ./cadence/scripts/get_vault_stats.cdc --network=emulator

# تشغيل executor
cd flow-executor && npm start

# إيقاف emulator
# Ctrl+C في terminal الـemulator
```

---

## ✅ Checklist

- [ ] Flow CLI مثبت (`flow version`)
- [ ] Emulator يعمل (`flow emulator`)
- [ ] العقود منشورة (`./scripts/deploy-flow.sh`)
- [ ] Deposit ناجح (اختبار)
- [ ] Executor يعمل (`npm start`)
- [ ] Events تظهر في logs
- [ ] Dune queries محفوظة (اختياري)
- [ ] Dashboard جاهز (اختياري)

---

## 🚀 الخطوة التالية

بعد التأكد من أن كل شيء يعمل:

1. **ادمج مع Frontend**
   - استخدم `@onflow/fcl` في React
   - اربط wallet المستخدم
   - عرض real-time stats

2. **فعّل AI Agent**
   - ضع AI agent address في العقد
   - شغّل auto-execution
   - راقب التوصيات

3. **راقب Analytics**
   - افتح Dune dashboard
   - شاهد TVL يزيد
   - تتبع أداء AI

---

**🎉 مبروك! مشروعك الآن يعمل على Flow Blockchain!**

للمساعدة:
- Discord: [Flow Discord](https://discord.gg/flow)
- Docs: [Flow Documentation](https://developers.flow.com)
- GitHub Issues: قدم issue إذا واجهت مشكلة

