#!/usr/bin/env bash
#
# ⚠️ Termux: شغّله بـ«bash scripts/<الاسم>» لا «./scripts/<الاسم>».
#    Termux لا يملك /usr/bin/env فيفشل سطر shebang بـExec format error.
#    «bash <ملف>» يتجاهل shebang وصلاحية التنفيذ، ويعمل في Termux والـCI معاً.
# ╔══════════════════════════════════════════════════════════════╗
# ║  يُجمّع ما سيُنشر:                                            ║
# ║    /            ← اللعبة نفسها (www)                         ║
# ║    /play/       ← صفحة التعريف بالّلعبة                      ║
# ║    /terms.html  /privacy.html  /delete.html  ← بأربع لغات    ║
# ║                                                              ║
# ║  ⚠️ الصفحات القانونية تبقى في الجذر حتماً: روابطها مسجّلة     ║
# ║     في Play Console وGoogle Cloud ولا يجوز تغييرها.          ║
# ║  يستعمله preview.sh و deploy-site.sh فتكون المعاينة مطابقة.  ║
# ╚══════════════════════════════════════════════════════════════╝
set -e
cd "$(dirname "$0")/.."

OUT=".site-build"
rm -rf "$OUT"
mkdir -p "$OUT/play"

# 1) اللعبة في الجذر
cp -r www/. "$OUT/"

# 2) الصفحات القانونية والأصول المشتركة في الجذر (بجانب اللعبة)
cp site/terms.html site/privacy.html site/delete.html "$OUT/"
cp site/style.css  site/i18n.js                        "$OUT/"

# 2ب) app-ads.txt في الجذر حتماً — تزحف إليه AdMob على
#     https://ronda-e11cd.web.app/app-ads.txt ولا تقبله في مجلّد فرعي.
#     ⚠️ يجب أن يكون حقل «الموقع الإلكتروني» في صفحة المتجر هو النطاق
#        وحده بلا مسار: https://ronda-e11cd.web.app  — فالرابط المنتهي
#        بـ/play/ يُربك الزاحف ولا تتناوله الوثائق.
#     cleanUrls لا يمسّ .txt، وFirebase يخدمه بنوع text/plain تلقائياً.
cp site/app-ads.txt "$OUT/"

# 3) صفحة التعريف في /play/
cp site/landing.html "$OUT/play/index.html"

# 4) [CACHE-BUST] بصمة محتوى على أصول CSS/JS.
# ترويسات الاستضافة تخزّنها أسبوعاً، فبلا رقم نسخة يبقى الزائر على نسخة
# قديمة بعد كل تعديل — وهذا ما جعل مبدّل اللغة يظهر بلا تنسيق بعد أول نشر.
# البصمة تتغيّر مع المحتوى، فيُطلب ملف جديد فوراً، ويبقى التخزين الطويل
# نافعاً لأن الرابط ذاته لا يتغيّر ما لم يتغيّر الملف.
HASH=$(cat site/style.css site/i18n.js | md5sum | cut -c1-10)
find "$OUT" -name "*.html" -print0 | xargs -0 sed -i \
  -e "s|style\.css\"|style.css?v=$HASH\"|g" \
  -e "s|i18n\.js\"|i18n.js?v=$HASH\"|g"
echo "   بصمة الأصول: $HASH"

echo "✓ جاهز في $OUT"
echo "   /            → اللعبة"
echo "   /play/       → صفحة التعريف"
echo "   /terms.html  /privacy.html  /delete.html → قانونية (4 لغات)"
