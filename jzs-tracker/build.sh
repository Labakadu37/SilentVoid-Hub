#!/bin/bash
# Builds JZS Brawl Tracker into a signed, installable APK.
#
# Deliberately Gradle-free: aapt2 -> javac -> d8 -> zipalign -> apksigner.
# Nothing is fetched from Maven, so the build works offline and cannot break
# on a dependency resolution failure.
set -euo pipefail

SDK="${ANDROID_HOME:-/opt/android-sdk}"
# 35.0.0 or newer: the d8 in 34.0.0 crashes reading any anonymous class
# emitted by a JDK 21 javac (null inner_name in InnerClasses).
BT="$SDK/build-tools/35.0.0"
PLATFORM="$SDK/platforms/android-34/android.jar"
MIN_SDK=24

HERE="$(cd "$(dirname "$0")" && pwd)"
APP="$HERE/app"
OUT="$HERE/build"
NAME="JZS-Brawl-Tracker"

for required in "$BT/aapt2" "$BT/d8" "$BT/zipalign" "$BT/apksigner" "$PLATFORM"; do
    [ -e "$required" ] || { echo "missing: $required"; exit 1; }
done

rm -rf "$OUT"
mkdir -p "$OUT/res" "$OUT/gen" "$OUT/classes"

echo "[1/6] compiling resources"
"$BT/aapt2" compile --dir "$APP/res" -o "$OUT/res/resources.zip"

echo "[2/6] linking resources"
"$BT/aapt2" link \
    -o "$OUT/base.apk" \
    -I "$PLATFORM" \
    --manifest "$APP/AndroidManifest.xml" \
    --java "$OUT/gen" \
    --min-sdk-version "$MIN_SDK" \
    --target-sdk-version 34 \
    "$OUT/res/resources.zip"

echo "[3/6] compiling java"
find "$APP/java" "$OUT/gen" -name '*.java' > "$OUT/sources.txt"
javac -nowarn -source 8 -target 8 -bootclasspath "$PLATFORM" \
    -classpath "$PLATFORM" -d "$OUT/classes" @"$OUT/sources.txt" 2>&1 \
    | grep -v 'bootstrap class path' || true

echo "[4/6] dexing"
find "$OUT/classes" -name '*.class' > "$OUT/classes.txt"
"$BT/d8" --release --min-api "$MIN_SDK" --lib "$PLATFORM" \
    --output "$OUT" @"$OUT/classes.txt"

echo "[5/6] packaging"
cp "$OUT/base.apk" "$OUT/unsigned.apk"
(cd "$OUT" && zip -q -X unsigned.apk classes.dex)
"$BT/zipalign" -f -p 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"

echo "[6/6] signing"
KEYSTORE="$OUT/jzs.jks"
keytool -genkeypair -keystore "$KEYSTORE" -alias jzs -keyalg RSA -keysize 2048 \
    -validity 10000 -storepass jzsbrawl -keypass jzsbrawl -dname "CN=JZS Brawl" 2>/dev/null
"$BT/apksigner" sign \
    --ks "$KEYSTORE" --ks-pass pass:jzsbrawl --key-pass pass:jzsbrawl \
    --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
    --out "$OUT/$NAME.apk" "$OUT/aligned.apk"
"$BT/apksigner" verify --print-certs "$OUT/$NAME.apk" > /dev/null

echo
echo "  built: $OUT/$NAME.apk  ($(du -h "$OUT/$NAME.apk" | cut -f1))"
