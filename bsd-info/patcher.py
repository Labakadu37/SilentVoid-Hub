#!/usr/bin/env python3
"""
BSD Info - APK Patcher
Injecte librevenge.so (Frida gadget) + agent.js dans l'APK Brawl Stars.

Usage:
    python3 patcher.py --input BrawlStars.apk --gadget librevenge.so --output BSInfo.apk
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

AGENT_SRC  = os.path.join(os.path.dirname(__file__), "agent", "agent.js")
CONFIG_SRC = os.path.join(os.path.dirname(__file__), "gadget-config.json")

PERM_OVERLAY = "android.permission.SYSTEM_ALERT_WINDOW"
TARGET_ARCH  = "arm64-v8a"


def check_tools():
    for tool in ("apktool", "zipalign", "apksigner", "keytool"):
        if shutil.which(tool) is None:
            sys.exit(f"[!] Outil manquant : {tool}")
    print("[+] Outils OK")


def decompile_apk(apk_path, out_dir):
    print(f"[*] Décompilation de {apk_path}...")
    subprocess.run(
        ["apktool", "d", "-f", "-o", out_dir, apk_path],
        check=True, capture_output=True
    )
    print("[+] APK décompilé")


def add_permission(manifest_path):
    with open(manifest_path, "r", encoding="utf-8") as f:
        content = f.read()

    if PERM_OVERLAY in content:
        print("[+] Permission SYSTEM_ALERT_WINDOW déjà présente")
        return

    # Insérer après la première <uses-permission .../>
    insert = f'    <uses-permission android:name="{PERM_OVERLAY}"/>\n'
    content = re.sub(
        r'(<uses-permission[^/]*/>\n)',
        r'\1' + insert,
        content,
        count=1
    )
    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("[+] Permission SYSTEM_ALERT_WINDOW ajoutée")


def inject_gadget(out_dir, gadget_path):
    lib_dir     = os.path.join(out_dir, "lib", TARGET_ARCH)
    gadget_dst  = os.path.join(lib_dir, "librevenge.so")
    config_dst  = os.path.join(lib_dir, "librevenge.config.so")
    agent_dst   = os.path.join(out_dir, "assets", "bsd_agent.js")

    os.makedirs(lib_dir, exist_ok=True)
    os.makedirs(os.path.join(out_dir, "assets"), exist_ok=True)

    shutil.copy2(gadget_path, gadget_dst)
    print(f"[+] Gadget injecté → lib/{TARGET_ARCH}/librevenge.so")

    # Config gadget : charge l'agent depuis les assets Android
    config_content = '{"interaction":{"type":"script","path":"/data/data/com.supercell.brawlstars/files/bsd_agent.js"}}'
    with open(config_dst, "w") as f:
        f.write(config_content)
    print("[+] Config gadget créée → librevenge.config.so")

    shutil.copy2(AGENT_SRC, agent_dst)
    print("[+] Agent.js copié → assets/bsd_agent.js")


def recompile_apk(out_dir, unsigned_apk):
    print("[*] Recompilation...")
    subprocess.run(
        ["apktool", "b", out_dir, "-o", unsigned_apk],
        check=True, capture_output=True
    )
    print(f"[+] APK recompilé : {unsigned_apk}")


def sign_apk(unsigned_apk, output_apk, keystore, alias, password):
    aligned = unsigned_apk + ".aligned.apk"

    subprocess.run(
        ["zipalign", "-f", "4", unsigned_apk, aligned],
        check=True, capture_output=True
    )

    subprocess.run(
        [
            "apksigner", "sign",
            "--ks", keystore,
            "--ks-key-alias", alias,
            "--ks-pass", f"pass:{password}",
            "--key-pass", f"pass:{password}",
            "--out", output_apk,
            aligned
        ],
        check=True, capture_output=True
    )
    os.remove(aligned)
    print(f"[+] APK signé : {output_apk}")


def generate_keystore(keystore_path, alias, password):
    if os.path.exists(keystore_path):
        return
    print("[*] Génération du keystore de debug...")
    subprocess.run(
        [
            "keytool", "-genkey", "-noprompt",
            "-keystore", keystore_path,
            "-alias", alias,
            "-keyalg", "RSA", "-keysize", "2048",
            "-validity", "10000",
            "-storepass", password, "-keypass", password,
            "-dname", "CN=BSDInfo, O=Debug, C=FR"
        ],
        check=True, capture_output=True
    )
    print(f"[+] Keystore créé : {keystore_path}")


def main():
    parser = argparse.ArgumentParser(description="BSD Info APK Patcher")
    parser.add_argument("--input",   required=True, help="APK Brawl Stars original")
    parser.add_argument("--gadget",  required=True, help="librevenge.so (Frida gadget arm64)")
    parser.add_argument("--output",  default="BSInfo.apk", help="APK de sortie")
    parser.add_argument("--arch",    default="arm64-v8a",  help="Architecture cible")
    args = parser.parse_args()

    global TARGET_ARCH
    TARGET_ARCH = args.arch

    check_tools()

    with tempfile.TemporaryDirectory(prefix="bsdpatch_") as tmp:
        decompile_dir = os.path.join(tmp, "decompiled")
        unsigned_apk  = os.path.join(tmp, "unsigned.apk")
        keystore      = os.path.join(tmp, "debug.keystore")

        decompile_apk(args.input, decompile_dir)
        add_permission(os.path.join(decompile_dir, "AndroidManifest.xml"))
        inject_gadget(decompile_dir, args.gadget)
        recompile_apk(decompile_dir, unsigned_apk)
        generate_keystore(keystore, "bsdinfo", "bsdinfo123")
        sign_apk(unsigned_apk, args.output, keystore, "bsdinfo", "bsdinfo123")

    print(f"\n[✓] Patch terminé → {args.output}")
    print("[!] Installe avec : adb install -r " + args.output)
    print("[!] Push agent.js  : adb push agent/agent.js /data/data/com.supercell.brawlstars/files/bsd_agent.js")


if __name__ == "__main__":
    main()
