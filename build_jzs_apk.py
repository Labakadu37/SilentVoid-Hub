#!/usr/bin/env python3
"""
Script pour construire l'APK JZS Brawl.
Usage:
  1. Clone le repo: git clone https://github.com/Labakadu37/SilentVoid-Hub.git
  2. Telecharge le BS v69 XAPK depuis APKPure et mets-le dans le dossier
  3. Lance: python3 build_jzs_apk.py <chemin_vers_xapk_ou_apk>

Le script va:
  - Extraire resources.arsc + sc/sfx/music du BS original
  - Combiner avec les fichiers JZS du repo
  - Signer l'APK
  - Resultat: JZSBrawl_signed.apk
"""
import zipfile, os, sys, subprocess, tempfile, shutil

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 build_jzs_apk.py <chemin_vers_bs.xapk_ou_bs.apk>")
        print("Telecharge BS v69 depuis APKPure (XAPK) ou un APK normal")
        sys.exit(1)

    bs_file = sys.argv[1]
    repo_dir = os.path.dirname(os.path.abspath(__file__))
    output = os.path.join(repo_dir, "JZSBrawl.apk")
    output_signed = os.path.join(repo_dir, "JZSBrawl_signed.apk")

    print(f"=== Construction de JZS Brawl APK ===")
    print(f"Source BS: {bs_file}")
    print(f"Repo JZS: {repo_dir}")

    # Detect if XAPK or APK
    with zipfile.ZipFile(bs_file, 'r') as z:
        names = z.namelist()
        is_xapk = any(n.endswith('.apk') for n in names if n != bs_file)

    tmpdir = tempfile.mkdtemp(prefix="jzs_build_")

    try:
        if is_xapk:
            print("\nDetecte: XAPK (bundle)")
            with zipfile.ZipFile(bs_file, 'r') as xapk:
                # Find base APK and asset pack
                base_apk_name = None
                asset_pack_name = None
                for n in xapk.namelist():
                    if n.startswith('com.supercell.brawlstars') and n.endswith('.apk'):
                        base_apk_name = n
                    elif 'asset_pack' in n and n.endswith('.apk'):
                        asset_pack_name = n

                if not base_apk_name:
                    # Fallback: first .apk that isn't config
                    for n in xapk.namelist():
                        if n.endswith('.apk') and 'config.' not in n and 'asset' not in n:
                            base_apk_name = n
                            break

                print(f"  Base APK: {base_apk_name}")
                print(f"  Asset pack: {asset_pack_name}")

                xapk.extract(base_apk_name, tmpdir)
                base_apk_path = os.path.join(tmpdir, base_apk_name)

                if asset_pack_name:
                    xapk.extract(asset_pack_name, tmpdir)
                    asset_pack_path = os.path.join(tmpdir, asset_pack_name)
                else:
                    asset_pack_path = None
        else:
            print("\nDetecte: APK simple")
            base_apk_path = bs_file
            asset_pack_path = None

        # Extract resources.arsc
        print("\nExtraction de resources.arsc...")
        with zipfile.ZipFile(base_apk_path, 'r') as base:
            base.extract('resources.arsc', tmpdir)
        resources_arsc = os.path.join(tmpdir, 'resources.arsc')

        # Build APK
        print("\nConstruction de l'APK JZS...")
        SKIP = {'.git', '.github', '.claude', '__pycache__'}
        SKIP_FILES = {'.gitattributes', '.gitignore', 'build_jzs_apk.py'}

        with zipfile.ZipFile(output, 'w', zipfile.ZIP_STORED) as apk:
            # Add resources.arsc
            apk.write(resources_arsc, 'resources.arsc')
            print("  + resources.arsc")

            # Add repo files
            count = 0
            for root, dirs, files in os.walk(repo_dir):
                dirs[:] = [d for d in dirs if d not in SKIP]
                for fname in files:
                    if fname in SKIP_FILES:
                        continue
                    fpath = os.path.join(root, fname)
                    arcname = os.path.relpath(fpath, repo_dir)
                    apk.write(fpath, arcname)
                    count += 1
                    if count % 3000 == 0:
                        print(f"  + {count} fichiers...")
            print(f"  Total repo: {count} fichiers")

            # Add sc/sfx/music from asset pack or base APK
            source = asset_pack_path or base_apk_path
            if source:
                print(f"\n  Ajout des assets (sc/sfx/music)...")
                added = 0
                with zipfile.ZipFile(source, 'r') as pack:
                    for info in pack.infolist():
                        name = info.filename
                        if ('assets/sc/' in name or 'assets/sfx/' in name or
                            'assets/music/' in name or 'assets/badge/' in name):
                            # Fix path if needed (remove leading dirs)
                            if name.startswith('assets/'):
                                arcname = name
                            else:
                                # Find assets/ in path
                                idx = name.find('assets/')
                                if idx >= 0:
                                    arcname = name[idx:]
                                else:
                                    continue
                            data = pack.read(name)
                            apk.writestr(arcname, data)
                            added += 1
                            if added % 2000 == 0:
                                print(f"  + {added} assets...")
                print(f"  Total assets ajoutes: {added}")

        size_mb = os.path.getsize(output) / 1024 / 1024
        print(f"\nAPK cree: {output} ({size_mb:.0f} MB)")

        # Sign
        print("\nSignature de l'APK...")
        keystore = os.path.join(tmpdir, "jzs.keystore")
        subprocess.run([
            "keytool", "-genkeypair", "-alias", "jzsbrawl",
            "-keyalg", "RSA", "-keysize", "2048", "-validity", "10000",
            "-keystore", keystore, "-storepass", "jzsbrawl123",
            "-keypass", "jzsbrawl123",
            "-dname", "CN=JZS Team, OU=JZS, O=JZS Brawl, L=Paris, ST=IDF, C=FR"
        ], check=True, capture_output=True)

        shutil.copy2(output, output_signed)
        subprocess.run([
            "jarsigner", "-sigalg", "SHA256withRSA", "-digestalg", "SHA-256",
            "-keystore", keystore, "-storepass", "jzsbrawl123",
            "-keypass", "jzsbrawl123", output_signed, "jzsbrawl"
        ], check=True, capture_output=True)

        print(f"\n=== TERMINE ! ===")
        print(f"APK signe: {output_signed}")
        print(f"Taille: {os.path.getsize(output_signed) / 1024 / 1024:.0f} MB")
        print(f"\nInstalle avec: adb install {output_signed}")
        print(f"Ou transfère le fichier sur ton telephone et installe-le.")

    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)

if __name__ == "__main__":
    main()
