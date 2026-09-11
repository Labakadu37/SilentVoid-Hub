package org.jzs.brawl.demo;

import android.app.Application;

import org.jzs.brawl.JzsMod;

/** Point d'entrée de la démo : pas de TitanApplication ici, juste Application. */
public final class JzsDemoApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        JzsMod.install(this);
    }
}
