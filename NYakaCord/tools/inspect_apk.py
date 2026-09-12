#!/usr/bin/env python3
"""Inspect an Android APK to determine which modding approach is viable.

Pure stdlib so it runs under Termux with only `pkg install python`.

Usage: python3 inspect_apk.py <path-to.apk>
"""

import sys
import zipfile
import struct
from collections import Counter

# Hermes bytecode files start with this 8-byte magic (little-endian 0x1F1903C103BC1FC6).
HERMES_MAGIC = bytes([0xC6, 0x1F, 0xBC, 0x03, 0xC1, 0x03, 0x19, 0x1F])

RN_BUNDLE_PATHS = (
    "assets/index.android.bundle",
    "assets/index.bundle",
    "assets/main.jsbundle",
)

# Native libraries that reveal the app's runtime architecture.
TELLTALE_LIBS = {
    "libhermes.so": "Hermes JS engine (React Native)",
    "libhermes-executor-release.so": "Hermes executor (React Native)",
    "libjsc.so": "JavaScriptCore engine (React Native, pre-Hermes)",
    "libreactnativejni.so": "React Native JNI bridge",
    "libreactnative.so": "React Native core",
    "libfbjni.so": "Facebook JNI (React Native dependency)",
    "libflipper.so": "Flipper debug tooling",
}


def human(n):
    for unit in ("B", "KB", "MB", "GB"):
        if abs(n) < 1024:
            return f"{n:.0f}{unit}" if unit == "B" else f"{n:.1f}{unit}"
        n /= 1024
    return f"{n:.1f}TB"


RES_STRING_POOL = 0x0001
RES_XML_START_ELEMENT = 0x0102
TYPE_STRING = 0x03


def _varlen(data, p, utf8):
    """Decode an AXML string length, which is 1-2 units with a high-bit flag."""
    if utf8:
        n = data[p]
        if n & 0x80:
            return ((n & 0x7F) << 8) | data[p + 1], p + 2
        return n, p + 1
    n = struct.unpack_from("<H", data, p)[0]
    if n & 0x8000:
        n2 = struct.unpack_from("<H", data, p + 2)[0]
        return ((n & 0x7FFF) << 16) | n2, p + 4
    return n, p + 2


def _string_pool(data, off):
    """Parse a RES_STRING_POOL chunk at `off`, returning a list of strings."""
    _t, _hdr, _size, count, _styles, flags, strings_start, _ss = struct.unpack_from(
        "<HHIIIIII", data, off
    )
    utf8 = bool(flags & (1 << 8))
    offsets_at = off + 28
    base = off + strings_start
    out = []
    for i in range(count):
        rel = struct.unpack_from("<I", data, offsets_at + i * 4)[0]
        p = base + rel
        if p >= len(data):
            out.append("")
            continue
        if utf8:
            _chars, p = _varlen(data, p, True)  # char count, then byte count
            nbytes, p = _varlen(data, p, True)
            out.append(data[p: p + nbytes].decode("utf-8", "replace"))
        else:
            nchars, p = _varlen(data, p, False)
            out.append(data[p: p + nchars * 2].decode("utf-16-le", "replace"))
    return out


def manifest_facts(data):
    """Extract package and versionName from a binary AndroidManifest.xml.

    Walks the AXML chunk tree to read the <manifest> element's attributes.
    Returns {} on malformed input: a failed parse must not abort inspection.
    """
    try:
        if len(data) < 8 or struct.unpack_from("<H", data, 0)[0] != 0x0003:
            return {}
        pool = None
        off = 8
        while off + 8 <= len(data):
            ctype, _hdr, csize = struct.unpack_from("<HHI", data, off)
            if csize <= 0:
                break
            if ctype == RES_STRING_POOL and pool is None:
                pool = _string_pool(data, off)
            elif ctype == RES_XML_START_ELEMENT and pool is not None:
                # lineNumber(4) comment(4) ns(4) name(4) attrStart(2) attrSize(2) attrCount(2)
                name_idx, attr_start, _attr_size, attr_count = struct.unpack_from(
                    "<IHHH", data, off + 20
                )
                if name_idx < len(pool) and pool[name_idx] == "manifest":
                    facts = {}
                    # attr_start is relative to the attrExt struct, which follows
                    # the 8-byte chunk header and 8-byte node header.
                    ap = off + 16 + attr_start
                    for _ in range(attr_count):
                        (_ns, a_name, a_raw, _size, _res0,
                         a_type, a_data) = struct.unpack_from("<IIIHBBI", data, ap)
                        ap += 20
                        key = pool[a_name] if a_name < len(pool) else ""
                        if key not in ("package", "versionName", "versionCode"):
                            continue
                        if a_type == TYPE_STRING:
                            idx = a_raw if a_raw != 0xFFFFFFFF else a_data
                            facts[key] = pool[idx] if idx < len(pool) else ""
                        else:
                            facts[key] = str(a_data)
                    return facts
            off += csize
        return {}
    except Exception:
        return {}


def inspect(path):
    try:
        zf = zipfile.ZipFile(path)
    except (zipfile.BadZipFile, FileNotFoundError, OSError) as e:
        print(f"ERROR: cannot open {path!r}: {e}")
        return 1

    names = zf.namelist()
    print(f"APK       : {path}")
    print(f"Entries   : {len(names)}")

    # --- identity -------------------------------------------------------
    if "AndroidManifest.xml" in names:
        facts = manifest_facts(zf.read("AndroidManifest.xml"))
        print(f"Package   : {facts.get('package', '<unreadable>')}")
        print(f"Version   : {facts.get('versionName', '<unreadable>')} "
              f"(code {facts.get('versionCode', '?')})")
    else:
        print("Package   : no AndroidManifest.xml (not an APK?)")

    # --- dex ------------------------------------------------------------
    dex = [n for n in names if n.endswith(".dex")]
    dex_bytes = sum(zf.getinfo(n).file_size for n in dex)
    print(f"Dex files : {len(dex)} ({human(dex_bytes)} uncompressed)")

    # --- react native bundle -------------------------------------------
    print("\n--- JS bundle ---")
    bundle = next((p for p in RN_BUNDLE_PATHS if p in names), None)
    if not bundle:
        cands = [n for n in names if n.endswith((".bundle", ".jsbundle", ".hbc"))]
        if cands:
            bundle = cands[0]
            print(f"note      : non-standard bundle path")

    bundle_kind = None
    if bundle:
        info = zf.getinfo(bundle)
        head = zf.open(bundle).read(64)
        if head.startswith(HERMES_MAGIC):
            bundle_kind = "hermes"
            ver = struct.unpack_from("<I", head, 8)[0] if len(head) >= 12 else "?"
            print(f"found     : {bundle} ({human(info.file_size)})")
            print(f"format    : Hermes BYTECODE (bytecode version {ver})")
        else:
            bundle_kind = "js"
            printable = sum(1 for b in head if 9 <= b <= 126)
            print(f"found     : {bundle} ({human(info.file_size)})")
            print(f"format    : plain JS text ({printable}/{len(head)} printable bytes)")
            print(f"preview   : {head[:48]!r}")
    else:
        print("found     : none")

    # --- native libs ----------------------------------------------------
    print("\n--- Native libraries ---")
    abis = Counter()
    seen = {}
    for n in names:
        if n.startswith("lib/") and n.endswith(".so"):
            parts = n.split("/")
            if len(parts) >= 3:
                abis[parts[1]] += 1
                base = parts[-1]
                if base in TELLTALE_LIBS:
                    seen[base] = TELLTALE_LIBS[base]
    if abis:
        print("ABIs      : " + ", ".join(f"{a} ({c} libs)" for a, c in sorted(abis.items())))
    else:
        print("ABIs      : none (split APK? libs in a separate config APK)")
    if seen:
        for lib, desc in sorted(seen.items()):
            print(f"  + {lib:<34} {desc}")
    else:
        print("  (no React Native / Hermes / JSC libraries found)")

    # --- verdict --------------------------------------------------------
    print("\n=== VERDICT ===")
    has_rn = bool(seen) or bundle_kind is not None
    if bundle_kind == "js":
        print("React Native with a PLAIN JS bundle.")
        print("Viable: prepend a loader to the bundle, rezip, resign.")
        print("This is the Bunny/Vendetta approach and by far the simplest.")
    elif bundle_kind == "hermes":
        print("React Native with a HERMES BYTECODE bundle.")
        print("NOT viable: you cannot prepend JS text to bytecode.")
        print("Options: ship a replacement non-Hermes bundle, or hook")
        print("libhermes.so natively. Both are substantially harder.")
    elif has_rn:
        print("React Native libraries present but no bundle in this APK.")
        print("Likely a split APK -- the bundle may live in a config/feature")
        print("split. Inspect the other APKs in the split set.")
    else:
        print("No React Native detected: this looks like a native")
        print("Java/Kotlin app. Modding requires smali patching of")
        print("obfuscated dex (the Aliucord approach). This is heavy")
        print("reverse-engineering work and breaks on every app update.")

    if not abis and len(dex) == 0:
        print("\nWARNING: no dex and no libs -- this is probably a base APK")
        print("from a split set, not a full standalone APK.")

    zf.close()
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__.strip())
        sys.exit(2)
    sys.exit(inspect(sys.argv[1]))
