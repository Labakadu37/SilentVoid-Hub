#!/usr/bin/env bash
# =====================================================================
#  Installateur du thème SilentVoid pour Pterodactyl (noir / bleu)
#  Usage :  sudo bash install-theme.sh
#           sudo bash install-theme.sh --uninstall
# =====================================================================
set -euo pipefail

PANEL="/var/www/pterodactyl"
CSS_URL="https://raw.githubusercontent.com/Labakadu37/SilentVoid-Hub/claude/vps-ssh-pterodactyl-d8temq/docs/theme/silentvoid.css"
CSS_DEST="$PANEL/public/theme/silentvoid.css"
MARK_START="<!-- SILENTVOID-THEME-START -->"
MARK_END="<!-- SILENTVOID-THEME-END -->"

BLADES=(
  "$PANEL/resources/views/templates/wrapper.blade.php"
  "$PANEL/resources/views/layouts/admin.blade.php"
  "$PANEL/resources/views/templates/auth.core.blade.php"
)

[[ $EUID -eq 0 ]] || { echo "Lance ce script en root (sudo)."; exit 1; }
[[ -d "$PANEL" ]]  || { echo "Panel introuvable dans $PANEL"; exit 1; }

remove_injection() {
  for f in "${BLADES[@]}"; do
    [[ -f "$f" ]] || continue
    perl -0pi -e "s/\Q$MARK_START\E.*?\Q$MARK_END\E\n?//s" "$f"
  done
}

if [[ "${1:-}" == "--uninstall" ]]; then
  echo ">> Suppression du thème..."
  remove_injection
  rm -f "$CSS_DEST"
  cd "$PANEL" && php artisan view:clear >/dev/null
  echo ">> Thème supprimé. Fais Ctrl+F5 dans le navigateur."
  exit 0
fi

# --- 1. Télécharger le CSS ------------------------------------------------
echo ">> Téléchargement du CSS..."
mkdir -p "$PANEL/public/theme"
curl -fsSL "$CSS_URL" -o "$CSS_DEST"
chown -R www-data:www-data "$PANEL/public/theme"

# --- 2. Injecter le lien dans les vues ------------------------------------
VERSION=$(date +%s)   # casse le cache navigateur à chaque installation
LINK="$MARK_START
    <link rel=\"stylesheet\" href=\"\/theme\/silentvoid.css?v=$VERSION\">
    $MARK_END"

echo ">> Injection dans les vues..."
remove_injection                     # évite les doublons si on relance
for f in "${BLADES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "   - ignoré (absent) : $f"
    continue
  fi
  [[ -f "$f.silentvoid.bak" ]] || cp "$f" "$f.silentvoid.bak"
  perl -0pi -e "s{</head>}{$LINK\n</head>}" "$f"
  echo "   - ok : $(basename "$f")"
done

# --- 3. Vider le cache ----------------------------------------------------
echo ">> Nettoyage du cache..."
cd "$PANEL"
php artisan view:clear   >/dev/null
php artisan config:clear >/dev/null
systemctl restart "php$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')-fpm" 2>/dev/null || true

echo
echo "=========================================="
echo " Thème SilentVoid installé."
echo " Ouvre ton panel et fais Ctrl + F5."
echo " Pour revenir en arrière :"
echo "   sudo bash install-theme.sh --uninstall"
echo "=========================================="
