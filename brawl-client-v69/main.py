#!/usr/bin/env python3
"""
SilentVoid Client v69 - Point d'entrée
Brawl Stars Custom Client Framework - Indépendant de BSD Brawl
"""

from core.client import SilentVoidClient


def main():
    print()
    print("  ╔═══════════════════════════════════════════════════╗")
    print("  ║         SilentVoid Client v69                    ║")
    print("  ║         Brawl Stars Custom Framework             ║")
    print("  ║         100% Indépendant - Pas de BSD Brawl      ║")
    print("  ╚═══════════════════════════════════════════════════╝")
    print()

    client = SilentVoidClient(width=1280, height=720)
    client.start()

    print()
    print(f"  Rendu HTML sauvegardé: {client.screen.output_path}")
    print()


if __name__ == "__main__":
    main()
