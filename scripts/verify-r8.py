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

    # [R8-DIAG] ترويسة mapping.txt تحمل هوية المُحسِّن ونسخته. وهي تحسم
    # سؤالاً لا يحسمه build.gradle: هل عمل R8 فعلاً، وأيّ نسخة منه؟
    with open(mp, "r", encoding="utf-8", errors="replace") as f:
        head = [f.readline() for _ in range(12)]
    for line in head:
        if re.match(r"^#\s*(compiler|min_api)", line):
            print("   %s" % line.strip().lstrip("# "))

    # ── 2) نسبة إعادة التسمية ──────────────────────────────────────────
    total = renamed = 0
    m_total = m_renamed = 0
    kept_by_pkg = {}
    cls_re = re.compile(r"^([\w.$\[\]]+)\s*->\s*([\w.$\[\]]+):")
    # سطر عضو: مُزاح، وفيه ( ) إن كان طريقة. قد يسبقه مدى أسطر "12:34:".
    mem_re = re.compile(r"^\s+(?:\d+:\d+:)?.*?\b([\w$]+)\([^)]*\)\s*->\s*([\w$<>]+)\s*$")
    cur_kept = None
    with open(mp, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            if line[:1] in ("#", "\n", ""):
                continue
            if line[:1] not in (" ", "\t"):
                m = cls_re.match(line)
                if not m:
                    cur_kept = None
                    continue
                total += 1
                src, dst = m.group(1), m.group(2)
                if short(src) != short(dst):
                    renamed += 1
                    cur_kept = None
                else:
                    cur_kept = src
                    # [R8-DIAG] أيّ الحزم تُقاوم التشويش؟ هذا ما يكشف أين
                    # تذهب النسبة: قاعدة حفظ واسعة عندك، أو مكتبة تشحن
                    # قواعدها الخاصة ولا حيلة فيها.
                    pkg = src.rsplit(".", 1)[0] if "." in src else "(بلا حزمة)"
                    parts = pkg.split(".")
                    pkg = ".".join(parts[:3]) if len(parts) > 3 else pkg
                    kept_by_pkg[pkg] = kept_by_pkg.get(pkg, 0) + 1
                continue
            mm = mem_re.match(line)
            if mm:
                m_total += 1
                if mm.group(1) != mm.group(2):
                    m_renamed += 1

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

    # [R8-DIAG] الطرق أكثر عدداً من الأصناف بكثير، وقياس Play ينصبّ على
    # الرمز لا على الأسماء وحدها — فنسبة الطرق أقرب إلى ما يراه Console.
    if m_total:
        print("✓ الطرق في mapping.txt: %d — أُعيدت تسمية %d (%.1f%%)"
              % (m_total, m_renamed, 100.0 * m_renamed / m_total))

    # [R8-DIAG] أكبر الحزم التي بقيت أسماؤها كما هي. إن ظهرت حزمة من رمزك
    # أنت أو من Capacitor في الصدارة فالسبب قاعدة حفظ واسعة يمكن تضييقها.
    # وإن كانت كلّها com.google.* فهي قواعد المكتبات نفسها ولا حيلة فيها.
    if kept_by_pkg:
        top = sorted(kept_by_pkg.items(), key=lambda kv: -kv[1])[:8]
        print("\n=== أكبر الحزم التي لم تُشوَّش (أين تذهب النسبة) ===")
        for pkg, n in top:
            print("   %6d  %s" % (n, pkg))

    # ── 2ج) [R8-MERGED-CONFIG] التهيئة المدموجة: الحقيقة الحاسمة ───────
    # Play يعرض «التحسين» و«التقليص» بشرطة حتى مع R8 كامل التفعيل، والسبب
    # الموثَّق أن -dontoptimize يُعطّل التحسين عالمياً. وهو قد لا يكون في
    # قواعدنا أصلاً: كل مكتبة تشحن قواعدها في consumerProguardFiles وتندمج
    # مع قواعدنا، فتكفي مكتبة واحدة لتُعطّله على التطبيق كلّه.
    # هذا الملف يكتبه R8 بنفسه (-printconfiguration) وفيه كل ما رآه.
    cfg = os.path.join(os.path.dirname(mp), "full-r8-config.txt")
    if not os.path.isfile(cfg):
        notes.append("full-r8-config.txt غير موجود — تقرير R8 المدموج "
                     "يظهر في البناء القادم بعد حقن -printconfiguration")
    else:
        with open(cfg, "r", encoding="utf-8", errors="replace") as f:
            cfg_lines = f.readlines()
        print("\n=== التهيئة المدموجة التي رآها R8: %d سطراً ===" % len(cfg_lines))
        killers = {"-dontoptimize": [], "-dontshrink": [], "-dontobfuscate": []}
        for i, line in enumerate(cfg_lines):
            s = line.strip()
            for k in killers:
                if s == k or s.startswith(k + " "):
                    # نلتقط ما قبلها: R8 يكتب تعليقاً باسم مصدر كل كتلة
                    src = ""
                    for j in range(i - 1, max(-1, i - 40), -1):
                        if cfg_lines[j].lstrip().startswith("#"):
                            src = cfg_lines[j].strip()
                            break
                    killers[k].append((i + 1, src))
        any_killer = False
        for k, hits in killers.items():
            if not hits:
                continue
            any_killer = True
            print("::warning::%s موجود في التهيئة المدموجة (%d مرّة) — "
                  "وهو ما يجعل Play يعرض شرطة بدل نسبة" % (k, len(hits)))
            for ln, src in hits[:5]:
                print("     سطر %d   مصدره على الأرجح: %s" % (ln, src or "(غير معروف)"))
        if not any_killer:
            print("   ✓ لا -dontoptimize ولا -dontshrink ولا -dontobfuscate "
                  "في التهيئة المدموجة")
            notes.append("التهيئة المدموجة نظيفة — لا مُعطِّل للتحسين من أي مكتبة")

    # [R8-DIAG] البذور: كل ما حفظته القواعد. عددها الكبير = تغطية منخفضة.
    seeds = os.path.join(os.path.dirname(mp), "r8-seeds.txt")
    if os.path.isfile(seeds):
        n = 0
        seed_pkg = {}
        with open(seeds, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                n += 1
                cls_name = line.split(":")[0].strip()
                if "." in cls_name:
                    parts = cls_name.rsplit(".", 1)[0].split(".")
                    key = ".".join(parts[:3]) if len(parts) > 3 else ".".join(parts)
                    seed_pkg[key] = seed_pkg.get(key, 0) + 1
        print("\n=== البذور المحفوظة: %d ===" % n)
        for pkg, c in sorted(seed_pkg.items(), key=lambda kv: -kv[1])[:8]:
            print("   %6d  %s" % (c, pkg))

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
