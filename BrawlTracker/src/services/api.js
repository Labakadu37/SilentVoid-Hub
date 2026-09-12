const BASE_URL = 'https://api.brawlstars.com/v1';
const API_KEY = 'YOUR_API_KEY_HERE';

const headers = {
  Authorization: `Bearer ${API_KEY}`,
  Accept: 'application/json',
};

function formatTag(tag) {
  let clean = tag.replace(/\s/g, '').toUpperCase();
  if (!clean.startsWith('#')) clean = '#' + clean;
  return encodeURIComponent(clean);
}

export async function getPlayer(tag) {
  const res = await fetch(`${BASE_URL}/players/${formatTag(tag)}`, { headers });
  if (!res.ok) {
    if (res.status === 404) throw new Error('Joueur introuvable');
    if (res.status === 403) throw new Error('Cle API invalide');
    throw new Error('Erreur serveur');
  }
  return res.json();
}

export async function getPlayerBattleLog(tag) {
  const res = await fetch(`${BASE_URL}/players/${formatTag(tag)}/battlelog`, { headers });
  if (!res.ok) throw new Error('Impossible de charger le battlelog');
  return res.json();
}

export async function getClub(tag) {
  const res = await fetch(`${BASE_URL}/clubs/${formatTag(tag)}`, { headers });
  if (!res.ok) throw new Error('Club introuvable');
  return res.json();
}

export async function getBrawlers() {
  const res = await fetch(`${BASE_URL}/brawlers`, { headers });
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
