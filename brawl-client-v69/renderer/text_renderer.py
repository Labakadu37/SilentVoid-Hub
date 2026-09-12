"""
TextRenderer - Moteur de rendu de texte pour le client SilentVoid.
Gère les polices, tailles, couleurs et positionnement.
"""


class TextElement:
    def __init__(self, text, x=0, y=0, size=16, color="#FFFFFF", font="default"):
        self.text = text
        self.x = x
        self.y = y
        self.size = size
        self.color = color
        self.font = font
        self.visible = True

    def to_dict(self):
        return {
            "text": self.text,
            "x": self.x,
            "y": self.y,
            "size": self.size,
            "color": self.color,
            "font": self.font,
            "visible": self.visible,
        }


class TextRenderer:
    FONTS = {
        "default": "Lilita One",
        "mono": "monospace",
        "brawl": "Supercell-Magic",
    }

    def __init__(self):
        self.elements = []

    def create_text(self, text, x=0, y=0, size=16, color="#FFFFFF", font="default"):
        element = TextElement(text, x, y, size, color, font)
        self.elements.append(element)
        return element

    def remove_text(self, element):
        if element in self.elements:
            self.elements.remove(element)

    def clear(self):
        self.elements.clear()

    def get_visible_elements(self):
        return [e.to_dict() for e in self.elements if e.visible]
