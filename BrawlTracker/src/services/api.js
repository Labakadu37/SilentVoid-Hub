// Change this URL to your deployed server (Render, Railway, etc.)
const SERVER_URL = 'https://your-server-url.onrender.com';

function cleanTag(tag) {
  return tag.replace(/\s/g, '').replace('#', '').toUpperCase();
}

export async function getPlayer(tag) {
  const res = await fetch(`${SERVER_URL}/api/players/${cleanTag(tag)}`);
  if (!res.ok) {
    if (res.status === 404) throw new Error('Joueur introuvable');
    throw new Error('Erreur serveur');
  }
  return res.json();
}

export async function getPlayerBattleLog(tag) {
  const res = await fetch(`${SERVER_URL}/api/players/${cleanTag(tag)}/battlelog`);
  if (!res.ok) throw new Error('Impossible de charger le battlelog');
  return res.json();
}

export async function getClub(tag) {
  const res = await fetch(`${SERVER_URL}/api/clubs/${cleanTag(tag)}`);
  if (!res.ok) throw new Error('Club introuvable');
  return res.json();
}

export async function getBrawlers() {
  const res = await fetch(`${SERVER_URL}/api/brawlers`);
  if (!res.ok) throw new Error('Erreur chargement brawlers');
  return res.json();
}

export function getRarityColor(rarity) {
  const map = {
    'Trophy Road': '#82e0ff',
    'Rare': '#00cc44',
    'Super Rare': '#0088ff',
    'Epic': '#bb44ff',
    'Mythic': '#ff4444',
    'Legendary': '#ff00ff',
    'Chromatic': '#ffd700',
  };
  return map[rarity] || '#ffffff';
}
