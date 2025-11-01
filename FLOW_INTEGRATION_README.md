# 🌊 AION AI Agent - Flow Blockchain Integration

> **AI-Powered DeFi Vault على Flow Blockchain مع Actions، Scheduled Transactions، وDune Analytics**

---

## 📋 نظرة عامة

تم تطوير AION AI Agent ليعمل على **Flow Blockchain** مع دعم كامل لـ:

- ✅ **Flow Actions** - نظام Actions قابل للاكتشاف والتنفيذ (FLIP-338)
- ✅ **Scheduled Transactions** - تنفيذ تلقائي مجدول للاستراتيجيات
- ✅ **Dune Analytics Integration** - تحليلات شاملة مع أحداث منظمة
- ✅ **AI-Powered Executor** - منفذ ذكي يستمع للأحداث وينفذ Actions

---

## 🏗️ بنية المشروع

```
AION_AI_Agent-fort/
│
├── cadence/                          # 🔵 Flow Smart Contracts
│   ├── contracts/
│   │   ├── ActionRegistry.cdc       # سجل Actions
│   │   └── AIONVault.cdc            # العقد الأساسي
│   ├── transactions/                 # معاملات التنفيذ
│   │   ├── deposit.cdc
│   │   ├── rebalance.cdc
│   │   └── withdraw.cdc
│   └── scripts/                      # سكريبتات القراءة
│       └── get_vault_stats.cdc
│
├── flow-executor/                    # 🟢 Node.js Executor
│   ├── src/
│   │   ├── index.js                 # النقطة الرئيسية
│   │   ├── eventListener.js         # مراقب الأحداث
│   │   ├── actionBuilder.js         # بناء Actions
│   │   ├── scheduler.js             # جدولة المعاملات
│   │   └── config.js                # الإعدادات
│   ├── package.json
│   └── .env.example
│
├── dune-analytics/                   # 📊 Dune Dashboards
│   ├── queries/
│   │   ├── tvl_over_time.sql
│   │   ├── rebalance_history.sql
│   │   ├── ai_recommendations.sql
│   │   ├── action_analytics.sql
│   │   └── user_earnings.sql
│   └── dashboard-config.json
│
├── contracts/                        # العقود الموجودة (Solidity)
│   └── src/
│       └── AIONVault.sol
│
├── flow.json                         # Flow CLI Configuration
└── FLOW_INTEGRATION_README.md       # هذا الملف
```

---

## 🚀 دليل البدء السريع

### المتطلبات الأساسية

1. **Flow CLI** - لنشر العقود
```bash
sh -ci "$(curl -fsSL https://raw.githubusercontent.com/onflow/flow-cli/master/install.sh)"
```

2. **Node.js** (v18+) - للـExecutor
```bash
# تحقق من الإصدار
node --version
```

3. **Flow Wallet** - للتوقيع على المعاملات
- احصل على wallet من [Flow Port](https://port.onflow.org/)

---

### الخطوة 1️⃣: إعداد Flow CLI

```bash
# انتقل لمجلد المشروع
cd "/Users/s/ming-template/base hack/AION_AI_Agent -fort"

# تهيئة Flow (إذا لم يتم)
flow init

# إنشاء حساب testnet جديد
flow keys generate
```

**احفظ المفاتيح!** سنحتاجها في `flow.json`

---

### الخطوة 2️⃣: تحديث flow.json

افتح `flow.json` وأضف معلومات حسابك:

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

### الخطوة 3️⃣: نشر العقود على Testnet

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

**✅ احفظ عناوين العقود المنشورة!**

---

### الخطوة 4️⃣: تثبيت Executor

```bash
cd flow-executor

# تثبيت التبعيات
npm install

# نسخ ملف البيئة
cp .env.example .env
```

عدّل `.env`:

```bash
FLOW_NETWORK=testnet
AION_VAULT_ADDRESS=0xYOUR_VAULT_ADDRESS
ACTION_REGISTRY_ADDRESS=0xYOUR_REGISTRY_ADDRESS
EXECUTOR_PRIVATE_KEY=your_executor_private_key
AUTO_EXECUTE=false
MIN_CONFIDENCE=80
```

---

### الخطوة 5️⃣: تشغيل Executor

```bash
# تشغيل عادي
npm start

# تطوير (مع auto-reload)
npm run dev
```

**يجب أن ترى:**
```
🚀 Initializing AION Flow Executor...
✅ Executor initialized successfully
📡 Connected to: https://rest-testnet.onflow.org
📝 Monitoring contracts:
   - AIONVault: 0xYOUR_ADDRESS
   - ActionRegistry: 0xYOUR_ADDRESS
🎬 Starting event monitoring...
✅ AION Flow Executor is now running
```

---

## 🔧 كيفية الاستخدام

### إيداع (Deposit)

```bash
flow transactions send ./cadence/transactions/deposit.cdc \
  --arg UFix64:1.5 \
  --network=testnet \
  --signer=testnet-account
```

### سحب (Withdraw)

```bash
flow transactions send ./cadence/transactions/withdraw.cdc \
  --arg UFix64:0.5 \
  --network=testnet \
  --signer=testnet-account
```

### Rebalance (AI Agent فقط)

```bash
flow transactions send ./cadence/transactions/rebalance.cdc \
  --arg String:"Venus" \
  --arg String:"PancakeSwap" \
  --arg UFix64:10.0 \
  --arg String:"AI Recommendation - Higher APY" \
  --network=testnet \
  --signer=ai-agent-account
```

### قراءة إحصائيات Vault

```bash
flow scripts execute ./cadence/scripts/get_vault_stats.cdc \
  --arg Address:0xYOUR_VAULT_ADDRESS \
  --network=testnet
```

---

## 🤖 تسجيل Action جديد

```bash
# من خلال Flow CLI
flow transactions send ./cadence/transactions/register_action.cdc \
  --arg String:"optimize_yield" \
  --arg String:"Optimize Yield" \
  --arg String:"AI-powered yield optimization" \
  --arg Address:0xVAULT_ADDRESS \
  --arg String:"rebalance" \
  --arg String:'{"from":"String","to":"String","amount":"UFix64"}' \
  --arg String:"optimize" \
  --arg UInt8:5 \
  --network=testnet \
  --signer=testnet-account
```

أو **برمجياً** من الـExecutor:

```javascript
const action = await actionBuilder.buildRegisterActionAction({
    id: "auto_harvest",
    name: "Auto Harvest Rewards",
    description: "Automatically harvest and compound rewards",
    contractAddress: "0xVaultAddress",
    method: "harvestAndCompound",
    schema: '{"minYield":"UFix64"}',
    category: "automation",
    riskLevel: 3
});

await executor.executeAction(action);
```

---

## 📊 إعداد Dune Analytics

### 1. إنشاء حساب Dune

- اذهب إلى [dune.com](https://dune.com)
- سجل حساب مجاني

### 2. رفع Queries

انسخ محتوى الملفات من `dune-analytics/queries/` وأنشئ query جديد لكل ملف:

1. **TVL Over Time** → `tvl_over_time.sql`
2. **Rebalance History** → `rebalance_history.sql`
3. **AI Recommendations** → `ai_recommendations.sql`
4. **Action Analytics** → `action_analytics.sql`
5. **User Earnings** → `user_earnings.sql`

### 3. إنشاء Dashboard

1. Dashboard جديد → "AION AI Vault - Flow"
2. أضف Queries السابقة
3. عدّل Visualizations:
   - TVL → Line Chart
   - Rebalances → Table
   - AI Recs → Combo Chart
   - Actions → Bar Chart
   - Users → Table

### 4. تحديث Parameters

في كل Query، استبدل:
```sql
{{aion_vault_address}} → عنوان عقد Vault الخاص بك
{{action_registry_address}} → عنوان عقد ActionRegistry
```

---

## 🎯 سيناريوهات الاستخدام

### سيناريو 1: إيداع تلقائي مع توصية AI

```javascript
// 1. المستخدم يودع
await vault.deposit(amount);

// 2. AI يحلل ويوصي
await vault.postRecommendation({
    strategies: ["Venus", "PancakeSwap"],
    apys: [15.2, 12.8],
    riskScore: 35,
    metadataCID: "Qm...",
    confidence: 87
});

// 3. Executor يلتقط التوصية
eventListener.on('StrategyRecommendation', async (event) => {
    if (event.confidence >= 80) {
        // ينفذ تلقائياً
        await executeRebalance(event);
    }
});
```

### سيناريو 2: Scheduled Rebalance

```javascript
// جدولة rebalance بعد ساعتين
const scheduleId = await scheduler.scheduleAction(
    rebalanceAction,
    7200 // 2 hours in seconds
);

console.log(`Scheduled: ${scheduleId}`);
// Output: ⏰ Scheduled action: Rebalance Strategy
//         Execute at: 2025-11-01 16:30:00
```

### سيناريو 3: تتبع أداء AI

```sql
-- Query في Dune
SELECT 
    COUNT(*) as total_recommendations,
    AVG(confidence) as avg_confidence,
    SUM(CASE WHEN executed THEN 1 ELSE 0 END) as executed_count,
    100.0 * SUM(CASE WHEN executed THEN 1 ELSE 0 END) / COUNT(*) as execution_rate
FROM ai_recommendations
WHERE rec_timestamp >= NOW() - INTERVAL '30' DAY;
```

---

## 🔐 الأمان

### Best Practices

1. **لا تشارك Private Keys أبداً**
```bash
# استخدم .env وأضف لـ .gitignore
echo ".env" >> .gitignore
```

2. **حدد صلاحيات AI Agent**
```cadence
// في AIONVault.cdc
pub fun rebalance(...) {
    pre {
        executor == self.aiAgentAddress: "Only AI Agent"
    }
}
```

3. **راجع Transactions قبل التوقيع**
```bash
# استخدم --dry-run للاختبار
flow transactions send ... --dry-run
```

4. **Circuit Breaker للطوارئ**
```javascript
if (lossPercentage > 10) {
    await vault.emergencyPause();
    console.log('🚨 Emergency pause activated!');
}
```

---

## 🧪 الاختبار

### اختبار العقود (Cadence)

```bash
# تشغيل Flow Emulator
flow emulator

# في terminal آخر - نشر واختبار
flow project deploy --network=emulator
flow transactions send ./cadence/transactions/deposit.cdc \
  --arg UFix64:1.0 \
  --network=emulator
```

### اختبار الـExecutor

```bash
cd flow-executor
npm test
```

### اختبار متكامل

```bash
# 1. شغّل Emulator
flow emulator

# 2. انشر العقود
flow project deploy --network=emulator

# 3. شغّل Executor
cd flow-executor && npm start

# 4. أرسل test deposit
flow transactions send ../cadence/transactions/deposit.cdc \
  --arg UFix64:5.0 \
  --network=emulator
```

---

## 📈 مقاييس النجاح

### للهاكاثون (Forte Hacks)

| Track | Deliverable | Status |
|-------|------------|--------|
| **Killer App** | One-click optimize UI | ✅ |
| **Flow Forte Actions** | ActionRegistry + Executor | ✅ |
| **Existing Code Integration** | Solidity → Cadence migration | ✅ |
| **Dune Analytics** | 5 comprehensive queries + dashboard | ✅ |

### KPIs الرئيسية

- **TVL** - Total Value Locked
- **AI Accuracy** - نسبة التوصيات المنفذة
- **User Growth** - عدد المستخدمين الجدد
- **Action Executions** - عدد Actions المنفذة
- **Gas Efficiency** - متوسط Gas المستخدم

---

## 🐛 استكشاف الأخطاء

### المشكلة: "Could not borrow reference to AIONVault"

**الحل:**
```bash
# تأكد من نشر العقد
flow accounts get 0xYOUR_ADDRESS --network=testnet
```

### المشكلة: Executor لا يلتقط الأحداث

**الحل:**
```javascript
// تحقق من POLL_INTERVAL في .env
POLL_INTERVAL=3000  # خفض إلى 3 ثوانٍ

// تحقق من contract addresses
console.log(config.AION_VAULT_ADDRESS);
```

### المشكلة: Transaction failed

**الحل:**
```bash
# شاهد logs مفصلة
flow transactions send ... --log-level=debug
```

---

## 📚 موارد إضافية

- [Flow Documentation](https://developers.flow.com/)
- [Cadence Language Guide](https://cadence-lang.org/)
- [Flow FCL (JavaScript SDK)](https://github.com/onflow/fcl-js)
- [Dune Analytics Docs](https://dune.com/docs/)
- [FLIP-338: Flow Actions](https://github.com/onflow/flips/pull/338)

---

## 🤝 المساهمة

نرحب بالمساهمات! 

```bash
# Fork الـrepo
# أنشئ branch جديد
git checkout -b feature/amazing-feature

# Commit تغييراتك
git commit -m "Add amazing feature"

# Push للـbranch
git push origin feature/amazing-feature

# افتح Pull Request
```

---

## 📄 الترخيص

MIT License - انظر [LICENSE](LICENSE) للتفاصيل.

---

## 🎬 Demo Video Script

**للهاكاثون - سكريبت الفيديو (2 دقيقة):**

1. **0:00-0:15** - عرض Dashboard (TVL, Users, AI Recommendations)
2. **0:15-0:30** - Deposit من UI → Event يظهر في Executor
3. **0:30-0:50** - AI يقترح rebalance → تنفيذ تلقائي
4. **0:50-1:10** - عرض Dune Dashboard (الـQueries والـCharts)
5. **1:10-1:30** - ActionRegistry + Scheduled Transactions
6. **1:30-1:50** - كود عملي (Cadence + Node.js executor)
7. **1:50-2:00** - Closing - الفوائد والابتكارات

---

## 🏆 الميزات التنافسية

### لماذا AION فريد؟

1. **🤖 AI-First** - أول vault على Flow بـAI مدمج
2. **⚡ Auto-Execution** - Executor ذكي يعمل 24/7
3. **📊 Data-Driven** - Dune analytics شامل
4. **🔧 Developer-Friendly** - Actions قابلة للتخصيص
5. **🔒 Secure** - أفضل ممارسات الأمان

---

## 📞 الدعم

- **Issues**: [GitHub Issues](https://github.com/your-repo/issues)
- **Discord**: [Join Community](#)
- **Email**: support@aion.ai

---

**🎉 مبروك! مشروعك جاهز للتنافس في Forte Hacks!**

ابدأ بـ:
```bash
flow project deploy --network=testnet
cd flow-executor && npm start
```


