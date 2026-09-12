package com.nyakacord.utils

import android.util.Log
import com.nyakacord.core.NYakaCordApp
import com.nyakacord.core.Settings

object Logger {

    fun d(message: String) {
        if (Settings.debugMode) {
            Log.d(NYakaCordApp.TAG, message)
        }
    }

    fun i(message: String) {
        Log.i(NYakaCordApp.TAG, message)
    }

    fun w(message: String) {
        Log.w(NYakaCordApp.TAG, message)
    }

    fun e(message: String, throwable: Throwable? = null) {
        Log.e(NYakaCordApp.TAG, message, throwable)
    }
}
