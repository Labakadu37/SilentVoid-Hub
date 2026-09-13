"""Draws the in-app icons that are not available from a CDN.

Bundling them keeps chrome elements instant and working offline, unlike
the brawler and map art which is fetched and cached at runtime.
"""
import os
import sys

from PIL import Image, ImageDraw

GOLD = (255, 198, 26, 255)
GOLD_DARK = (214, 158, 0, 255)
S = 192  # supersample factor base; drawn large then downscaled for smoothing


def trophy(size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    u = size / 100.0

    def box(x0, y0, x1, y1):
        return [x0 * u, y0 * u, x1 * u, y1 * u]

    handle_w = int(7 * u)
    # Handles first, so the bowl paints over where they meet it.
    d.arc(box(12, 20, 44, 58), start=90, end=270, fill=GOLD_DARK, width=handle_w)
    d.arc(box(56, 20, 88, 58), start=270, end=90, fill=GOLD_DARK, width=handle_w)

    # Bowl: straight sides down to a rounded base.
    d.rectangle(box(28, 16, 72, 46), fill=GOLD)
    d.pieslice(box(28, 22, 72, 68), start=0, end=180, fill=GOLD)

    # Stem and foot.
    d.rectangle(box(45, 64, 55, 78), fill=GOLD_DARK)
    d.rectangle(box(34, 78, 66, 87), fill=GOLD)
    d.rounded_rectangle(box(30, 84, 70, 92), radius=3 * u, fill=GOLD_DARK)
    return img


def main(res_dir):
    out_dir = os.path.join(res_dir, "drawable-xxhdpi")
    os.makedirs(out_dir, exist_ok=True)

    big = trophy(S * 4)
    path = os.path.join(out_dir, "trophy.png")
    big.resize((S // 2, S // 2), Image.LANCZOS).save(path, optimize=True)
    print("  trophy.png", S // 2, "px")


if __name__ == "__main__":
    main(sys.argv[1])
