#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════╗
# ║     Ronda - بناء نسخة Android للنشر على Play Store      ║
# ╚══════════════════════════════════════════════════════════╝

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'; BOLD='\033[1m'

KEYSTORE="release-keystore.jks"
ALIAS="ronda-key"
AAB_OUT="android/app/build/outputs/bundle/release/app-release.aab"
APK_OUT="android/app/build/outputs/apk/release/app-release-unsigned.apk"

echo -e "${BLUE}${BOLD}🎴 Ronda Android Release Builder${NC}\n"

# ── Check keystore ─────────────────────────────────────────────
if [ ! -f "$KEYSTORE" ]; then
  echo -e "${YELLOW}لا يوجد Keystore. سيتم إنشاء واحد جديد...${NC}"
  echo ""
  echo -e "${BOLD}معلومات الشهادة:${NC}"

  read -p "الاسم الكامل (CN): " CERT_CN
  read -p "اسم المؤسسة (O): " CERT_O
  read -p "المدينة (L): " CERT_L
  read -p "الدولة (2 حرف، مثل MA): " CERT_C
  read -s -p "كلمة المرور: " KEYSTORE_PASS
  echo ""

  keytool -genkeypair \
    -v \
    -keystore "$KEYSTORE" \
    -alias "$ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$KEYSTORE_PASS" \
    -keypass "$KEYSTORE_PASS" \
    -dname "CN=$CERT_CN, O=$CERT_O, L=$CERT_L, C=$CERT_C"

  echo -e "\n${GREEN}✓ تم إنشاء Keystore: $KEYSTORE${NC}"
  echo -e "${RED}⚠  احتفظ بهذا الملف في مكان آمن! بدونه لا يمكنك تحديث التطبيق.${NC}\n"
else
  read -s -p "كلمة مرور Keystore: " KEYSTORE_PASS
  echo ""
fi

# ── Sync Capacitor ─────────────────────────────────────────────
echo -e "\n${BLUE}▶ مزامنة Capacitor...${NC}"
npx cap sync android
echo -e "${GREEN}✓ تمت المزامنة${NC}"

# ── Build AAB (Play Store) ─────────────────────────────────────
echo -e "\n${BLUE}▶ بناء AAB للـ Play Store...${NC}"
cd android

./gradlew bundleRelease \
  -Pandroid.injected.signing.store.file="../$KEYSTORE" \
  -Pandroid.injected.signing.store.password="$KEYSTORE_PASS" \
  -Pandroid.injected.signing.key.alias="$ALIAS" \
  -Pandroid.injected.signing.key.password="$KEYSTORE_PASS"

cd ..

if [ -f "$AAB_OUT" ]; then
  SIZE=$(du -sh "$AAB_OUT" | cut -f1)
  echo -e "${GREEN}✓ AAB جاهز: $AAB_OUT ($SIZE)${NC}"
  cp "$AAB_OUT" "ronda-release.aab"
  echo -e "${GREEN}✓ نسخة: ronda-release.aab${NC}"
else
  echo -e "${RED}✗ فشل بناء AAB${NC}"
  exit 1
fi

# ── Build APK (direct install) ─────────────────────────────────
echo -e "\n${BLUE}▶ بناء APK للتثبيت المباشر...${NC}"
cd android
./gradlew assembleRelease \
  -Pandroid.injected.signing.store.file="../$KEYSTORE" \
  -Pandroid.injected.signing.store.password="$KEYSTORE_PASS" \
  -Pandroid.injected.signing.key.alias="$ALIAS" \
  -Pandroid.injected.signing.key.password="$KEYSTORE_PASS"
cd ..

if [ -f "android/app/build/outputs/apk/release/app-release.apk" ]; then
  cp "android/app/build/outputs/apk/release/app-release.apk" "ronda-release.apk"
  echo -e "${GREEN}✓ APK جاهز: ronda-release.apk${NC}"
fi

# ── Summary ────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║   ✅  البناء اكتمل!                               ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  📦 ${BOLD}Play Store${NC} → رفع ${CYAN}ronda-release.aab${NC}"
echo -e "  📱 ${BOLD}تثبيت مباشر${NC} → ${CYAN}ronda-release.apk${NC}"
echo ""
echo -e "  🔗 رابط Play Console: ${CYAN}https://play.google.com/console${NC}"
