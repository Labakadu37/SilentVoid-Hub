package com.nyakacord.plugins

import android.content.Context
import android.util.Log
import com.nyakacord.core.NYakaCordApp
import com.nyakacord.core.Settings
import java.io.File

class PluginManager(private val context: Context) {

    private val plugins = mutableMapOf<String, Plugin>()
    private val pluginsDir: File = File(context.filesDir, "plugins")

    init {
        if (!pluginsDir.exists()) {
            pluginsDir.mkdirs()
        }
    }

    fun loadPlugins() {
        if (!Settings.pluginsEnabled) {
            Log.i(NYakaCordApp.TAG, "Plugins disabled, skipping load")
            return
        }

        loadBuiltInPlugins()
        loadExternalPlugins()
        Log.i(NYakaCordApp.TAG, "Loaded ${plugins.size} plugins")
    }

    private fun loadBuiltInPlugins() {
        registerPlugin(BuiltInPlugins.MessageLogger())
        registerPlugin(BuiltInPlugins.AlwaysOnline())
        registerPlugin(BuiltInPlugins.BetterMedia())
    }

    private fun loadExternalPlugins() {
        val pluginFiles = pluginsDir.listFiles { file -> file.extension == "jar" } ?: return
        pluginFiles.forEach { file ->
            try {
                Log.d(NYakaCordApp.TAG, "Loading external plugin: ${file.name}")
                // External plugin loading via DexClassLoader
            } catch (e: Exception) {
                Log.e(NYakaCordApp.TAG, "Failed to load plugin: ${file.name}", e)
            }
        }
    }

    fun registerPlugin(plugin: Plugin) {
        if (plugins.containsKey(plugin.id)) {
            Log.w(NYakaCordApp.TAG, "Plugin ${plugin.id} already registered")
            return
        }

        plugins[plugin.id] = plugin
        if (Settings.isPluginEnabled(plugin.id)) {
            plugin.load(context)
        }
    }

    fun unregisterPlugin(pluginId: String) {
        plugins.remove(pluginId)?.unload()
    }

    fun enablePlugin(pluginId: String) {
        Settings.setPluginEnabled(pluginId, true)
        plugins[pluginId]?.load(context)
    }

    fun disablePlugin(pluginId: String) {
        Settings.setPluginEnabled(pluginId, false)
        plugins[pluginId]?.unload()
    }

    fun getPlugin(pluginId: String): Plugin? = plugins[pluginId]

    fun getAllPlugins(): List<Plugin> = plugins.values.toList()

    fun getPluginsDir(): File = pluginsDir
}
