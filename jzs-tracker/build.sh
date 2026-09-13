#!/bin/bash
# Builds BrawlBee into a signed, installable APK.
#
# Deliberately Gradle-free: aapt2 -> javac -> R8 -> zipalign -> apksigner.
# Nothing is fetched from Maven, so the build works offline and cannot break
# on a dependency resolution failure.
#
# Hardening baked in here:
#   - the API token is AES-encrypted into a generated Secrets.java, never
#     shipped or committed in the clear;
#   - the signing certificate's hash is embedded so the app can refuse to run
#     if it was repackaged and re-signed (see Guard.java);
#   - R8 renames and shrinks the code so the decompiled result is unreadable.
#
# The signing keystore is created once and kept (gitignored): a stable key is
# what lets users install an update over a previous version, and what makes the
# tamper check meaningful.
set -euo pipefail

SDK="${ANDROID_HOME:-/opt/android-sdk}"
# 35.0.0 or newer: the d8/r8 in 34.0.0 crashes reading any anonymous class
# emitted by a JDK 21 javac (null inner_name in InnerClasses).
BT="$SDK/build-tools/35.0.0"
PLATFORM="$SDK/platforms/android-34/android.jar"
MIN_SDK=24

HERE="$(cd "$(dirname "$0")" && pwd)"
APP="$HERE/app"
OUT="$HERE/build"
NAME="BrawlBee"
KEYSTORE="$HERE/keystore.jks"
STOREPASS="brawlbee"

for required in "$BT/aapt2" "$BT/zipalign" "$BT/apksigner" "$BT/lib/d8.jar" "$PLATFORM"; do
    [ -e "$required" ] || { echo "missing: $required"; exit 1; }
done

rm -rf "$OUT"
mkdir -p "$OUT/res" "$OUT/gen" "$OUT/classes"

# --- signing key: created once, then reused for every build ------------------
if [ ! -f "$KEYSTORE" ]; then
    echo "[*] creating signing key (kept in keystore.jks)"
    keytool -genkeypair -keystore "$KEYSTORE" -alias brawlbee -keyalg RSA \
        -keysize 2048 -validity 10000 -storepass "$STOREPASS" -keypass "$STOREPASS" \
        -dname "CN=BrawlBee" 2>/dev/null
fi
keytool -exportcert -keystore "$KEYSTORE" -alias brawlbee -storepass "$STOREPASS" \
    -file "$OUT/cert.der" 2>/dev/null

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

echo "[3/6] packing secrets"
# Encrypt the token and embed the cert hash into a generated Secrets.java.
# token.txt is gitignored, so the plaintext key never enters the tree.
cp -r "$APP/java" "$OUT/src"
if [ -s "$HERE/token.txt" ]; then
    javac -d "$OUT/tool" "$HERE/tools/Enc.java" 2>&1 | grep -v 'bootstrap' || true
    java -cp "$OUT/tool" Enc \
        "$HERE/token.txt" "$OUT/cert.der" \
        "$OUT/src/com/jzs/brawltracker/Secrets.java"
    grep -q 'static String token' "$OUT/src/com/jzs/brawltracker/Secrets.java" \
        || { echo "secret packing failed"; exit 1; }
else
    echo "      no token.txt: building a Secrets stub (app cannot reach the API)"
    cat > "$OUT/src/com/jzs/brawltracker/Secrets.java" <<'JAVA'
package com.jzs.brawltracker;
final class Secrets {
    static final String CERT_SHA256 = "";
    static String token() { return ""; }
    private Secrets() {}
}
JAVA
fi

echo "[4/6] compiling java"
find "$OUT/src" "$OUT/gen" -name '*.java' > "$OUT/sources.txt"
javac -nowarn -source 8 -target 8 -bootclasspath "$PLATFORM" \
    -classpath "$PLATFORM" -d "$OUT/classes" @"$OUT/sources.txt" 2>&1 \
    | grep -v 'bootstrap class path' || true

echo "[5/6] shrinking and obfuscating (R8)"
find "$OUT/classes" -name '*.class' > "$OUT/classes.txt"
cat > "$OUT/rules.pro" <<'RULES'
# The manifest entry point must survive renaming; everything else is fair game.
-keep class com.jzs.brawltracker.MainActivity { public <init>(...); }
-keepclassmembers class com.jzs.brawltracker.MainActivity {
    public void onCreate(android.os.Bundle);
    public void onBackPressed();
}
-dontwarn **
-ignorewarnings
RULES

if java -cp "$BT/lib/d8.jar" com.android.tools.r8.R8 \
        --release --min-api "$MIN_SDK" --lib "$PLATFORM" \
        --pg-conf "$OUT/rules.pro" --output "$OUT" \
        @"$OUT/classes.txt" 2>"$OUT/r8.log"; then
    echo "      R8 ok"
else
    echo "      R8 failed, falling back to d8 (no obfuscation):"
    tail -3 "$OUT/r8.log" | sed 's/^/        /'
    "$BT/d8" --release --min-api "$MIN_SDK" --lib "$PLATFORM" \
        --output "$OUT" @"$OUT/classes.txt"
fi

echo "[6/6] packaging and signing"
cp "$OUT/base.apk" "$OUT/unsigned.apk"
(cd "$OUT" && zip -q -X unsigned.apk classes.dex)
"$BT/zipalign" -f -p 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"
"$BT/apksigner" sign \
    --ks "$KEYSTORE" --ks-pass "pass:$STOREPASS" --key-pass "pass:$STOREPASS" \
    --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
    --out "$OUT/$NAME.apk" "$OUT/aligned.apk"
"$BT/apksigner" verify --print-certs "$OUT/$NAME.apk" > /dev/null

echo
echo "  built: $OUT/$NAME.apk  ($(du -h "$OUT/$NAME.apk" | cut -f1))"
