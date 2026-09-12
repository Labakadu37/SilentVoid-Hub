package com.nyakacord.core

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONObject

object Settings {

    private const val PREFS_NAME = "nyakacord_settings"
    private lateinit var prefs: SharedPreferences

    fun initialize(context: Context) {
        prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    var pluginsEnabled: Boolean
        get() = prefs.getBoolean("plugins_enabled", true)
        set(value) = prefs.edit().putBoolean("plugins_enabled", value).apply()

    var themesEnabled: Boolean
        get() = prefs.getBoolean("themes_enabled", true)
        set(value) = prefs.edit().putBoolean("themes_enabled", value).apply()

    var currentTheme: String?
        get() = prefs.getString("current_theme", null)
        set(value) = prefs.edit().putString("current_theme", value).apply()

    var debugMode: Boolean
        get() = prefs.getBoolean("debug_mode", false)
        set(value) = prefs.edit().putBoolean("debug_mode", value).apply()

    fun getPluginSetting(pluginId: String, key: String, default: String = ""): String {
        return prefs.getString("plugin_${pluginId}_$key", default) ?: default
    }

    fun setPluginSetting(pluginId: String, key: String, value: String) {
        prefs.edit().putString("plugin_${pluginId}_$key", value).apply()
    }

    fun isPluginEnabled(pluginId: String): Boolean {
        return prefs.getBoolean("plugin_${pluginId}_enabled", true)
    }

    fun setPluginEnabled(pluginId: String, enabled: Boolean) {
        prefs.edit().putBoolean("plugin_${pluginId}_enabled", enabled).apply()
    }

    fun exportSettings(): JSONObject {
        val json = JSONObject()
        prefs.all.forEach { (key, value) ->
            when (value) {
                is Boolean -> json.put(key, value)
                is String -> json.put(key, value)
                is Int -> json.put(key, value)
                is Long -> json.put(key, value)
                is Float -> json.put(key, value)
            }
        }
        return json
    }
}
