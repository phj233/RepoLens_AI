package top.phj233.repolens_ai

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.os.Build
import android.view.View
import android.view.Window
import android.view.WindowInsetsController

internal fun Window.configureRepoLensSystemBars(useDarkIcons: Boolean) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        statusBarColor = Color.TRANSPARENT
        navigationBarColor = Color.TRANSPARENT
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        navigationBarDividerColor = Color.TRANSPARENT
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        var flags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        if (useDarkIcons) {
            flags = flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && useDarkIcons) {
            flags = flags or View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
        }
        decorView.systemUiVisibility = flags
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        val lightBars = WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS or
            WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS
        insetsController?.setSystemBarsAppearance(
            if (useDarkIcons) lightBars else 0,
            lightBars,
        )
    }
}

internal fun AndroidNativeSnapshot.usesDarkSystemBarIcons(context: Context): Boolean {
    val systemDark = (context.resources.configuration.uiMode and
        Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
    val isDark = when (settings.themeMode) {
        "dark" -> true
        "light" -> false
        else -> systemDark
    }
    return settings.androidLiquidGlassBackground.isLightSystemBarBackground() ?: !isDark
}

private fun String.isLightSystemBarBackground(): Boolean? {
    val cleaned = trim().removePrefix("#")
    if (cleaned.isEmpty()) return null
    val parsed = cleaned.toLongOrNull(16) ?: return null
    val rgb = when (cleaned.length) {
        6 -> parsed
        8 -> parsed and 0x00FFFFFF
        else -> return null
    }
    val red = ((rgb shr 16) and 0xFF) / 255.0
    val green = ((rgb shr 8) and 0xFF) / 255.0
    val blue = (rgb and 0xFF) / 255.0
    val luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
    return luminance >= 0.52
}
