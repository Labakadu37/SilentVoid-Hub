package org.jzs.brawl;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;

/**
 * Ping et nombre de joueurs connectés.
 *
 * Le ping est un vrai aller-retour TCP vers l'hôte mesuré ; il n'est jamais
 * simulé, sinon la valeur affichée ne veut rien dire.
 */
public final class JzsStats implements Runnable {

    public interface Listener {
        void onStats(int pingMs, String region, int online);
    }

    private static final int REFRESH_MS = 10_000;
    private static final int TIMEOUT_MS = 3_000;

    private final JzsConfig cfg;
    private final Listener listener;
    private Thread worker;
    private volatile boolean running;

    public JzsStats(JzsConfig cfg, Listener listener) {
        this.cfg = cfg;
        this.listener = listener;
    }

    public void start() {
        if (running) return;
        running = true;
        worker = new Thread(this, "jzs-stats");
        worker.setDaemon(true);
        worker.start();
    }

    public void stop() {
        running = false;
        if (worker != null) worker.interrupt();
    }

    @Override
    public void run() {
        while (running) {
            int ping = -1;
            String region = "";
            int online = -1;

            if (!cfg.statsUrl.isEmpty()) {
                try {
                    JSONObject o = fetchJson(cfg.statsUrl);
                    online = o.optInt("online", -1);
                    region = o.optString("region", "");
                    String host = o.optString("pingHost", "");
                    int port = o.optInt("pingPort", 443);
                    if (!host.isEmpty()) ping = measurePing(host, port);
                } catch (Exception ignored) {
                    // Réseau indisponible : on affichera les tirets.
                }
            }

            listener.onStats(ping, region, online);

            try {
                Thread.sleep(REFRESH_MS);
            } catch (InterruptedException e) {
                return;
            }
        }
    }

    private static int measurePing(String host, int port) {
        long best = Long.MAX_VALUE;
        for (int i = 0; i < 3; i++) {
            try (Socket s = new Socket()) {
                long t0 = System.nanoTime();
                s.connect(new InetSocketAddress(host, port), TIMEOUT_MS);
                long dt = (System.nanoTime() - t0) / 1_000_000L;
                if (dt < best) best = dt;
            } catch (Exception e) {
                return -1;
            }
        }
        return best == Long.MAX_VALUE ? -1 : (int) best;
    }

    private static JSONObject fetchJson(String url) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(TIMEOUT_MS);
        c.setReadTimeout(TIMEOUT_MS);
        try (InputStream in = c.getInputStream()) {
            ByteArrayOutputStream buf = new ByteArrayOutputStream();
            byte[] chunk = new byte[4096];
            int n;
            while ((n = in.read(chunk)) > 0) buf.write(chunk, 0, n);
            return new JSONObject(buf.toString("UTF-8"));
        } finally {
            c.disconnect();
        }
    }
}
