#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
inject-bundle-config.py
═══════════════════════════════════════════════════════════════════════
يُضيف كتلة bundle{} في android/app/build.gradle لتعطيل تقسيم الحزمة.

المشكلة التي يحلّها:
  عند بناء AAB، يُولّد Google Play حزمة أساس (base) + حزم مرافقة
  (config APKs) للغة والكثافة والمعمارية. إن وصلت حزمة الأساس وحدها
  دون المرافقة — بسبب استعادة نسخة احتياطية، نقل بين جهازين، تنزيل
  ناقص، أو مدير تطبيقات صارم — يعتبر النظام التثبيت ناقصاً ويمنع فتح
  التطبيق بنافذة:
      "Something went wrong — Check that Google Play is enabled…"
  وتظهر هذه النافذة من داخل التطبيق (بثيمه) قبل تحميل الواجهة.

  الفحص المسؤول عنها (MissingSplitsManager) منطقه:
    • لا توجد بيانات "splits.required"  → تثبيت سليم، لا نافذة ✅
    • توجد + لا حزم مرافقة مثبّتة       → تثبيت ناقص، تظهر النافذة ❌
    • توجد + حزمة مرافقة واحدة فأكثر    → تثبيت سليم ✅

  بتعطيل التقسيم لا تُولَّد حزم مرافقة أصلاً، فيستحيل أن تنقص.

الثمن: حجم تنزيل أكبر قليلاً (كل اللغات والكثافات والمعماريات في حزمة
واحدة). مقبول تماماً للعبة ورق صغيرة مقابل منع "التطبيق لا يفتح".

الاستخدام: python3 scripts/inject-bundle-config.py
"""
import re
import sys

GRADLE_PATH = "android/app/build.gradle"

BUNDLE_BLOCK = """
    // [NO-SPLITS] تسليم حزمة واحدة بدل حزم مقسّمة — يمنع نافذة
    // "Something went wrong / try reinstalling the app" التي تظهر عند
    // وصول حزمة الأساس دون الحزم المرافقة. لا حزم مرافقة = لا شيء ينقص.
    bundle {
        language { enableSplit = false }
        density  { enableSplit = false }
        abi      { enableSplit = false }
    }
"""


def main():
    try:
        with open(GRADLE_PATH, "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print("::error::%s غير موجود — هل نجح cap add android؟" % GRADLE_PATH)
        sys.exit(1)

    # idempotent: لا تُضِف مرتين
    if re.search(r"^\s*bundle\s*\{", content, re.M):
        print("✓ كتلة bundle موجودة مسبقاً — لا تغيير")
        sys.exit(0)

    # أدرِج مباشرة بعد سطر فتح كتلة android{} (أول سطر يبدأ بـ android {)
    m = re.search(r"^android\s*\{[ \t]*$", content, re.M)
    if not m:
        # صيغة بديلة: android { على سطر فيه محتوى بعده
        m = re.search(r"^android\s*\{", content, re.M)
    if not m:
        print("::error::تعذّر العثور على كتلة android{} في %s" % GRADLE_PATH)
        sys.exit(1)

    insert_at = m.end()
    content = content[:insert_at] + BUNDLE_BLOCK + content[insert_at:]

    with open(GRADLE_PATH, "w", encoding="utf-8") as f:
        f.write(content)

    print("✓ أُضيفت كتلة bundle{} — تقسيم الحزمة معطّل (language/density/abi)")

    # تحقُّق فوري من النتيجة
    with open(GRADLE_PATH, "r", encoding="utf-8") as f:
        check = f.read()
    ok = all(
        re.search(k + r"\s*\{\s*enableSplit\s*=\s*false\s*\}", check)
        for k in ("language", "density", "abi")
    )
    if not ok:
        print("::error::الحقن لم يكتمل بشكل صحيح")
        sys.exit(1)
    print("✅ [NO-SPLITS] تأكيد: language/density/abi معطّلة جميعاً")


if __name__ == "__main__":
    main()
