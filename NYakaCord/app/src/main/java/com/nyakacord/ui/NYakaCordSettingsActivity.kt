package com.nyakacord.ui

import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.Switch
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.nyakacord.core.NYakaCordApp
import com.nyakacord.core.Settings
import com.nyakacord.plugins.BuiltInPlugins
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class NYakaCordSettingsActivity : AppCompatActivity() {

    private lateinit var contentContainer: LinearLayout
    private var currentTab = "general"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Settings.initialize(this)
        currentTab = intent.getStringExtra("tab") ?: "general"
        buildUI()
    }

    private fun buildUI() {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#1E1F22"))
        }

        root.addView(buildToolbar())
        root.addView(buildTabBar())

        contentContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }

        val scrollView = ScrollView(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f
            )
            addView(contentContainer)
        }
        root.addView(scrollView)

        showTab(currentTab)
        setContentView(root)
    }

    private fun buildToolbar(): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setBackgroundColor(Color.parseColor("#2B2D31"))
            setPadding(dp(16), dp(16), dp(16), dp(16))

            addView(TextView(context).apply {
                text = "←"
                textSize = 22f
                setTextColor(Color.parseColor("#DBDEE1"))
                setPadding(0, 0, dp(16), 0)
                setOnClickListener { finish() }
            })

            addView(TextView(context).apply {
                text = "NYakaCord"
                textSize = 20f
                setTextColor(Color.WHITE)
                typeface = Typeface.DEFAULT_BOLD
            })

            addView(View(context).apply {
                layoutParams = LinearLayout.LayoutParams(0, 0, 1f)
            })

            addView(TextView(context).apply {
                text = "v1.0.0"
                textSize = 12f
                setTextColor(Color.parseColor("#5865F2"))
            })
        }
    }

    private fun buildTabBar(): LinearLayout {
        val tabs = listOf(
            "general" to "⚙️ General",
            "plugins" to "🔌 Plugins",
            "themes" to "🎨 Themes",
            "message_logger" to "📝 Logs",
            "updater" to "🔄 Updater"
        )

        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(Color.parseColor("#2B2D31"))
            setPadding(dp(8), 0, dp(8), dp(8))

            tabs.forEach { (tabId, label) ->
                addView(createTab(tabId, label, tabId == currentTab))
            }
        }
    }

    private fun createTab(tabId: String, label: String, active: Boolean): TextView {
        val bg = GradientDrawable().apply {
            cornerRadius = dp(12).toFloat()
            if (active) setColor(Color.parseColor("#5865F2"))
        }

        return TextView(this).apply {
            text = label
            textSize = 12f
            setTextColor(if (active) Color.WHITE else Color.parseColor("#949BA4"))
            background = bg
            setPadding(dp(12), dp(8), dp(12), dp(8))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { marginEnd = dp(4) }
            setOnClickListener {
                currentTab = tabId
                buildUI()
            }
        }
    }

    private fun showTab(tab: String) {
        contentContainer.removeAllViews()
        when (tab) {
            "general" -> showGeneralTab()
            "plugins" -> showPluginsTab()
            "themes" -> showThemesTab()
            "message_logger" -> showMessageLoggerTab()
            "updater" -> showUpdaterTab()
        }
    }

    private fun showGeneralTab() {
        contentContainer.apply {
            addView(sectionTitle("General Settings"))
            addView(settingToggle("Enable Plugins", "Load and run NYakaCord plugins", Settings.pluginsEnabled) {
                Settings.pluginsEnabled = it
            })
            addView(settingToggle("Enable Themes", "Apply custom themes to Discord", Settings.themesEnabled) {
                Settings.themesEnabled = it
            })
            addView(settingToggle("Debug Mode", "Show detailed logs in logcat", Settings.debugMode) {
                Settings.debugMode = it
            })

            addView(sectionTitle("About"))
            addView(infoRow("Version", "1.0.0"))
            addView(infoRow("Plugins loaded", "${NYakaCordApp.instance.pluginManager.getAllPlugins().size}"))
            addView(infoRow("Themes available", "${NYakaCordApp.instance.themeManager.getAllThemes().size}"))
        }
    }

    private fun showPluginsTab() {
        contentContainer.apply {
            addView(sectionTitle("Installed Plugins"))

            NYakaCordApp.instance.pluginManager.getAllPlugins().forEach { plugin ->
                addView(pluginCard(plugin.name, plugin.description, plugin.author, plugin.version,
                    Settings.isPluginEnabled(plugin.id)) { enabled ->
                    if (enabled) NYakaCordApp.instance.pluginManager.enablePlugin(plugin.id)
                    else NYakaCordApp.instance.pluginManager.disablePlugin(plugin.id)
                })
            }
        }
    }

    private fun showThemesTab() {
        contentContainer.apply {
            addView(sectionTitle("Available Themes"))

            val activeTheme = NYakaCordApp.instance.themeManager.getActiveTheme()

            NYakaCordApp.instance.themeManager.getAllThemes().forEach { theme ->
                val isActive = activeTheme?.id == theme.id
                addView(themeCard(theme.name, theme.description, theme.author, theme.colors.primary, isActive) {
                    NYakaCordApp.instance.themeManager.applyTheme(theme.id)
                    showTab("themes")
                })
            }
        }
    }

    private fun showMessageLoggerTab() {
        val logger = NYakaCordApp.instance.pluginManager.getPlugin("message_logger")
                as? BuiltInPlugins.MessageLogger

        contentContainer.apply {
            addView(sectionTitle("Message Logger"))

            if (logger == null || !logger.isLoaded) {
                addView(statusCard("Message Logger is disabled", "Enable it in the Plugins tab to start logging deleted and edited messages."))
                return
            }

            val deleted = logger.getAllDeletedMessages()

            addView(infoRow("Deleted messages captured", "${deleted.size}"))

            addView(actionButton("Clear All Logs") {
                logger.clearLogs()
                showTab("message_logger")
            })

            addView(sectionTitle("Recent Deleted Messages"))

            if (deleted.isEmpty()) {
                addView(statusCard("No deleted messages yet", "Deleted messages will appear here once they are intercepted."))
            } else {
                deleted.values
                    .sortedByDescending { it.deletedAt }
                    .take(50)
                    .forEach { msg ->
                        addView(deletedMessageCard(msg))
                    }
            }
        }
    }

    private fun showUpdaterTab() {
        contentContainer.apply {
            addView(sectionTitle("Updater"))
            addView(statusCard("You are up to date!", "NYakaCord v1.0.0 is the latest version."))
            addView(actionButton("Check for Updates") {
                // Check for updates logic
            })
        }
    }

    // --- UI Components ---

    private fun sectionTitle(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 13f
            setTextColor(Color.parseColor("#5865F2"))
            typeface = Typeface.DEFAULT_BOLD
            letterSpacing = 0.05f
            setPadding(dp(16), dp(20), dp(16), dp(8))
        }
    }

    private fun settingToggle(title: String, subtitle: String, default: Boolean, onChange: (Boolean) -> Unit): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(16), dp(12), dp(16), dp(12))

            val textContainer = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)

                addView(TextView(context).apply {
                    text = title
                    textSize = 16f
                    setTextColor(Color.parseColor("#DBDEE1"))
                })
                addView(TextView(context).apply {
                    text = subtitle
                    textSize = 13f
                    setTextColor(Color.parseColor("#949BA4"))
                })
            }
            addView(textContainer)

            addView(Switch(context).apply {
                isChecked = default
                setOnCheckedChangeListener { _, isChecked -> onChange(isChecked) }
            })
        }
    }

    private fun pluginCard(name: String, desc: String, author: String, version: String,
                           enabled: Boolean, onToggle: (Boolean) -> Unit): LinearLayout {
        val cardBg = GradientDrawable().apply {
            setColor(Color.parseColor("#2B2D31"))
            cornerRadius = dp(12).toFloat()
        }

        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = cardBg
            setPadding(dp(16), dp(14), dp(16), dp(14))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginStart = dp(12); marginEnd = dp(12); topMargin = dp(6)
            }

            val header = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL

                addView(TextView(context).apply {
                    text = name
                    textSize = 16f
                    setTextColor(Color.WHITE)
                    typeface = Typeface.DEFAULT_BOLD
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                })

                addView(Switch(context).apply {
                    isChecked = enabled
                    setOnCheckedChangeListener { _, isChecked -> onToggle(isChecked) }
                })
            }
            addView(header)

            addView(TextView(context).apply {
                text = desc
                textSize = 13f
                setTextColor(Color.parseColor("#949BA4"))
                setPadding(0, dp(4), 0, dp(4))
            })

            addView(TextView(context).apply {
                text = "by $author • v$version"
                textSize = 11f
                setTextColor(Color.parseColor("#72767D"))
            })
        }
    }

    private fun themeCard(name: String, desc: String, author: String, accentColor: String,
                          active: Boolean, onClick: () -> Unit): LinearLayout {
        val cardBg = GradientDrawable().apply {
            setColor(Color.parseColor("#2B2D31"))
            cornerRadius = dp(12).toFloat()
            if (active) {
                setStroke(dp(2), Color.parseColor(accentColor))
            }
        }

        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            background = cardBg
            setPadding(dp(16), dp(14), dp(16), dp(14))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginStart = dp(12); marginEnd = dp(12); topMargin = dp(6)
            }
            isClickable = true
            setOnClickListener { onClick() }

            val colorPreview = View(context).apply {
                layoutParams = LinearLayout.LayoutParams(dp(40), dp(40)).apply { marginEnd = dp(12) }
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(Color.parseColor(accentColor))
                }
            }
            addView(colorPreview)

            val textContainer = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)

                addView(TextView(context).apply {
                    text = if (active) "$name  ✔" else name
                    textSize = 16f
                    setTextColor(Color.WHITE)
                    typeface = Typeface.DEFAULT_BOLD
                })
                addView(TextView(context).apply {
                    text = desc
                    textSize = 13f
                    setTextColor(Color.parseColor("#949BA4"))
                })
                addView(TextView(context).apply {
                    text = "by $author"
                    textSize = 11f
                    setTextColor(Color.parseColor("#72767D"))
                })
            }
            addView(textContainer)
        }
    }

    private fun deletedMessageCard(msg: BuiltInPlugins.MessageLogger.DeletedMessage): LinearLayout {
        val cardBg = GradientDrawable().apply {
            setColor(Color.parseColor("#2B2D31"))
            cornerRadius = dp(8).toFloat()
            setStroke(1, Color.parseColor("#ED4245"))
        }

        val dateFormat = SimpleDateFormat("dd/MM HH:mm:ss", Locale.getDefault())

        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = cardBg
            setPadding(dp(12), dp(10), dp(12), dp(10))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginStart = dp(12); marginEnd = dp(12); topMargin = dp(4)
            }

            val header = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL

                addView(TextView(context).apply {
                    text = msg.authorName
                    textSize = 14f
                    setTextColor(Color.WHITE)
                    typeface = Typeface.DEFAULT_BOLD
                })
                addView(TextView(context).apply {
                    text = "  •  ${dateFormat.format(Date(msg.deletedAt))}"
                    textSize = 11f
                    setTextColor(Color.parseColor("#72767D"))
                })
            }
            addView(header)

            addView(TextView(context).apply {
                text = msg.content
                textSize = 14f
                setTextColor(Color.parseColor("#ED4245"))
                setPadding(0, dp(4), 0, 0)
            })

            if (msg.attachments.isNotEmpty()) {
                addView(TextView(context).apply {
                    text = "📎 ${msg.attachments.size} attachment(s)"
                    textSize = 12f
                    setTextColor(Color.parseColor("#949BA4"))
                    setPadding(0, dp(4), 0, 0)
                })
            }
        }
    }

    private fun statusCard(title: String, desc: String): LinearLayout {
        val cardBg = GradientDrawable().apply {
            setColor(Color.parseColor("#2B2D31"))
            cornerRadius = dp(12).toFloat()
        }

        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = cardBg
            gravity = Gravity.CENTER
            setPadding(dp(24), dp(24), dp(24), dp(24))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginStart = dp(12); marginEnd = dp(12); topMargin = dp(8)
            }

            addView(TextView(context).apply {
                text = title
                textSize = 16f
                setTextColor(Color.WHITE)
                typeface = Typeface.DEFAULT_BOLD
                this.gravity = Gravity.CENTER
            })
            addView(TextView(context).apply {
                text = desc
                textSize = 13f
                setTextColor(Color.parseColor("#949BA4"))
                this.gravity = Gravity.CENTER
                setPadding(0, dp(4), 0, 0)
            })
        }
    }

    private fun actionButton(text: String, onClick: () -> Unit): LinearLayout {
        val btnBg = GradientDrawable().apply {
            setColor(Color.parseColor("#5865F2"))
            cornerRadius = dp(8).toFloat()
        }

        return LinearLayout(this).apply {
            gravity = Gravity.CENTER
            setPadding(0, dp(8), 0, dp(8))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginStart = dp(12); marginEnd = dp(12); topMargin = dp(8)
            }

            addView(TextView(context).apply {
                this.text = text
                textSize = 14f
                setTextColor(Color.WHITE)
                typeface = Typeface.DEFAULT_BOLD
                background = btnBg
                this.gravity = Gravity.CENTER
                setPadding(dp(24), dp(12), dp(24), dp(12))
                isClickable = true
                setOnClickListener { onClick() }
            })
        }
    }

    private fun infoRow(label: String, value: String): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(dp(16), dp(10), dp(16), dp(10))

            addView(TextView(context).apply {
                text = label
                textSize = 14f
                setTextColor(Color.parseColor("#949BA4"))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            })
            addView(TextView(context).apply {
                text = value
                textSize = 14f
                setTextColor(Color.WHITE)
            })
        }
    }

    private fun dp(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, dp.toFloat(), resources.displayMetrics
        ).toInt()
    }
}
