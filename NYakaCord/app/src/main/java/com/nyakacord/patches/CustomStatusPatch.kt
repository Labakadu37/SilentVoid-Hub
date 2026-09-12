package com.nyakacord.patches

import android.util.Log
import com.nyakacord.core.NYakaCordApp

class CustomStatusPatch : Patch(
    name = "CustomStatus",
    description = "Allows setting custom playing status text"
) {
    var customText: String = ""
    var statusType: StatusType = StatusType.PLAYING

    enum class StatusType(val value: Int) {
        PLAYING(0),
        STREAMING(1),
        LISTENING(2),
        WATCHING(3),
        COMPETING(5)
    }

    override fun onEnable() {
        Log.i(NYakaCordApp.TAG, "CustomStatus patch enabled")
    }

    override fun onDisable() {
        Log.i(NYakaCordApp.TAG, "CustomStatus patch disabled")
    }
}
