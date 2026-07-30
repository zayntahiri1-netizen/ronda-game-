#!/usr/bin/env python3
"""
inject-signing.py
يُضيف signingConfigs في android/app/build.gradle
الاستخدام: python3 scripts/inject-signing.py <ks_path> <ks_pass> <ks_alias>
"""
import sys
import re

ks_path  = sys.argv[1]
ks_pass  = sys.argv[2]
ks_alias = sys.argv[3]

gradle_path = "android/app/build.gradle"

with open(gradle_path, "r") as f:
    content = f.read()

# إذا signing موجود بالفعل، لا نُضيفه مجدداً
if "signingConfigs" in content:
    print("✓ signingConfigs موجود بالفعل")
    sys.exit(0)

signing_block = (
    "\n    signingConfigs {\n"
    "        release {\n"
    "            storeFile file('" + ks_path + "')\n"
    "            storePassword '" + ks_pass + "'\n"
    "            keyAlias '" + ks_alias + "'\n"
    "            keyPassword '" + ks_pass + "'\n"
    "        }\n"
    "    }\n"
)

# إضافة signingConfigs قبل buildTypes
content = content.replace(
    "    buildTypes {",
    signing_block + "    buildTypes {"
)

# إضافة signingConfig داخل buildTypes > release (مرة واحدة فقط)
content = re.sub(
    r'(buildTypes\s*\{[^}]*release\s*\{)',
    r'\1\n            signingConfig signingConfigs.release',
    content,
    count=1,
    flags=re.DOTALL
)

with open(gradle_path, "w") as f:
    f.write(content)

print("✓ signing config مُضاف بنجاح في build.gradle")
