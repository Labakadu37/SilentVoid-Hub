# Toutes les commandes — VPS / SSH / Pterodactyl

## 1. SSH (machine locale)
```bash
ssh-keygen -t ed25519 -C "mon-pc"
ssh-copy-id root@IP_DU_VPS
ssh root@IP_DU_VPS
ssh root@IP_DU_VPS -p 2222
scp fichier.txt root@IP_DU_VPS:/root/
scp root@IP_DU_VPS:/chemin/fichier .
rsync -avz ./dossier/ root@IP_DU_VPS:/opt/app/
ssh -L 8080:localhost:80 root@IP_DU_VPS
```

## 2. Sécurisation du VPS
```bash
apt update && apt upgrade -y
adduser deploy
usermod -aG sudo deploy
rsync --archive --chown=deploy:deploy ~/.ssh /home/deploy

nano /etc/ssh/sshd_config
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
systemctl restart ssh

ufw allow OpenSSH
ufw allow 80,443/tcp
ufw enable
apt install -y fail2ban
systemctl enable --now fail2ban
```

## 3. Commandes système utiles
```bash
htop
df -h
free -h
systemctl status SERVICE
systemctl restart SERVICE
journalctl -u SERVICE -f
tmux
docker ps -a
docker logs ID
```

## 4. Dépendances Pterodactyl
```bash
apt install -y software-properties-common curl ca-certificates gnupg2 lsb-release
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
apt update
apt install -y php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} \
  mariadb-server nginx tar unzip git redis-server
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
```

## 5. Panel
```bash
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/
```

### Base de données
```bash
mysql -u root -p
```
```sql
CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY 'MOT_DE_PASSE';
CREATE DATABASE panel;
GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

### Configuration
```bash
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan p:environment:setup
php artisan p:environment:database
php artisan migrate --seed --force
php artisan p:user:make
chown -R www-data:www-data /var/www/pterodactyl/*
```

### Cron + queue
```bash
crontab -e
# * * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1

nano /etc/systemd/system/pteroq.service
systemctl enable --now redis-server pteroq.service
```

### Nginx + SSL
```bash
apt install -y certbot python3-certbot-nginx
certbot certonly --nginx -d panel.mondomaine.fr
rm /etc/nginx/sites-enabled/default
nano /etc/nginx/sites-available/pterodactyl.conf
ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

## 6. Wings
```bash
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker

mkdir -p /etc/pterodactyl
curl -Lo /usr/local/bin/wings \
  "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
chmod u+x /usr/local/bin/wings

nano /etc/pterodactyl/config.yml     # coller le YAML du panel
nano /etc/systemd/system/wings.service
systemctl enable --now wings
systemctl status wings

ufw allow 8080/tcp
ufw allow 2022/tcp
ufw allow 25565/tcp
```

## 7. Debug
```bash
journalctl -u wings -f
journalctl -u pteroq -f
tail -f /var/www/pterodactyl/storage/logs/laravel-*.log
systemctl status php8.3-fpm
nginx -t
docker ps -a
```

## 8. Mise à jour du panel
```bash
cd /var/www/pterodactyl
php artisan down
curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
chmod -R 755 storage/* bootstrap/cache
composer install --no-dev --optimize-autoloader
php artisan view:clear && php artisan config:clear
php artisan migrate --seed --force
chown -R www-data:www-data /var/www/pterodactyl/*
systemctl restart pteroq
php artisan up
```
