package top.phj233.repolens_ai

import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class AndroidNativeShellState(
    private val channel: MethodChannel,
    private val onSnapshotChanged: (AndroidNativeSnapshot) -> Unit,
) {
    private val mainHandler = Handler(Looper.getMainLooper())

    var snapshot by mutableStateOf(AndroidNativeSnapshot.empty)
        private set
    var hasReceivedSnapshot by mutableStateOf(false)
        private set
    var selectedIndex by mutableIntStateOf(0)
        private set
    private var pendingNavigationIndex: Int? = null
    private var pendingNavigationSinceMillis: Long = 0L

    init {
        channel.setMethodCallHandler(::handleMethodCall)
    }

    fun refresh() {
        channel.invokeMethod(
            "requestState",
            null,
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    applySnapshot(result)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) = Unit
                override fun notImplemented() = Unit
            },
        )
    }

    fun select(index: Int) {
        val nextIndex = index.coerceIn(0, 4)
        pendingNavigationIndex = nextIndex
        pendingNavigationSinceMillis = SystemClock.uptimeMillis()
        selectedIndex = nextIndex
        val nextSnapshot = snapshot.copy(
            navigationIndex = nextIndex,
            projectDetailOpen = false,
            settingsProviderDetailOpen = false,
            settingsAppearanceDetailOpen = false,
        )
        snapshot = nextSnapshot
        onSnapshotChanged(nextSnapshot)
        invoke("setNavigationIndex", nextIndex)
    }

    fun updateFilters(keyword: String, dateRange: String, language: String, minStars: Int) {
        invoke(
            "updateFilters",
            mapOf(
                "keyword" to keyword,
                "dateRange" to dateRange,
                "language" to language,
                "minStars" to minStars,
            ),
        )
    }

    fun discover() = invoke("discover")
    fun selectProject(fullName: String) = invoke("selectProject", fullName)
    fun openProjectDetail(fullName: String) = invoke("openProjectDetail", fullName)
    fun closeProjectDetail() = invoke("closeProjectDetail")
    fun openSettingsProviderDetail() = invoke("openSettingsProviderDetail")
    fun closeSettingsProviderDetail() = invoke("closeSettingsProviderDetail")
    fun openSettingsAppearanceDetail() = invoke("openSettingsAppearanceDetail")
    fun closeSettingsAppearanceDetail() = invoke("closeSettingsAppearanceDetail")
    fun dismissMessage() = invoke("dismissMessage")
    fun closeImagePreview() = invoke("closeImagePreview")
    fun toggleFavorite(fullName: String) = invoke("toggleFavorite", fullName)
    fun analyzeSelectedProject() = invoke("analyzeSelectedProject")
    fun analyzeSelectedProjectAndOpenAnalysis() = invoke("analyzeSelectedProjectAndOpenAnalysis")
    fun export(format: String) = invoke("exportCurrentData", format)
    fun exportSelected(format: String) = invoke("exportSelectedProjectData", format)
    fun openExportFile(filePath: String) = invoke("openExportFile", filePath)
    fun deleteExport(export: AndroidNativeExport) = invoke("deleteExport", mapOf("id" to export.id))
    fun updateLanguage(language: String) {
        updateLocalSettings { it.copy(language = language) }
        invoke("updateLanguage", language)
    }

    fun updateThemeMode(mode: String) {
        updateLocalSettings { it.copy(themeMode = mode) }
        invoke("updateThemeMode", mode)
    }

    fun updateThemeColor(color: String) {
        val nextColor = color.trim()
        updateLocalSettings { it.copy(themeColor = nextColor) }
        invoke("updateThemeColor", nextColor)
    }

    fun updateAndroidLiquidGlassBackground(background: String) {
        val nextBackground = background.trim()
        updateLocalSettings { it.copy(androidLiquidGlassBackground = nextBackground) }
        invoke("updateAndroidLiquidGlassBackground", nextBackground)
    }

    fun updateVisualStyle(style: String) {
        updateLocalSettings { it.copy(visualStyle = style) }
        invoke("updateVisualStyle", style)
    }
    fun updateMcpWriteAccess(enabled: Boolean) = invoke("updateMcpWriteAccess", enabled)
    fun addProvider(payload: Map<String, Any?>) = invoke("addProvider", payload)
    fun selectProvider(providerId: String) = invoke("selectProvider", providerId)
    fun deleteProvider(providerId: String) = invoke("deleteProvider", providerId)
    fun refreshSelectedProviderModels() = invoke("refreshSelectedProviderModels")
    fun saveGithubToken(token: String) = invoke("saveGithubToken", token)
    fun saveProviderApiKey(apiKey: String) = invoke("saveProviderApiKey", apiKey)

    fun saveProvider(payload: Map<String, Any?>) {
        invoke("updateProvider", payload)
    }

    private fun invoke(method: String, arguments: Any? = null) {
        channel.invokeMethod(
            method,
            arguments,
                object : MethodChannel.Result {
                override fun success(result: Any?) {
                    if (result == null) {
                        refresh()
                    } else {
                        applySnapshot(result)
                    }
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    refresh()
                }

                override fun notImplemented() {
                    refresh()
                }
            },
        )
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "stateChanged" -> {
                applySnapshot(call.arguments)
                result.success(null)
            }
            "navigationIndexChanged" -> {
                pendingNavigationIndex = null
                selectedIndex = (call.arguments as? Number)?.toInt() ?: 0
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun updateLocalSettings(transform: (AndroidNativeSettings) -> AndroidNativeSettings) {
        runOnMain {
            val next = snapshot.copy(settings = transform(snapshot.settings))
            hasReceivedSnapshot = true
            snapshot = next
            onSnapshotChanged(next)
        }
    }

    private fun applySnapshot(value: Any?) {
        runOnMain {
            val incoming = AndroidNativeSnapshot.from(value)
            val pendingIndex = pendingNavigationIndex
            val next =
                if (
                    pendingIndex != null &&
                    incoming.navigationIndex != pendingIndex &&
                    SystemClock.uptimeMillis() - pendingNavigationSinceMillis < 2500L
                ) {
                    incoming.copy(navigationIndex = pendingIndex)
                } else {
                    if (pendingIndex != null) {
                        pendingNavigationIndex = null
                    }
                    incoming
                }
            hasReceivedSnapshot = true
            snapshot = next
            selectedIndex = next.navigationIndex
            onSnapshotChanged(next)
        }
    }

    private fun runOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }
}
