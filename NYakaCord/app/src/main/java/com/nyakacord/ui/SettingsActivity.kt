package com.nyakacord.ui

import android.os.Bundle
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.Switch
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.nyakacord.core.NYakaCordApp
import com.nyakacord.core.Settings

class SettingsActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Settings.initialize(this)
        buildSettingsUI()
    }

    private fun buildSettingsUI() {
        val scrollView = ScrollView(this)
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(48, 48, 48, 48)
        }

        layout.addView(createHeader("NYakaCord Settings"))
        layout.addView(createSubHeader("v1.0.0"))

        layout.addView(createSectionTitle("General"))
        layout.addView(createToggle("Enable Plugins", Settings.pluginsEnabled) { Settings.pluginsEnabled = it })
        layout.addView(createToggle("Enable Themes", Settings.themesEnabled) { Settings.themesEnabled = it })
        layout.addView(createToggle("Debug Mode", Settings.debugMode) { Settings.debugMode = it })

        layout.addView(createSectionTitle("Plugins"))
        NYakaCordApp.instance.pluginManager.getAllPlugins().forEach { plugin ->
            layout.addView(
                createToggle(
                    "${plugin.name} - ${plugin.description}",
                    Settings.isPluginEnabled(plugin.id)
                ) { enabled ->
                    if (enabled) {
                        NYakaCordApp.instance.pluginManager.enablePlugin(plugin.id)
                    } else {
                        NYakaCordApp.instance.pluginManager.disablePlugin(plugin.id)
                    }
                }
            )
        }

        layout.addView(createSectionTitle("Themes"))
        NYakaCordApp.instance.themeManager.getAllThemes().forEach { theme ->
            layout.addView(createThemeItem(theme.name, theme.description, theme.id))
        }

        scrollView.addView(layout)
        setContentView(scrollView)
    }

    private fun createHeader(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 28f
            setTextColor(0xFFFFFFFF.toInt())
            setPadding(0, 0, 0, 8)
        }
    }

    private fun createSubHeader(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 14f
            setTextColor(0xFF949BA4.toInt())
            setPadding(0, 0, 0, 32)
        }
    }

    private fun createSectionTitle(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 18f
            setTextColor(0xFF5865F2.toInt())
            setPadding(0, 32, 0, 16)
        }
    }

    private fun createToggle(label: String, default: Boolean, onChange: (Boolean) -> Unit): Switch {
        return Switch(this).apply {
            text = label
            isChecked = default
            textSize = 15f
            setTextColor(0xFFFFFFFF.toInt())
            setPadding(0, 16, 0, 16)
            setOnCheckedChangeListener { _, isChecked -> onChange(isChecked) }
        }
    }

    private fun createThemeItem(name: String, description: String, themeId: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 12, 0, 12)
            isClickable = true
            setOnClickListener {
                NYakaCordApp.instance.themeManager.applyTheme(themeId)
            }

            addView(TextView(context).apply {
                text = name
                textSize = 16f
                setTextColor(0xFFFFFFFF.toInt())
            })
            addView(TextView(context).apply {
                text = description
                textSize = 12f
                setTextColor(0xFF949BA4.toInt())
            })
        }
    }
}
