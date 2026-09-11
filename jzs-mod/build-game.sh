#!/bin/bash
# Construit JZSBrawl.apk : le jeu + notre mod, fusionne, aligne et signe.
set -e
cd "$(dirname "$0")"

SCRATCH="${SCRATCH:-/tmp/claude-0/-home-user-SilentVoid-Hub/c5cf47e1-6a0b-5343-b3dd-b1185d284e45/scratchpad}"
BT="$SCRATCH/build-tools/android-14"
JAR="$SCRATCH/platform/android-35/android.jar"
XAPK="${XAPK:-$SCRATCH/bs_official.xapk}"
ABI="${ABI:-armeabi-v7a}"
OUT="${OUT:-$SCRATCH/JZSBrawl.apk}"

WORK="$SCRATCH/gamebuild"
rm -rf "$WORK" && mkdir -p "$WORK/classes" "$WORK/dex"

echo "[1/6] Compilation (mod + hook + stub)"
javac -source 8 -target 8 -bootclasspath "$JAR:$BT/core-lambda-stubs.jar" -nowarn \
    -d "$WORK/classes" \
    src/main/java/org/jzs/brawl/*.java \
    src/game/java/org/jzs/brawl/*.java \
    src/stub/java/com/supercell/titan/*.java

echo "[2/6] JAR livre (sans le stub TitanApplication)"
# Le stub sert uniquement a la compilation : l'embarquer ecraserait la vraie
# classe du jeu au chargement.
jar cf "$WORK/stub.jar" -C "$WORK/classes" com
jar cf "$WORK/mod.jar" -C "$WORK/classes" org

echo "[3/6] DEX"
"$BT/d8" --lib "$JAR" --lib "$WORK/stub.jar" --min-api 24 \
    --output "$WORK/dex" "$WORK/mod.jar" 2>&1 | grep -vi "picked up" || true

echo "[4/6] Fusion du XAPK + injection"
python3 tools/merge_apk.py "$XAPK" "$WORK/merged.apk" \
    --abi "$ABI" --dex "$WORK/dex/classes.dex" --assets assets

echo "[5/6] zipalign"
"$BT/zipalign" -f -p 4 "$WORK/merged.apk" "$WORK/aligned.apk"

echo "[6/6] Signature v1+v2+v3"
"$BT/apksigner" sign --ks "$SCRATCH/jzs.keystore" \
    --ks-pass pass:jzsbrawl123 --key-pass pass:jzsbrawl123 \
    --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
    --min-sdk-version 24 --out "$OUT" "$WORK/aligned.apk" 2>&1 | grep -vi "picked up" || true

echo
ls -lh "$OUT"
"$BT/apksigner" verify --verbose "$OUT" 2>&1 | grep -viE "picked up|WARNING" || true
"$BT/aapt2" dump badging "$OUT" 2>/dev/null | head -3
