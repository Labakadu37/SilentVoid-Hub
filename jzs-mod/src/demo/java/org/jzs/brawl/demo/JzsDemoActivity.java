package org.jzs.brawl.demo;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;

/**
 * Écran de test : un fond sombre pour vérifier le rendu de l'overlay sans
 * avoir à lancer le jeu. L'overlay lui-même est posé par JzsApplication.
 */
public final class JzsDemoActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        View bg = new View(this);
        bg.setBackgroundColor(Color.parseColor("#2B1B4D"));
        setContentView(bg);
    }
}
