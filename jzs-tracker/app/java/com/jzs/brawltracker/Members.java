package com.jzs.brawltracker;

import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Member counts for the banner.
 *
 * How many people have the app, and how many have it open right now, can only
 * be known by something every copy reports to. This pings that endpoint with a
 * per-install id: the endpoint counts distinct ids as members, and ids seen
 * recently as online. Without an endpoint configured there is nothing to
 * report and the banner shows no numbers rather than invented ones.
 */
final class Members {

    private static final String KEY_INSTALL_ID = "install_id";

    interface Callback {
        void onCounts(int online, int total);
    }

    private static final ExecutorService IO = Executors.newSingleThreadExecutor();
    private static final Handler MAIN = new Handler(Looper.getMainLooper());

    private Members() {
    }

    static boolean configured() {
        return !Config.MEMBERS_URL.isEmpty();
    }

    /** Stable per-install id, created once and kept for the life of the app. */
    private static String installId(SharedPreferences prefs) {
        String id = prefs.getString(KEY_INSTALL_ID, "");
        if (id.isEmpty()) {
            id = UUID.randomUUID().toString();
            prefs.edit().putString(KEY_INSTALL_ID, id).apply();
        }
        return id;
    }

    static void fetch(SharedPreferences prefs, Callback cb) {
        if (!configured()) {
            return;
        }
        IO.execute(new Ping(installId(prefs), cb));
    }

    private static final class Ping implements Runnable {
        private final String id;
        private final Callback cb;

        Ping(String id, Callback cb) {
            this.id = id;
            this.cb = cb;
        }

        @Override
        public void run() {
            HttpURLConnection c = null;
            try {
                String url = Config.MEMBERS_URL
                        + (Config.MEMBERS_URL.contains("?") ? "&" : "?")
                        + "id=" + URLEncoder.encode(id, "UTF-8");
                c = (HttpURLConnection) new URL(url).openConnection();
                c.setConnectTimeout(8000);
                c.setReadTimeout(8000);
                if (c.getResponseCode() != 200) {
                    return;
                }
                BufferedReader r = new BufferedReader(
                        new InputStreamReader(c.getInputStream(), "UTF-8"));
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = r.readLine()) != null) {
                    sb.append(line);
                }
                r.close();

                JSONObject body = new JSONObject(sb.toString());
                final int online = body.optInt("online", 0);
                final int total = body.optInt("total", 0);
                MAIN.post(new Runnable() {
                    @Override
                    public void run() {
                        cb.onCounts(online, total);
                    }
                });
            } catch (Exception ignored) {
                // Counts are decoration; a failure leaves the banner as it was.
            } finally {
                if (c != null) {
                    c.disconnect();
                }
            }
        }
    }
}
