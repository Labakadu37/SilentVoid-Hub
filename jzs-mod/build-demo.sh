#!/bin/bash
set -e
cd "$(dirname "$0")"

BT=build-tools/android-14
JAR=platform/android-35/android.jar
SRC=/home/user/SilentVoid-Hub/jzs-mod

rm -rf demo && mkdir -p demo/classes demo/dex demo/assets/jzs

echo "[1/6] Compilation Java"
javac -source 8 -target 8 -bootclasspath "$JAR:$BT/core-lambda-stubs.jar" -nowarn \
    -d demo/classes \
    "$SRC"/src/main/java/org/jzs/brawl/*.java \
    "$SRC"/src/demo/java/org/jzs/brawl/demo/*.java 2>&1 | grep -E "error" || true

echo "[2/6] JAR + DEX"
jar cf demo/jzsdemo.jar -C demo/classes .
"$BT/d8" --lib "$JAR" --min-api 24 --output demo/dex demo/jzsdemo.jar 2>&1 | grep -vi "picked up" || true

echo "[3/6] Link des ressources (aapt2)"
"$BT/aapt2" link \
    -I "$JAR" \
    --manifest "$SRC/src/demo/AndroidManifest.xml" \
    --min-sdk-version 24 --target-sdk-version 35 \
    -o demo/base.apk

echo "[4/6] Ajout du DEX et des assets"
cp "$SRC/assets/jzs/credits.json" demo/assets/jzs/credits.json
cd demo
cp base.apk demo_unsigned.apk
cp dex/classes.dex classes.dex
zip -q -X demo_unsigned.apk classes.dex
zip -q -X -r demo_unsigned.apk assets
cd ..

echo "[5/6] zipalign"
"$BT/zipalign" -f -p 4 demo/demo_unsigned.apk demo/demo_aligned.apk

echo "[6/6] Signature v1+v2+v3"
"$BT/apksigner" sign --ks jzs.keystore \
    --ks-pass pass:jzsbrawl123 --key-pass pass:jzsbrawl123 \
    --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
    --min-sdk-version 24 \
    --out JZS_Overlay_Test.apk demo/demo_aligned.apk 2>&1 | grep -vi "picked up" || true

echo
ls -lh JZS_Overlay_Test.apk
"$BT/apksigner" verify --verbose JZS_Overlay_Test.apk 2>&1 | grep -viE "picked up|WARNING" || true
"$BT/aapt2" dump badging JZS_Overlay_Test.apk 2>/dev/null | head -4
