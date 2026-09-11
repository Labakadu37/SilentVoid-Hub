package org.jzs.brawl;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.FrameLayout.LayoutParams;

/**
 * Installe et pilote l'overlay.
 *
 * La logique vit ici plutôt que dans une classe Application, parce que le point
 * d'entrée diffère selon la cible : dans le jeu il faut hériter de
 * TitanApplication, dans la démo d'Application. Les deux appellent install().
 *
 * Tous les points d'entrée sont sous try/catch : si le mod échoue, l'hôte doit
 * continuer à tourner normalement plutôt que planter.
 */
public final class JzsMod
        implements Application.ActivityLifecycleCallbacks, JzsStats.Listener {

    private JzsConfig cfg;
    private JzsStats stats;
    private JzsOverlay overlay;

    public static void install(Application app) {
        try {
            JzsMod mod = new JzsMod();
            mod.cfg = JzsConfig.load(app);
            app.registerActivityLifecycleCallbacks(mod);
        } catch (Throwable ignored) {
        }
    }

    @Override
    public void onStats(int pingMs, String region, int online) {
        JzsOverlay v = overlay;
        if (v != null) v.updateStats(pingMs, region, online);
    }

    private void attach(Activity activity) {
        if (overlay != null && overlay.getParent() != null) return;

        ViewGroup root = activity.findViewById(android.R.id.content);
        if (root == null) return;

        JzsOverlay v = new JzsOverlay(activity, cfg);
        root.addView(v, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        v.bringToFront();
        overlay = v;

        stats = new JzsStats(cfg, this);
        stats.start();
    }

    private void detach() {
        if (stats != null) {
            stats.stop();
            stats = null;
        }
        JzsOverlay v = overlay;
        overlay = null;
        if (v != null && v.getParent() instanceof ViewGroup) {
            ((ViewGroup) v.getParent()).removeView(v);
        }
    }

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
