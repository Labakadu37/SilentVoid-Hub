# JZS Brawl - Guide de build

## 1. Compiler libJZS.so (Android NDK)

```bash
# Installe NDK depuis Android Studio ou :
# https://developer.android.com/ndk/downloads

export ANDROID_NDK=/path/to/ndk

# Build arm64 (Android moderne)
mkdir -p build/arm64 && cd build/arm64
cmake ../.. \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DCMAKE_BUILD_TYPE=Release
make -j4
# → build/arm64/libJZS.so

# Build arm32 (anciens appareils)
cd ../..
mkdir -p build/arm32 && cd build/arm32
cmake ../.. \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=armeabi-v7a \
  -DANDROID_PLATFORM=android-21 \
  -DCMAKE_BUILD_TYPE=Release
make -j4
# → build/arm32/libJZS.so
```

## 2. Patcher l'APK Brawl Stars

```bash
# Dépendances :
#   pip install (rien, stdlib Python seulement)
#   apt install apktool zipalign apksigner  (ou via sdkmanager)

cd patch/

python3 patch_apk.py \
  /path/to/BrawlStars_v69.apk \
  ../build/arm64/libJZS.so \
  ../build/arm32/libJZS.so
```

Le script génère : **JZSBrawl_v69.230.apk**

## 3. Installer

```bash
adb install -r JZSBrawl_v69.230.apk
```

## Résultat

Au lancement du jeu, en haut à gauche :

```
JZS Brawl v69.230 - (release)   ← texte OR #FFD700
Telegram: t.me/jzbrawl           ← texte OR avec ombre noire
```
