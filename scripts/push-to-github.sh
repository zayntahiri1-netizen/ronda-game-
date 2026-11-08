#!/usr/bin/env bash
#
# ⚠️ Termux: شغّله بـ«bash scripts/<الاسم>» لا «./scripts/<الاسم>».
#    Termux لا يملك /usr/bin/env فيفشل سطر shebang بـExec format error.
#    «bash <ملف>» يتجاهل shebang وصلاحية التنفيذ، ويعمل في Termux والـCI معاً.
# ╔══════════════════════════════════════════════════════════╗
# ║   رفع روندة على GitHub وبناء APK تلقائياً في السحابة    ║
# ╚══════════════════════════════════════════════════════════╝

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════╗"
echo "║   🎴 Ronda → GitHub → APK            ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# ── تثبيت git إذا لم يكن موجوداً ───────────────────────────
if ! command -v git &>/dev/null; then
  echo -e "${BLUE}▶ تثبيت git...${NC}"
  pkg install -y git
fi

# ── تحديد مسار المشروع تلقائياً ────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${BLUE}▶ مسار المشروع: $PROJECT_DIR${NC}"
cd "$PROJECT_DIR"

# ── بيانات GitHub ───────────────────────────────────────────
# تُقرأ من متغيّرات البيئة إن مُرّرت، وإلا تُطلب تفاعلياً. هذا يسمح
# بتشغيل السكربت في أمر واحد مسلسل:
#   GH_USER=... GH_REPO=... GH_TOKEN=... ./scripts/push-to-github.sh
if [ -n "$GH_USER" ] && [ -n "$GH_REPO" ] && [ -n "$GH_TOKEN" ]; then
  echo -e "${BLUE}▶ بيانات GitHub من متغيّرات البيئة: ${GH_USER}/${GH_REPO}${NC}"
else
  echo -e "${BOLD}أدخل بيانات GitHub:${NC}"
  [ -z "$GH_USER" ]  && read -p "  اسم المستخدم (username): " GH_USER
  [ -z "$GH_REPO" ]  && read -p "  اسم الـ Repository (مثل: ronda-game-): " GH_REPO
  [ -z "$GH_TOKEN" ] && { read -s -p "  Personal Access Token: " GH_TOKEN; echo ""; }
fi

if [ -z "$GH_USER" ] || [ -z "$GH_REPO" ] || [ -z "$GH_TOKEN" ]; then
  echo -e "${RED}✗ بيانات GitHub ناقصة${NC}"; exit 1
fi

REPO_URL="https://${GH_USER}:${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git"

# ── تهيئة git ──────────────────────────────────────────────
echo -e "\n${BLUE}▶ تهيئة Git...${NC}"

# [FIX-GIT-CONFIG] مجلّد .git تالف يوقف كلّ أوامر git بـ«bad config line 1»
# قبل أن تبدأ، فيفشل الرفع بلا سبب ظاهر. نكتشفه ونُعيد التهيئة.
# آمن: التاريخ محفوظ على GitHub، والسكربت يرفع بـ--force أصلاً، فلا يضيع
# شيء. ومع ذلك ننقل القديم جانباً بدل حذفه، فالحذف لا رجعة فيه.
if [ -d .git ] && ! git rev-parse --git-dir >/dev/null 2>&1; then
  BK=".git.broken-$(date +%Y%m%d-%H%M%S)"
  echo -e "${YELLOW}⚠ مجلّد .git تالف — أنقله إلى ${BK} وأُعيد التهيئة${NC}"
  mv .git "$BK" || { echo -e "${RED}✗ تعذّر نقل .git${NC}"; exit 1; }
fi

# ⚠️ التهيئة قبل الضبط لا بعده: git config يفشل بـ«not in a git directory»
# إن لم يكن المستودع موجوداً — وهذا يقع عند أوّل رفع، وبعد إصلاح .git أعلاه.
if [ ! -d ".git" ]; then
  git init -q
  git branch -M main
fi

git config user.email "${GH_USER}@users.noreply.github.com"
git config user.name "$GH_USER"

# ── ربط بـ GitHub ──────────────────────────────────────────
if git remote | grep -q origin; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

# ── رفع الكود ──────────────────────────────────────────────
echo -e "${BLUE}▶ رفع الكود على GitHub...${NC}"
git add .
git commit -m "🎴 Ronda Mobile v1.0 - Initial release" 2>/dev/null || \
git commit -m "🔄 Update" --allow-empty

# [FIX-PUSH-CHECK] كان السكربت يطبع «نجح» مهما كانت النتيجة، لأنه لا يفحص
# خروج git push أصلاً. فيظنّ المرء أن الكود رُفع بينما رفضه GitHub.
OUT=$(git push -u origin main --force 2>&1)
RC=$?
echo "$OUT" | sed 's/'"${GH_TOKEN}"'/***/g'

if [ $RC -ne 0 ]; then
  echo -e "\n${RED}✗ فشل الرفع. السبب على الأرجح:${NC}\n"
  if echo "$OUT" | grep -qi "workflow.*scope\|refusing to allow"; then
    echo -e "${YELLOW}▶ الرمز (Token) ينقصه إذن workflow.${NC}"
    echo "  عدّلنا .github/workflows/build-android.yml، ورفعُ أي ملف"
    echo "  داخل .github/workflows يتطلّب هذا الإذن تحديداً. لهذا نجح"
    echo "  الرفع سابقاً وفشل الآن."
    echo ""
    echo "  الحلّ: github.com/settings/tokens ← رمزك ← فعّل خانة workflow"
    echo "         (أو أنشئ رمزاً جديداً بخانتَي repo و workflow) ثم أعد الأمر."
  elif echo "$OUT" | grep -qi "authentication failed\|invalid username or password\|bad credentials"; then
    echo -e "${YELLOW}▶ الرمز خاطئ أو منتهي الصلاحية.${NC}"
    echo "  تأكّد أنك استبدلت ghp_xxx برمزك الحقيقي."
    echo "  رمز جديد: github.com/settings/tokens (خانتا repo و workflow)"
  elif echo "$OUT" | grep -qi "repository not found\|could not read from remote"; then
    echo -e "${YELLOW}▶ المستودع ${GH_USER}/${GH_REPO} غير موجود أو لا تملك صلاحيته.${NC}"
    echo "  أنشئه أولاً: github.com/new  باسم ${GH_REPO}"
  elif echo "$OUT" | grep -qi "could not resolve host\|network\|timed out"; then
    echo -e "${YELLOW}▶ لا اتصال بالإنترنت.${NC}"
  else
    echo -e "${YELLOW}▶ انظر رسالة git أعلاه.${NC}"
  fi
  exit 1
fi

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ تم الرفع على GitHub بنجاح! 🎴           ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${BOLD}الخطوات التالية:${NC}"
echo -e "  1. افتح: ${CYAN}https://github.com/${GH_USER}/${GH_REPO}/actions${NC}"
echo -e "  2. ستجد workflow يبني APK تلقائياً ⚙️"
echo -e "  3. بعد ~10 دقائق، حمّل الـ APK من Artifacts 📦"
echo ""
echo -e "${YELLOW}⚠ تأكد أن الـ Repository موجود على github.com مسبقاً${NC}"
