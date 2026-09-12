package com.nyakacord.core

import android.app.Application
import android.util.Log
import com.nyakacord.plugins.PluginManager
import com.nyakacord.themes.ThemeManager

class NYakaCordApp : Application() {

    lateinit var pluginManager: PluginManager
        private set
    lateinit var themeManager: ThemeManager
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.i(TAG, "NYakaCord v1.0.0 starting...")

        try {
            Settings.initialize(this)
            pluginManager = PluginManager(this)
            themeManager = ThemeManager(this)
            initializeCore()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize NYakaCord", e)
        }
    }

    private fun initializeCore() {
        HookManager.initialize(this)
        pluginManager.loadPlugins()
        themeManager.loadThemes()
        Log.i(TAG, "NYakaCord initialized successfully")
    }

    companion object {
        const val TAG = "NYakaCord"
        lateinit var instance: NYakaCordApp
            private set
    }
}
