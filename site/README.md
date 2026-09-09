# Site vitrine — Claude

Site vitrine statique, écrit à la main : **HTML + CSS + JavaScript**, aucune
dépendance, aucune étape de build. Thème sombre, dégradés orange sur fond noir.

## Lancer

Ouvrir `index.html` dans un navigateur, ou servir le dossier :

```bash
cd site
python3 -m http.server 8000
# puis http://localhost:8000
```

## Structure

```
site/
├── index.html              page unique, sections ancrées
├── README.md
└── assets/
    ├── favicon.svg
    ├── css/main.css        tokens, composants, responsive, print
    └── js/main.js          interactions (aucune librairie)
```

## Sections

Hero · bandeau défilant · chiffres · expertise · stack · méthode ·
travaux · manifeste · FAQ · contact · pied de page.

## Ce que fait le JavaScript

| Module | Rôle |
| --- | --- |
| Préchargeur | compteur 000 → 100, filet de sécurité à 4 s |
| Curseur | point + anneau avec inertie (souris fine uniquement) |
| Navigation | barre collée, barre de progression, lien actif |
| Menu mobile | tiroir plein écran, fermeture à `Échap` |
| Révélations | `IntersectionObserver`, décalages via `--delay` |
| Compteurs | animation `easeOutCubic` au premier passage |
| Projecteur | halo orange suivant la souris sur les cartes |
| Magnétisme | boutons attirés par le pointeur |
| Inclinaison | terminal du hero en perspective 3D |
| Terminal | session de commandes tapée caractère par caractère |
| FAQ | accordéon accessible (`aria-expanded`) |
| Braises | particules canvas montantes, en pause hors écran |

## Accessibilité et performance

- `prefers-reduced-motion` : animations coupées, contenus affichés directement
  (le terminal s'imprime d'un coup, les braises et le grain sont désactivés).
- Navigation au clavier avec `:focus-visible` visible sur fond sombre.
- Accordéon FAQ câblé en `aria-expanded` / `aria-controls`.
- Canvas mis en pause quand l'onglet passe en arrière-plan, densité de
  particules proportionnelle à la largeur de l'écran.
- Feuille de style `@media print` pour une impression propre.

## Personnaliser

Toutes les couleurs, rayons et polices sont des variables CSS au début de
`assets/css/main.css`, dans le bloc `:root`. Changer `--o-500` et `--ember`
suffit à basculer l'ensemble du site sur une autre teinte.
