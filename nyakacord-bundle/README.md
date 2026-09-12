# NYakaCord

A client modification for Discord Android — plugins, themes and fonts.

NYakaCord is a fork of [Revenge](https://github.com/revenge-mod/revenge-bundle),
which is itself a continuation of Bunny and Vendetta. The hooking engine and
Discord module resolution come from that lineage; the branding, bundled themes
and first-party plugins are ours. See [LICENSE](LICENSE) for the full copyright
chain.

The plugin API is exposed as `window.bunny`, unchanged from upstream, so
**existing Revenge, Bunny and Vendetta plugins work in NYakaCord**.

## Installing

NYakaCord ships as a JavaScript bundle, not an APK. You need a loader that
patches Discord and then fetches the bundle:

- **Non-rooted Android** — [Revenge Manager](https://github.com/revenge-mod/revenge-manager)
- **Rooted Android** — [RevengeXposed](https://github.com/revenge-mod/revenge-xposed)

Once a loader is installed:

1. Open Discord, go to **Settings → General** and enable **Developer Settings**.
2. Go to **Settings → Developer** and enable **Load from custom URL**.
3. Set the URL to the NYakaCord bundle:

   ```
   https://raw.githubusercontent.com/Labakadu37/SilentVoid-Hub/claude/vendcord-discord-client-4avk2r/nyakacord-bundle/dist/nyakacord.js
   ```

4. Restart Discord. The client will fetch NYakaCord instead of upstream.

If the bundle appears stale, use **Settings → Developer → Clear JS bundle**.

## Building

Requires [Bun](https://bun.sh).

```sh
bun install
bun run build     # -> dist/nyakacord.js
bun run lint
```

To iterate against a device on the same network, `bun run serve` serves the
bundle on port 4040; point the custom URL at `http://<your-ip>:4040/nyakacord.js`.

## Disclaimer

Modified Discord clients violate Discord's Terms of Service and can get an
account terminated. Use at your own risk.
