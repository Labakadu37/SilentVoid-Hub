"""
SilentVoid Client v69 - Brawl Stars Custom Client Framework
Framework indépendant pour le modding client-side de Brawl Stars.
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from renderer.screen import Screen
from renderer.text_renderer import TextRenderer
from ui.overlay import Overlay


class SilentVoidClient:
    VERSION = "69.0.0"
    NAME = "SilentVoid"

    def __init__(self, width=1280, height=720):
        self.width = width
        self.height = height
        self.running = False
        self.screen = Screen(width, height, f"{self.NAME} Client v{self.VERSION}")
        self.text_renderer = TextRenderer()
        self.overlay = Overlay(self.screen, self.text_renderer)

    def start(self):
        self.running = True
        print(f"[{self.NAME}] Client v{self.VERSION} démarré")
        print(f"[{self.NAME}] Résolution: {self.width}x{self.height}")
        print(f"[{self.NAME}] Framework indépendant - Aucune dépendance BSD Brawl")

        self.overlay.add_text("SilentVoid Client v69", x=20, y=20, size=32, color="#FFFFFF")
        self.overlay.add_text("Framework indépendant", x=20, y=60, size=18, color="#00FF88")
        self.overlay.add_text("Brawl Stars Client Mod", x=20, y=85, size=18, color="#FFD700")
        self.overlay.add_text("Statut: Connecté", x=20, y=120, size=16, color="#00CCFF")

        self.screen.render(self.overlay)
        print(f"[{self.NAME}] Texte affiché avec succès!")

    def stop(self):
        self.running = False
        self.screen.close()
        print(f"[{self.NAME}] Client arrêté")


def main():
    client = SilentVoidClient()
    client.start()
    return client


if __name__ == "__main__":
    main()
