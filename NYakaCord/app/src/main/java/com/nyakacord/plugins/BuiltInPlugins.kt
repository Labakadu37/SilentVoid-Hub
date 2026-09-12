package com.nyakacord.plugins

import android.content.Context
import android.util.Log
import com.nyakacord.core.NYakaCordApp

object BuiltInPlugins {

    class MessageLogger : Plugin() {
        override val id = "message_logger"
        override val name = "Message Logger"
        override val description = "Logs deleted and edited messages so you can still see them"
        override val version = "1.0.0"
        override val author = "NYakaCord"

        override fun onLoad(context: Context) {
            Log.i(NYakaCordApp.TAG, "MessageLogger plugin loaded")
        }

        override fun onUnload() {
            Log.i(NYakaCordApp.TAG, "MessageLogger plugin unloaded")
        }
    }

    class AlwaysOnline : Plugin() {
        override val id = "always_online"
        override val name = "Always Online"
        override val description = "Keeps your status as online even when the app is in background"
        override val version = "1.0.0"
        override val author = "NYakaCord"

        override fun onLoad(context: Context) {
            Log.i(NYakaCordApp.TAG, "AlwaysOnline plugin loaded")
        }

        override fun onUnload() {
            Log.i(NYakaCordApp.TAG, "AlwaysOnline plugin unloaded")
        }
    }

    class BetterMedia : Plugin() {
        override val id = "better_media"
        override val name = "Better Media"
        override val description = "Enhanced media viewer with download support and zoom"
        override val version = "1.0.0"
        override val author = "NYakaCord"

        override fun onLoad(context: Context) {
            Log.i(NYakaCordApp.TAG, "BetterMedia plugin loaded")
        }

        override fun onUnload() {
            Log.i(NYakaCordApp.TAG, "BetterMedia plugin unloaded")
        }
    }
}
