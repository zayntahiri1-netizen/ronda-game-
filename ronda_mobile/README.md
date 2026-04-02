# 🎴 Ronda روندة — Mobile App

> تحويل لعبة روندة إلى تطبيق أصلي لـ Google Play Store و Apple App Store

---

## 📋 المحتويات

1. [متطلبات النظام](#متطلبات-النظام)
2. [الإعداد السريع](#الإعداد-السريع)
3. [نشر Android على Play Store](#android--google-play-store)
4. [نشر iOS على App Store](#ios--apple-app-store)
5. [هيكل المشروع](#هيكل-المشروع)
6. [الأسئلة الشائعة](#الأسئلة-الشائعة)

---

## متطلبات النظام

### للـ Android (يعمل على Windows/Mac/Linux)
| المتطلب | الإصدار | رابط |
|---------|---------|------|
| Node.js | 18+ | https://nodejs.org |
| Java JDK | 17+ | https://adoptium.net |
| Android Studio | Latest | https://developer.android.com/studio |
| Android SDK | API 34 | عبر Android Studio |

### للـ iOS (يتطلب Mac فقط)
| المتطلب | الإصدار |
|---------|---------|
| macOS | 13+ |
| Xcode | 15+ |
| Apple Developer Account | $99/سنة |

---

## الإعداد السريع

```bash
# 1. فك الضغط والدخول للمجلد
unzip ronda_mobile.zip
cd ronda_mobile

# 2. تشغيل سكريبت الإعداد (مرة واحدة فقط)
chmod +x scripts/*.sh
./scripts/setup.sh
```

هذا السكريبت يقوم بـ:
- ✅ تثبيت كل المكتبات
- ✅ تهيئة Capacitor
- ✅ إضافة Android و iOS
- ✅ توليد جميع الأيقونات وشاشات البداية
- ✅ ضبط جميع الإعدادات

---

## Android — Google Play Store

### الخطوة 1: بناء ملف AAB

```bash
./scripts/build-android-release.sh
```

سيسألك عن:
- بيانات شهادة التوقيع (إذا أول مرة)
- كلمة مرور Keystore

النتيجة: ملف `ronda-release.aab` ✅

> ⚠️ **مهم جداً:** احتفظ بملف `release-keystore.jks` في مكان آمن!
> بدونه لا يمكنك أبداً تحديث التطبيق.

### الخطوة 2: إنشاء حساب Play Console

1. اذهب إلى: https://play.google.com/console
2. ادفع رسوم التسجيل: **$25** (مرة واحدة فقط)
3. أنشئ تطبيقاً جديداً

### الخطوة 3: تعبئة معلومات التطبيق

#### المعلومات الأساسية
```
اسم التطبيق:         Ronda روندة
معرف التطبيق:        com.ronda.cardgame
الفئة:               ألعاب / ورق
التصنيف العمري:     +7 (مناسب للعائلة)
```

#### وصف قصير (80 حرف)
```
لعبة الورق المغربية الأصيلة - العب أونلاين مع أصدقائك!
```

#### وصف طويل
```
روندة — لعبة الورق المغربية الأصيلة التي تجمع العائلات والأصدقاء!

🎴 ميزات اللعبة:
• ألعاب متعددة: كلاسيكية مغربية (41 نقطة)، إسكوبا إسبانية (21 نقطة)، سريعة
• أوضاع اللعب: 1 ضد 1، 2 ضد 2، 4 لاعبين
• ذكاء اصطناعي بمستويات متعددة
• نظام أصدقاء ودعوات للعب
• لوحة متصدرين عالمية
• متجر ومكافآت يومية

🌍 العب مع أصدقائك في أي مكان في العالم!
```

### الخطوة 4: رفع الـ AAB

1. Play Console → إصدارات التطبيق → الإنتاج
2. "إنشاء إصدار جديد"
3. رفع `ronda-release.aab`
4. كتابة ملاحظات الإصدار
5. مراجعة ونشر

> المراجعة تستغرق: **3-7 أيام** للنشر الأول

---

## iOS — Apple App Store

> ⚠️ يتطلب جهاز Mac + حساب Apple Developer ($99/سنة)

### الخطوة 1: فتح المشروع في Xcode

```bash
npx cap open ios
```

### الخطوة 2: ضبط إعدادات Xcode

1. **Bundle Identifier:** `com.ronda.cardgame`
2. **Version:** `1.0.0`
3. **Build:** `1`
4. **Deployment Target:** iOS 14.0+
5. **Signing:** اختر Team من Apple Developer

### الخطوة 3: إنشاء Archive

1. Xcode → Product → Destination → "Any iOS Device (arm64)"
2. Product → **Archive**
3. Window → Organizer → Distribute App
4. "App Store Connect" → Next → Upload

### الخطوة 4: App Store Connect

1. اذهب إلى: https://appstoreconnect.apple.com
2. "تطبيقاتي" → "+"
3. Platform: iOS
4. Bundle ID: `com.ronda.cardgame`
5. أضف لقطات الشاشة (6.5 بوصة + 5.5 بوصة)
6. أكمل المعلومات وأرسل للمراجعة

> المراجعة تستغرق: **24-48 ساعة** عادةً

---

## هيكل المشروع

```
ronda_mobile/
├── 📄 package.json              ← تبعيات Capacitor
├── 📄 capacitor.config.json     ← إعدادات Capacitor الرئيسية
│
├── 🌐 www/                      ← محتوى الويب
│   ├── index.html               ← اللعبة الرئيسية
│   ├── manifest.json            ← إعدادات PWA
│   ├── sw.js                    ← Service Worker
│   └── icons/                   ← أيقونات PWA (تُولد تلقائياً)
│
├── 🎨 assets/
│   ├── icon.svg                 ← أيقونة التطبيق (1024×1024)
│   ├── splash.svg               ← شاشة البداية (2732×2732)
│   └── icon-foreground.svg      ← Adaptive icon foreground
│
├── 📜 scripts/
│   ├── setup.sh                 ← إعداد أولي شامل
│   ├── build-android-release.sh ← بناء APK/AAB للنشر
│   └── generate-assets.js       ← توليد الأيقونات
│
├── 🤖 android/                  ← مشروع Android (يُنشأ تلقائياً)
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── res/                 ← الأيقونات والـ splash
│
├── 🍎 ios/                      ← مشروع iOS (يُنشأ على Mac)
│   └── App/App/Assets.xcassets/
│
├── 🛠 android-patches/          ← ملفات Android يدوية
└── 📦 store-assets/             ← أصول المتاجر
    ├── play-store-icon-512.png
    ├── feature-graphic-1024x500.png
    └── app-store-icon-1024.png
```

---

## الأسئلة الشائعة

**س: هل يعمل التطبيق بدون انترنت؟**
ج: الواجهة تعمل offline، لكن اللعب الجماعي يحتاج انترنت.

**س: هل يمكن النشر بدون Mac لـ iOS؟**
ج: لا. Apple تشترط Mac + Xcode لبناء ملفات iOS.

**س: ما الفرق بين APK و AAB؟**
ج: AAB هو تنسيق Google الجديد للـ Play Store (أصغر حجماً). APK للتثبيت المباشر.

**س: كم يستغرق مراجعة Google Play؟**
ج: أول تطبيق: 3-7 أيام. التحديثات: 1-3 أيام.

**س: كيف أحدث الـ app بعد النشر؟**
ج: عدّل الكود → ارفع الـ Version في build.gradle → أعد البناء → ارفع AAB جديد.

---

## معلومات النشر

```
App ID:      com.ronda.cardgame
Version:     1.0.0
Min Android: 5.1 (API 22)
Min iOS:     14.0
```

---

*تم إعداد هذا المشروع بواسطة Claude - Anthropic*
