package com.nyakacord.themes

data class Theme(
    val id: String,
    val name: String,
    val author: String,
    val version: String,
    val description: String,
    val colors: ThemeColors
)

data class ThemeColors(
    val primary: String = "#5865F2",
    val secondary: String = "#4752C4",
    val background: String = "#313338",
    val backgroundSecondary: String = "#2B2D31",
    val backgroundTertiary: String = "#1E1F22",
    val text: String = "#FFFFFF",
    val textMuted: String = "#949BA4",
    val accent: String = "#5865F2",
    val danger: String = "#ED4245",
    val success: String = "#57F287",
    val warning: String = "#FEE75C"
)
