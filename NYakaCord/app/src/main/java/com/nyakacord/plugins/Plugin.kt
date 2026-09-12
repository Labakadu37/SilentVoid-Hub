package com.nyakacord.plugins

import android.content.Context

abstract class Plugin {
    abstract val id: String
    abstract val name: String
    abstract val description: String
    abstract val version: String
    abstract val author: String

    var isLoaded: Boolean = false
        private set

    fun load(context: Context) {
        if (!isLoaded) {
            onLoad(context)
            isLoaded = true
        }
    }

    fun unload() {
        if (isLoaded) {
            onUnload()
            isLoaded = false
        }
    }

    protected abstract fun onLoad(context: Context)
    protected abstract fun onUnload()
}
