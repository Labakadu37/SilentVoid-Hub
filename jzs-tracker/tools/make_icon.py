import math, struct, zlib, sys

SIZE = 192
BG = (11, 15, 20)
ACCENT = (0, 229, 160)


def rounded_rect(x, y, w, h, r, px, py):
    if px < x or py < y or px >= x + w or py >= y + h:
        return False
    cx = min(max(px, x + r), x + w - r)
    cy = min(max(py, y + r), y + h - r)
    return (px - cx) ** 2 + (py - cy) ** 2 <= r * r


STEM_L, STEM_R = 110, 138
HOOK_CX, HOOK_CY = 96, 116
HOOK_IN, HOOK_OUT = 14, 42


def in_j(px, py):
    """Stem plus the bottom hook of a capital J.

    The hook is the lower half of an annulus whose thickness equals the stem
    width, centred so its rightmost span lines up with the stem exactly.
    """
    if STEM_L <= px <= STEM_R and 34 <= py <= HOOK_CY:
        return True
    dx, dy = px - HOOK_CX, py - HOOK_CY
    return dy >= 0 and HOOK_IN <= math.hypot(dx, dy) <= HOOK_OUT


rows = []
for y in range(SIZE):
    row = bytearray([0])
    for x in range(SIZE):
        if in_j(x, y):
            row += bytes(ACCENT)
        elif rounded_rect(16, 16, SIZE - 32, SIZE - 32, 42, x, y):
            row += bytes(BG)
        else:
            row += bytes(BG)
    rows.append(bytes(row))

raw = b"".join(rows)


def chunk(tag, data):
    return (struct.pack(">I", len(data)) + tag + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))


png = (b"\x89PNG\r\n\x1a\n"
       + chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0))
       + chunk(b"IDAT", zlib.compress(raw, 9))
       + chunk(b"IEND", b""))

with open(sys.argv[1], "wb") as f:
    f.write(png)
print("wrote", sys.argv[1], len(png), "bytes")
