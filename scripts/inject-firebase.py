#!/usr/bin/env python3
"""
inject-firebase.py
يُضيف Google Services classpath/plugin و Firebase BoM في ملفات Gradle.
الاستخدام: python3 scripts/inject-firebase.py

ملاحظة مهمة (إصلاح):
  لا يجوز إنشاء كتلة plugins {} في ROOT build.gradle قبل buildscript {}،
  لأن Gradle يفرض أن تأتي كل كتل buildscript {} قبل أي كتلة plugins {}.
  لذلك نُدرِج classpath الخاص بـ google-services داخل buildscript { dependencies } الموجودة.
"""
import re, sys, os

GS_CLASSPATH_KEY = "com.google.gms:google-services"   # صيغة النقطتين (classpath)
GS_PLUGIN_KEY    = "com.google.gms.google-services"   # صيغة النقاط (apply plugin/id)
GS_VERSION       = "4.4.2"

# ── 1. Root build.gradle ──────────────────────────────────────
ROOT_GRADLE = "android/build.gradle"

with open(ROOT_GRADLE, "r") as f:
    root = f.read()

if GS_CLASSPATH_KEY in root:
    print("✓ Root build.gradle: google-services classpath موجود مسبقاً")
else:
    classpath_line = "\n        classpath 'com.google.gms:google-services:%s'" % GS_VERSION
    inserted = False

    # (أ) الإدراج بعد classpath الخاص بـ Android Gradle Plugin (مضمون داخل buildscript.dependencies)
    m = re.search(r"classpath\s+['\"]com\.android\.tools\.build:gradle[^'\"]*['\"]", root)
    if m:
        root = root[:m.end()] + classpath_line + root[m.end():]
        inserted = True

    # (ب) احتياط: الإدراج داخل أول dependencies { } تتبع buildscript {
    if not inserted:
        bs_idx = root.find("buildscript")
        if bs_idx != -1:
            dep_idx = root.find("dependencies", bs_idx)
            if dep_idx != -1:
                brace_idx = root.find("{", dep_idx)
                if brace_idx != -1:
                    root = root[:brace_idx + 1] + classpath_line + root[brace_idx + 1:]
                    inserted = True

    # (ج) احتياط أخير: لا توجد buildscript إطلاقاً → ننشئ كتلة buildscript (وليست plugins)
    if not inserted:
        bs_block = (
            "buildscript {\n"
            "    repositories {\n"
            "        google()\n"
            "        mavenCentral()\n"
            "    }\n"
            "    dependencies {\n"
            "        classpath 'com.google.gms:google-services:%s'\n" % GS_VERSION +
            "    }\n"
            "}\n\n"
        )
        root = bs_block + root

    with open(ROOT_GRADLE, "w") as f:
        f.write(root)
    print("✓ Root build.gradle: أُضيف google-services classpath داخل buildscript")

# ── 2. App build.gradle ──────────────────────────────────────
APP_GRADLE = "android/app/build.gradle"

with open(APP_GRADLE, "r") as f:
    app = f.read()

# 2.1 تطبيق الـ plugin
if GS_PLUGIN_KEY in app:
    print("✓ App build.gradle: google-services plugin مطبَّق مسبقاً")
else:
    if re.search(r"apply plugin:\s*['\"]com\.android\.application['\"]", app):
        # أسلوب Capacitor 6: apply plugin
        app = re.sub(
            r"(apply plugin:\s*['\"]com\.android\.application['\"])",
            r"\1\napply plugin: 'com.google.gms.google-services'",
            app, count=1
        )
        print("✓ App build.gradle: أُضيف google-services (apply plugin)")
    elif re.search(r"id\s*['\"]com\.android\.application['\"]", app):
        # أسلوب plugins { id ... }
        app = re.sub(
            r"(id\s*['\"]com\.android\.application['\"])",
            r"\1\n    id 'com.google.gms.google-services'",
            app, count=1
        )
        print("✓ App build.gradle: أُضيف google-services (plugins id)")
    else:
        print("⚠ لم يُعثر على إعلان com.android.application — لم يُطبَّق google-services plugin")

# 2.2 إضافة Firebase dependencies
if "firebase-bom" in app:
    print("✓ App build.gradle: Firebase BoM موجود مسبقاً")
else:
    firebase_deps = (
        "\n    // Firebase BoM\n"
        "    implementation platform('com.google.firebase:firebase-bom:33.7.0')\n"
        "    implementation 'com.google.firebase:firebase-analytics'\n"
        "    implementation 'com.google.firebase:firebase-database'\n"
        "    implementation 'com.google.firebase:firebase-auth'\n"
    )
    if "dependencies {" in app:
        app = re.sub(r'(dependencies \{)', r'\1' + firebase_deps, app, count=1)
        print("✓ App build.gradle: أُضيفت Firebase dependencies")
    else:
        print("⚠ لم يُعثر على dependencies block!")

with open(APP_GRADLE, "w") as f:
    f.write(app)

print("\n=== Root build.gradle (أول 20 سطر) ===")
with open(ROOT_GRADLE) as f:
    for i, line in enumerate(f.readlines()[:20], 1):
        print(f"{i:3}: {line}", end="")

print("\n=== App build.gradle (أول 30 سطر) ===")
with open(APP_GRADLE) as f:
    for i, line in enumerate(f.readlines()[:30], 1):
        print(f"{i:3}: {line}", end="")
