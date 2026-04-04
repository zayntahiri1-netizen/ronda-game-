#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║          Ronda Mobile - إعداد المشروع الكامل                ║
# ║    تشغيل هذا السكريبت مرة واحدة لإعداد كل شيء               ║
# ╚══════════════════════════════════════════════════════════════╝

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

banner() {
  echo ""
  echo -e "${CYAN}${BOLD}╔══════════════════════════════════════╗${NC}"
  echo -e "${CYAN}${BOLD}║    🎴  Ronda روندة - Mobile Setup    ║${NC}"
  echo -e "${CYAN}${BOLD}╚══════════════════════════════════════╝${NC}"
  echo ""
}

step() { echo -e "\n${BLUE}${BOLD}▶ $1${NC}"; }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }

banner

# ── Check prerequisites ────────────────────────────────────────
step "فحص المتطلبات..."

command -v node  >/dev/null 2>&1 || fail "Node.js غير مثبت. حمله من: https://nodejs.org"
command -v npm   >/dev/null 2>&1 || fail "npm غير مثبت"
command -v java  >/dev/null 2>&1 || warn "Java غير موجود (مطلوب للـ Android)"

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  fail "Node.js 18+ مطلوب. النسخة الحالية: $(node -v)"
fi

ok "Node.js $(node -v)"
ok "npm $(npm -v)"

# ── Install dependencies ───────────────────────────────────────
step "تثبيت المكتبات..."
npm install
ok "تم تثبيت المكتبات"

# ── Add PWA to index.html ──────────────────────────────────────
step "إضافة PWA إلى index.html..."

HTML_FILE="www/index.html"

# Add manifest link if not present
if ! grep -q "manifest.json" "$HTML_FILE"; then
  sed -i 's|</head>|  <link rel="manifest" href="manifest.json">\n  </head>|' "$HTML_FILE"
  ok "تمت إضافة manifest.json"
else
  ok "manifest.json موجود بالفعل"
fi

# Add Capacitor core script if not present
if ! grep -q "capacitor.js" "$HTML_FILE"; then
  sed -i 's|</head>|  <script src="capacitor.js" type="module"></script>\n  </head>|' "$HTML_FILE"
  ok "تمت إضافة capacitor.js"
fi

# Add service worker registration
if ! grep -q "serviceWorker" "$HTML_FILE"; then
  cat >> /tmp/sw_snippet.js << 'SWEOF'

<script>
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(reg => console.log('[SW] Registered:', reg.scope))
      .catch(err => console.log('[SW] Failed:', err));
  });
}
// Capacitor app ready
document.addEventListener('deviceready', () => {
  console.log('[Capacitor] Device ready');
}, false);
</script>
SWEOF
  sed -i "s|</body>|$(cat /tmp/sw_snippet.js)\n</body>|" "$HTML_FILE"
  ok "تمت إضافة Service Worker"
fi

# ── Initialize Capacitor ───────────────────────────────────────
step "تهيئة Capacitor..."

if ! npx cap --version >/dev/null 2>&1; then
  npm install -g @capacitor/cli
fi

# Init if not already done
if [ ! -f "capacitor.config.json" ] || [ ! -d "node_modules/@capacitor/core" ]; then
  warn "التهيئة ستتم تلقائياً من capacitor.config.json"
fi

ok "Capacitor version: $(npx cap --version)"

# ── Add Android ────────────────────────────────────────────────
step "إضافة منصة Android..."
if [ ! -d "android" ]; then
  npx cap add android
  ok "تمت إضافة Android"
else
  ok "Android موجود بالفعل"
fi

# ── Patch AndroidManifest.xml ──────────────────────────────────
step "ضبط Android Manifest..."

MANIFEST="android/app/src/main/AndroidManifest.xml"

# Add internet permission
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  sed -i 's|<manifest|<manifest\n    <uses-permission android:name="android.permission.INTERNET" />\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />\n    <uses-permission android:name="android.permission.VIBRATE" />|' "$MANIFEST"
fi

# Add orientation lock (portrait)
sed -i 's|android:screenOrientation="[^"]*"|android:screenOrientation="portrait"|g' "$MANIFEST" 2>/dev/null || true

ok "AndroidManifest.xml محدث"

# ── Patch build.gradle ─────────────────────────────────────────
step "ضبط Android build.gradle..."
BUILD_GRADLE="android/app/build.gradle"

# Update minSdk if needed
sed -i 's/minSdkVersion [0-9]*/minSdkVersion 22/g'    "$BUILD_GRADLE" 2>/dev/null || true
sed -i 's/targetSdkVersion [0-9]*/targetSdkVersion 34/g' "$BUILD_GRADLE" 2>/dev/null || true
sed -i 's/compileSdkVersion [0-9]*/compileSdkVersion 34/g' "$BUILD_GRADLE" 2>/dev/null || true

# Add signing config if keystore exists
if [ -f "release-keystore.jks" ]; then
  ok "Keystore موجود - سيتم استخدامه للـ Release"
fi

ok "build.gradle محدث"

# ── Add iOS (macOS only) ──────────────────────────────────────
step "إضافة منصة iOS..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [ ! -d "ios" ]; then
    npx cap add ios
    ok "تمت إضافة iOS"
  else
    ok "iOS موجود بالفعل"
  fi
else
  warn "iOS يتطلب macOS - تخطي"
fi

# ── Generate Assets ─────────────────────────────────────────────
step "توليد الأيقونات وشاشات البداية..."
if node scripts/generate-assets.js; then
  ok "تم توليد جميع الأصول"
else
  warn "sharp قد يحتاج إلى تثبيت: npm install sharp"
fi

# ── Sync ────────────────────────────────────────────────────────
step "مزامنة Capacitor..."
npx cap sync
ok "تمت المزامنة"

# ── Done ────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║   ✅  تم إعداد المشروع بنجاح! 🎴                ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}الخطوات التالية:${NC}"
echo ""
echo -e "  ${CYAN}Android APK/AAB:${NC}"
echo "  1. ./scripts/build-android-release.sh"
echo "  2. رفع الـ AAB إلى Google Play Console"
echo ""
echo -e "  ${CYAN}iOS IPA:${NC}"
echo "  1. npx cap open ios"
echo "  2. Xcode → Product → Archive"
echo "  3. رفع عبر Transporter أو Xcode"
echo ""
