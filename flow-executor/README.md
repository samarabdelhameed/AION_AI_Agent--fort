# 🟢 AION Flow Executor

> **Automated execution engine for AION AI Agent on Flow Blockchain**

## ما هو Executor؟

الـExecutor هو نظام Node.js ذكي يعمل كوسيط بين blockchain والعالم الخارجي. يقوم بـ:

- 👂 **الاستماع** للأحداث من عقود Flow (Deposits, AI Recommendations, etc.)
- 🤖 **اتخاذ القرارات** بناءً على قواعد مبرمجة أو AI
- ⚡ **تنفيذ Actions** تلقائياً (Rebalancing, Compounding, etc.)
- ⏰ **جدولة المعاملات** للتنفيذ المستقبلي
- 📊 **إرسال البيانات** إلى Dune Analytics

---

## 🚀 التثبيت

```bash
# من جذر المشروع
cd flow-executor

# تثبيت التبعيات
npm install

# نسخ ملف البيئة
cp .env.example .env
```

---

## ⚙️ الإعدادات

عدّل `.env`:

```bash
# Flow Network
FLOW_NETWORK=testnet
FLOW_ACCESS_NODE=https://rest-testnet.onflow.org

# Contract Addresses (من deploy-flow.sh)
AION_VAULT_ADDRESS=0xYOUR_VAULT_ADDRESS
ACTION_REGISTRY_ADDRESS=0xYOUR_REGISTRY_ADDRESS

# Executor Behavior
AUTO_EXECUTE=false          # تنفيذ تلقائي للتوصيات
MIN_CONFIDENCE=80           # الحد الأدنى للثقة (%)
REBALANCE_PERCENTAGE=100    # نسبة إعادة التوازن

# Scheduled Transactions
USE_SCHEDULED_TX=true       # استخدام المعاملات المجدولة
EXECUTION_DELAY=300         # تأخير التنفيذ (ثواني)

# Event Monitoring
POLL_INTERVAL=5000          # فاصل زمني للتحقق من الأحداث (ms)
BLOCK_LOOKBACK=100          # عدد الـblocks للفحص

# Security
EXECUTOR_PRIVATE_KEY=your_key_here
EXECUTOR_ADDRESS=0xYOUR_EXECUTOR_ADDRESS

# Logging
LOG_LEVEL=info
LOG_TO_FILE=true
```

---

## 🎮 الاستخدام

### تشغيل عادي

```bash
npm start
```

### وضع التطوير (مع auto-reload)

```bash
npm run dev
```

### Output المتوقع

```
🚀 Initializing AION Flow Executor...
✅ Executor initialized successfully
📡 Connected to: https://rest-testnet.onflow.org
📝 Monitoring contracts:
   - AIONVault: 0x123...
   - ActionRegistry: 0x456...
🎬 Starting event monitoring...
👂 Starting event listener...
   Starting from block: 12345678
✅ Event listener started (polling every 5000ms)
✅ AION Flow Executor is now running
   Press Ctrl+C to stop
```

---

## 📡 الأحداث المراقبة

| Event | Description | Auto-Action |
|-------|-------------|-------------|
| `Deposit` | مستخدم يودع أموال | تسجيل في Analytics |
| `Withdraw` | مستخدم يسحب أموال | تسجيل في Analytics |
| `StrategyRecommendation` | AI يقترح استراتيجية | تنفيذ إذا confidence >= MIN_CONFIDENCE |
| `Rebalance` | تنفيذ إعادة توازن | تسجيل في Analytics |
| `YieldRealized` | تحقيق عوائد | تسجيل في Analytics |
| `ActionExecuted` | تنفيذ Action | تسجيل الإحصائيات |

---

## 🔧 الوحدات (Modules)

### 1. Event Listener (`eventListener.js`)

يستمع للأحداث من blockchain:

```javascript
const listener = new EventListener(config);

listener.on('StrategyRecommendation', async (event) => {
    console.log('AI recommended:', event.recommendedStrategies);
});

await listener.start();
```

### 2. Action Builder (`actionBuilder.js`)

يبني معاملات Cadence:

```javascript
const builder = new ActionBuilder(config);

const rebalanceAction = await builder.buildRebalanceAction({
    fromStrategy: 'Venus',
    toStrategy: 'PancakeSwap',
    amount: 10.5,
    reason: 'Higher APY'
});
```

### 3. Scheduler (`scheduler.js`)

يجدول المعاملات للتنفيذ المستقبلي:

```javascript
const scheduler = new Scheduler(config);

// جدولة بعد ساعة
const scheduleId = scheduler.scheduleAction(action, 3600);

// إلغاء جدولة
scheduler.cancelSchedule(scheduleId);

// إحصائيات
const stats = scheduler.getStats();
// { total: 10, pending: 3, completed: 6, failed: 1 }
```

---

## 🤖 سيناريوهات التنفيذ التلقائي

### سيناريو 1: تنفيذ توصية AI تلقائياً

```javascript
// في .env
AUTO_EXECUTE=true
MIN_CONFIDENCE=85

// Executor يستمع
eventListener.on('StrategyRecommendation', async (event) => {
    if (event.confidence >= 85) {
        console.log('🎯 Executing recommendation...');
        
        const action = await actionBuilder.buildRebalanceAction({
            fromStrategy: 'current',
            toStrategy: event.recommendedStrategies[0],
            amount: calculateAmount(event),
            reason: `AI: ${event.confidence}% confidence`
        });
        
        await executeAction(action);
    }
});
```

### سيناريو 2: جدولة معاملة للتنفيذ بعد ساعتين

```javascript
const action = await buildAction(...);

const scheduleId = scheduler.scheduleAction(action, 7200);
console.log(`⏰ Scheduled: ${scheduleId}`);

// بعد ساعتين تلقائياً:
// ⚡ Executing scheduled action: Rebalance Strategy
// ✅ Scheduled action executed successfully
```

### سيناريو 3: إرسال بيانات لـDune عند كل Deposit

```javascript
eventListener.on('Deposit', async (event) => {
    await sendToAnalytics('deposit', {
        user: event.user,
        amount: event.amount,
        timestamp: event.timestamp,
        txHash: event.transactionId
    });
});
```

---

## 📊 Integration مع Dune

```javascript
// في config.js
ANALYTICS_WEBHOOK=https://your-webhook.com/events

// الـExecutor يرسل تلقائياً
async function sendToAnalytics(type, data) {
    await fetch(config.ANALYTICS_WEBHOOK, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type, data, timestamp: new Date() })
    });
}
```

---

## 🧪 الاختبار

```bash
# اختبارات الوحدة
npm test

# اختبار على Emulator
flow emulator &
npm start
```

---

## 🔐 الأمان

### ✅ Best Practices

1. **لا تشارك `.env` أبداً**
```bash
echo ".env" >> .gitignore
```

2. **استخدم مفاتيح منفصلة للتطوير والإنتاج**
```bash
# Development
EXECUTOR_PRIVATE_KEY=dev_key_here

# Production
EXECUTOR_PRIVATE_KEY=prod_key_here
```

3. **حدد صلاحيات الـExecutor**
```cadence
// فقط AI Agent يمكنه إعادة التوازن
pub fun rebalance(...) {
    pre {
        executor == self.aiAgentAddress
    }
}
```

4. **راقب Logs باستمرار**
```bash
tail -f logs/executor.log
```

---

## 🐛 استكشاف الأخطاء

### الـExecutor لا يلتقط الأحداث

```bash
# تحقق من الاتصال
curl https://rest-testnet.onflow.org

# تحقق من contract addresses
flow accounts get $AION_VAULT_ADDRESS --network=testnet

# خفض POLL_INTERVAL
POLL_INTERVAL=3000
```

### Transaction failed

```javascript
// أضف error handling
try {
    await executeAction(action);
} catch (error) {
    console.error('Failed:', error.message);
    // أرسل إشعار أو أعد المحاولة
}
```

### Out of Gas

```javascript
// زد limit
fcl.limit(2000)  // بدلاً من 1000
```

---

## 📈 المراقبة والإشعارات

### إضافة Webhook للإشعارات

```javascript
// عند حدوث خطأ
async function notifyError(error) {
    await fetch('https://hooks.slack.com/your-webhook', {
        method: 'POST',
        body: JSON.stringify({
            text: `🚨 Executor Error: ${error.message}`
        })
    });
}
```

### Metrics Dashboard

```javascript
setInterval(() => {
    const stats = {
        uptime: process.uptime(),
        eventsProcessed: eventListener.totalEvents,
        actionsExecuted: executor.totalActions,
        scheduledPending: scheduler.getPendingSchedules().length
    };
    
    console.log('📊 Stats:', stats);
}, 60000); // كل دقيقة
```

---

## 🚀 Production Deployment

### باستخدام PM2

```bash
# تثبيت PM2
npm install -g pm2

# تشغيل
pm2 start src/index.js --name aion-executor

# مراقبة
pm2 logs aion-executor

# إعادة تشغيل تلقائية
pm2 startup
pm2 save
```

### باستخدام Docker

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install --production

COPY . .

CMD ["node", "src/index.js"]
```

```bash
docker build -t aion-executor .
docker run -d --env-file .env aion-executor
```

---

## 📚 API Reference

### EventListener

```javascript
// Methods
listener.start()           // بدء الاستماع
listener.stop()            // إيقاف
listener.getCurrentBlock() // الحصول على رقم الـblock الحالي

// Events
listener.on(eventName, handler)
listener.emit(eventName, data)
```

### ActionBuilder

```javascript
// Methods
buildRebalanceAction({ from, to, amount, reason })
buildDepositAction({ amount })
buildWithdrawAction({ shares })
buildRegisterActionAction(actionData)
buildRecommendationAction(recommendationData)
```

### Scheduler

```javascript
// Methods
scheduleAction(action, delaySeconds)
cancelSchedule(scheduleId)
getSchedule(scheduleId)
getPendingSchedules()
getStats()
cleanup(olderThanMs)
```

---

## 🎯 Roadmap

- [ ] WebSocket support للـreal-time events
- [ ] Multi-network support (mainnet + testnet متزامنان)
- [ ] Advanced AI decision engine
- [ ] Automated testing suite
- [ ] Grafana dashboard integration
- [ ] Mobile notifications

---

## 🤝 Contributing

نرحب بالمساهمات! انظر [CONTRIBUTING.md](../CONTRIBUTING.md)

---

## 📄 License

MIT - See [LICENSE](../LICENSE)

---

**Made with ❤️ for Flow Forte Hacks**

