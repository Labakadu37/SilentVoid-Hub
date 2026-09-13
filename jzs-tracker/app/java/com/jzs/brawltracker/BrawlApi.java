package com.jzs.brawltracker;

import android.os.Handler;
import android.os.Looper;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Calls the Brawl Stars API through the RoyaleAPI proxy.
 *
 * Supercell ties an API key to a fixed IP, which a phone can never satisfy.
 * The proxy has a stable IP that the key is issued against, so the same key
 * works from every device.
 */
public final class BrawlApi {

    public static final String PROXY_IP = "45.79.218.79";
    private static final String BASE = "https://bsproxy.royaleapi.dev/v1";

    public interface Callback {
        void onSuccess(JSONObject body);

        void onError(String message);
    }

    private final ExecutorService io = Executors.newSingleThreadExecutor();
    private final Handler main = new Handler(Looper.getMainLooper());
    private final String token;

    public BrawlApi(String token) {
        this.token = token;
    }

    /** Uppercases, strips a leading #, and maps the O/0 and I/1 lookalikes. */
    public static String normalizeTag(String raw) {
        String t = raw == null ? "" : raw.trim().toUpperCase();
        if (t.startsWith("#")) {
            t = t.substring(1);
        }
        return t.replace('O', '0').replace('I', '1');
    }

    public void player(String tag, Callback cb) {
        get("/players/" + encodeTag(tag), cb);
    }

    public void battlelog(String tag, Callback cb) {
        get("/players/" + encodeTag(tag) + "/battlelog", cb);
    }

    public void club(String tag, Callback cb) {
        get("/clubs/" + encodeTag(tag), cb);
    }

    /** region is "global" or a two-letter country code. */
    public void rankedPlayers(String region, Callback cb) {
        get("/rankings/" + region + "/players?limit=50", cb);
    }

    public void rankedClubs(String region, Callback cb) {
        get("/rankings/" + region + "/clubs?limit=50", cb);
    }

    /** The rotation returns a bare array, so it is wrapped under "items". */
    public void events(Callback cb) {
        get("/events/rotation", cb);
    }

    private static String encodeTag(String tag) {
        try {
            return URLEncoder.encode("#" + normalizeTag(tag), "UTF-8");
        } catch (IOException e) {
            return "%23" + normalizeTag(tag);
        }
    }

    private void get(String path, Callback cb) {
        io.execute(new Fetch(this, path, cb));
    }

    /** Runs one request off the main thread, then hands the outcome back to it. */
    private static final class Fetch implements Runnable {
        private final BrawlApi api;
        private final String path;
        private final Callback cb;

        Fetch(BrawlApi api, String path, Callback cb) {
            this.api = api;
            this.path = path;
            this.cb = cb;
        }

        @Override
        public void run() {
            try {
                api.main.post(new Deliver(cb, api.request(path), null));
            } catch (Exception e) {
                api.main.post(new Deliver(cb, null, describe(e)));
            }
        }
    }

    private static final class Deliver implements Runnable {
        private final Callback cb;
        private final JSONObject body;
        private final String error;

        Deliver(Callback cb, JSONObject body, String error) {
            this.cb = cb;
            this.body = body;
            this.error = error;
        }

        @Override
        public void run() {
            if (error != null) {
                cb.onError(error);
            } else {
                cb.onSuccess(body);
            }
        }
    }

    private JSONObject request(String path) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(BASE + path).openConnection();
        try {
            c.setRequestMethod("GET");
            c.setRequestProperty("Authorization", "Bearer " + token);
            c.setRequestProperty("Accept", "application/json");
            c.setConnectTimeout(15000);
            c.setReadTimeout(15000);

            int code = c.getResponseCode();
            String text = read(code >= 400 ? c.getErrorStream() : c.getInputStream());

            if (code >= 400) {
                throw new ApiException(code, reasonFor(code, text));
            }
            // Some endpoints answer with a bare array; wrap it so callers can
            // read every response the same way.
            String body = text.trim();
            if (body.startsWith("[")) {
                return new JSONObject().put("items", new JSONArray(body));
            }
            return new JSONObject(body);
        } finally {
            c.disconnect();
        }
    }

    private static String read(InputStream in) throws IOException {
        if (in == null) {
            return "";
        }
        BufferedReader r = new BufferedReader(new InputStreamReader(in, "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = r.readLine()) != null) {
            sb.append(line);
        }
        r.close();
        return sb.toString();
    }

    /** Turns the API's terse error codes into something a player can act on. */
    private static String reasonFor(int code, String body) {
        switch (code) {
            case 400:
                return "Invalid tag. Check the characters.";
            case 403:
                // Only the build's own key can cause this, so there is nothing
                // for the person holding the phone to fix.
                return "Service temporarily unavailable.";
            case 404:
                return "Player not found. This tag does not exist.";
            case 429:
                return "Too many requests. Try again in a few seconds.";
            case 503:
                return "The Brawl Stars API is under maintenance.";
            default:
                String detail = body == null ? "" : body;
                if (detail.length() > 140) {
                    detail = detail.substring(0, 140);
                }
                return "Error " + code + (detail.isEmpty() ? "" : " - " + detail);
        }
    }

    private static String describe(Exception e) {
        if (e instanceof ApiException) {
            return e.getMessage();
        }
        return "No connection. Check your network.";
    }

    public static final class ApiException extends Exception {
        public final int code;

        ApiException(int code, String message) {
            super(message);
            this.code = code;
        }
    }
}
