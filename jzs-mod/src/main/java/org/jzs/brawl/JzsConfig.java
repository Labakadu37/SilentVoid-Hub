package org.jzs.brawl;

import android.content.Context;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;

/** Textes et réglages de l'overlay, lus depuis assets/jzs/credits.json. */
public final class JzsConfig {

    public String modName = "JZS Brawl";
    public String version = "v69.230";
    public String channel = "release";
    public String socials = "t.me/jzbrawl";
    public String statsUrl = "";
    public int textColor = 0xFFFFD700;
    public int shadowColor = 0xFF000000;
    public float textSizeSp = 12f;
    public float marginDp = 8f;

    public static JzsConfig load(Context ctx) {
        JzsConfig cfg = new JzsConfig();
        try (InputStream in = ctx.getAssets().open("jzs/credits.json")) {
            ByteArrayOutputStream buf = new ByteArrayOutputStream();
            byte[] chunk = new byte[8192];
            int n;
            while ((n = in.read(chunk)) > 0) {
                buf.write(chunk, 0, n);
            }
            JSONObject o = new JSONObject(buf.toString("UTF-8"));
            cfg.modName = o.optString("LobbyCreditModName", cfg.modName);
            cfg.version = o.optString("Version", cfg.version);
            cfg.channel = o.optString("Channel", cfg.channel);
            cfg.socials = o.optString("LobbyCreditSocials", cfg.socials);
            cfg.statsUrl = o.optString("StatsUrl", cfg.statsUrl);
            cfg.textColor = parseColor(o.optString("TextColor", ""), cfg.textColor);
            cfg.textSizeSp = (float) o.optDouble("TextSizeSp", cfg.textSizeSp);
        } catch (Exception ignored) {
            // Config absente ou illisible : on garde les valeurs par défaut.
        }
        return cfg;
    }

    private static int parseColor(String s, int fallback) {
        if (s == null || s.isEmpty()) return fallback;
        try {
            return (int) Long.parseLong(s.replace("#", ""), 16) | 0xFF000000;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
