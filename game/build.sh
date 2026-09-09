#!/usr/bin/env bash
# Construit Battle Brink : APK Android, build web, binaire Linux.
#
#   ./build.sh apk     -> build/BattleBrink.apk
#   ./build.sh web     -> build/web/index.html
#   ./build.sh linux   -> build/BattleBrink.x86_64
#   ./build.sh all
#
# Le script installe ce qui manque dans .tools/ (Godot, templates d'export,
# SDK Android, JDK 17, cle de debug). Rien n'est installe sur le systeme.
set -euo pipefail

GODOT_VERSION="4.4.1-stable"
JDK_VERSION="17.0.13+11"
BUILD_TOOLS="34.0.0"
ANDROID_PLATFORM="android-34"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS="$HERE/.tools"
OUT="$HERE/../build"
mkdir -p "$TOOLS" "$OUT"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# ---------------------------------------------------------------- Godot
GODOT_BIN="${GODOT:-}"
if [ -z "$GODOT_BIN" ]; then
	GODOT_BIN="$TOOLS/Godot_v${GODOT_VERSION}_linux.x86_64"
	if [ ! -x "$GODOT_BIN" ]; then
		say "Telechargement de Godot $GODOT_VERSION"
		curl -sSL -o "$TOOLS/godot.zip" \
			"https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
		unzip -q -o "$TOOLS/godot.zip" -d "$TOOLS"
		chmod +x "$GODOT_BIN"
	fi
fi

# ---------------------------------------------------------------- templates
TPL_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION/-/.}"
if [ ! -f "$TPL_DIR/android_debug.apk" ]; then
	say "Telechargement des templates d'export (~1 Go)"
	curl -sSL -o "$TOOLS/templates.tpz" \
		"https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_export_templates.tpz"
	mkdir -p "$(dirname "$TPL_DIR")"
	rm -rf "$TOOLS/tpl"
	unzip -q -o "$TOOLS/templates.tpz" -d "$TOOLS/tpl"
	rm -rf "$TPL_DIR"
	mv "$TOOLS/tpl/templates" "$TPL_DIR"
fi

setup_android() {
	# --- JDK 17 : Godot 4.4 refuse les autres versions pour Android
	JDK="$TOOLS/jdk-$JDK_VERSION"
	if [ ! -x "$JDK/bin/javac" ]; then
		say "Telechargement du JDK $JDK_VERSION"
		curl -sSL -o "$TOOLS/jdk.tar.gz" \
			"https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_VERSION/+/%2B}/OpenJDK17U-jdk_x64_linux_hotspot_${JDK_VERSION/+/_}.tar.gz"
		tar xzf "$TOOLS/jdk.tar.gz" -C "$TOOLS"
	fi

	# --- SDK Android
	SDK="$TOOLS/android-sdk"
	if [ ! -x "$SDK/build-tools/$BUILD_TOOLS/apksigner" ]; then
		say "Installation du SDK Android"
		mkdir -p "$SDK/cmdline-tools"
		curl -sSL -o "$TOOLS/cmdtools.zip" \
			"https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
		rm -rf "$TOOLS/cmdtmp"
		unzip -q -o "$TOOLS/cmdtools.zip" -d "$TOOLS/cmdtmp"
		rm -rf "$SDK/cmdline-tools/latest"
		mv "$TOOLS/cmdtmp/cmdline-tools" "$SDK/cmdline-tools/latest"
		yes 2>/dev/null | "$SDK/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null || true
		"$SDK/cmdline-tools/latest/bin/sdkmanager" \
			"platform-tools" "build-tools;$BUILD_TOOLS" "platforms;$ANDROID_PLATFORM" >/dev/null
	fi

	# --- cle de debug
	KEYSTORE="$TOOLS/debug.keystore"
	if [ ! -f "$KEYSTORE" ]; then
		say "Generation de la cle de debug"
		"$JDK/bin/keytool" -keyalg RSA -genkeypair -alias androiddebugkey \
			-keypass android -keystore "$KEYSTORE" -storepass android \
			-dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
	fi

	# --- reglages editeur lus par l'export en ligne de commande
	mkdir -p "$HOME/.config/godot"
	cat > "$HOME/.config/godot/editor_settings-4.4.tres" <<EOF
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$SDK"
export/android/java_sdk_path = "$JDK"
export/android/debug_keystore = "$KEYSTORE"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
EOF
}

target="${1:-all}"

case "$target" in
	apk|android|all)
		setup_android
		say "Export APK"
		"$GODOT_BIN" --headless --path "$HERE" --export-debug "Android" "$OUT/BattleBrink.apk"
		ls -lh "$OUT/BattleBrink.apk"
		;;&
	web|all)
		say "Export web"
		mkdir -p "$OUT/web"
		"$GODOT_BIN" --headless --path "$HERE" --export-debug "Web" "$OUT/web/index.html"
		;;&
	linux|all)
		say "Export Linux"
		"$GODOT_BIN" --headless --path "$HERE" --export-debug "Linux" "$OUT/BattleBrink.x86_64"
		;;&
	apk|android|web|linux|all) say "Termine. Resultats dans $OUT" ;;
	*) echo "usage: $0 [apk|web|linux|all]"; exit 1 ;;
esac
