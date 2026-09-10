#!/usr/bin/env python3
"""
patch_apk.py — JZS Brawl APK Patcher
Utilisation : python3 patch_apk.py <BrawlStars.apk> <libJZS_arm64.so> <libJZS_arm32.so>

Ce script :
  1. Décompile l'APK avec apktool
  2. Copie JZSOverlay.smali
  3. Injecte System.loadLibrary("JZS") dans la MainActivity
  4. Injecte l'appel JZSOverlay.setup() dans onStart()
  5. Copie libJZS.so pour arm64-v8a et armeabi-v7a
  6. Recompile et signe l'APK
"""

import os
import sys
import shutil
import subprocess
import re
import glob

# ── Config ────────────────────────────────────────────────────────────────────
SMALI_SRC    = os.path.join(os.path.dirname(__file__), "../smali")
OUT_APK      = "JZSBrawl_v69.230.apk"
WORK_DIR     = "bs_decompiled"
KEYSTORE     = "jzs_key.keystore"
KEY_ALIAS    = "jzs"
KEY_PASS     = "jzsbrawl"

# ── Couleurs terminal ─────────────────────────────────────────────────────────
def ok(msg):  print(f"\033[92m[+]\033[0m {msg}")
def err(msg): print(f"\033[91m[-]\033[0m {msg}")
def inf(msg): print(f"\033[94m[*]\033[0m {msg}")

# ── Helpers ───────────────────────────────────────────────────────────────────
def run(cmd, check=True):
    inf(f"$ {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if check and result.returncode != 0:
        err(f"Echec: {result.stderr}")
        sys.exit(1)
    return result

def find_main_activity(work_dir):
    """Trouve la MainActivity dans l'AndroidManifest."""
    manifest = os.path.join(work_dir, "AndroidManifest.xml")
    with open(manifest, "r", encoding="utf-8") as f:
        content = f.read()
    # Cherche l'activity avec MAIN + LAUNCHER
    match = re.search(
        r'android:name="([^"]+)"[^>]*(?:(?!<activity).)*?'
        r'<action\s+android:name="android\.intent\.action\.MAIN"',
        content, re.DOTALL
    )
    if not match:
        # Fallback : cherche juste le premier <activity android:name=
        match = re.search(r'<activity[^>]*android:name="([^"]+)"', content)
    return match.group(1) if match else None

def activity_to_smali_path(work_dir, activity_name):
    """Convertit com.supercell.brawlstars.MainActivity → chemin smali."""
    if activity_name.startswith("."):
        # Nom relatif → cherche le package dans le manifest
        with open(os.path.join(work_dir, "AndroidManifest.xml")) as f:
            pkg_match = re.search(r'package="([^"]+)"', f.read())
        pkg = pkg_match.group(1) if pkg_match else ""
        activity_name = pkg + activity_name
    smali_rel = activity_name.replace(".", "/") + ".smali"
    # Cherche dans smali, smali_classes2, etc.
    for folder in sorted(glob.glob(os.path.join(work_dir, "smali*"))):
        path = os.path.join(folder, smali_rel)
        if os.path.exists(path):
            return path
    return None

def inject_load_library(smali_path):
    """Injecte System.loadLibrary('JZS') dans le constructeur statique ou onCreate."""
    with open(smali_path, "r", encoding="utf-8") as f:
        content = f.read()

    load_code = (
        "\n    # ── JZS Brawl : charge la lib native ──\n"
        "    const-string v0, \"JZS\"\n"
        "    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V\n"
        "    # ───────────────────────────────────────\n"
    )

    # Vérifie si déjà injecté
    if "JZS Brawl" in content:
        ok("loadLibrary déjà présent, skip")
        return

    # Cherche onCreate ou le premier .method public (fallback)
    target = '.method public onCreate(Landroid/os/Bundle;)V'
    if target not in content:
        target = '.method public constructor <init>()V'
    if target not in content:
        err(f"Impossible de trouver un point d'injection dans {smali_path}")
        return

    # Insère après la première ligne ".registers" ou après le .method
    idx = content.index(target)
    block_start = content.index('\n', idx) + 1
    # Cherche .registers ou la 1re instruction
    reg_match = re.search(r'\.registers \d+\n', content[block_start:])
    if reg_match:
        insert_pos = block_start + reg_match.end()
    else:
        insert_pos = block_start

    content = content[:insert_pos] + load_code + content[insert_pos:]
    with open(smali_path, "w", encoding="utf-8") as f:
        f.write(content)
    ok(f"loadLibrary injecté dans {os.path.basename(smali_path)}")

def inject_overlay_call(smali_path):
    """Injecte JZSOverlay.setup(this) dans onStart()."""
    with open(smali_path, "r", encoding="utf-8") as f:
        content = f.read()

    overlay_code = (
        "\n    # ── JZS Brawl : affiche l'overlay texte doré ──\n"
        "    invoke-static {p0}, Lcom/jzsbrawl/JZSOverlay;->setup(Landroid/app/Activity;)V\n"
        "    # ──────────────────────────────────────────────\n"
    )

    if "JZSOverlay" in content:
        ok("overlay call déjà présent, skip")
        return

    # Cherche onStart, sinon onResume, sinon onCreate
    for target in [
        ".method public onStart()V",
        ".method protected onStart()V",
        ".method public onResume()V",
        ".method protected onResume()V",
        ".method public onCreate(Landroid/os/Bundle;)V",
    ]:
        if target in content:
            idx = content.index(target)
            block_start = content.index('\n', idx) + 1
            reg_match = re.search(r'\.registers \d+\n', content[block_start:])
            if reg_match:
                insert_pos = block_start + reg_match.end()
            else:
                insert_pos = block_start
            content = content[:insert_pos] + overlay_code + content[insert_pos:]
            with open(smali_path, "w", encoding="utf-8") as f:
                f.write(content)
            ok(f"JZSOverlay.setup() injecté dans {target.split()[2]}")
            return

    err("Aucune méthode onStart/onResume/onCreate trouvée pour l'overlay")

def copy_smali(work_dir):
    """Copie les fichiers smali de JZS dans le dossier décompilé."""
    dst_smali = os.path.join(work_dir, "smali", "com", "jzsbrawl")
    os.makedirs(dst_smali, exist_ok=True)
    src = os.path.join(SMALI_SRC, "com", "jzsbrawl")
    for f in os.listdir(src):
        shutil.copy2(os.path.join(src, f), dst_smali)
    ok("Smali JZS copiés")

def copy_so(work_dir, so_arm64, so_arm32):
    """Copie libJZS.so dans les dossiers lib/."""
    for arch, so_path in [("arm64-v8a", so_arm64), ("armeabi-v7a", so_arm32)]:
        if not so_path or not os.path.exists(so_path):
            inf(f"lib {arch} ignorée (fichier non fourni)")
            continue
        dst = os.path.join(work_dir, "lib", arch)
        os.makedirs(dst, exist_ok=True)
        shutil.copy2(so_path, os.path.join(dst, "libJZS.so"))
        ok(f"libJZS.so copié → lib/{arch}/")

def generate_keystore():
    """Génère un keystore de debug si absent."""
    if os.path.exists(KEYSTORE):
        return
    inf("Génération du keystore de signature...")
    run([
        "keytool", "-genkeypair", "-v",
        "-keystore", KEYSTORE,
        "-alias", KEY_ALIAS,
        "-keyalg", "RSA", "-keysize", "2048",
        "-validity", "9125",
        "-storepass", KEY_PASS,
        "-keypass", KEY_PASS,
        "-dname", "CN=JZSBrawl, OU=JZS, O=JZS, L=Unknown, ST=Unknown, C=US"
    ])
    ok("Keystore créé : " + KEYSTORE)

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    if len(sys.argv) < 2:
        print(f"Usage: python3 {sys.argv[0]} <BrawlStars.apk> [arm64.so] [arm32.so]")
        sys.exit(1)

    apk_in  = sys.argv[1]
    so_64   = sys.argv[2] if len(sys.argv) > 2 else None
    so_32   = sys.argv[3] if len(sys.argv) > 3 else None

    if not os.path.exists(apk_in):
        err(f"APK introuvable : {apk_in}")
        sys.exit(1)

    print()
    print("  ╔══════════════════════════════════════╗")
    print("  ║   JZS Brawl v69.230 - APK Patcher   ║")
    print("  ║   Telegram: t.me/jzbrawl             ║")
    print("  ╚══════════════════════════════════════╝")
    print()

    # 1. Décompile
    if os.path.exists(WORK_DIR):
        shutil.rmtree(WORK_DIR)
    run(["apktool", "d", apk_in, "-o", WORK_DIR, "--no-src", "-f"])
    ok("APK décompilé")

    # 2. Trouve la MainActivity
    activity = find_main_activity(WORK_DIR)
    if not activity:
        err("MainActivity introuvable dans le manifest")
        sys.exit(1)
    inf(f"MainActivity : {activity}")

    smali_path = activity_to_smali_path(WORK_DIR, activity)
    if not smali_path:
        err(f"Fichier smali introuvable pour {activity}")
        sys.exit(1)
    inf(f"Fichier smali : {smali_path}")

    # 3. Injections
    inject_load_library(smali_path)
    copy_smali(WORK_DIR)
    inject_overlay_call(smali_path)

    # 4. Copy .so libs
    copy_so(WORK_DIR, so_64, so_32)

    # 5. Recompile
    unsigned = OUT_APK.replace(".apk", "_unsigned.apk")
    run(["apktool", "b", WORK_DIR, "-o", unsigned])
    ok("APK recompilé")

    # 6. Aligne
    aligned = OUT_APK.replace(".apk", "_aligned.apk")
    run(["zipalign", "-v", "-p", "4", unsigned, aligned], check=False)
    if not os.path.exists(aligned):
        shutil.copy2(unsigned, aligned)
        inf("zipalign ignoré (non installé), utilise l'APK brut")

    # 7. Signe
    generate_keystore()
    run([
        "apksigner", "sign",
        "--ks", KEYSTORE,
        "--ks-key-alias", KEY_ALIAS,
        "--ks-pass", f"pass:{KEY_PASS}",
        "--key-pass", f"pass:{KEY_PASS}",
        "--out", OUT_APK,
        aligned
    ])

    # Nettoyage
    for f in [unsigned, aligned]:
        if os.path.exists(f):
            os.remove(f)

    print()
    ok(f"APK patchée : \033[1m{OUT_APK}\033[0m")
    print()
    print("  Installation : adb install -r " + OUT_APK)
    print()

if __name__ == "__main__":
    main()
