#!/usr/bin/env python3
"""
JZS Brawl - Injection du code smali overlay dans l'APK decompile.
Copie la classe JzsOverlay et hook l'activite principale pour l'appeler.
"""

import os
import re
import glob
import shutil


def find_game_activity(decompiled_dir):
    """Trouve l'activite principale du jeu dans le smali."""
    manifest_path = os.path.join(decompiled_dir, "AndroidManifest.xml")

    activity_class = None
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = f.read()

        match = re.search(
            r'<activity[^>]*android:name="([^"]*)"[^>]*>.*?'
            r'<action\s+android:name="android\.intent\.action\.MAIN"',
            manifest, re.DOTALL
        )
        if match:
            activity_class = match.group(1)
            print(f"[JZS] Activite MAIN trouvee dans le manifest: {activity_class}")

    smali_dirs = sorted(glob.glob(os.path.join(decompiled_dir, "smali*")))
    if not smali_dirs:
        return None, None

    if activity_class:
        smali_rel = activity_class.replace(".", "/") + ".smali"
        for sd in smali_dirs:
            candidate = os.path.join(sd, smali_rel)
            if os.path.exists(candidate):
                return candidate, activity_class

    search_names = [
        "GameApp", "GameActivity", "MainActivity", "GameNativeActivity",
        "NativeActivity", "UnityPlayerActivity", "SupercellActivity"
    ]

    for sd in smali_dirs:
        for root, dirs, files in os.walk(sd):
            for name in search_names:
                for f in files:
                    if name.lower() in f.lower() and f.endswith(".smali"):
                        path = os.path.join(root, f)
                        rel = os.path.relpath(path, sd).replace(".smali", "").replace("/", ".")
                        return path, rel

    for sd in smali_dirs:
        for root, dirs, files in os.walk(sd):
            for f in files:
                if not f.endswith(".smali"):
                    continue
                path = os.path.join(root, f)
                try:
                    with open(path, "r", encoding="utf-8") as fh:
                        content = fh.read(3000)
                    if "onCreate" in content and "Landroid/app/Activity" in content:
                        rel = os.path.relpath(path, sd).replace(".smali", "").replace("/", ".")
                        return path, rel
                except Exception:
                    pass

    return None, None


def copy_overlay_class(decompiled_dir):
    """Copie la classe JzsOverlay.smali dans le dossier smali."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    source = os.path.join(script_dir, "smali_overlay", "JzsOverlay.smali")

    smali_dirs = sorted(glob.glob(os.path.join(decompiled_dir, "smali*")))
    target_dir = smali_dirs[0] if smali_dirs else os.path.join(decompiled_dir, "smali")

    dest_dir = os.path.join(target_dir, "com", "jzs", "brawl")
    os.makedirs(dest_dir, exist_ok=True)

    dest_file = os.path.join(dest_dir, "JzsOverlay.smali")
    shutil.copy2(source, dest_file)
    print(f"[JZS] Classe overlay copiee: {dest_file}")
    return dest_file


def hook_oncreate(activity_path):
    """Injecte l'appel a JzsOverlay.inject() dans le onCreate de l'activite."""
    with open(activity_path, "r", encoding="utf-8") as f:
        smali = f.read()

    if "JzsOverlay" in smali:
        print("[JZS] Hook deja present, skip")
        return True

    inject_call = (
        "\n"
        "    # JZS Brawl overlay hook\n"
        "    invoke-static {p0}, Lcom/jzs/brawl/JzsOverlay;->inject(Landroid/app/Activity;)V\n"
    )

    pattern = r'(\.method[^\n]*onCreate\(Landroid/os/Bundle;\)V.*?)(invoke-super[^\n]*onCreate[^\n]*\n)'
    match = re.search(pattern, smali, re.DOTALL)

    if match:
        insert_pos = match.end()
        smali = smali[:insert_pos] + inject_call + smali[insert_pos:]

        with open(activity_path, "w", encoding="utf-8") as f:
            f.write(smali)
        print(f"[JZS] Hook injecte apres super.onCreate dans: {activity_path}")
        return True

    oncreate_match = re.search(r'\.method[^\n]*onCreate[^\n]*\n', smali)
    if oncreate_match:
        search_start = oncreate_match.end()
        end_method = smali.find(".end method", search_start)
        return_match = re.search(r'return-void', smali[search_start:end_method])

        if return_match:
            insert_pos = search_start + return_match.start()
            smali = smali[:insert_pos] + inject_call + "\n" + smali[insert_pos:]

            with open(activity_path, "w", encoding="utf-8") as f:
                f.write(smali)
            print(f"[JZS] Hook injecte avant return-void dans: {activity_path}")
            return True

    print(f"[JZS] WARN: Impossible de hooker onCreate dans {activity_path}")
    return False


def ensure_register_count(activity_path):
    """Verifie que le onCreate a assez de registres pour notre injection."""
    with open(activity_path, "r", encoding="utf-8") as f:
        smali = f.read()

    pattern = r'(\.method[^\n]*onCreate[^\n]*\n.*?)(\.registers\s+)(\d+)'
    match = re.search(pattern, smali, re.DOTALL)

    if match:
        current = int(match.group(3))
        if current < 4:
            smali = smali[:match.start(3)] + str(max(current, 4)) + smali[match.end(3):]
            with open(activity_path, "w", encoding="utf-8") as f:
                f.write(smali)
            print(f"[JZS] Registres augmentes a {max(current, 4)}")


def run_injection(decompiled_dir):
    """Pipeline complet d'injection smali."""
    print("\n[JZS] === Injection Smali ===\n")

    activity_path, activity_class = find_game_activity(decompiled_dir)

    if not activity_path:
        print("[JZS] ERREUR: Activite principale non trouvee!")
        print("[JZS] Le jeu sera quand meme patche via les layouts XML")
        return False

    print(f"[JZS] Activite: {activity_class}")
    print(f"[JZS] Fichier: {activity_path}")

    copy_overlay_class(decompiled_dir)
    ensure_register_count(activity_path)
    result = hook_oncreate(activity_path)

    if result:
        print("\n[JZS] Injection smali reussie!")
        print("[JZS] Le texte 'JZS Brawl V69.230 / Version testing'")
        print("[JZS] sera affiche en overlay sur le menu du jeu")

    return result


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 inject_smali.py <chemin_decompile>")
        sys.exit(1)
    run_injection(sys.argv[1])
