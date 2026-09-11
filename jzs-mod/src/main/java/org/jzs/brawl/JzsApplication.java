package org.jzs.brawl;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.view.FrameLayout;
import android.view.ViewGroup;
import android.widget.FrameLayout.LayoutParams;

/**
 * Point d'entrée du mod : on remplace android:name de <application> dans le
 * manifeste par cette classe, ce qui nous fait démarrer avec le jeu.
 *
 * Toute la logique est sous try/catch : si le mod échoue, le jeu doit continuer
 * à tourner normalement plutôt que planter.
 */
public final class JzsApplication extends Application {

    private JzsConfig cfg;
    private JzsStats stats;
    private JzsOverlay overlay;

    @Override
    public void onCreate() {
        super.onCreate();
        try {
            cfg = JzsConfig.load(this);
            registerActivityLifecycleCallbacks(new Callbacks());
        } catch (Throwable ignored) {
        }
    }

    private void attach(Activity activity) {
        if (overlay != null && overlay.getParent() != null) return;

        ViewGroup root = activity.findViewById(android.R.id.content);
        if (root == null) return;

        overlay = new JzsOverlay(activity, cfg);
        root.addView(overlay, new LayoutParams(
                LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        overlay.bringToFront();

        stats = new JzsStats(cfg, (ping, region, online) -> {
            if (overlay != null) overlay.updateStats(ping, region, online);
        });
        stats.start();
    }

    private void detach() {
        if (stats != null) {
            stats.stop();
            stats = null;
        }
        if (overlay != null && overlay.getParent() instanceof ViewGroup) {
            ((ViewGroup) overlay.getParent()).removeView(overlay);
        }
        overlay = null;
    }

    private final class Callbacks implements ActivityLifecycleCallbacks {
        @Override
        public void onActivityResumed(Activity activity) {
            try {
                attach(activity);
            } catch (Throwable ignored) {
            }
        }

        @Override
        public void onActivityPaused(Activity activity) {
            try {
                detach();
            } catch (Throwable ignored) {
            }
        }

        @Override public void onActivityCreated(Activity a, Bundle b) { }
        @Override public void onActivityStarted(Activity a) { }
        @Override public void onActivityStopped(Activity a) { }
        @Override public void onActivitySaveInstanceState(Activity a, Bundle b) { }
        @Override public void onActivityDestroyed(Activity a) { }
    }
}
