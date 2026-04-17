# 🛒 إعداد Google Play Billing — روندة

## الخطوة 1: تفعيل Google Play Billing في Play Console

1. افتح [Google Play Console](https://play.google.com/console)
2. اختر تطبيق **Ronda Tahiro**
3. من القائمة الجانبية: **Monetize → Products → In-app products**
4. اضغط **Create product**

---

## الخطوة 2: إضافة كل المنتجات (consumable)

أضف هذه المنتجات **بنفس الـ Product ID بالضبط**:

| Product ID               | الاسم              | السعر   |
|--------------------------|-------------------|---------|
| `ronda_coins_500`        | المبتدئ - 500 عملة  | $4.99   |
| `ronda_coins_1200`       | الناشئ - 1200 عملة  | $9.99   |
| `ronda_coins_2000`       | النشيط - 2000 عملة  | $14.99  |
| `ronda_coins_3000`       | قيمة ممتازة - 3000  | $19.99  |
| `ronda_coins_5000`       | المحترف - 5000 عملة | $29.99  |
| `ronda_coins_9000`       | الماسي - 9000 عملة  | $49.99  |
| `ronda_coins_13000`      | النجم - 13000 عملة  | $74.99  |
| `ronda_coins_20000`      | الملك - 20000 عملة  | $99.99  |
| `ronda_coins_30000`      | الأسطورة - 30000    | $149.99 |
| `ronda_coins_50000`      | القائد - 50000 عملة | $199.99 |
| `ronda_coins_80000`      | الإمبراطور - 80000  | $299.99 |
| `ronda_coins_120000`     | السلطان - 120000    | $499.99 |
| `ronda_coins_200000`     | أسطورة روندة        | $999.99 |
| `ronda_bundle_rondag`    | حزمة الرونداجي       | $11.99  |
| `ronda_bundle_hero`      | حزمة البطل           | $29.99  |
| `ronda_bundle_vip`       | حزمة VIP             | $89.99  |
| `ronda_bundle_season`    | حزمة الموسم          | $199.99 |
| `ronda_deal_daily`       | عرض اليوم            | $34.99  |

**نوع كل منتج: Managed product (consumable)**

---

## الخطوة 3: لماذا يعمل PayPal عبر Google Play؟

عندما يربط المستخدم حسابه في Google بـ PayPal:
```
إعدادات Google → مدفوعات → إضافة طريقة دفع → PayPal
```
كل عملية شراء من Google Play ستُخصم تلقائياً من PayPal.  
**أنت لا تحتاج لأي كود PayPal — Google تتكفل بكل شيء.**

---

## الخطوة 4: إضافة cordova-plugin-purchase

```bash
cd ronda_mobile
npm install cordova-plugin-purchase
npx cap sync android
```

---

## الخطوة 5: التحقق من المشتريات server-side (اختياري لكن مهم)

لمنع الغش، أرسل `purchaseToken` إلى Supabase Edge Function:

```javascript
// في _shopVerifyAndCredit (index.html)
const res = await fetch('https://YOUR_PROJECT.supabase.co/functions/v1/verify-purchase', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    purchaseToken,
    packageName: 'com.ronda.cardgame',
    productId: GPB_PRODUCT_IDS[pkg.id],
    playerId: P.id,
    coinsAmount: pkg.coins
  })
});
```

---

## ملاحظة مهمة

- Google تأخذ **15%** من كل عملية شراء (30% للسنة الأولى فوق مليون دولار)
- يجب **نشر التطبيق أولاً** في Google Play قبل أن تعمل IAP في الإنتاج
- للاختبار قبل النشر: أضف حسابك في **License Testers** في Play Console
