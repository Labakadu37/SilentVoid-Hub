#!/usr/bin/env python3
"""
JZS Brawl - APK Creator
Crée JZS Brawl depuis le mod BSD (REvengeBS.apk) :
  - Patch binaire : _bsd → _jzs dans libapp.so
  - Rename librevenge.so → libjzs.so + config
  - Re-signe avec un nouveau keystore

Usage:
    python3 make_jzs.py --input REvengeBS.apk --output JZSBrawl.apk
"""

import argparse
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import zipfile


# ---- Patch binaire : remplace TOUTES les occurrences de needle par replacement ----
def binary_patch(data: bytes, needle: bytes, replacement: bytes) -> bytes:
    assert len(needle) == len(replacement), "Même longueur requise pour patch in-place"
    result = bytearray(data)
    pos = 0
    count = 0
    while True:
        idx = result.find(needle, pos)
        if idx == -1:
            break
        result[idx:idx + len(needle)] = replacement
        pos = idx + len(replacement)
        count += 1
    print(f"  [{count} occurrence(s)] {needle!r} → {replacement!r}")
    return bytes(result)


# ---- Re-signe l'APK ----
def sign_apk(unsigned: str, output: str, keystore: str, alias: str, pwd: str):
    aligned = unsigned + ".aligned"
    subprocess.run(["zipalign", "-f", "4", unsigned, aligned], check=True, capture_output=True)
    subprocess.run([
        "apksigner", "sign",
        "--ks", keystore,
        "--ks-key-alias", alias,
        "--ks-pass", f"pass:{pwd}",
        "--key-pass", f"pass:{pwd}",
        "--out", output,
        aligned
    ], check=True, capture_output=True)
    os.remove(aligned)


def gen_keystore(path: str, alias: str, pwd: str):
    if os.path.exists(path):
        return
    subprocess.run([
        "keytool", "-genkey", "-noprompt",
        "-keystore", path,
        "-alias", alias,
        "-keyalg", "RSA", "-keysize", "2048",
        "-validity", "10000",
        "-storepass", pwd, "-keypass", pwd,
        "-dname", "CN=JZSBrawl, O=JZS, C=FR"
    ], check=True, capture_output=True)
    print("[+] Keystore JZS généré")


def check_tools():
    for t in ("zipalign", "apksigner", "keytool"):
        if not shutil.which(t):
            sys.exit(f"[!] Outil manquant : {t}")


def main():
    parser = argparse.ArgumentParser(description="JZS Brawl APK Creator")
    parser.add_argument("--input",  required=True, help="REvengeBS.apk (mod BSD)")
    parser.add_argument("--output", default="JZSBrawl.apk")
    args = parser.parse_args()

    check_tools()

    print(f"[*] Lecture de {args.input} ({os.path.getsize(args.input) // 1024 // 1024} MB)...")

    with tempfile.TemporaryDirectory(prefix="jzspatch_") as tmp:
        unsigned  = os.path.join(tmp, "unsigned.apk")
        keystore  = os.path.join(tmp, "jzs.keystore")

        gen_keystore(keystore, "jzsbrawl", "jzsbrawl123")

        print("[*] Patch du mod BSD → JZS Brawl...")

        # Fichiers à patcher dans le ZIP (nom → nouvelle data)
        patches = {}

        with zipfile.ZipFile(args.input, "r") as src_zip:
            names = src_zip.namelist()

            # ---- Patch libapp.so (_bsd → _jzs) ----
            if "lib/arm64-v8a/libapp.so" in names:
                print("[*] Patch libapp.so...")
                data = src_zip.read("lib/arm64-v8a/libapp.so")
                data = binary_patch(data, b"_bsd@", b"_jzs@")
                data = binary_patch(data, b"_Bsd@", b"_Jzs@")
                patches["lib/arm64-v8a/libapp.so"] = data
                print("[+] libapp.so patché")

            # ---- Rename librevenge.so → libjzs.so ----
            # On garde librevenge.so tel quel (c'est le gadget Frida, rien à changer)
            # mais on ajoute la config sous le bon nom
            if "lib/arm64-v8a/librevenge.so" in names:
                # Lire le gadget
                gadget_data = src_zip.read("lib/arm64-v8a/librevenge.so")
                # Garder sous le même nom (le système Android charge les .so au démarrage)
                patches["lib/arm64-v8a/librevenge.so"] = gadget_data
                print("[+] librevenge.so conservé (Frida gadget)")

        # ---- Réécrire le ZIP sans les signatures META-INF originales ----
        print("[*] Reconstruction APK...")
        with zipfile.ZipFile(args.input, "r") as src_zip, \
             zipfile.ZipFile(unsigned, "w", zipfile.ZIP_DEFLATED, allowZip64=True) as dst_zip:

            for item in src_zip.infolist():
                name = item.filename

                # Supprimer l'ancienne signature
                if name.startswith("META-INF/") and name.endswith((".RSA", ".SF", ".MF")):
                    continue
                if name == "stamp-cert-sha256":
                    continue

                if name in patches:
                    # Écrire la version patchée
                    dst_zip.writestr(item, patches[name])
                else:
                    # Copier tel quel
                    data = src_zip.read(name)
                    dst_zip.writestr(item, data)

        print("[*] Signature JZS Brawl...")
        sign_apk(unsigned, args.output, keystore, "jzsbrawl", "jzsbrawl123")

        size_mb = os.path.getsize(args.output) // 1024 // 1024
        print(f"\n[✓] JZS Brawl créé → {args.output} ({size_mb} MB)")
        print("[!] Install : adb install -r " + args.output)
        print("[!] Ou copie sur le téléphone et installe manuellement (activer sources inconnues)")


if __name__ == "__main__":
    main()
