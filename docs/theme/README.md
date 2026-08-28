# Thème SilentVoid pour Pterodactyl (noir / bleu dégradé)

Deux méthodes. La **méthode CSS** ne touche pas au code source du panel : elle
survit aux mises à jour (il suffit de re-injecter la ligne `<link>`) et ne
nécessite aucune compilation.

---

## Installation automatique (copier-coller, 1 commande)

Sur le VPS, en root :

```bash
curl -fsSL https://raw.githubusercontent.com/Labakadu37/SilentVoid-Hub/claude/vps-ssh-pterodactyl-d8temq/docs/theme/install-theme.sh -o /tmp/install-theme.sh
sudo bash /tmp/install-theme.sh
```

Le script télécharge le CSS, l'installe dans `public/theme/`, injecte la ligne
`<link>` dans les trois fichiers blade (avec sauvegarde `.silentvoid.bak`),
vide le cache et redémarre php-fpm.

Pour tout annuler :

```bash
sudo bash /tmp/install-theme.sh --uninstall
```

Relancer le script met simplement le thème à jour (pas de doublon).


---

## Méthode 1 (manuelle) — CSS personnalisé (recommandée)

### 1. Déposer le fichier

```bash
mkdir -p /var/www/pterodactyl/public/theme
nano /var/www/pterodactyl/public/theme/silentvoid.css   # coller le contenu de silentvoid.css
chown -R www-data:www-data /var/www/pterodactyl/public/theme
```

### 2. Injecter le CSS dans les pages

**Interface client (React)** — fichier `resources/views/templates/wrapper.blade.php`,
juste avant `</head>` :

```blade
<link rel="stylesheet" href="/theme/silentvoid.css?v=1">
```

**Interface admin (AdminLTE)** — fichier `resources/views/layouts/admin.blade.php`,
au même endroit :

```blade
<link rel="stylesheet" href="/theme/silentvoid.css?v=1">
```

**Pages de connexion** — `resources/views/templates/auth.core.blade.php`
(même ligne).

### 3. Appliquer

```bash
cd /var/www/pterodactyl
php artisan view:clear
php artisan config:clear
systemctl restart php8.3-fpm
```

Puis **Ctrl + F5** dans le navigateur. Incrémente `?v=2`, `?v=3`… à chaque
modification pour casser le cache.

### 4. Après une mise à jour du panel

`php artisan view:clear` efface les vues compilées, mais une mise à jour
**écrase les fichiers blade** : il faut remettre la ligne `<link>`. Le CSS
dans `public/theme/` n'est pas touché.

---

## Méthode 2 — Modifier le code source (thème « en dur »)

Plus propre visuellement, mais il faut recompiler et refaire après chaque
mise à jour.

```bash
cd /var/www/pterodactyl
apt install -y nodejs npm
npm install -g yarn
yarn install

# Couleurs Tailwind
nano tailwind.config.js
# Variables SCSS du panel
nano resources/scripts/index.tsx
nano resources/styles/main.css

yarn build:production
chown -R www-data:www-data /var/www/pterodactyl/*
php artisan view:clear
```

Dans `tailwind.config.js`, la palette se surcharge ainsi :

```js
theme: {
    extend: {
        colors: {
            primary: {
                50:'#eaf2ff',100:'#cfe0ff',200:'#9dc1ff',300:'#6ba1ff',
                400:'#4f9dff',500:'#2f7bff',600:'#1f5fd6',700:'#153f96',
                800:'#0b2a66',900:'#061733',
            },
            neutral: {
                50:'#e6edf7',100:'#c3d0e4',200:'#8fa3c0',300:'#5d7093',
                400:'#3b4d6d',500:'#26344f',600:'#1c2942',700:'#111a2e',
                800:'#0a0f1c',900:'#05070d',
            },
        },
    },
},
```

---

## Personnaliser les couleurs

Tout est piloté par les variables en haut de `silentvoid.css` :

```css
--sv-bg-0:      #05070d;   /* fond */
--sv-blue:      #2f7bff;   /* bleu principal */
--sv-cyan:      #35d0ff;   /* accent du dégradé */
--sv-blue-deep: #0b3d91;   /* bleu foncé des boutons */
```

Change ces quatre valeurs et tout le panel suit.

Le dégradé de fond est ici :

```css
body {
    background-image:
        radial-gradient(1200px 600px at 15% -10%, rgba(47,123,255,.18), transparent 60%),
        radial-gradient(900px 500px at 85% 110%, rgba(53,208,255,.12), transparent 60%),
        linear-gradient(160deg, #05070d 0%, #070c17 45%, #050912 100%) !important;
}
```

---

## Logo et nom

- Nom du panel : **Admin → Settings → General → Company Name**
- Favicon : remplacer `/var/www/pterodactyl/public/favicons/`
- Logo de connexion : ajouter dans le CSS

```css
.login-box-body::before {
    content: "";
    display: block;
    height: 80px;
    margin-bottom: 18px;
    background: url("/theme/logo.png") center/contain no-repeat;
}
```

---

## Dépannage

| Problème | Solution |
|---|---|
| Le CSS ne s'applique pas | `php artisan view:clear` + Ctrl+F5 + incrémenter `?v=` |
| 404 sur le fichier CSS | vérifier `chown www-data` et le chemin `public/theme/` |
| Certains éléments restent gris | l'interface client est en React : ajouter `!important` et cibler la balise (`div[class*="ContentBox"]`) |
| Tout est cassé | supprimer la ligne `<link>` dans le blade, `php artisan view:clear` |
