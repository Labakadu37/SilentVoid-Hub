"""Packages the official Brawl Stars artwork into app drawables.

Sources live in app/assets/ at full resolution; each is emitted at a size
suited to how it is used, trimmed of empty margins so it optically fills
the space the layout gives it.
"""
import os
import sys

from PIL import Image

# name -> (source file, target height in px at xxhdpi)
ASSETS = {
    "trophy": ("trophy.png", 108),
    "brawl": ("brawl.png", 132),
    "skull": ("skull.png", 108),
}


def trimmed(img):
    """Crops fully transparent margins so sizing is driven by real pixels."""
    box = img.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    return img.crop(box) if box else img


def main(src_dir, res_dir):
    out_dir = os.path.join(res_dir, "drawable-xxhdpi")
    os.makedirs(out_dir, exist_ok=True)

    for name, (filename, height) in ASSETS.items():
        img = trimmed(Image.open(os.path.join(src_dir, filename)).convert("RGBA"))
        width = max(1, round(img.width * height / img.height))
        out = img.resize((width, height), Image.LANCZOS)
        out.save(os.path.join(out_dir, name + ".png"), optimize=True)
        print(f"  {name + '.png':12s} {width}x{height}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
