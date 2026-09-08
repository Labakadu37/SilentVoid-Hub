# SilentVoid Brawl — Lobby

Jeu mobile facon **Brawl Stars / Stumble Guys**, en **Godot 4**.
Le lobby est termine et jouable, le multijoueur fonctionne, et le jeu
s'exporte en **APK Android**.

![lobby](docs/lobby.png)

## Lancer

```bash
godot --path game          # ou : ouvrir game/project.godot dans Godot 4.4
```

## Construire

```bash
cd game
./build.sh apk     # -> build/SilentVoidBrawl.apk
./build.sh web     # -> build/web/index.html  (jouable au navigateur, mobile compris)
./build.sh linux   # -> build/SilentVoidBrawl.x86_64
```

Le script installe tout seul ce qui manque dans `game/.tools/` : Godot, les
templates d'export, le SDK Android, un **JDK 17** (Godot 4.4 refuse les autres
versions pour Android) et une cle de debug. Rien n'est installe sur le systeme.

> Piege rencontre : sans `textures/vram_compression/import_etc2_astc=true` dans
> `project.godot`, Godot refuse l'export Android **avec un message d'erreur vide**.
> Le reglage est deja en place ici.

## L'interface

Elle suit l'organisation de Brawl Stars :

| Zone | Contenu |
| --- | --- |
| Haut gauche | pastille de niveau, carte joueur + club, trophees avec barre de rang |
| Haut droite | bandeau noir des monnaies (points de puissance, pieces, gemmes) + menu |
| Colonne gauche | BOUTIQUE, BRAWLERS, CLUB |
| Colonne droite | INFOS, AMIS, CHAT |
| Centre | le brawler sous les projecteurs, sa fiche au-dessus, les slots d'equipe |
| Bas gauche | passe de combat avec barre d'XP, quetes |
| Bas droite | carte d'evenement (ouvre le choix du mode) et gros bouton JOUER |

Le decor est une **arene couverte dessinee en code** : mur vert et lambris,
banniere emblematique, projecteurs et leurs cones de lumiere, plancher bois en
perspective, poussieres dans la lumiere, coins assombris.

## Multijoueur

Trois facons de jouer, toutes gerees par `autoload/Net.gd` :

```bash
# 1. Heberger un serveur (aucune interface, tourne sur un VPS ou un PC)
godot --headless --path game -- --server 8910

# 2. Rejoindre depuis le jeu : bouton menu (en haut a droite) -> MULTIJOUEUR
#    ou directement au lancement :
godot --path game -- --join 192.168.1.20 8910

# 3. Sans serveur : le jeu reste jouable, des bots remplissent la partie.
```

**La regle demandee est respectee** : on attend d'abord de vrais joueurs, et si
la file ne se remplit pas en 5 secondes, des bots prennent le relais pour que la
partie parte quand meme. Dans l'ecran de recherche, chaque bot porte un badge
`BOT` et le statut indique si tu es en ligne.

Test de bout en bout (un serveur + deux clients) :

```bash
godot --headless --path game -- --server 8910 &
godot --headless --path game res://scenes/dev/NetSmokeTest.tscn -- --join 127.0.0.1 --as Alice &
godot --headless --path game res://scenes/dev/NetSmokeTest.tscn -- --join 127.0.0.1 --as Bob
# [Alice] PARTIE TROUVEE : 2 humains + 4 bots -> Alice, Bob, Kyro53(bot), ...
```

## Le premier brawler : VOID

| | |
| --- | --- |
| Role | ASSASSIN — legendaire |
| PV | 3600 |
| Attaque | **ECLAT DE NEANT** — trois eclats en cone, plus fort de pres (3 x 360) |
| Super | **FAILLE** — traverse les murs jusqu'au point vise, degats a l'arrivee |
| Gadget | **SILENCE** — inciblable 1 s et +1200 PV |
| Pouvoir stellaire | **OMBRE PORTEE** — invisible 1,5 s apres chaque Super |

Visuellement : capuche, cape qui ondule, epaulieres, emblème sur le torse, yeux
lumineux, baton a orbe. Tout est decrit dans `GameState._build_brawlers()` et
dessine par `scripts/ui/CharacterView.gd`.

Cinq autres brawlers accompagnent VOID (SHELDY, BRUTUS, NOVA, PIXO, et ZENTY
verrouille a 950 gemmes), chacun avec son role, ses stats et son apparence.

## Zero asset a fournir

Toute la direction artistique est **dessinee en code** : decor, icones, boutons,
brawlers. Aucune image a importer, rien ne pixelise. Seule exception, la police
**Lilita One** (licence OFL, dans `assets/fonts/`), qui donne le rendu de titre
typique du genre.

## Organisation

```
game/
├── project.godot
├── build.sh                  # APK / web / Linux en une commande
├── autoload/
│   ├── GameState.gd          # monnaies, brawlers, modes, passe, sauvegarde
│   └── Net.gd                # serveur, file d'attente, bots de remplacement
├── scenes/
│   ├── Main.tscn             # racine : bascule lobby <-> partie
│   ├── ArenaStub.tscn        # ecran temoin de la partie (gameplay a venir)
│   ├── lobby/Lobby.tscn      # squelette du lobby (editable a la souris)
│   └── dev/NetSmokeTest.tscn # test reseau sans interface
└── scripts/
    ├── core/                 # Main.gd, ArenaStub.gd
    ├── ui/
    │   ├── UiSkin.gd         # PALETTE : toutes les couleurs du jeu
    │   ├── Painter.gd        # ombres, cartes, bannieres, boutons, texte contoure
    │   ├── Icons.gd          # 22 icones vectorielles
    │   ├── ChunkyButton.gd   # le bouton "Supercell" reutilisable partout
    │   └── CharacterView.gd  # les brawlers dessines
    └── lobby/                # TopLeftBar, TopRightBar, SideTabs, BrawlerStage,
                              # BottomBar, ModePicker, NetPanel, Matchmaking...
```

## Personnaliser

- **Couleurs** : `scripts/ui/UiSkin.gd`. Change `HALL`/`FLOOR` et l'arene change d'ambiance.
- **Brawlers** : `GameState._build_brawlers()` — couleurs, arme (`gun`, `hammer`,
  `bow`, `staff`, `fist`), chapeau (`cap`, `helmet`, `hood`, `crown`, `hair`),
  `cape`, `glow_eyes`, plus les stats et le kit.
- **Modes de jeu** : `GameState._build_modes()`.
- **Mise en page** : ouvre `scenes/lobby/Lobby.tscn` dans Godot et deplace les
  zones ; chacune se remplit toute seule.

Les scripts d'interface sont en `@tool` : l'apercu est deja style dans l'editeur,
sans animation (donc sans consommer de CPU pendant que tu edites).

## Prochaines etapes

1. **Le gameplay** : remplacer `ArenaStub.tscn` par la vraie arene (joystick, tir, degats).
2. **Synchroniser la partie** en reseau (`Net.gd` a deja le salon et la composition).
3. **Ecran Brawlers** : la grille complete derriere le bouton BRAWLERS.
4. **Boutique** : brancher les monnaies et l'achat du brawler verrouille.
