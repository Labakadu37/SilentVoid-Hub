"""Generates the BrawlBee launcher icons from the source logo.

Emits one square PNG per mipmap density plus a small drawable for the
in-app header. The logo already sits on black, matching the app ground.
"""
import os
import sys

from PIL import Image

DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}
BLACK = (0, 0, 0, 255)


def square(img):
    """Pads to a square so no density crops the wings."""
    if img.width == img.height:
        return img
    side = max(img.width, img.height)
    canvas = Image.new("RGBA", (side, side), BLACK)
    canvas.paste(img, ((side - img.width) // 2, (side - img.height) // 2), img)
    return canvas


def main(source, res_dir):
    img = square(Image.open(source).convert("RGBA"))

    for name, size in DENSITIES.items():
        out_dir = os.path.join(res_dir, "mipmap-" + name)
        os.makedirs(out_dir, exist_ok=True)
        path = os.path.join(out_dir, "ic_launcher.png")
        img.resize((size, size), Image.LANCZOS).save(path, optimize=True)
        print(f"  mipmap-{name:8s} {size}x{size}")

    header_dir = os.path.join(res_dir, "drawable-xxhdpi")
    os.makedirs(header_dir, exist_ok=True)
    header = os.path.join(header_dir, "logo.png")
    img.resize((96, 96), Image.LANCZOS).save(header, optimize=True)
    print("  drawable logo  96x96")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
