const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());

const API_KEY = process.env.BRAWL_API_KEY;
const BASE_URL = 'https://api.brawlstars.com/v1';
const PORT = process.env.PORT || 3000;

if (!API_KEY) {
  console.error('BRAWL_API_KEY environment variable is required');
  process.exit(1);
}

const headers = {
  Authorization: `Bearer ${API_KEY}`,
  Accept: 'application/json',
};

async function proxyRequest(path, res) {
  try {
    const response = await fetch(`${BASE_URL}${path}`, { headers });
    const data = await response.json();
    if (!response.ok) {
      return res.status(response.status).json(data);
    }
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
}

app.get('/api/players/:tag', (req, res) => {
  const tag = encodeURIComponent(`#${req.params.tag}`);
  proxyRequest(`/players/${tag}`, res);
});

app.get('/api/players/:tag/battlelog', (req, res) => {
  const tag = encodeURIComponent(`#${req.params.tag}`);
  proxyRequest(`/players/${tag}/battlelog`, res);
});

app.get('/api/clubs/:tag', (req, res) => {
  const tag = encodeURIComponent(`#${req.params.tag}`);
  proxyRequest(`/clubs/${tag}`, res);
});

app.get('/api/brawlers', (req, res) => {
  proxyRequest('/brawlers', res);
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Brawl Tracker API running on port ${PORT}`);
});
