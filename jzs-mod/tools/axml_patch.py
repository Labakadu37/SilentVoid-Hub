#!/usr/bin/env python3
"""
Remplace une chaîne dans le pool d'un AndroidManifest.xml binaire (AXML).

Pourquoi pas apktool : apktool régénère resources.arsc, et sur un APK de jeu
fortement personnalisé ça casse des références de ressources. Ici on ne touche
qu'au pool de chaînes du manifeste ; tout le reste de l'APK est laissé
strictement intact.

Les noeuds XML référencent les chaînes par INDEX, donc tant qu'on garde le même
index et le même nombre de chaînes, rien d'autre ne bouge : il suffit de
recalculer les offsets et les tailles de chunk.

Usage:
    axml_patch.py <in.xml> <out.xml> <ancienne> <nouvelle> [<ancienne> <nouvelle> ...]
"""
import struct
import sys

RES_STRING_POOL_TYPE = 0x0001
UTF8_FLAG = 1 << 8


def _decode_len_utf16(data, off):
    n = struct.unpack_from('<H', data, off)[0]
    off += 2
    if n & 0x8000:
        low = struct.unpack_from('<H', data, off)[0]
        off += 2
        n = ((n & 0x7FFF) << 16) | low
    return n, off


def _decode_len_utf8(data, off):
    n = data[off]
    off += 1
    if n & 0x80:
        n = ((n & 0x7F) << 8) | data[off]
        off += 1
    return n, off


def _encode_len_utf16(n):
    if n > 0x7FFF:
        return struct.pack('<HH', (n >> 16) | 0x8000, n & 0xFFFF)
    return struct.pack('<H', n)


def _encode_len_utf8(n):
    if n > 0x7F:
        return bytes([(n >> 8) | 0x80, n & 0xFF])
    return bytes([n])


def read_strings(data, pool_off):
    (_type, header_size, chunk_size, string_count, style_count,
     flags, strings_start, styles_start) = struct.unpack_from('<HHIIIIII', data, pool_off)

    utf8 = bool(flags & UTF8_FLAG)
    offsets = struct.unpack_from('<%dI' % string_count, data, pool_off + header_size)
    base = pool_off + strings_start

    strings = []
    for off in offsets:
        p = base + off
        if utf8:
            _u16len, p = _decode_len_utf8(data, p)
            blen, p = _decode_len_utf8(data, p)
            strings.append(data[p:p + blen].decode('utf-8', 'replace'))
        else:
            n, p = _decode_len_utf16(data, p)
            strings.append(data[p:p + n * 2].decode('utf-16-le', 'replace'))

    return strings, utf8, style_count, chunk_size, header_size, styles_start


def build_pool(strings, utf8, style_count, header_size, old_style_bytes):
    blobs = []
    offsets = []
    cursor = 0
    for s in strings:
        if utf8:
            raw = s.encode('utf-8')
            blob = _encode_len_utf8(len(s)) + _encode_len_utf8(len(raw)) + raw + b'\x00'
        else:
            raw = s.encode('utf-16-le')
            blob = _encode_len_utf16(len(s)) + raw + b'\x00\x00'
        offsets.append(cursor)
        blobs.append(blob)
        cursor += len(blob)

    string_data = b''.join(blobs)
    pad = (-len(string_data)) % 4
    string_data += b'\x00' * pad

    offset_table = struct.pack('<%dI' % len(offsets), *offsets)
    style_table = b''  # style_count is asserted to be 0 by the caller

    strings_start = header_size + len(offset_table) + len(style_table)
    styles_start = 0 if style_count == 0 else strings_start + len(string_data)
    chunk_size = strings_start + len(string_data) + len(old_style_bytes)

    header = struct.pack(
        '<HHIIIIII',
        RES_STRING_POOL_TYPE, header_size, chunk_size,
        len(strings), style_count,
        UTF8_FLAG if utf8 else 0,
        strings_start, styles_start,
    )
    return header + offset_table + style_table + string_data + old_style_bytes


def patch(data, old, new):
    magic, file_size = struct.unpack_from('<II', data, 0)
    if magic != 0x00080003:
        raise ValueError('pas un AXML (magic 0x%08x)' % magic)

    pool_off = 8
    ptype = struct.unpack_from('<H', data, pool_off)[0]
    if ptype != RES_STRING_POOL_TYPE:
        raise ValueError('chunk 0x%04x au lieu du pool de chaînes' % ptype)

    strings, utf8, style_count, chunk_size, header_size, styles_start = \
        read_strings(data, pool_off)

    if style_count != 0:
        raise ValueError('styles présents (%d) : non géré' % style_count)

    if old not in strings:
        raise ValueError('chaîne introuvable : %r' % old)
    idx = strings.index(old)
    strings[idx] = new

    new_pool = build_pool(strings, utf8, style_count, header_size, b'')
    rest = data[pool_off + chunk_size:]
    out = bytearray(data[:pool_off] + new_pool + rest)
    struct.pack_into('<I', out, 4, len(out))

    return bytes(out), idx


def main():
    if len(sys.argv) < 5 or len(sys.argv) % 2 != 1:
        print(__doc__)
        return 1

    src, dst = sys.argv[1:3]
    pairs = list(zip(sys.argv[3::2], sys.argv[4::2]))

    data = open(src, 'rb').read()
    original_size = len(data)
    for old, new in pairs:
        data, idx = patch(data, old, new)
        print('index %d : %r -> %r' % (idx, old, new))

    open(dst, 'wb').write(data)
    print('taille %d -> %d octets' % (original_size, len(data)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
