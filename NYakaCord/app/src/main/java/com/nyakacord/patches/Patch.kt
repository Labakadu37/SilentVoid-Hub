package com.nyakacord.patches

abstract class Patch(
    val name: String,
    val description: String,
    val version: String = "1.0.0"
) {
    var isEnabled: Boolean = false
        private set

    fun enable() {
        if (!isEnabled) {
            onEnable()
            isEnabled = true
        }
    }

    fun disable() {
        if (isEnabled) {
            onDisable()
            isEnabled = false
        }
    }

    protected abstract fun onEnable()
    protected abstract fun onDisable()
}
