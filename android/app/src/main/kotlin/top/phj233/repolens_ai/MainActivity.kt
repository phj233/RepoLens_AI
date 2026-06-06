package top.phj233.repolens_ai

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.Window
import androidx.core.content.FileProvider
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    private var nativeShell: AndroidNativeLiquidGlassShell? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configureEdgeToEdge(window)
        window.decorView.attachAndroidXViewTreeOwners(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "repolens.ai/android_liquid_glass"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "capabilities" -> result.success(
                    mapOf(
                        "library" to "io.github.kyant0:backdrop:2.0.0",
                        "packageAvailable" to isBackdropLibraryAvailable(),
                        "androidSdk" to Build.VERSION.SDK_INT,
                        "renderEffectCapable" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S),
                        "lensCapable" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU),
                        "defaultStyle" to "liquidGlass",
                        "alternateStyle" to "jetpackMaterial3"
                    )
                )
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "repolens.ai/file_opener"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openFile" -> openFile(call.arguments, result)
                else -> result.notImplemented()
            }
        }

        nativeShell = AndroidNativeLiquidGlassShell(this, flutterEngine).also {
            it.install()
        }
    }

    private fun openFile(arguments: Any?, result: MethodChannel.Result) {
        val path = (arguments as? Map<*, *>)?.get("path") as? String
        if (path.isNullOrBlank()) {
            result.error("missing_path", "File path is required.", null)
            return
        }

        val file = File(path)
        if (!file.exists()) {
            result.error("missing_file", "File does not exist.", path)
            return
        }

        val uri = FileProvider.getUriForFile(
            this,
            "$packageName.fileProvider",
            file
        )
        val viewIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeTypeFor(file.name))
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        val chooser = Intent.createChooser(viewIntent, null).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        try {
            startActivity(chooser)
            result.success(null)
        } catch (error: ActivityNotFoundException) {
            result.error("activity_not_found", "No app can open this file.", path)
        } catch (error: Exception) {
            result.error("open_failed", error.message, path)
        }
    }

    private fun isBackdropLibraryAvailable(): Boolean {
        return runCatching {
            Class.forName("com.kyant.backdrop.backdrops.LayerBackdropKt")
        }.isSuccess
    }

    private fun configureEdgeToEdge(window: Window) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = android.graphics.Color.TRANSPARENT
            window.navigationBarColor = android.graphics.Color.TRANSPARENT
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            window.decorView.systemUiVisibility =
                android.view.View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                    android.view.View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                    android.view.View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        }
    }

    private fun mimeTypeFor(fileName: String): String {
        return when (fileName.substringAfterLast('.', "").lowercase()) {
            "json" -> "application/json"
            "csv" -> "text/csv"
            "md", "markdown" -> "text/markdown"
            "pdf" -> "application/pdf"
            "png" -> "image/png"
            "ts" -> "text/plain"
            else -> "*/*"
        }
    }
}

private fun View.attachAndroidXViewTreeOwners(activity: FragmentActivity) {
    setTag(androidx.lifecycle.runtime.R.id.view_tree_lifecycle_owner, activity)
    setTag(androidx.lifecycle.viewmodel.R.id.view_tree_view_model_store_owner, activity)
    setTag(androidx.savedstate.R.id.view_tree_saved_state_registry_owner, activity)
}
