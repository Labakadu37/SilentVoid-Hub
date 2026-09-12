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

    private static final String CDN = "https://cdn.brawlify.com/brawlers/borderless/";

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

    static void brawler(ImageView view, int brawlerId) {
        String key = String.valueOf(brawlerId);
        view.setTag(key);

        Bitmap cached = MEMORY.get(key);
        if (cached != null) {
            view.setImageBitmap(cached);
            return;
        }
        view.setImageBitmap(null);
        IO.execute(new Load(view, key, CDN + brawlerId + ".png"));
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
            return new File(c.getCacheDir(), "brawler_" + key + ".png");
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
                view.setImageBitmap(bmp);
            }
        }
    }
}
