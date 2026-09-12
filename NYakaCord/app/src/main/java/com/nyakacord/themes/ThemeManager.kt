package com.nyakacord.themes

import android.content.Context
import android.util.Log
import com.nyakacord.core.NYakaCordApp
import com.nyakacord.core.Settings
import org.json.JSONObject
import java.io.File

class ThemeManager(private val context: Context) {

    private val themes = mutableMapOf<String, Theme>()
    private val themesDir: File = File(context.filesDir, "themes")
    private var activeTheme: Theme? = null

    init {
        if (!themesDir.exists()) {
            themesDir.mkdirs()
        }
    }

    fun loadThemes() {
        if (!Settings.themesEnabled) {
            Log.i(NYakaCordApp.TAG, "Themes disabled, skipping load")
            return
        }

        loadBuiltInThemes()
        loadExternalThemes()

        Settings.currentTheme?.let { themeId ->
            applyTheme(themeId)
        }

        Log.i(NYakaCordApp.TAG, "Loaded ${themes.size} themes")
    }

    private fun loadBuiltInThemes() {
        registerTheme(
            Theme(
                id = "midnight",
                name = "Midnight",
                author = "NYakaCord",
                version = "1.0.0",
                description = "A deep dark theme with blue accents",
                colors = ThemeColors(
                    primary = "#5865F2",
                    background = "#0D1117",
                    backgroundSecondary = "#161B22",
                    backgroundTertiary = "#010409"
                )
            )
        )

        registerTheme(
            Theme(
                id = "amoled",
                name = "AMOLED Black",
                author = "NYakaCord",
                version = "1.0.0",
                description = "Pure black theme for AMOLED displays",
                colors = ThemeColors(
                    primary = "#5865F2",
                    background = "#000000",
                    backgroundSecondary = "#0A0A0A",
                    backgroundTertiary = "#000000"
                )
            )
        )

        registerTheme(
            Theme(
                id = "nyaka_purple",
                name = "NYaka Purple",
                author = "NYakaCord",
                version = "1.0.0",
                description = "Custom purple theme by NYakaCord",
                colors = ThemeColors(
                    primary = "#9B59B6",
                    secondary = "#8E44AD",
                    background = "#1A0A2E",
                    backgroundSecondary = "#16082A",
                    backgroundTertiary = "#0D0519",
                    accent = "#9B59B6"
                )
            )
        )
    }

    private fun loadExternalThemes() {
        val themeFiles = themesDir.listFiles { file -> file.extension == "json" } ?: return
        themeFiles.forEach { file ->
            try {
                val json = JSONObject(file.readText())
                val colors = json.optJSONObject("colors") ?: JSONObject()
                val theme = Theme(
                    id = json.getString("id"),
                    name = json.getString("name"),
                    author = json.optString("author", "Unknown"),
                    version = json.optString("version", "1.0.0"),
                    description = json.optString("description", ""),
                    colors = ThemeColors(
                        primary = colors.optString("primary", "#5865F2"),
                        secondary = colors.optString("secondary", "#4752C4"),
                        background = colors.optString("background", "#313338"),
                        backgroundSecondary = colors.optString("backgroundSecondary", "#2B2D31"),
                        backgroundTertiary = colors.optString("backgroundTertiary", "#1E1F22"),
                        text = colors.optString("text", "#FFFFFF"),
                        textMuted = colors.optString("textMuted", "#949BA4"),
                        accent = colors.optString("accent", "#5865F2")
                    )
                )
                registerTheme(theme)
            } catch (e: Exception) {
                Log.e(NYakaCordApp.TAG, "Failed to load theme: ${file.name}", e)
            }
        }
    }

    fun registerTheme(theme: Theme) {
        themes[theme.id] = theme
    }

    fun applyTheme(themeId: String) {
        val theme = themes[themeId] ?: return
        activeTheme = theme
        Settings.currentTheme = themeId
        Log.i(NYakaCordApp.TAG, "Applied theme: ${theme.name}")
    }

    fun getActiveTheme(): Theme? = activeTheme

    fun getAllThemes(): List<Theme> = themes.values.toList()

    fun getThemesDir(): File = themesDir
}
