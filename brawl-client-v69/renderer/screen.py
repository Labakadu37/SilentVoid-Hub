"""
Screen - Gestion de l'écran de rendu.
Génère un rendu HTML/canvas pour la visualisation, ou un rendu terminal en fallback.
"""

import os


class Screen:
    def __init__(self, width, height, title):
        self.width = width
        self.height = height
        self.title = title
        self.output_path = None

    def render(self, overlay):
        html = self._build_html(overlay)

        output_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "output")
        os.makedirs(output_dir, exist_ok=True)
        self.output_path = os.path.join(output_dir, "client_screen.html")

        with open(self.output_path, "w", encoding="utf-8") as f:
            f.write(html)

        self._render_terminal(overlay)

    def _build_html(self, overlay):
        text_elements = ""
        for item in overlay.elements:
            text_elements += f"""
            <div style="
                position: absolute;
                left: {item['x']}px;
                top: {item['y']}px;
                font-size: {item['size']}px;
                color: {item['color']};
                font-family: 'Supercell-Magic', 'Lilita One', 'Impact', sans-serif;
                font-weight: bold;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.8), 0 0 10px rgba(0,0,0,0.5);
                letter-spacing: 1px;
            ">{item['text']}</div>"""

        return f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{self.title}</title>
    <link href="https://fonts.googleapis.com/css2?family=Lilita+One&display=swap" rel="stylesheet">
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            background: #0a0a0a;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            font-family: sans-serif;
        }}
        .screen {{
            width: {self.width}px;
            height: {self.height}px;
            background: linear-gradient(135deg, #1a0a2e 0%, #0d1b2a 30%, #1b2838 60%, #0a192f 100%);
            position: relative;
            overflow: hidden;
            border: 2px solid #333;
            border-radius: 8px;
            box-shadow: 0 0 30px rgba(0, 255, 136, 0.1), inset 0 0 60px rgba(0, 0, 0, 0.5);
        }}
        .screen::before {{
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background:
                radial-gradient(circle at 20% 80%, rgba(0, 255, 136, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(255, 215, 0, 0.05) 0%, transparent 50%);
            pointer-events: none;
        }}
        .grid {{
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px);
            background-size: 40px 40px;
            pointer-events: none;
        }}
        .watermark {{
            position: absolute;
            bottom: 10px;
            right: 15px;
            color: rgba(255, 255, 255, 0.15);
            font-size: 11px;
            font-family: monospace;
        }}
        .status-bar {{
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 30px;
            background: rgba(0, 0, 0, 0.6);
            border-top: 1px solid rgba(0, 255, 136, 0.2);
            display: flex;
            align-items: center;
            padding: 0 15px;
            font-family: monospace;
            font-size: 11px;
            color: rgba(0, 255, 136, 0.6);
            gap: 20px;
        }}
        .dot {{
            width: 6px; height: 6px;
            background: #00ff88;
            border-radius: 50%;
            box-shadow: 0 0 6px #00ff88;
        }}
    </style>
</head>
<body>
    <div class="screen">
        <div class="grid"></div>
        {text_elements}
        <div class="status-bar">
            <div class="dot"></div>
            <span>SilentVoid Framework v69.0.0</span>
            <span>|</span>
            <span>Brawl Stars Client</span>
            <span>|</span>
            <span>{self.width}x{self.height}</span>
            <span>|</span>
            <span>Framework indépendant</span>
        </div>
        <div class="watermark">SilentVoid-Hub</div>
    </div>
</body>
</html>"""

    def _render_terminal(self, overlay):
        w = 70
        print()
        print("┌" + "─" * w + "┐")
        print("│" + f" {self.title}".ljust(w) + "│")
        print("├" + "─" * w + "┤")

        for item in overlay.elements:
            line = f" {item['text']}"
            print("│" + line.ljust(w) + "│")

        remaining = 8 - len(overlay.elements)
        for _ in range(max(0, remaining)):
            print("│" + " " * w + "│")

        print("├" + "─" * w + "┤")
        print("│" + " ● SilentVoid Framework v69 | Brawl Stars | Indépendant".ljust(w) + "│")
        print("└" + "─" * w + "┘")
        print()

    def close(self):
        print(f"[Screen] Fermé ({self.width}x{self.height})")
