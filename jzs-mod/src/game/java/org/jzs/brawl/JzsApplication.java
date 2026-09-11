package org.jzs.brawl;

import com.supercell.titan.TitanApplication;

/**
 * Point d'entrée dans le jeu.
 *
 * On hérite de TitanApplication et non d'Application : c'est elle qui initialise
 * le moteur. La remplacer ferait planter le jeu au démarrage. super.onCreate()
 * passe en premier pour que le jeu soit prêt avant qu'on pose l'overlay.
 *
 * Se branche via android:name sur <application> dans le manifeste.
 */
public final class JzsApplication extends TitanApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        JzsMod.install(this);
    }
}
