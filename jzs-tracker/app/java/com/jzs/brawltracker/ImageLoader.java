package com.jzs.brawltracker;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.util.LruCache;
import android.widget.ImageView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** Loads brawler portraits, caching them in memory and on disk. */
final class ImageLoader {

    private static final String CDN = "https://cdn.brawlify.com/";

    private static final LruCache<String, Bitmap> MEMORY =
            new LruCache<String, Bitmap>(6 * 1024 * 1024) {
                @Override
                protected int sizeOf(String key, Bitmap value) {
                    return value.getByteCount();
                }
            };

    private static final ExecutorService IO = Executors.newFixedThreadPool(3);
    private static final Handler MAIN = new Handler(Looper.getMainLooper());

    private ImageLoader() {
    }

    static void brawler(ImageView view, int id) {
        load(view, "brawlers/borderless", id);
    }

    static void profileIcon(ImageView view, int id) {
        load(view, "profile-icons/regular", id);
    }

    static void clubBadge(ImageView view, int id) {
        load(view, "club-badges/regular", id);
    }

    /** Battle events are keyed by map id, which doubles as the map artwork. */
    static void map(ImageView view, int eventId) {
        load(view, "maps/regular", eventId);
    }

    /**
     * The game's own mode icon. Mode artwork is numbered from a fixed base,
     * so the API's modeId maps straight onto it — verified against the live
     * rotation, where every mode's id lined up with its icon.
     */
    static void gameMode(ImageView view, int modeId) {
        load(view, "game-modes/regular", modeId < 0 ? 0 : GAME_MODE_BASE + modeId);
    }

    private static final int GAME_MODE_BASE = 48000000;

    static void starPower(ImageView view, int id) {
        load(view, "star-powers/regular", id);
    }

    static void gadget(ImageView view, int id) {
        load(view, "gadgets/regular", id);
    }

    static void gear(ImageView view, int id) {
        load(view, "gears/regular", id);
    }

    /**
     * Shows a dimmed mark straight away so a slot never reads as a hole while
     * the artwork is in flight, or if it never arrives.
     */
    private static void placeholder(ImageView view) {
        view.setImageResource(R.drawable.logo);
        view.setAlpha(0.16f);
    }

    private static void load(ImageView view, String category, int id) {
        if (id <= 0) {
            view.setTag(null);
            placeholder(view);
            return;
        }
        String key = category + "/" + id;
        view.setTag(key);

        Bitmap cached = MEMORY.get(key);
        if (cached != null) {
            view.setAlpha(1f);
            view.setImageBitmap(cached);
            return;
        }
        placeholder(view);
        IO.execute(new Load(view, key, CDN + key + ".png"));
    }

    private static final class Load implements Runnable {
        private final ImageView view;
        private final String key;
        private final String url;

        Load(ImageView view, String key, String url) {
            this.view = view;
            this.key = key;
            this.url = url;
        }

        @Override
        public void run() {
            Bitmap bmp = fromDisk();
            if (bmp == null) {
                bmp = fromNetwork();
            }
            if (bmp == null) {
                return;
            }
            MEMORY.put(key, bmp);
            MAIN.post(new Apply(view, key, bmp));
        }

        private File cacheFile() {
            Context c = view.getContext();
            return new File(c.getCacheDir(), key.replace('/', '_') + ".png");
        }

        private Bitmap fromDisk() {
            File f = cacheFile();
            return f.exists() ? BitmapFactory.decodeFile(f.getAbsolutePath()) : null;
        }

        private Bitmap fromNetwork() {
            HttpURLConnection c = null;
            try {
                c = (HttpURLConnection) new URL(url).openConnection();
                c.setConnectTimeout(12000);
                c.setReadTimeout(12000);
                if (c.getResponseCode() != 200) {
                    return null;
                }
                InputStream in = c.getInputStream();
                Bitmap bmp = BitmapFactory.decodeStream(in);
                in.close();
                if (bmp != null) {
                    FileOutputStream out = new FileOutputStream(cacheFile());
                    bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
                    out.close();
                }
                return bmp;
            } catch (Exception e) {
                return null;
            } finally {
                if (c != null) {
                    c.disconnect();
                }
            }
        }
    }

    /** Only paints if the view was not recycled for a different brawler meanwhile. */
    private static final class Apply implements Runnable {
        private final ImageView view;
        private final String key;
        private final Bitmap bmp;

        Apply(ImageView view, String key, Bitmap bmp) {
            this.view = view;
            this.key = key;
            this.bmp = bmp;
        }

        @Override
        public void run() {
            if (key.equals(view.getTag())) {
                view.setAlpha(1f);
                view.setImageBitmap(bmp);
            }
        }
    }
}
