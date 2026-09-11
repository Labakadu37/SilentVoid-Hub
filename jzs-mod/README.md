# JZS Mod

Notre overlay de lobby. Code entièrement écrit par nous — aucun binaire tiers.

## Ce que ça fait

Affiche en haut à gauche du jeu :

```
JZS Brawl v69.230 (release)
Telegram: t.me/jzbrawl
Ping: 60 ms (EU/Germany-1)
Online: 74
```

Le ping est un vrai aller-retour TCP mesuré (3 essais, on garde le meilleur).
Le nombre de joueurs vient de notre backend. Sans `StatsUrl` configurée, ces
deux lignes affichent `--` plutôt qu'une valeur inventée.

## Architecture

| Fichier | Rôle |
|---|---|
| `JzsApplication.java` | Point d'entrée, s'accroche au cycle de vie des activités |
| `JzsOverlay.java` | Dessine le bandeau doré (`Canvas.drawText`) |
| `JzsStats.java` | Mesure le ping, récupère le nombre de joueurs |
| `JzsConfig.java` | Lit `assets/jzs/credits.json` |

L'overlay est une `View` transparente posée par-dessus `android.R.id.content`.
Elle n'est pas cliquable, donc les touches passent au travers jusqu'au jeu.

Toute la logique est sous `try/catch` : si le mod casse, le jeu continue.

## Configuration

`assets/jzs/credits.json` :

| Clé | Effet |
|---|---|
| `LobbyCreditModName` | Nom affiché en première ligne |
| `Version` / `Channel` | `v69.230` et `(release)` |
| `LobbyCreditSocials` | Ligne Telegram |
| `TextColor` | Couleur hex, `FFD700` = doré |
| `TextSizeSp` | Taille du texte |
| `StatsUrl` | Endpoint JSON de notre backend |

Réponse attendue de `StatsUrl` :

```json
{ "online": 74, "region": "EU/Germany-1", "pingHost": "game.exemple.net", "pingPort": 443 }
```

## Compilation

```bash
./gradlew :jzs-mod:assembleRelease
```

Produit un `classes.dex` contenant nos classes.

## Injection dans l'APK

1. Décompiler l'APK cible avec `apktool d base.apk`
2. Copier nos classes compilées dans les `smali/`
3. Dans `AndroidManifest.xml`, mettre sur `<application>` :
   `android:name="org.jzs.brawl.JzsApplication"`
4. Copier `assets/jzs/` dans les assets
5. Recompiler : `apktool b`
6. Aligner puis signer :

```bash
zipalign -f -p 4 out.apk aligned.apk
apksigner sign --ks jzs.keystore \
  --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
  --min-sdk-version 24 --out JZSBrawl.apk aligned.apk
```

`zipalign` + signature v2/v3 ne sont pas optionnels : Android 11+ refuse
d'installer un APK signé uniquement en v1.
