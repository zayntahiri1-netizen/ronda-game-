#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
inject-r8.py
═══════════════════════════════════════════════════════════════════════════
يُفعّل تحسين رمز DEX بـR8 في بناء الإصدار، ويثبّت قواعد الحفظ اللازمة.

المتطلب الذي يحلّه:
  تطلب Google Play اعتباراً من فبراير 2027 أن يكون التطبيق محسَّناً بتغطية
  لا تقلّ عن 25% في التحسين والتقليص والتشويش بأداة مثل R8. التطبيقات التي
  لا تحقّق الحدّ "قد ينخفض ظهورها وتتقلّص إمكانات نشرها على Google Play".

  قالب Capacitor يشحن release بـ minifyEnabled=false، فالتشويش يبقى نحو 3%.
  كما أن proguard-android.txt الافتراضي يحوي -dontoptimize، فلا يكفي تشغيل
  R8 وحده: يجب التحويل إلى proguard-android-optimize.txt.

ما يفعله هذا السكربت (كلّه idempotent):
  1. ينسخ android-patches/proguard-rules.pro → android/app/proguard-rules.pro
  2. يضبط minifyEnabled true داخل كتلة release وحدها (لا يمسّ debug)
  3. يحوّل proguard-android.txt → proguard-android-optimize.txt
  4. يضمن android.enableR8.fullMode=true في gradle.properties
     (تعطيل الوضع الكامل يخفض النسبة التي يقيسها Play)
  5. يتحقّق من النتيجة ويوقف البناء إن لم يكتمل الضبط

الاستخدام: python3 scripts/inject-r8.py
"""
import os
import re
import shutil
import sys

APP_GRADLE  = "android/app/build.gradle"
GRADLE_PROPS = "android/gradle.properties"
SRC_RULES   = "android-patches/proguard-rules.pro"
DST_RULES   = "android/app/proguard-rules.pro"

OPTIMIZE_FILE = "proguard-android-optimize.txt"
PLAIN_FILE    = "proguard-android.txt"


def find_block(text, start_idx):
    """يُعيد (بداية المحتوى، نهاية المحتوى) لكتلة {} تبدأ عند أول { بعد start_idx."""
    open_idx = text.find("{", start_idx)
    if open_idx == -1:
        return None
    depth = 0
    for i in range(open_idx, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return (open_idx + 1, i)
    return None


def main():
    # ── 1) انسخ قواعد الحفظ ─────────────────────────────────────────────
    if not os.path.isfile(SRC_RULES):
        print("::error::%s غير موجود — قواعد R8 مفقودة من المستودع" % SRC_RULES)
        sys.exit(1)
    if not os.path.isdir(os.path.dirname(DST_RULES)):
        print("::error::%s غير موجود — هل نجح cap add android؟" % os.path.dirname(DST_RULES))
        sys.exit(1)
    shutil.copyfile(SRC_RULES, DST_RULES)
    print("✓ نُسخت قواعد R8 → %s" % DST_RULES)

    # ── 2) عدّل كتلة release في app/build.gradle ────────────────────────
    try:
        with open(APP_GRADLE, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print("::error::%s غير موجود" % APP_GRADLE)
        sys.exit(1)

    m = re.search(r"\bbuildTypes\s*\{", content)
    if not m:
        print("::error::تعذّر العثور على buildTypes{} في %s" % APP_GRADLE)
        sys.exit(1)
    bt = find_block(content, m.start())
    if not bt:
        print("::error::كتلة buildTypes{} غير متوازنة الأقواس")
        sys.exit(1)
    bt_body = content[bt[0]:bt[1]]

    rm = re.search(r"\brelease\s*\{", bt_body)
    if not rm:
        print("::error::تعذّر العثور على كتلة release داخل buildTypes")
        sys.exit(1)
    rel = find_block(bt_body, rm.start())
    if not rel:
        print("::error::كتلة release{} غير متوازنة الأقواس")
        sys.exit(1)
    rel_body = bt_body[rel[0]:rel[1]]
    original_rel = rel_body

    # (أ) minifyEnabled → true (داخل release فقط)
    if re.search(r"\bminifyEnabled\s+(true|false)\b", rel_body):
        rel_body = re.sub(r"\bminifyEnabled\s+(true|false)\b",
                          "minifyEnabled true", rel_body, count=1)
    else:
        rel_body = "\n            minifyEnabled true" + rel_body

    # (ب) proguardFiles → ملف التحسين (الافتراضي يحوي -dontoptimize)
    if "proguardFiles" in rel_body or "proguardFile " in rel_body:
        rel_body = rel_body.replace("'%s'" % PLAIN_FILE, "'%s'" % OPTIMIZE_FILE)
        rel_body = rel_body.replace('"%s"' % PLAIN_FILE, '"%s"' % OPTIMIZE_FILE)
        if OPTIMIZE_FILE not in rel_body:
            print("::error::proguardFiles موجود لكن تعذّر تحويله إلى %s" % OPTIMIZE_FILE)
            print(rel_body)
            sys.exit(1)
        if "proguard-rules.pro" not in rel_body:
            rel_body = re.sub(
                r"(proguardFiles\s+getDefaultProguardFile\(\s*['\"]%s['\"]\s*\))" % re.escape(OPTIMIZE_FILE),
                r"\1, 'proguard-rules.pro'", rel_body, count=1)
    else:
        rel_body = ("\n            proguardFiles getDefaultProguardFile('%s'), 'proguard-rules.pro'"
                    % OPTIMIZE_FILE) + rel_body

    # ⚠️ لا shrinkResources: الموارد المُشار إليها بالاسم من JavaScript لا
    # يراها المقلِّص، وهو غير مطلوب لتحقيق حدّ الـ25%.

    if rel_body != original_rel:
        new_bt = bt_body[:rel[0]] + rel_body + bt_body[rel[1]:]
        content = content[:bt[0]] + new_bt + content[bt[1]:]
        with open(APP_GRADLE, "w", encoding="utf-8") as f:
            f.write(content)
        print("✓ كتلة release: minifyEnabled true + %s" % OPTIMIZE_FILE)
    else:
        print("✓ كتلة release مضبوطة مسبقاً — لا تغيير")

    # ── 3) الوضع الكامل لـR8 ────────────────────────────────────────────
    props = ""
    if os.path.isfile(GRADLE_PROPS):
        with open(GRADLE_PROPS, "r", encoding="utf-8") as f:
            props = f.read()
    if re.search(r"^\s*android\.enableR8\.fullMode\s*=\s*false", props, re.M):
        props = re.sub(r"^\s*android\.enableR8\.fullMode\s*=\s*false.*$",
                       "android.enableR8.fullMode=true", props, flags=re.M)
        print("✓ صُحّح android.enableR8.fullMode من false إلى true")
    elif not re.search(r"^\s*android\.enableR8\.fullMode\s*=", props, re.M):
        if props and not props.endswith("\n"):
            props += "\n"
        props += ("# [R8] الوضع الكامل يرفع نسبة التحسين التي يقيسها Play.\n"
                  "# قواعد الحفظ في app/proguard-rules.pro تجعله آمناً مع Capacitor 6.\n"
                  "android.enableR8.fullMode=true\n")
        print("✓ أُضيف android.enableR8.fullMode=true")
    else:
        print("✓ android.enableR8.fullMode مضبوط مسبقاً")
    with open(GRADLE_PROPS, "w", encoding="utf-8") as f:
        f.write(props)

    # ── 4) تحقُّق نهائي ─────────────────────────────────────────────────
    with open(APP_GRADLE, "r", encoding="utf-8") as f:
        chk = f.read()
    m2 = re.search(r"\bbuildTypes\s*\{", chk)
    bt2 = find_block(chk, m2.start())
    body2 = chk[bt2[0]:bt2[1]]
    rm2 = re.search(r"\brelease\s*\{", body2)
    rel2 = find_block(body2, rm2.start())
    final_rel = body2[rel2[0]:rel2[1]]

    problems = []
    if not re.search(r"\bminifyEnabled\s+true\b", final_rel):
        problems.append("minifyEnabled true غير موجود في كتلة release")
    if OPTIMIZE_FILE not in final_rel:
        problems.append("%s غير مستعمل — القواعد الافتراضية تحوي -dontoptimize" % OPTIMIZE_FILE)
    if "proguard-rules.pro" not in final_rel:
        problems.append("proguard-rules.pro غير مُدرَج في proguardFiles")
    if not os.path.isfile(DST_RULES):
        problems.append("%s غير موجود" % DST_RULES)
    else:
        with open(DST_RULES, "r", encoding="utf-8") as f:
            rules = f.read()
        if "com.getcapacitor.annotation" not in rules:
            problems.append("قاعدة تعليقات Capacitor الحرجة مفقودة (ستنهار الإضافات)")
        for bad in ("-dontobfuscate", "-dontoptimize", "-dontshrink"):
            if re.search(r"^\s*%s\b" % re.escape(bad), rules, re.M):
                problems.append("%s موجود في القواعد — سيُفشل حدّ الـ25%%" % bad)

    print("\n=== كتلة release النهائية ===")
    print("release {" + final_rel + "}")

    if problems:
        for p in problems:
            print("::error::%s" % p)
        sys.exit(1)
    print("✅ [R8] تأكيد: التحسين مُفعَّل وقواعد حفظ Capacitor مثبَّتة")


if __name__ == "__main__":
    main()
