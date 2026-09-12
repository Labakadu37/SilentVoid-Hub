"""
Overlay - Couche d'interface superposée au rendu du jeu.
Gère l'affichage des éléments UI (texte, panneaux, infos).
"""


class Overlay:
    def __init__(self, screen, text_renderer):
        self.screen = screen
        self.text_renderer = text_renderer
        self.elements = []
        self.visible = True

    def add_text(self, text, x=0, y=0, size=16, color="#FFFFFF"):
        element = self.text_renderer.create_text(text, x, y, size, color)
        self.elements.append(element.to_dict())
        return element

    def clear(self):
        self.elements.clear()
        self.text_renderer.clear()

    def toggle(self):
        self.visible = not self.visible
