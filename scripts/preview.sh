#!/usr/bin/env bash
#
# ⚠️ Termux: شغّله بـ«bash scripts/<الاسم>» لا «./scripts/<الاسم>».
#    Termux لا يملك /usr/bin/env فيفشل سطر shebang بـExec format error.
#    «bash <ملف>» يتجاهل shebang وصلاحية التنفيذ، ويعمل في Termux والـCI معاً.
# ╔══════════════════════════════════════════════════════════════╗
# ║  معاينة محلّية في المتصفّح — الموقع واللعبة معاً              ║
# ║  الاستعمال:  bash scripts/preview.sh   [المنفذ]               ║
# ╚══════════════════════════════════════════════════════════════╝
set -e
cd "$(dirname "$0")/.."

PORT="${1:-8080}"
bash ./scripts/build-site.sh

echo ""
echo "════════════════════════════════════════════════"
echo "  اللعبة  : http://localhost:$PORT/"
echo "  التعريف : http://localhost:$PORT/play/"
echo "  الشروط  : http://localhost:$PORT/terms"
echo "  الخصوصية: http://localhost:$PORT/privacy"
echo "  الحذف   : http://localhost:$PORT/delete"
echo "════════════════════════════════════════════════"
echo "  للإيقاف: Ctrl+C"
echo ""

# ⚠️ لا تستعمل «python3 -m http.server» وحده: لا يعرف cleanUrls فيردّ 404
# على /terms، فتختلف المعاينة عن الإنتاج وتظنّ الرابط مكسوراً وهو سليم.
# _serve.py يحاكي قاعدتَي Firebase: يخدم /terms من terms.html، ويعيد
# توجيه /terms.html إلى /terms بـ301 — تماماً كالاستضافة.
if command -v python3 >/dev/null 2>&1; then
  python3 scripts/_serve.py "$PORT" .site-build
else
  echo "✗ تحتاج python3 للمعاينة (pkg install python في Termux)"; exit 1
fi
