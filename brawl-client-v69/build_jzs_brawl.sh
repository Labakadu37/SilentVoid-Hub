#!/bin/bash
#
# JZS Brawl V69.230 - Build Script (sans upload)
# Décompile, injecte le texte, recompile et signe l'APK
#
# Prérequis: Java, Python3, unzip
# Usage: bash build_jzs_brawl.sh <chemin_vers_xapk_ou_apk>

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="/tmp/jzs-brawl-build"
APKTOOL_JAR="$WORK_DIR/apktool.jar"

echo ""
echo "  JZS Brawl V69.230 - Build System"
echo "  Version testing - APK Builder"
echo ""

if [ -z "$1" ]; then
    echo "[!] Usage: $0 <chemin_vers_xapk_ou_apk>"
    exit 1
fi

INPUT_FILE="$1"
if [ ! -f "$INPUT_FILE" ]; then
    echo "[!] Fichier non trouvé: $INPUT_FILE"
    exit 1
fi

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Télécharger apktool
if [ ! -f "$APKTOOL_JAR" ]; then
    echo "[*] Téléchargement d'apktool..."
    curl -sL -o "$APKTOOL_JAR" "https://github.com/iBotPeaches/Apktool/releases/download/v3.0.3/apktool_3.0.3.jar"
fi

# Extraction
EXT="${INPUT_FILE##*.}"
if [ "$EXT" = "xapk" ]; then
    echo "[1/6] Extraction du XAPK..."
    mkdir -p "$WORK_DIR/xapk"
    unzip -q "$INPUT_FILE" -d "$WORK_DIR/xapk"
    APK_FILE=$(find "$WORK_DIR/xapk" -maxdepth 1 -name "com.supercell.brawlstars.apk" -o -name "base.apk" 2>/dev/null | head -1)
    [ -z "$APK_FILE" ] && APK_FILE=$(find "$WORK_DIR/xapk" -maxdepth 1 -name "*.apk" -not -name "config.*" -not -name "install_time*" | head -1)
    [ -z "$APK_FILE" ] && APK_FILE=$(find "$WORK_DIR/xapk" -maxdepth 1 -name "*.apk" | head -1)
else
    APK_FILE="$INPUT_FILE"
fi

echo "[2/6] Décompilation..."
java -jar "$APKTOOL_JAR" d "$APK_FILE" -o "$WORK_DIR/decompiled" -f 2>&1 | tail -3

echo "[3/6] Patch des ressources..."
STRINGS="$WORK_DIR/decompiled/res/values/strings.xml"
[ -f "$STRINGS" ] && sed -i 's|</resources>|    <string name="jzs_brand">JZS Brawl V69.230</string>\n    <string name="jzs_version">Version testing</string>\n</resources>|; s|<string name="app_name">[^<]*</string>|<string name="app_name">JZS Brawl</string>|' "$STRINGS"

echo "[4/6] Injection overlay..."
FIRST_SMALI=$(find "$WORK_DIR/decompiled" -maxdepth 1 -name "smali*" -type d | sort | head -1)
mkdir -p "$FIRST_SMALI/com/jzs/brawl"
cp "$SCRIPT_DIR/modding/smali_overlay/JzsOverlay.smali" "$FIRST_SMALI/com/jzs/brawl/"

MAIN_ACT=$(grep -oP 'android:name="\K[^"]*' "$WORK_DIR/decompiled/AndroidManifest.xml" | head -1)
SMALI_FILE=$(find "$WORK_DIR/decompiled"/smali* -path "*/$(echo "$MAIN_ACT" | tr '.' '/').smali" 2>/dev/null | head -1)
if [ -n "$SMALI_FILE" ] && ! grep -q "JzsOverlay" "$SMALI_FILE"; then
    sed -i '/invoke-super.*onCreate/a\    # JZS Brawl overlay\n    invoke-static {p0}, Lcom\/jzs\/brawl\/JzsOverlay;->inject(Landroid\/app\/Activity;)V' "$SMALI_FILE" 2>/dev/null || true
fi

echo "[5/6] Recompilation..."
java -jar "$APKTOOL_JAR" b "$WORK_DIR/decompiled" -o "$WORK_DIR/unsigned.apk" 2>&1 | tail -3

echo "[6/6] Signature..."
keytool -genkeypair -keystore "$WORK_DIR/k.jks" -alias jzs -keyalg RSA -keysize 2048 -validity 10000 -storepass jzsbrawl69 -keypass jzsbrawl69 -dname "CN=JZS" 2>/dev/null
jarsigner -keystore "$WORK_DIR/k.jks" -storepass jzsbrawl69 -signedjar "$WORK_DIR/JZS-Brawl-V69.230.apk" "$WORK_DIR/unsigned.apk" jzs 2>/dev/null

echo ""
echo "  BUILD OK: $WORK_DIR/JZS-Brawl-V69.230.apk"
echo "  Taille: $(du -h "$WORK_DIR/JZS-Brawl-V69.230.apk" | cut -f1)"
echo ""
