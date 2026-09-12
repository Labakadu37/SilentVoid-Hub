package com.nyakacord.patches

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.nyakacord.core.NYakaCordApp
import com.nyakacord.ui.NYakaCordSettingsActivity

class SettingsInjectionPatch : Patch(
    name = "SettingsInjection",
    description = "Injects NYakaCord category into Discord's settings page"
) {
    override fun onEnable() {
        Log.i(NYakaCordApp.TAG, "SettingsInjection enabled - NYakaCord tab will appear in Discord settings")
    }

    override fun onDisable() {
        Log.i(NYakaCordApp.TAG, "SettingsInjection disabled")
    }

    companion object {
        fun createSettingsSection(context: Context): LinearLayout {
            return LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(0, dp(context, 16), 0, dp(context, 8))

                addView(createCategoryHeader(context))
                addView(createDivider(context))
                addView(createSettingsItem(context, "NYakaCord Settings", "⚙️") {
                    context.startActivity(Intent(context, NYakaCordSettingsActivity::class.java))
                })
                addView(createSettingsItem(context, "Plugins", "🔌") {
                    context.startActivity(
                        Intent(context, NYakaCordSettingsActivity::class.java)
                            .putExtra("tab", "plugins")
                    )
                })
                addView(createSettingsItem(context, "Themes", "🎨") {
                    context.startActivity(
                        Intent(context, NYakaCordSettingsActivity::class.java)
                            .putExtra("tab", "themes")
                    )
                })
                addView(createSettingsItem(context, "Message Logger", "📝") {
                    context.startActivity(
                        Intent(context, NYakaCordSettingsActivity::class.java)
                            .putExtra("tab", "message_logger")
                    )
                })
                addView(createSettingsItem(context, "Updater", "🔄") {
                    context.startActivity(
                        Intent(context, NYakaCordSettingsActivity::class.java)
                            .putExtra("tab", "updater")
                    )
                })
            }
        }

        private fun createCategoryHeader(context: Context): LinearLayout {
            return LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(context, 16), dp(context, 12), dp(context, 16), dp(context, 12))

                addView(TextView(context).apply {
                    text = "NYakaCord"
                    setTextColor(Color.parseColor("#5865F2"))
                    textSize = 13f
                    typeface = Typeface.DEFAULT_BOLD
                    letterSpacing = 0.05f
                })

                addView(View(context).apply {
                    layoutParams = LinearLayout.LayoutParams(0, 1, 1f).apply {
                        marginStart = dp(context, 8)
                    }
                    setBackgroundColor(Color.parseColor("#3F4147"))
                })
            }
        }

        private fun createSettingsItem(
            context: Context,
            title: String,
            icon: String,
            onClick: () -> Unit
        ): LinearLayout {
            val bg = GradientDrawable().apply {
                cornerRadius = dp(context, 8).toFloat()
            }

            return LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(context, 16), dp(context, 14), dp(context, 16), dp(context, 14))
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    marginStart = dp(context, 8)
                    marginEnd = dp(context, 8)
                    topMargin = dp(context, 2)
                }
                background = bg
                isClickable = true
                isFocusable = true

                setOnClickListener { onClick() }
                setOnTouchListener { v, event ->
                    when (event.action) {
                        android.view.MotionEvent.ACTION_DOWN -> bg.setColor(Color.parseColor("#3F4147"))
                        android.view.MotionEvent.ACTION_UP,
                        android.view.MotionEvent.ACTION_CANCEL -> bg.setColor(Color.TRANSPARENT)
                    }
                    false
                }

                addView(TextView(context).apply {
                    text = icon
                    textSize = 20f
                    setPadding(0, 0, dp(context, 12), 0)
                })

                addView(TextView(context).apply {
                    text = title
                    textSize = 16f
                    setTextColor(Color.parseColor("#DBDEE1"))
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                })

                addView(TextView(context).apply {
                    text = "›"
                    textSize = 20f
                    setTextColor(Color.parseColor("#949BA4"))
                })
            }
        }

        private fun createDivider(context: Context): View {
            return View(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, 1
                ).apply {
                    marginStart = dp(context, 16)
                    marginEnd = dp(context, 16)
                    bottomMargin = dp(context, 4)
                }
                setBackgroundColor(Color.parseColor("#3F4147"))
            }
        }

        private fun dp(context: Context, dp: Int): Int {
            return TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                dp.toFloat(),
                context.resources.displayMetrics
            ).toInt()
        }
    }
}
