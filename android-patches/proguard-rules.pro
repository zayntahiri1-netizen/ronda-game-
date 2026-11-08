# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  Ronda Tahiro — قواعد R8 / ProGuard                                      ║
# ║                                                                          ║
# ║  سبب وجود هذا الملف:                                                     ║
# ║  تطلب Google Play اعتباراً من فبراير 2027 أن يكون رمز DEX محسَّناً بتغطية  ║
# ║  لا تقلّ عن 25% في التحسين والتقليص والتشويش بأداة مثل R8. التطبيقات      ║
# ║  التي لا تحقّق الحدّ "قد ينخفض ظهورها وتتقلّص إمكانات نشرها على Google    ║
# ║  Play". قالب Capacitor يشحن minifyEnabled=false، فالتشويش يبقى نحو 3%    ║
# ║  أي أقل من الحدّ بكثير.                                                  ║
# ║                                                                          ║
# ║  المبدأ المتَّبع هنا: قواعد حفظ ضيّقة ومحدّدة فقط. أي قاعدة واسعة من نوع  ║
# ║  -keep class ** { *; } أو -dontobfuscate أو -dontoptimize تُبقي النسبة    ║
# ║  منخفضة وتُفشل المتطلب، فهي ممنوعة في هذا الملف.                         ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# ──────────────────────────────────────────────────────────────────────────
# [R8-CAP-ANNOT] ⚠️ أهمّ قاعدة في هذا الملف — لا تُحذف.
#
# يقرأ Capacitor تعليق @CapacitorPlugin بالـreflection وقت التشغيل. وفي
# الوضع الكامل لـ R8 (وهو الافتراضي في AGP 8) لا يرى R8 مرجعاً ساكناً
# لأنواع هذه التعليقات، فيَعدّها غير مستخدمة ويُحوّل نتيجة getAnnotation()
# إلى null، فينهار التطبيق عند أول نداء إضافة يمسّ مسار الأذونات:
#     java.lang.NullPointerException at Bridge.getPermissionStates
#
# أضاف Capacitor هذه القاعدة إلى قواعده المُستهلكة في الإصدار 8.6.0 فقط،
# وهذا المشروع على 6.2.0 — فيجب تثبيتها هنا يدوياً.
#   المرجع: ionic-team/capacitor issue #8589
#
# ملاحظة: -keepattributes *Annotation* لا يكفي ولا يحلّ المشكلة، لأنه يحفظ
# سمات التعليقات لا أصناف التعليقات نفسها.
-keep @interface com.getcapacitor.annotation.** { *; }
-keep @interface com.getcapacitor.PluginMethod { *; }
-keep @interface com.getcapacitor.NativePlugin { *; }

# شبكة أمان إضافية: الحقول المخزَّنة التي يقرأ منها PluginHandle التعليق.
# إن لم توجد هذه الأعضاء في إصدار Capacitor الحالي فلا ضرر — R8 يتجاهل
# قاعدة لا تطابق شيئاً دون خطأ.
-keepclassmembers class com.getcapacitor.PluginHandle {
    java.lang.Class pluginClass;
    com.getcapacitor.annotation.CapacitorPlugin pluginAnnotation;
    com.getcapacitor.NativePlugin legacyPluginAnnotation;
    com.getcapacitor.annotation.CapacitorPlugin getPluginAnnotation();
    com.getcapacitor.NativePlugin getLegacyPluginAnnotation();
}

# ──────────────────────────────────────────────────────────────────────────
# [R8-CAP-PLUGINS] أصناف الإضافات وطرقها التي تُنادى بالاسم من JavaScript.
# يشحن Capacitor 6 هذه القواعد ضمن consumerProguardFiles (أُضيفت في 3.x)،
# ونُكرّرها صراحةً هنا كتوثيق وكشبكة أمان — التكرار لا يضرّ.
-keep @com.getcapacitor.annotation.CapacitorPlugin public class * {
    @com.getcapacitor.annotation.PermissionCallback <methods>;
    @com.getcapacitor.annotation.ActivityCallback <methods>;
    @com.getcapacitor.annotation.Permission <methods>;
    @com.getcapacitor.PluginMethod public <methods>;
}
-keep public class * extends com.getcapacitor.Plugin { *; }

# ──────────────────────────────────────────────────────────────────────────
# [R8-JSBRIDGE] الجسر بين WebView وJava: هذه الطرق تُنادى بالاسم من
# JavaScript، فلا يراها R8 مستخدمة. (قواعد AGP الافتراضية تحفظها أيضاً،
# والتصريح هنا يجعل الأمر موثَّقاً ومضموناً.)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ──────────────────────────────────────────────────────────────────────────
# [R8-ENTRY] نقطة الدخول: يُنشئها النظام بالاسم من المانيفست.
# (قواعد AGP المولَّدة تحفظ مكوّنات المانيفست تلقائياً — هذا توكيد صريح.)
# ملاحظة مقصودة: لا نحفظ حزمة التطبيق كاملة بـ{ *; } لأن ذلك يخفض النسبة.
-keep class com.rondatahiro.myapp.MainActivity { *; }

# ──────────────────────────────────────────────────────────────────────────
# [R8-ATTRS] السمات اللازمة للتعليقات والأنواع العامة والأصناف الداخلية.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses, EnclosingMethod

# [R8-TRACE] أبقِ أسماء الملفات وأرقام الأسطر حتى تبقى تقارير الانهيار في
# Play Console مقروءة. يُدرِج AGP ملف mapping.txt داخل الـAAB تلقائياً،
# فيستعمله Play لفكّ تشويش الأثر — وهذا يُسكت أيضاً تحذير Console عن
# "ملف فكّ التشويش غير مرفوع".
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ──────────────────────────────────────────────────────────────────────────
# ملاحظات على ما لم نكتبه هنا — مقصود:
#
#  • Firebase (analytics / database / auth) وGoogle Play Services وAdMob:
#    كلّها تشحن قواعدها المُستهلكة داخل حِزم AAR الخاصة بها، فيطبّقها R8
#    تلقائياً. لا حاجة لقواعد يدوية، وإضافة قواعد واسعة لها تخفض النسبة.
#
#  • لا قواعد لنماذج POJO الخاصة بـFirebase Database: التطبيق لا يحوي أي
#    رمز Java خاص به غير MainActivity — منطق اللعبة كلّه JavaScript داخل
#    WebView، وشبكة اللعب (PeerJS / Ably / PubNub / Photon / Supabase)
#    مكتبات JavaScript لا يمسّها R8 إطلاقاً لأنها ليست في DEX أصلاً.
#
#  • لا shrinkResources: تقليص الموارد محفوف بالخطر في تطبيقات Capacitor
#    لأن الموارد المُشار إليها بالاسم من JavaScript لا يراها المقلِّص،
#    وهو غير مطلوب لتحقيق حدّ الـ25%.
#
#  • لا android.enableR8.fullMode=false: تعطيل الوضع الكامل يخفض نسبة
#    التحسين التي يقيسها Play — والقواعد أعلاه تجعل الوضع الكامل آمناً.
