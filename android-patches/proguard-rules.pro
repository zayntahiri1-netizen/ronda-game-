# ═══ ProGuard Rules — Ronda Tahiro ═══
# يحافظ هذا الملف على قابلية قراءة تقارير ANR والـ crash

# Capacitor core
-keep class com.getcapacitor.** { *; }
-keep class com.rondatahiro.myapp.** { *; }

# AdMob / Google Play Services
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep JavaScript interface classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Suppress warnings
-dontwarn com.google.android.gms.**
