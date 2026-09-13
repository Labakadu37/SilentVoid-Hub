/**
 * Member counter for the BrawlBee banner.
 *
 * Each copy of the app calls this with its own install id. Distinct ids are
 * members; ids seen in the last few minutes are online. Runs on Cloudflare
 * Workers' free tier.
 *
 * Deploy:
 *   npm create cloudflare@latest brawlbee-members -- --type=hello-world
 *   # replace src/index.js with this file
 *   npx wrangler kv namespace create MEMBERS
 *   # put the returned id in wrangler.toml:
 *   #   [[kv_namespaces]]
 *   #   binding = "MEMBERS"
 *   #   id = "<the id>"
 *   npx wrangler deploy
 *
 * Then put the deployed URL in Config.MEMBERS_URL and rebuild the app.
 */

const ONLINE_WINDOW_MS = 5 * 60 * 1000;
const SEEN_TTL_S = 60 * 60 * 24 * 90;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const id = (url.searchParams.get('id') || '').slice(0, 64);

    if (!id) {
      return json({ error: 'missing id' }, 400);
    }

    const now = Date.now();
    const key = `seen:${id}`;
    const previous = await env.MEMBERS.get(key);

    // A first sighting is a new member; every sighting refreshes presence.
    if (previous === null) {
      const total = Number(await env.MEMBERS.get('count:total')) || 0;
      await env.MEMBERS.put('count:total', String(total + 1));
    }
    await env.MEMBERS.put(key, String(now), { expirationTtl: SEEN_TTL_S });

    const total = Number(await env.MEMBERS.get('count:total')) || 0;
    const online = await countOnline(env, now);

    return json({ online, total });
  },
};

/**
 * KV has no range query, so presence is counted by listing the seen: keys.
 * Fine at this scale; past a few thousand members this wants a Durable Object.
 */
async function countOnline(env, now) {
  let online = 0;
  let cursor;

  do {
    const page = await env.MEMBERS.list({ prefix: 'seen:', cursor });
    for (const entry of page.keys) {
      const at = Number(await env.MEMBERS.get(entry.name));
      if (now - at < ONLINE_WINDOW_MS) {
        online++;
      }
    }
    cursor = page.cursor;
    if (page.list_complete) {
      break;
    }
  } while (cursor);

  return online;
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json',
      'cache-control': 'no-store',
      'access-control-allow-origin': '*',
    },
  });
}
