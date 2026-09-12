#!/usr/bin/env python3
"""
JZS Brawl - Patch du menu principal pour afficher le texte custom.
Injecte un TextView overlay dans le layout du menu de Brawl Stars.
"""

import os
import re
import glob


BRAND_TEXT = "JZS Brawl V69.230"
VERSION_TEXT = "Version testing"


def find_main_activity_layout(decompiled_dir):
    """Cherche le layout XML du menu principal de Brawl Stars."""
    res_dir = os.path.join(decompiled_dir, "res")

    candidates = []
    for layout_dir in glob.glob(os.path.join(res_dir, "layout*")):
        for xml_file in glob.glob(os.path.join(layout_dir, "*.xml")):
            candidates.append(xml_file)

    priority_names = [
        "activity_main", "main_menu", "menu_main", "home_screen",
        "activity_game", "game_main", "main", "activity_loading",
        "splash", "loading_screen"
    ]

    for name in priority_names:
        for c in candidates:
            if name in os.path.basename(c).lower():
                return c

    if candidates:
        return candidates[0]

    return None


def create_overlay_layout(decompiled_dir):
    """Cree un layout overlay XML pour l'affichage du texte custom."""
    layout_dir = os.path.join(decompiled_dir, "res", "layout")
    os.makedirs(layout_dir, exist_ok=True)

    overlay_path = os.path.join(layout_dir, "jzs_overlay.xml")
    overlay_xml = f"""<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_gravity="top|left"
    android:padding="12dp">

    <LinearLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:background="#80000000"
        android:padding="8dp">

        <TextView
            android:id="@+id/jzs_brand"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="{BRAND_TEXT}"
            android:textColor="#FFFFFF"
            android:textSize="16sp"
            android:textStyle="bold"
            android:shadowColor="#000000"
            android:shadowDx="1"
            android:shadowDy="1"
            android:shadowRadius="3" />

        <TextView
            android:id="@+id/jzs_version"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="{VERSION_TEXT}"
            android:textColor="#00FF88"
            android:textSize="12sp"
            android:shadowColor="#000000"
            android:shadowDx="1"
            android:shadowDy="1"
            android:shadowRadius="2" />

    </LinearLayout>
</FrameLayout>
"""
    with open(overlay_path, "w", encoding="utf-8") as f:
        f.write(overlay_xml)

    print(f"[JZS] Layout overlay cree: {overlay_path}")
    return overlay_path


def inject_into_main_layout(layout_path):
    """Injecte le texte JZS directement dans un layout existant."""
    with open(layout_path, "r", encoding="utf-8") as f:
        content = f.read()

    jzs_overlay = f"""
    <!-- JZS Brawl Overlay -->
    <FrameLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="top|left"
        android:padding="16dp"
        android:elevation="100dp">
        <LinearLayout
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:background="#80000000"
            android:padding="10dp">
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="{BRAND_TEXT}"
                android:textColor="#FFFFFF"
                android:textSize="18sp"
                android:textStyle="bold"
                android:shadowColor="#000000"
                android:shadowDx="2"
                android:shadowDy="2"
                android:shadowRadius="4" />
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="{VERSION_TEXT}"
                android:textColor="#00E5A0"
                android:textSize="13sp"
                android:shadowColor="#000000"
                android:shadowDx="1"
                android:shadowDy="1"
                android:shadowRadius="2" />
        </LinearLayout>
    </FrameLayout>
"""

    root_tags = [
        "</FrameLayout>",
        "</RelativeLayout>",
        "</LinearLayout>",
        "</ConstraintLayout>",
        "</CoordinatorLayout>",
        "</androidx.constraintlayout.widget.ConstraintLayout>",
    ]

    injected = False
    for tag in root_tags:
        if tag in content:
            last_idx = content.rfind(tag)
            content = content[:last_idx] + jzs_overlay + "\n" + content[last_idx:]
            injected = True
            break

    if not injected:
        close_match = re.search(r'</\w+Layout>', content)
        if close_match:
            idx = close_match.start()
            content = content[:idx] + jzs_overlay + "\n" + content[idx:]
            injected = True

    if injected:
        with open(layout_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[JZS] Texte injecte dans: {layout_path}")
    else:
        print(f"[JZS] WARN: Impossible d'injecter dans {layout_path}")

    return injected


def patch_smali_add_overlay(decompiled_dir):
    """
    Injecte du code smali dans l'activite principale pour ajouter
    un overlay texte par-dessus la vue du jeu.
    """
    smali_dirs = glob.glob(os.path.join(decompiled_dir, "smali*"))

    main_activity = None
    for smali_dir in smali_dirs:
        for root, dirs, files in os.walk(smali_dir):
            for f in files:
                path = os.path.join(root, f)
                if "GameApp" in f or "MainActivity" in f or "GameActivity" in f:
                    main_activity = path
                    break
                if f.endswith(".smali"):
                    try:
                        with open(path, "r", encoding="utf-8") as fh:
                            head = fh.read(2000)
                        if "onCreate" in head and ("Activity" in head or "android/app" in head):
                            if main_activity is None:
                                main_activity = path
                    except Exception:
                        pass

    if not main_activity:
        print("[JZS] WARN: Activite principale non trouvee dans le smali")
        return False

    print(f"[JZS] Activite principale trouvee: {main_activity}")

    with open(main_activity, "r", encoding="utf-8") as f:
        smali = f.read()

    overlay_smali = """
    # --- JZS Brawl Overlay Injection ---
    # Adds "JZS Brawl V69.230 / Version testing" text on screen

    new-instance v0, Landroid/widget/TextView;
    invoke-direct {v0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    const-string v1, "JZS Brawl V69.230\\nVersion testing"
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    const/high16 v1, 0x41900000  # 18.0f text size
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    const v1, -0x1  # White color
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextColor(I)V
    # --- End JZS Injection ---
"""

    if "JZS Brawl" not in smali and "onCreate" in smali:
        on_create_idx = smali.find(".method", smali.find("onCreate"))
        if on_create_idx >= 0:
            end_method_idx = smali.find(".end method", on_create_idx)
            if end_method_idx >= 0:
                return_idx = smali.rfind("return", on_create_idx, end_method_idx)
                if return_idx >= 0:
                    smali = smali[:return_idx] + overlay_smali + "\n    " + smali[return_idx:]
                    with open(main_activity, "w", encoding="utf-8") as f:
                        f.write(smali)
                    print("[JZS] Code smali d'overlay injecte!")
                    return True

    print("[JZS] INFO: Injection smali ignoree (deja present ou structure non reconnue)")
    return False


def patch_strings_xml(decompiled_dir):
    """Ajoute les strings JZS dans les ressources."""
    values_dir = os.path.join(decompiled_dir, "res", "values")
    strings_path = os.path.join(values_dir, "strings.xml")

    jzs_strings = f"""    <string name="jzs_brand">{BRAND_TEXT}</string>
    <string name="jzs_version">{VERSION_TEXT}</string>
    <string name="jzs_full">{BRAND_TEXT} - {VERSION_TEXT}</string>"""

    if os.path.exists(strings_path):
        with open(strings_path, "r", encoding="utf-8") as f:
            content = f.read()

        if "jzs_brand" not in content:
            content = content.replace("</resources>", jzs_strings + "\n</resources>")
            with open(strings_path, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"[JZS] Strings ajoutees dans: {strings_path}")
    else:
        os.makedirs(values_dir, exist_ok=True)
        with open(strings_path, "w", encoding="utf-8") as f:
            f.write(f"""<?xml version="1.0" encoding="utf-8"?>
<resources>
{jzs_strings}
</resources>
""")
        print(f"[JZS] Fichier strings.xml cree: {strings_path}")


def patch_app_name(decompiled_dir):
    """Change le nom de l'application en JZS Brawl."""
    strings_path = os.path.join(decompiled_dir, "res", "values", "strings.xml")
    if os.path.exists(strings_path):
        with open(strings_path, "r", encoding="utf-8") as f:
            content = f.read()

        content = re.sub(
            r'<string name="app_name">[^<]*</string>',
            '<string name="app_name">JZS Brawl</string>',
            content
        )

        with open(strings_path, "w", encoding="utf-8") as f:
            f.write(content)
        print("[JZS] Nom de l'app change en 'JZS Brawl'")


def run_patches(decompiled_dir):
    """Execute toutes les modifications."""
    print(f"\n{'='*50}")
    print(f"  JZS Brawl - Patch du client v69")
    print(f"  Texte: {BRAND_TEXT}")
    print(f"  Version: {VERSION_TEXT}")
    print(f"{'='*50}\n")

    patch_strings_xml(decompiled_dir)
    patch_app_name(decompiled_dir)
    create_overlay_layout(decompiled_dir)

    main_layout = find_main_activity_layout(decompiled_dir)
    if main_layout:
        print(f"[JZS] Layout principal trouve: {main_layout}")
        inject_into_main_layout(main_layout)
    else:
        print("[JZS] Aucun layout XML trouve (le jeu utilise peut-etre un rendu custom)")

    patch_smali_add_overlay(decompiled_dir)

    print(f"\n[JZS] Patches appliques avec succes!")


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 patch_menu_text.py <chemin_decompile>")
        print("Exemple: python3 patch_menu_text.py ./brawlstars_decompiled/")
        sys.exit(1)

    run_patches(sys.argv[1])
