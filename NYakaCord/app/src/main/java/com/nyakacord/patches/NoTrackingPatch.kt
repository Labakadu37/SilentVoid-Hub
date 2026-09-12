package com.nyakacord.patches

import android.util.Log
import com.nyakacord.core.NYakaCordApp

class NoTrackingPatch : Patch(
    name = "NoTracking",
    description = "Blocks Discord analytics and tracking requests"
) {
    private val blockedEndpoints = listOf(
        "/api/v9/science",
        "/api/v10/science",
        "/api/v9/metrics",
        "/api/v10/metrics"
    )

    override fun onEnable() {
        Log.i(NYakaCordApp.TAG, "NoTracking patch enabled - blocking ${blockedEndpoints.size} endpoints")
    }

    override fun onDisable() {
        Log.i(NYakaCordApp.TAG, "NoTracking patch disabled")
    }
}
