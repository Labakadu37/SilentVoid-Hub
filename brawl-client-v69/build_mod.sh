#!/bin/bash
#
# JZS Brawl v69.230 - Build Script
# Pipeline complet : XAPK -> Decompile -> Patch -> Recompile -> Signe
#
# Usage:
#   ./build_mod.sh <chemin_vers_xapk_ou_apk>
#
# Exemple:
#   ./build_mod.sh ~/Brawl_Stars_69.252.xapk
#   ./build_mod.sh ~/brawlstars.apk

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APKTOOL_JAR="/tmp/apktool-install/apktool.jar"
WORK_DIR="$SCRIPT_DIR/build"
KEYSTORE="$SCRIPT_DIR/modding/jzs-brawl.keystore"
KEY_ALIAS="jzsbrawl"
KEY_PASS="jzsbrawl69"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}+=================================================+${NC}"
echo -e "${CYAN}|       JZS Brawl V69.230 - Build System       |${NC}"
echo -e "${CYAN}|       Version testing - APK Builder           |${NC}"
echo -e "${CYAN}+=================================================+${NC}"
echo ""

if [ -z "$1" ]; then
    echo -e "${RED}[!] Usage: $0 <chemin_vers_xapk_ou_apk>${NC}"
    echo ""
    echo "    Exemples:"
    echo "      $0 ~/Downloads/Brawl_Stars_69.252.xapk"
    echo "      $0 ~/Downloads/brawlstars.apk"
    exit 1
fi

INPUT_FILE="$1"
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}[!] Fichier non trouve: $INPUT_FILE${NC}"
    exit 1
fi

# Verifier apktool
if [ ! -f "$APKTOOL_JAR" ]; then
    echo -e "${YELLOW}[*] Telechargement d'apktool...${NC}"
    mkdir -p "$(dirname "$APKTOOL_JAR")"
    curl -sL -o "$APKTOOL_JAR" "https://github.com/iBotPeaches/Apktool/releases/download/v3.0.3/apktool_3.0.3.jar"
fi

# Preparer le dossier de build
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# --- ETAPE 1 : Extraction XAPK si necessaire ---
EXT="${INPUT_FILE##*.}"
APK_FILE=""

if [ "$EXT" = "xapk" ]; then
    echo -e "${GREEN}[1/6] Extraction du XAPK...${NC}"
    XAPK_DIR="$WORK_DIR/xapk_extracted"
    mkdir -p "$XAPK_DIR"
    unzip -q "$INPUT_FILE" -d "$XAPK_DIR"

    # Trouver l'APK principal (le plus gros, ou celui nomme avec le package)
    APK_FILE=$(find "$XAPK_DIR" -name "*.apk" -type f | head -1)

    if [ -z "$APK_FILE" ]; then
        echo -e "${RED}[!] Aucun APK trouve dans le XAPK${NC}"
        exit 1
    fi

    echo -e "    APK trouve: $(basename "$APK_FILE")"

    # Lister les split APKs
    SPLIT_COUNT=$(find "$XAPK_DIR" -name "*.apk" -type f | wc -l)
    echo -e "    Total APKs dans le XAPK: $SPLIT_COUNT"

elif [ "$EXT" = "apk" ]; then
    echo -e "${GREEN}[1/6] APK detecte directement${NC}"
    APK_FILE="$INPUT_FILE"
else
    echo -e "${RED}[!] Format non supporte: .$EXT (utilisez .apk ou .xapk)${NC}"
    exit 1
fi

# --- ETAPE 2 : Decompilation ---
echo -e "${GREEN}[2/6] Decompilation avec apktool...${NC}"
DECOMPILED_DIR="$WORK_DIR/decompiled"
java -jar "$APKTOOL_JAR" d "$APK_FILE" -o "$DECOMPILED_DIR" -f 2>&1 | tail -5

echo -e "    Decompile dans: $DECOMPILED_DIR"

# --- ETAPE 3 : Application des patches JZS ---
echo -e "${GREEN}[3/6] Application des patches JZS Brawl...${NC}"
python3 "$SCRIPT_DIR/modding/patch_menu_text.py" "$DECOMPILED_DIR"

echo -e "${GREEN}[4/6] Injection du code smali overlay...${NC}"
python3 "$SCRIPT_DIR/modding/inject_smali.py" "$DECOMPILED_DIR"

# --- ETAPE 5 : Recompilation ---
echo -e "${GREEN}[5/6] Recompilation de l'APK...${NC}"
OUTPUT_APK="$WORK_DIR/jzs-brawl-unsigned.apk"
java -jar "$APKTOOL_JAR" b "$DECOMPILED_DIR" -o "$OUTPUT_APK" 2>&1 | tail -5

if [ ! -f "$OUTPUT_APK" ]; then
    echo -e "${RED}[!] Echec de la recompilation${NC}"
    exit 1
fi

echo -e "    APK non signe: $OUTPUT_APK"

# --- ETAPE 6 : Signature ---
echo -e "${GREEN}[6/6] Signature de l'APK...${NC}"

# Generer un keystore si necessaire
if [ ! -f "$KEYSTORE" ]; then
    keytool -genkeypair \
        -keystore "$KEYSTORE" \
        -alias "$KEY_ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass "$KEY_PASS" \
        -keypass "$KEY_PASS" \
        -dname "CN=JZS Brawl, OU=SilentVoid, O=JZS, L=Paris, ST=IDF, C=FR" \
        2>/dev/null
    echo -e "    Keystore genere"
fi

SIGNED_APK="$WORK_DIR/JZS-Brawl-V69.230.apk"
jarsigner \
    -keystore "$KEYSTORE" \
    -storepass "$KEY_PASS" \
    -keypass "$KEY_PASS" \
    -signedjar "$SIGNED_APK" \
    "$OUTPUT_APK" \
    "$KEY_ALIAS" \
    2>/dev/null

if [ -f "$SIGNED_APK" ]; then
    SIZE=$(du -h "$SIGNED_APK" | cut -f1)
    echo ""
    echo -e "${CYAN}+=================================================+${NC}"
    echo -e "${CYAN}|              BUILD REUSSI !                   |${NC}"
    echo -e "${CYAN}+=================================================+${NC}"
    echo -e "  APK: ${GREEN}$SIGNED_APK${NC}"
    echo -e "  Taille: ${GREEN}$SIZE${NC}"
    echo -e "  Texte: ${GREEN}JZS Brawl V69.230${NC}"
    echo -e "  Version: ${GREEN}Version testing${NC}"
    echo ""
    echo -e "  Installe l'APK sur ton telephone :"
    echo -e "    ${YELLOW}adb install $SIGNED_APK${NC}"
    echo ""
else
    echo -e "${RED}[!] Echec de la signature${NC}"
    exit 1
fi
