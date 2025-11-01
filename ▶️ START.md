# ▶️ ابدأ هنا - AION على Flow

## 🎯 5 خطوات = خلصت!

---

### 1️⃣ ولّد مفاتيح

```bash
flow keys generate
```

**احفظ:**
- 🔑 Private Key
- 🔓 Public Key

---

### 2️⃣ احصل على FLOW

https://testnet-faucet.onflow.org/

- الصق Public Key
- انسخ Address

---

### 3️⃣ أضف Account

```bash
./add-testnet-account.sh
```

- ادخل Address
- ادخل Private Key

---

### 4️⃣ تحقق

```bash
flow accounts get testnet-account --network=testnet
```

لازم تشوف Balance: 1000

---

### 5️⃣ انشر

```bash
./DEPLOY_NOW.sh
```

انتظر 2-3 دقائق...

---

## 🎉 خلصت!

لما تشوف:
```
🎉 Deployment Complete! 🎉
```

**نجحت!** احفظ العناوين اللي هتظهر

---

## 🚀 بعدها

```bash
# Terminal 1
cd flow-executor && npm start

# Terminal 2  
cd frontend && npm run dev
```

---

## 📚 محتاج تفاصيل؟

- **دليل عربي كامل:** `README_ARABIC.md`
- **خطوات سريعة:** `QUICKSTART.txt`
- **ملخص شامل:** `COMPLETE_SUMMARY.md`

---

**ابدأ دلوقتي!** 🚀

```bash
flow keys generate
```

