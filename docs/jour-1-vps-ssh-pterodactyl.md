# Jour 1 — VPS, SSH et installation de Pterodactyl

Guide pas à pas pour débuter : se connecter à un VPS en SSH, le sécuriser,
puis installer le panel Pterodactyl et un node Wings.

---

## Partie 1 — Comprendre le VPS

Un VPS (Virtual Private Server) est une machine Linux louée chez un hébergeur
(Hetzner, Contabo, OVH, Oracle Cloud…). Tu y as un accès root complet, et tu
la pilotes **uniquement en ligne de commande via SSH**.

Ce dont tu as besoin pour Pterodactyl :

| Ressource | Minimum | Confortable |
|---|---|---|
| CPU | 2 vCPU | 4 vCPU |
| RAM | 2 Go (panel seul) | 8 Go (panel + serveurs de jeu) |
| Disque | 20 Go SSD | 80 Go SSD |
| OS | Ubuntu 22.04 / 24.04 LTS | idem |

L'hébergeur te donne : une **IP publique**, un **utilisateur** (`root`) et un
mot de passe (ou une clé SSH).

---

## Partie 2 — SSH : les bases

### 2.1 Première connexion

```bash
ssh root@203.0.113.10          # remplace par ton IP
ssh root@203.0.113.10 -p 2222  # si le port n'est pas 22
```

La première fois, SSH affiche l'empreinte du serveur → répondre `yes`.
Elle est stockée dans `~/.ssh/known_hosts`.

### 2.2 Clés SSH (à faire tout de suite, c'est plus sûr qu'un mot de passe)

Sur **ta machine locale** :

```bash
ssh-keygen -t ed25519 -C "mon-pc"        # laisse le chemin par défaut, mets une passphrase
ssh-copy-id root@203.0.113.10            # copie la clé publique sur le VPS
ssh root@203.0.113.10                    # doit se connecter sans mot de passe
```

- `~/.ssh/id_ed25519` = clé **privée**, ne la partage JAMAIS.
- `~/.ssh/id_ed25519.pub` = clé **publique**, c'est elle qu'on copie sur les serveurs.

### 2.3 Raccourci avec `~/.ssh/config`

```
Host vps
    HostName 203.0.113.10
    User deploy
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

Ensuite : `ssh vps` suffit.

### 2.4 Commandes SSH utiles

```bash
scp fichier.txt vps:/home/deploy/        # envoyer un fichier
scp vps:/var/log/syslog .                # récupérer un fichier
rsync -avz ./dossier/ vps:/opt/app/      # synchroniser un dossier
ssh -L 8080:localhost:80 vps             # tunnel : localhost:8080 -> port 80 du VPS
```

---

## Partie 3 — Sécuriser le VPS (obligatoire avant Pterodactyl)

```bash
# 1. Mettre à jour
apt update && apt upgrade -y

# 2. Créer un utilisateur non-root
adduser deploy
usermod -aG sudo deploy
rsync --archive --chown=deploy:deploy ~/.ssh /home/deploy

# 3. Durcir SSH
nano /etc/ssh/sshd_config
```

Dans le fichier, mettre :

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Puis :

```bash
systemctl restart ssh
```

> ⚠️ **Garde ta session actuelle ouverte** et teste `ssh deploy@IP` dans un
> second terminal avant de fermer. Si tu te trompes, tu te verrouilles dehors.

```bash
# 4. Pare-feu
ufw allow OpenSSH
ufw allow 80,443/tcp
ufw enable

# 5. Anti-bruteforce
apt install -y fail2ban && systemctl enable --now fail2ban
```

### Survie en ligne de commande

```bash
htop            # processus / RAM / CPU
df -h           # espace disque
journalctl -u nginx -f    # logs d'un service en direct
systemctl status nginx    # état d'un service
tmux            # garder une session ouverte même si SSH coupe
```

---

## Partie 4 — Installer le Panel Pterodactyl

Architecture : **Panel** (interface web) + **Wings** (démon qui lance les
serveurs de jeu dans Docker). Les deux peuvent être sur la même machine.

Prérequis : un **nom de domaine** pointant vers l'IP du VPS
(ex. `panel.mondomaine.fr` → enregistrement A → 203.0.113.10).

### 4.1 Dépendances

```bash
# PHP 8.3, MariaDB, Redis, Nginx
apt install -y software-properties-common curl ca-certificates gnupg2 lsb-release
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash

apt update
apt install -y php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} \
  mariadb-server nginx tar unzip git redis-server

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
```

### 4.2 Télécharger le panel

```bash
mkdir -p /var/www/pterodactyl && cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
```

### 4.3 Base de données

```bash
mysql -u root -p
```

```sql
CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY 'UN_MOT_DE_PASSE_FORT';
CREATE DATABASE panel;
GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

### 4.4 Configuration

```bash
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force

php artisan p:environment:setup      # URL du panel, timezone, cache/queue = redis
php artisan p:environment:database   # host 127.0.0.1, db panel, user pterodactyl
php artisan migrate --seed --force

php artisan p:user:make              # crée ton compte admin
```

> 🔑 `php artisan key:generate` ne doit être lancé **qu'une seule fois** :
> régénérer la clé rend toutes les données chiffrées illisibles.

### 4.5 Permissions + queue worker

```bash
chown -R www-data:www-data /var/www/pterodactyl/*

# Tâche planifiée
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -

# Service de queue
cat > /etc/systemd/system/pteroq.service <<'UNIT'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
UNIT

systemctl enable --now redis-server pteroq.service
```

### 4.6 Nginx + HTTPS

```bash
apt install -y certbot python3-certbot-nginx
certbot certonly --nginx -d panel.mondomaine.fr
rm /etc/nginx/sites-enabled/default
nano /etc/nginx/sites-available/pterodactyl.conf
```

Configuration minimale :

```nginx
server {
    listen 80;
    server_name panel.mondomaine.fr;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name panel.mondomaine.fr;
    root /var/www/pterodactyl/public;
    index index.php;

    ssl_certificate     /etc/letsencrypt/live/panel.mondomaine.fr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/panel.mondomaine.fr/privkey.pem;

    client_max_body_size 100m;

    location / { try_files $uri $uri/ /index.php?$query_string; }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
    }
}
```

```bash
ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
```

Le panel est accessible sur `https://panel.mondomaine.fr`.

---

## Partie 5 — Installer Wings (le démon)

```bash
# Docker
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker

# Wings
mkdir -p /etc/pterodactyl
curl -Lo /usr/local/bin/wings \
  "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo amd64 || echo arm64)"
chmod u+x /usr/local/bin/wings
```

Dans le panel : **Admin → Nodes → Create New**. Une fois le node créé,
onglet **Configuration** → copier le YAML dans `/etc/pterodactyl/config.yml`.

```bash
cat > /etc/systemd/system/wings.service <<'UNIT'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
UNIT

systemctl enable --now wings
systemctl status wings
```

Ouvre les ports nécessaires :

```bash
ufw allow 8080/tcp     # API Wings
ufw allow 2022/tcp     # SFTP Pterodactyl
ufw allow 25565/tcp    # exemple : Minecraft
```

Le node doit passer au **vert** dans le panel. Tu peux alors créer ton premier
serveur (Admin → Servers → Create New).

---

## Dépannage rapide

| Symptôme | Piste |
|---|---|
| Node rouge dans le panel | `journalctl -u wings -f` ; vérifier le certificat SSL et le port 8080 |
| Erreur 500 sur le panel | `tail -f /var/www/pterodactyl/storage/logs/laravel-*.log` |
| `502 Bad Gateway` | php-fpm arrêté : `systemctl status php8.3-fpm` |
| Serveur de jeu ne démarre pas | Docker : `docker ps -a`, `docker logs <id>` |
| SSH refuse la connexion | mauvaise clé ou `PasswordAuthentication no` : passer par la console web de l'hébergeur |

---

## Récapitulatif Jour 1

- [ ] Se connecter au VPS en SSH
- [ ] Générer une clé SSH et désactiver le mot de passe
- [ ] Créer un utilisateur `sudo` non-root
- [ ] Configurer UFW + fail2ban
- [ ] Installer PHP / MariaDB / Redis / Nginx
- [ ] Installer le panel Pterodactyl + HTTPS
- [ ] Installer Docker + Wings, node vert
- [ ] Créer un premier serveur de test

Documentation officielle : <https://pterodactyl.io/panel/1.0/getting_started.html>
