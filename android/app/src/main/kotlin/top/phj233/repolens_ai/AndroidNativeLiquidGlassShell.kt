package top.phj233.repolens_ai

import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Analytics
import androidx.compose.material.icons.outlined.FileDownload
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.fragment.app.FragmentActivity
import com.kyant.backdrop.Backdrop
import com.kyant.backdrop.backdrops.layerBackdrop
import com.kyant.backdrop.backdrops.rememberCombinedBackdrop
import com.kyant.backdrop.backdrops.rememberLayerBackdrop
import com.kyant.backdrop.drawBackdrop
import com.kyant.backdrop.effects.blur
import com.kyant.backdrop.effects.lens
import com.kyant.backdrop.effects.vibrancy
import com.kyant.backdrop.highlight.Highlight
import com.kyant.backdrop.shadow.InnerShadow
import com.kyant.backdrop.shadow.Shadow
import com.kyant.shapes.Capsule
import com.kyant.shapes.RoundedRectangle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AndroidNativeLiquidGlassShell(
    private val activity: FragmentActivity,
    flutterEngine: FlutterEngine,
) {
    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "repolens.ai/native_shell",
    )
    private val shellState = AndroidNativeShellState(
        channel = channel,
        onSnapshotChanged = ::updateVisibility,
    )
    private val composeView = ComposeView(activity).apply {
        setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
        setBackgroundColor(android.graphics.Color.TRANSPARENT)
        isClickable = true
        isFocusable = true
        importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_AUTO
        elevation = 24f
    }
    private var flutterView: View? = null

    fun install() {
        activity.window.decorView.attachShellAndroidXViewTreeOwners(activity)
        composeView.attachShellAndroidXViewTreeOwners(activity)
        composeView.setContent {
            RepoLensAndroidNativeShell(shellState = shellState)
        }
        activity.addContentView(
            composeView,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )
        composeView.bringToFront()
        composeView.post {
            flutterView = activity.window.decorView.findFlutterView()
            updateVisibility(shellState.snapshot)
        }
        updateVisibility(shellState.snapshot)
        scheduleStateRefresh()
    }

    private fun updateVisibility(snapshot: AndroidNativeSnapshot) {
        val nativeVisible = snapshot.settings.visualStyle == "liquidGlass"
        composeView.visibility = if (nativeVisible) View.VISIBLE else View.GONE
        if (nativeVisible) {
            composeView.bringToFront()
        }
        val flutter = flutterView ?: activity.window.decorView.findFlutterView().also {
            flutterView = it
        }
        flutter?.visibility = View.VISIBLE
        flutter?.alpha = if (nativeVisible) 0f else 1f
    }

    private fun scheduleStateRefresh(attempt: Int = 0) {
        val delayMillis = if (attempt == 0) 0L else 450L
        composeView.postDelayed(
            {
                shellState.refresh()
                if (
                    attempt < 80 &&
                    (!shellState.hasReceivedSnapshot || shellState.snapshot.isBootstrapping)
                ) {
                    scheduleStateRefresh(attempt + 1)
                }
            },
            delayMillis,
        )
    }
}

private fun View.findFlutterView(): View? {
    if (this is FlutterView) {
        return this
    }
    val group = this as? ViewGroup ?: return null
    for (index in 0 until group.childCount) {
        val found = group.getChildAt(index).findFlutterView()
        if (found != null) {
            return found
        }
    }
    return null
}
