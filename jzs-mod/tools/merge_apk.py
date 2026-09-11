#!/usr/bin/env python3
"""
Fusionne un XAPK (App Bundle découpé) en un APK unique installable, en y
injectant notre mod.

Un XAPK contient un APK de base plus des splits : les assets, les bibliothèques
natives par ABI, les ressources par densité et par langue. Android refuse
d'installer la base seule parce que le manifeste déclare requiredSplitTypes ;
on neutralise donc cette exigence et on recopie le contenu des splits.

Les assets et les lib/ se recopient tels quels : ils ne passent pas par
resources.arsc. Les res/ des splits de densité sont recopiés aussi, mais leurs
entrées arsc restent dans le split : les ressources concernées retombent sur
celles de la base.

Usage:
    merge_apk.py <in.xapk> <out.apk> --abi armeabi-v7a --dex our.dex --assets dir
"""
import argparse
import io
import os
import zipfile

import axml_patch

# Python passe en Zip64 dès 2 Go ; les outils Android ne le lisent pas.
zipfile.ZIP64_LIMIT = 0xFFFFFFFF - 1

GAME_APPLICATION = 'com.supercell.titan.TitanApplication'
MOD_APPLICATION = 'org.jzs.brawl.JzsApplication'
SPLIT_TYPES = 'base__abi,base__density'
SPLITS_REQUIRED = 'com.android.vending.splits.required'
SPLITS_NEUTRALISED = 'com.android.vending.splits.ignored'

SIGNATURE_SUFFIXES = ('.SF', '.RSA', '.DSA', '.EC')


def is_signature(name):
    up = name.upper()
    return up.startswith('META-INF/') and (
        up.endswith(SIGNATURE_SUFFIXES) or up == 'META-INF/MANIFEST.MF')


def parts_of(xapk):
    """Classe les membres du XAPK : base, asset pack, splits de config."""
    base = None
    assets = None
    configs = {}
    for name in xapk.namelist():
        if not name.endswith('.apk'):
            continue
        if 'asset_pack' in name:
            assets = name
        elif name.startswith('config.') or '.config.' in name:
            configs[name] = name
        elif base is None:
            base = name
    return base, assets, configs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('xapk')
    ap.add_argument('out')
    ap.add_argument('--abi', default='armeabi-v7a')
    ap.add_argument('--dex', required=True, help='notre classes.dex')
    ap.add_argument('--assets', required=True, help='dossier assets a injecter')
    args = ap.parse_args()

    xapk = zipfile.ZipFile(args.xapk)
    base_name, assets_name, configs = parts_of(xapk)
    print('base       : %s' % base_name)
    print('asset pack : %s' % assets_name)
    print('configs    : %s' % ', '.join(sorted(configs)))

    base = zipfile.ZipFile(io.BytesIO(xapk.read(base_name)))

    manifest = axml_patch.patch(base.read('AndroidManifest.xml'), GAME_APPLICATION, MOD_APPLICATION)[0]
    manifest = axml_patch.patch(manifest, SPLIT_TYPES, '')[0]
    manifest = axml_patch.patch(manifest, SPLITS_REQUIRED, SPLITS_NEUTRALISED)[0]
    print('manifeste  : application hookee, exigence de splits neutralisee')

    seen = set()
    out = zipfile.ZipFile(args.out, 'w', allowZip64=True)

    def copy(src, name, data=None):
        if name in seen or is_signature(name):
            return False
        info = src.getinfo(name)
        ni = zipfile.ZipInfo(name, info.date_time)
        ni.compress_type = info.compress_type
        ni.external_attr = info.external_attr
        out.writestr(ni, src.read(name) if data is None else data)
        seen.add(name)
        return True

    n = 0
    for name in base.namelist():
        if name == 'AndroidManifest.xml':
            copy(base, name, manifest)
        elif copy(base, name):
            n += 1
    print('base       : %d fichiers' % n)

    if assets_name:
        pack = zipfile.ZipFile(io.BytesIO(xapk.read(assets_name)))
        n = sum(1 for x in pack.namelist() if x.startswith('assets/') and copy(pack, x))
        print('assets     : %d fichiers' % n)

    for cfg_name in sorted(configs):
        cfg = zipfile.ZipFile(io.BytesIO(xapk.read(cfg_name)))
        keep = [x for x in cfg.namelist()
                if x.startswith('lib/%s/' % args.abi) or x.startswith('res/')]
        n = sum(1 for x in keep if copy(cfg, x))
        if n:
            print('%-26s : %d fichiers' % (cfg_name, n))

    with open(args.dex, 'rb') as f:
        dex = f.read()
    slot = next('classes%d.dex' % i for i in range(2, 100)
                if ('classes%d.dex' % i) not in seen)
    out.writestr(slot, dex)
    print('mod        : %s (%d octets)' % (slot, len(dex)))

    for root, _dirs, files in os.walk(args.assets):
        for fn in files:
            path = os.path.join(root, fn)
            arc = 'assets/' + os.path.relpath(path, args.assets).replace(os.sep, '/')
            if arc not in seen:
                out.writestr(arc, open(path, 'rb').read())
                seen.add(arc)
                print('mod        : %s' % arc)

    out.close()
    print('\n%s : %.0f Mo' % (args.out, os.path.getsize(args.out) / 1024 / 1024))


if __name__ == '__main__':
    main()
