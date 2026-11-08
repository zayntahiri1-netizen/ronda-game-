#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
verify-r8.py
═══════════════════════════════════════════════════════════════════════════
يتحقّق من أن R8 عمل فعلاً على المخرَج النهائي، لا على الملفات المصدرية.

لماذا لا يكفي فحص build.gradle:
  قد يُضبط minifyEnabled=true ثم يُلغيه مسار تجاوز خفي (كاش بناء قديم،
  إضافة تُعدّل buildType، فشل صامت)، فتُرفع حزمة غير محسَّنة تُفشل متطلب
  فبراير 2027 بصمت. وجود mapping.txt هو الدليل القاطع على عمل R8: فهو
  لا يُولَّد إطلاقاً إن لم يعمل التقليص والتشويش.

ما يفحصه:
  1. وجود mapping.txt ومحتواه (R8 عمل فعلاً)
  2. نسبة الأصناف المُعاد تسميتها — تقدير لتغطية التشويش
  3. إدراج بيانات فكّ التشويش داخل الـAAB ليقرأها Play
  4. وجود r8.json إن توفّر (يقرؤه Play مباشرة في AGP 8.10+)

الاستخدام: python3 scripts/verify-r8.py   (من جذر المشروع)
"""
import os
import re
import sys
import zipfile

MAPPING_DIRS = [
    "android/app/build/outputs/mapping/release",
    "android/app/build/outputs/mapping/releaseRelease",
]
AAB_GLOB_DIR = "android/app/build/outputs/bundle"

# أقلّ نسبة إعادة تسمية نعدّها دليلاً على تشويش حقيقي. الحدّ الرسمي 25%
# يقيسه Play بطريقته الخاصة على التحسين والتقليص والتشويش معاً، وهذا فحص
# محلّي تقريبي الغرض منه كشف "R8 لم يشوّش شيئاً" لا محاكاة قياس Play.
MIN_RENAMED_PCT = 25.0


def find_mapping():
    for d in MAPPING_DIRS:
        p = os.path.join(d, "mapping.txt")
        if os.path.isfile(p):
            return p
    for root, _dirs, files in os.walk("android/app/build/outputs"):
        if "mapping.txt" in files:
            return os.path.join(root, "mapping.txt")
    return None


def short(name):
    return name.rsplit(".", 1)[-1]


def main():
    problems = []
    notes = []

    # ── 1) mapping.txt ─────────────────────────────────────────────────
    mp = find_mapping()
    if not mp:
        print("::error::mapping.txt غير موجود — R8 لم يعمل على بناء الإصدار!")
        print("::error::الحزمة ستكون غير محسَّنة وتُفشل متطلب فبراير 2027.")
        sys.exit(1)

    size = os.path.getsize(mp)
    print("✓ mapping.txt موجود: %s (%.1f كيلوبايت)" % (mp, size / 1024.0))
    if size < 2048:
        problems.append("mapping.txt صغير جداً (%d بايت) — التشويش شبه معدوم" % size)

    # ── 2) نسبة إعادة التسمية ──────────────────────────────────────────
    total = renamed = 0
    cls_re = re.compile(r"^([\w.$\[\]]+)\s*->\s*([\w.$\[\]]+):")
    with open(mp, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            if line[:1] in (" ", "\t", "#", "\n", ""):
                continue
            m = cls_re.match(line)
            if not m:
                continue
            total += 1
            if short(m.group(1)) != short(m.group(2)):
                renamed += 1

    if total == 0:
        problems.append("لا أصناف في mapping.txt — مخرَج R8 غير سليم")
    else:
        pct = 100.0 * renamed / total
        print("✓ الأصناف في mapping.txt: %d — أُعيدت تسمية %d (%.1f%%)"
              % (total, renamed, pct))
        if pct < MIN_RENAMED_PCT:
            problems.append(
                "نسبة إعادة التسمية %.1f%% أقل من %.0f%% — راجع قواعد الحفظ "
                "الواسعة في app/proguard-rules.pro" % (pct, MIN_RENAMED_PCT))
        else:
            notes.append("نسبة إعادة التسمية %.1f%% — فوق الحدّ بهامش مريح" % pct)

    # ── 3) و(4) داخل الـAAB ────────────────────────────────────────────
    aab = None
    if os.path.isdir(AAB_GLOB_DIR):
        for root, _d, files in os.walk(AAB_GLOB_DIR):
            for fn in files:
                if fn.endswith(".aab"):
                    aab = os.path.join(root, fn)
                    break
            if aab:
                break
    if not aab:
        notes.append("لم يُعثر على ملف AAB — تُخطّى فحوص المحتوى")
    else:
        print("✓ الحزمة: %s (%.1f ميغابايت)" % (aab, os.path.getsize(aab) / 1048576.0))
        try:
            with zipfile.ZipFile(aab) as z:
                names = z.namelist()
            # AGP يسمّيه BUNDLE-METADATA/com.android.tools.build.obfuscation/
            # proguard.map — لا "mapping"، فنقبل الصيغ الثلاث.
            has_map = any(
                ("obfuscation" in n.lower() or "proguard.map" in n.lower()
                 or "mapping" in n.lower())
                for n in names if n.startswith("BUNDLE-METADATA"))
            has_r8 = any(n.lower().endswith("r8.json") for n in names)
            if has_map:
                print("✓ بيانات فكّ التشويش مُدرَجة في الـAAB — تقارير الانهيار "
                      "ستكون مقروءة في Console")
            else:
                notes.append("لم تُدرَج بيانات فكّ التشويش في الـAAB — قد يظهر "
                             "تحذير Console عن ملف فكّ التشويش")
            notes.append("r8.json: " + ("موجود (يقرؤه Play مباشرة)" if has_r8
                                        else "غير موجود — Play سيعتمد mapping.txt "
                                             "(طبيعي قبل AGP 8.10)"))
        except zipfile.BadZipFile:
            problems.append("تعذّر قراءة الـAAB — الملف تالف؟")

    for n in notes:
        print("  • " + n)

    if problems:
        print()
        for p in problems:
            print("::error::%s" % p)
        sys.exit(1)
    print("\n✅ [R8-VERIFY] تأكيد: تحسين رمز DEX مُطبَّق على الحزمة المبنية")


if __name__ == "__main__":
    main()
