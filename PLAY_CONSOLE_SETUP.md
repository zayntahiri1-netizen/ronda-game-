# ⚙️ إقرارات Play Console الأحد عشر — بالترتيب

**اللعبة:** Ronda Tahiro · `com.rondatahiro.myapp` · منشورة في الإنتاج
**المطوّر:** Ahmed Bakkali Tahiri · **محدَّث:** 2026-11-08

المكان واحد لكلّها:
```
Play Console → Ronda Tahiro → Monitor and improve
            → Policy and programs → App content
```

الترتيب أدناه مقصود: الأسرع أولاً لتُنجز ستّة في دقائق، ثم ما يحتاج تفكيراً.

---

## ⚡ المجموعة الأولى — ثلاثة أجوبة قاطعة (دقيقتان)

| # | الإقرار | الجواب |
|---|---------|--------|
| 1 | التطبيقات المتعلّقة بالصحة | **ليس تطبيقاً صحّياً** |
| 2 | التطبيقات الحكومية | **ليس تطبيقاً حكومياً** |
| 3 | الميزات المالية | **لا يقدّم أي ميزات مالية** |

لا قروض ولا مدفوعات ولا عملات رقمية. المتجر مجمّد في الكود (`openShop`
يُخفي كل الباقات)، فلا وسيلة دفع أصلاً.

---

## ⚡ المجموعة الثانية — جوابان بـ«نعم» (دقيقة)

| # | الإقرار | الجواب | لماذا |
|---|---------|--------|-------|
| 4 | الإعلانات | **نعم، يحتوي على إعلانات** | لافتة AdMob أسفل الشاشة |
| 5 | المعرِّفات الإعلانية | **نعم، يستخدم معرّف الإعلانات** | الغرض: الإعلان والتسويق + التحليلات |

---

## 🔍 المجموعة الثالثة — تحقّق فقط، بلا تغيير غالباً (٣ دقائق)

### 6) سياسة الخصوصية
```
الرابط = https://ronda-e11cd.web.app/privacy
```
إن كان مسجَّلاً بصيغة `privacy.html` فهو يعمل أيضاً (إعادة توجيه تلقائية)،
لكن حدّثه للصيغة النظيفة متى شئت.

### 7) تفاصيل تسجيل الدخول (App access)
الجواب الصحيح: **«All functionality is available without special access»**

اللعبة واللعب الجماعي ولوحة الترتيب تعمل كلّها بلا تسجيل دخول. الحفظ
السحابي وحده يحتاجه، ويستطيع المراجِع تجربته بحساب Google الخاص به.
غيّره **فقط** لو حجبتَ لاحقاً محتوىً خلف تسجيل الدخول.

### 8) حالة التسجيل كجهة تجارية وبنود الخدمة
أنجزته في 5 نونبر 2026. يبقى أمران:

- **ضع رابط بنود الخدمة فيه:** `https://ronda-e11cd.web.app/terms`
  (من يصرّح trader يُطلب منه رابط البنود لكل تطبيق)
- **تحقّق من إقرار مستوى الحساب** — لا يظهر في هذه القائمة لأنها
  تعرض إقرارات التطبيق وحدها:
  ```
  Manage account → Account details → About you
  ```
  هذا هو الإقرار الذي يحمل الموعد النهائي **1 فبراير 2027**.
  عدم إنجازه يؤدّي إلى حجب التحديثات وإزالة التطبيق **عالمياً**.

---

## 🎯 المجموعة الرابعة — الثلاثة التي تحتاج تفكيراً

### 9) الجمهور المستهدف والمحتوى

**اختر «18 سنة فما فوق» وحدها. لا تؤشّر على أي فئة دونها.**

السبب: اللعبة فيها **رهان بالذهب** (١٠٠ إلى ٥٠٬٠٠٠ ذهبية تُخصم عند دخول
المباراة ويأخذها الفائز). سياسات العائلات في Google Play تعدّ «القمار
الحقيقي أو المحاكى» مخالفةً في التطبيقات الموجَّهة للأطفال. واختيار
13–17 يُدخلك في «الجمهور المختلط» بمتطلّبات إضافية ومخاطرة بالمخالفة.

واختيار 18+ متّسق مع إعدادك الحالي في `capacitor.config.json`:
`tagForChildDirectedTreatment: false`.

- *هل قد تجذب صفحتك في المتجر الأطفال دون قصد؟* → **لا**

### 10) تقييمات المحتوى

استبيان IARC. صياغة الأسئلة تختلف قليلاً حسب المنطقة، لكن معناها:

| السؤال | جوابك |
|--------|-------|
| الفئة | **لعبة** |
| عنف | لا |
| محتوى جنسي أو عُري | لا |
| ألفاظ نابية | لا |
| مخدّرات أو كحول أو تبغ | لا |
| **قمار محاكى / مواضيع قمار** | **نعم** ← لا تُخفِ هذا |
| هل تُشترى العملة الافتراضية بمال حقيقي؟ | **لا** (المتجر مجمّد) |
| هل تُصرَف الأرباح نقداً؟ | **لا** |
| هل يتفاعل اللاعبون أو يتبادلون محتوى؟ | **نعم** (غرف، أسماء، صور) |
| هل تُشارَك مواقع اللاعبين؟ | لا |
| هل تُشترى سلع رقمية؟ | **لا** |
| هل يحتوي على إعلانات؟ | **نعم** |

> إخفاء القمار المحاكى هو تحديداً ما يُسقِط التقييم ويُعرّض التطبيق
> للإزالة عند أول مراجعة. صرّح به، فهو **مسموح** ما دام بلا مال حقيقي.

### 11) أمان البيانات — الأهم، لأنك مخالف اليوم

آخر تعديل 18 أبريل 2026، أي قبل تسجيل Google والحفظ السحابي بكثير.

**الشاشة ١ — Overview:** اقرأ ثم **Next**.

**الشاشة ٢ — Data collection and security:**

| السؤال | الجواب |
|--------|--------|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes** |
| Do you provide a way for users to request that their data is deleted? | **Yes** |

**الشاشة ٣ — Data types:** أشّر على هذه، وأبقِ `Device or other IDs`:

- Personal info → **Name** · **Email address** · **User IDs**
- Photos and videos → **Photos**
- App activity → **Other actions**

**الشاشة ٤ — Data usage and handling:** اضغط **Start** عند كل نوع.
الجوابان الأولان واحد في الخمسة:

- *collected, shared, or both?* → **Collected** فقط
  (Supabase مزوّد خدمة يعالج نيابةً عنك، وهذا ليس «مشاركة» اصطلاحاً)
- *processed ephemerally?* → **No**

أمّا الثالث فيختلف — **ولا تعمّمه**:

| النوع | required أم users can choose؟ | الغرض |
|------|------------------------------|-------|
| Name | **Data collection is required** | App functionality · Account management |
| User IDs | **Data collection is required** | App functionality · Account management |
| Other actions | **Data collection is required** | App functionality |
| Email address | **Users can choose** | Account management |
| Photos | **Users can choose** | App functionality |

> لماذا «required» في الثلاثة الأولى؟ لأن `savePlayerStats` ثم `_lbOnLogin`
> يَنشران اسمك ومعرّفك وإحصائياتك إلى Supabase **بعد ثانيتين من إقلاع
> اللعبة، بلا تسجيل دخول**، ولا يوجد في الكود خيار لإيقاف ذلك.

**لا تلمس** `Device or other IDs`: يبقى Collected **و Shared** (معرّف
الإعلانات يذهب إلى AdMob، وهو طرف ثالث فعلاً لا مزوّد خدمة).

**الشاشة ٥:** راجع المعاينة ثم **Submit** (لا «Save as draft»).
المراجعة تصل إلى **٧ أيام**، ولا يلزمك إصدار جديد من التطبيق.

> ⏱ **توقيت:** تسجيل Google لم يُنشر بعد، فالبريد لا يجمعه التطبيق الحيّ
> اليوم. ارفع الحزمة الجديدة أولاً ثم قدّم النموذج بالخمسة معاً، فيتطابق
> النموذج مع البناء.

---

# 🖥️ ويندوز — Google Play Games on PC

لا يحتاج بناءً منفصلاً: **نفس حزمة AAB** تعمل، لأن اللعبة WebView تعمل
بالفأرة أصلاً. تحقّقنا في الكود:

| التفاعل | بالفأرة؟ |
|---------|----------|
| لعب ورقة | ✅ `click` موجود (السحب بالإصبع إضافة لا بديل) |
| إخفاء الشرح التفاعلي | ✅ `pointerdown` |
| إغلاق النوافذ المنبثقة | ✅ نقر الخلفية |
| بقيّة الأزرار | ✅ 315 مُعالِج `onclick` |

**أ) أضف عامل الشكل:**
```
Release → Advanced settings → Form factors
       → + Add form factor → Google Play Games on PC
       → Use the same release track and artifacts as your mobile app
```

**ب) الاشتراك:**
```
نفس الصفحة → Manage → ✔ Opt-in → Save → Publish
```
بلا «Publish» لا يُفعَّل العامل وسيفشل الإرسال.

**ج) مسار الاختبار:**
```
Release → Test → Closed testing → Create track
  الاسم:    Play multiplatform users        ← بالحرف
  المختبرون: Google Groups →
             play-multiplatform-test-track@googlegroups.com
  الدول:     إن قيّدتها فأدخِل الولايات المتحدة والمملكة المتحدة إلزاماً
```
ثم `Create release` → نفس AAB → `Start roll-out`.

**د) بطاقات اللعبة (اختيارية):**
```
Grow → Store presence → Main store listing
  Feature graphic: PNG/JPG · 16:9 · ≤15MB · كل ضلع 720–7680px · بلا نصّ
  Logo:            PNG · 600×400 · ≤8MB · خلفية شفّافة
```
يُضبطان **معاً** وإلّا رفض Console الحفظ.

> بعد التفعيل، كلّ تحديث للهاتف يلزمه تحديث للحاسوب.

---

# 🗄️ خارج Console — Supabase

تسجيل Google والحفظ السحابي **لا يعملان** قبل هذه الأربعة:

| # | المهمة | الملف |
|---|--------|------|
| 1 | شغّل سكربت جدول البوتات | `supabase/01_bot_stats.sql` |
| 2 | انشر الدالة الطرفية | `supabase/functions/update-bot-stats/` |
| 3 | شغّل سكربت الحفظ السحابي | `supabase/02_cloud_save.sql` |
| 4 | فعّل مزوّد Google + رابط إعادة التوجيه | `supabase/GOOGLE_AUTH.md` |

الزرّ يفحص Supabase قبل أن يظهر، فيبقى مخفياً حتى تُنجز رقم 4 — ولا
ينكسر شيء في الإنتاج بسبب التأجيل.

**وفي Google Cloud:**
```
Google Auth Platform → Branding
  Lien vers les Conditions d'utilisation = https://ronda-e11cd.web.app/terms
  Page d'accueil de l'application        = https://ronda-e11cd.web.app/play/
```

---

## المصادر

- [Trader status declaration](https://support.google.com/googleplay/android-developer/answer/17594752)
- [Google Play Families Policies](https://support.google.com/googleplay/android-developer/answer/9893335)
- [Content rating requirements](https://support.google.com/googleplay/android-developer/answer/9859655)
- [Data safety form](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Submit your Google Play Games on PC game](https://developer.android.com/games/playgames/development-submit)
- [Prepare your app for review (App access)](https://support.google.com/googleplay/android-developer/answer/9859456)
