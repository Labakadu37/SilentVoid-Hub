#!/usr/bin/env python3
"""
axml_remove_split.py — retire les attributs de split du AndroidManifest binaire
Neutralise `requiredSplitTypes` et `splitTypes` pour qu'un APK mergé (universel)
s'installe sur Android 12+ sans réclamer les split APKs.

Usage: python3 axml_remove_split.py <AndroidManifest.xml> <sortie.xml>
"""
import sys, struct

def read_string_pool(data, off):
    """Retourne (liste_strings, taille_chunk). off pointe le début du chunk string pool."""
    chunk_type, header_size, chunk_size = struct.unpack_from("<HHI", data, off)
    string_count, style_count, flags, strings_start, styles_start = \
        struct.unpack_from("<IIIII", data, off + 8)
    is_utf8 = (flags & 0x100) != 0
    offsets = [struct.unpack_from("<I", data, off + 28 + i*4)[0] for i in range(string_count)]
    strings = []
    base = off + strings_start
    for o in offsets:
        p = base + o
        if is_utf8:
            # len16 (chars), len8 (bytes)
            n = data[p]; q = p + 1
            if n & 0x80: n = ((n & 0x7f) << 8) | data[q]; q += 1
            b = data[q]; r = q + 1
            if b & 0x80: b = ((b & 0x7f) << 8) | data[r]; r += 1
            strings.append(data[r:r+b].decode("utf-8", "replace"))
        else:
            n = struct.unpack_from("<H", data, p)[0]; q = p + 2
            if n & 0x8000: n = ((n & 0x7fff) << 16) | struct.unpack_from("<H", data, q)[0]; q += 2
            strings.append(data[q:q+n*2].decode("utf-16-le", "replace"))
    return strings, chunk_size

def main():
    src, dst = sys.argv[1], sys.argv[2]
    data = bytearray(open(src, "rb").read())

    # En-tête AXML : magic (0x00080003), taille fichier
    magic, file_size = struct.unpack_from("<II", data, 0)
    assert magic == 0x00080003, f"Pas un AXML valide: {magic:#x}"

    # String pool commence à l'offset 8
    strings, sp_size = read_string_pool(data, 8)

    # Trouve les index des strings cibles
    targets = {}
    for i, s in enumerate(strings):
        if s in ("requiredSplitTypes", "splitTypes"):
            targets[i] = s
    if not targets:
        print("Aucun attribut de split trouvé (déjà propre ?)")
        open(dst, "wb").write(data)
        return
    print("Strings cibles:", targets)

    # Parcourt les chunks XML pour trouver START_ELEMENT contenant ces attributs
    pos = 8 + sp_size
    removed = 0
    while pos < len(data):
        if pos + 8 > len(data): break
        ctype, hsize, csize = struct.unpack_from("<HHI", data, pos)
        if ctype == 0x0102:  # START_ELEMENT
            attr_count = struct.unpack_from("<H", data, pos + 0x1C)[0]
            attr_base = pos + 0x24
            # Parcourt les attributs à l'envers pour supprimer proprement
            a = attr_count - 1
            while a >= 0:
                ap = attr_base + a * 20
                name_idx = struct.unpack_from("<I", data, ap + 4)[0]
                if name_idx in targets:
                    # Supprime ce bloc de 20 octets
                    del data[ap:ap+20]
                    attr_count -= 1
                    csize -= 20
                    file_size -= 20
                    removed += 1
                    # Réécrit attributeCount et chunkSize de CE chunk
                    struct.pack_into("<H", data, pos + 0x1C, attr_count)
                    struct.pack_into("<I", data, pos + 4, csize)
                a -= 1
        pos += csize if csize > 0 else 8
        if csize == 0: break

    # Réécrit la taille totale du fichier dans l'en-tête
    struct.pack_into("<I", data, 4, file_size)
    open(dst, "wb").write(data)
    print(f"Terminé — {removed} attribut(s) de split retiré(s). Nouvelle taille: {file_size}")

if __name__ == "__main__":
    main()
