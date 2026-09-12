package com.nyakacord.core

import android.content.Context
import android.util.Log
import com.nyakacord.patches.Patch
import java.util.concurrent.CopyOnWriteArrayList

object HookManager {

    private val patches = CopyOnWriteArrayList<Patch>()
    private var initialized = false

    fun initialize(context: Context) {
        if (initialized) return
        Log.i(NYakaCordApp.TAG, "HookManager initializing...")

        registerDefaultPatches()
        applyPatches()

        initialized = true
        Log.i(NYakaCordApp.TAG, "HookManager ready - ${patches.size} patches loaded")
    }

    fun registerPatch(patch: Patch) {
        patches.add(patch)
        Log.d(NYakaCordApp.TAG, "Registered patch: ${patch.name}")
    }

    fun unregisterPatch(patch: Patch) {
        patches.remove(patch)
        patch.disable()
        Log.d(NYakaCordApp.TAG, "Unregistered patch: ${patch.name}")
    }

    fun getPatches(): List<Patch> = patches.toList()

    private fun registerDefaultPatches() {
        // Default patches are registered here
    }

    private fun applyPatches() {
        patches.forEach { patch ->
            try {
                patch.enable()
                Log.d(NYakaCordApp.TAG, "Applied patch: ${patch.name}")
            } catch (e: Exception) {
                Log.e(NYakaCordApp.TAG, "Failed to apply patch: ${patch.name}", e)
            }
        }
    }
}
