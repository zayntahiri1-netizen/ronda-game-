#!/usr/bin/env bash
#
# ⚠️ Termux: شغّله بـ«bash scripts/<الاسم>» لا «./scripts/<الاسم>».
#    Termux لا يملك /usr/bin/env فيفشل سطر shebang بـExec format error.
#    «bash <ملف>» يتجاهل shebang وصلاحية التنفيذ، ويعمل في Termux والـCI معاً.
# ╔══════════════════════════════════════════════════════════════╗
# ║  نشر الموقع واللعبة على Firebase Hosting                     ║
# ║  الاستعمال:  ./scripts/deploy-site.sh                         ║
# ╚══════════════════════════════════════════════════════════════╝
set -e
cd "$(dirname "$0")/.."

GREEN='\033[0;32m'; YEL='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

# ── أداة Firebase ──────────────────────────────────────────────
# نستعمل npx لا تثبيتاً عاماً: أخفّ على Termux ولا يحتاج صلاحيات.
FB="npx --yes firebase-tools"

# ── تسجيل الدخول ───────────────────────────────────────────────
# --no-localhost ضرورية على الهاتف: لا يوجد متصفّح يستقبل رابط العودة،
# فتُعطيك الأداة رابطاً تفتحه يدوياً وتلصق الرمز الناتج.
if ! $FB projects:list >/dev/null 2>&1; then
  echo -e "${YEL}▶ سجّل دخولك بحساب Google الذي يملك مشروع ronda-e11cd${NC}"
  $FB login --no-localhost
fi

# ⚠️ تنبيه مهم: النشر يستبدل محتوى الموقع كاملاً.
# إن كانت لديك صفحة privacy.html منشورة سابقاً ومكتوبة بصيغة تريد
# الاحتفاظ بها، انسخها إلى مجلّد site/ قبل التشغيل — وإلا ستحلّ
# محلّها النسخة الموجودة هنا.
echo ""
echo -e "${YEL}⚠ النشر يستبدل كل محتوى الموقع الحالي.${NC}"
echo "  ستُنشر الصفحات التالية:"
ls site/ | sed 's/^/     • /'
echo "     • /       (اللعبة كنسخة ويب)"
  echo "     • /play/  (صفحة التعريف)"
echo ""
# YES=1 يتخطّى السؤال — ليعمل السكربت داخل أمر مسلسل بلا توقّف
if [ "$YES" != "1" ]; then
  read -r -p "متابعة؟ [y/N] " ans
  case "$ans" in [yY]*) ;; *) echo "أُلغي."; exit 0 ;; esac
fi

bash ./scripts/build-site.sh
$FB deploy --only hosting

echo ""
echo -e "${GREEN}✅ تم النشر${NC}"
echo "   اللعبة  : https://ronda-e11cd.web.app"
echo "   التعريف : https://ronda-e11cd.web.app/play/"
echo "   الشروط : https://ronda-e11cd.web.app/terms.html"
