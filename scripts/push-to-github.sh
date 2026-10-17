#!/usr/bin/env bash
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

# ── إدخال بيانات GitHub ─────────────────────────────────────
echo -e "${BOLD}أدخل بيانات GitHub:${NC}"
read -p "  اسم المستخدم (username): " GH_USER
read -p "  اسم الـ Repository (مثل: ronda-game-): " GH_REPO
read -s -p "  Personal Access Token: " GH_TOKEN
echo ""

REPO_URL="https://${GH_USER}:${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git"

# ── تهيئة git ──────────────────────────────────────────────
echo -e "\n${BLUE}▶ تهيئة Git...${NC}"

git config user.email "${GH_USER}@users.noreply.github.com"
git config user.name "$GH_USER"

if [ ! -d ".git" ]; then
  git init
  git branch -M main
fi

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

git push -u origin main --force

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
