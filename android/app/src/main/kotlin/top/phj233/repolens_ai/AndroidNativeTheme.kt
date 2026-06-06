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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal object RepoLensAndroidTokens {
    var isDark by mutableStateOf(false)
        private set
    var background by mutableStateOf(Color(0xFFFFFFFF))
        private set
    var panel by mutableStateOf(Color(0xFFFAFAFA))
        private set
    var ink by mutableStateOf(Color(0xFF151A20))
        private set
    var muted by mutableStateOf(Color(0xFF68717A))
        private set
    var accent by mutableStateOf(Color(0xFF0088FF))
        private set
    var accentSoft by mutableStateOf(Color(0x330088FF))
        private set
    var onAccent by mutableStateOf(Color(0xFFF7FBFF))
        private set
    var danger by mutableStateOf(Color(0xFFB3261E))
        private set
    var warning by mutableStateOf(Color(0xFFC98512))
        private set
    var info by mutableStateOf(Color(0xFF2F6FBC))
        private set
    var success by mutableStateOf(Color(0xFF2F7D5F))
        private set
    val error: Color
        get() = danger

    fun configure(isDark: Boolean, backgroundOverride: String, themeColor: String) {
        this.isDark = isDark
        val configuredAccent = parseColor(themeColor)
        background = parseColor(backgroundOverride) ?: if (isDark) {
            Color(0xFF000000)
        } else {
            Color(0xFFFFFFFF)
        }
        panel = if (isDark) Color(0xFF171A1F) else Color(0xFFFAFAFA)
        ink = if (isDark) Color(0xFFEAF0F4) else Color(0xFF151A20)
        muted = if (isDark) Color(0xFFA8B1BA) else Color(0xFF68717A)
        accent = configuredAccent ?: if (isDark) Color(0xFF66B7FF) else Color(0xFF0088FF)
        accentSoft = accent.copy(alpha = if (isDark) 0.24f else 0.20f)
        onAccent = if (isDark) Color(0xFF07111C) else Color(0xFFF7FBFF)
        danger = if (isDark) Color(0xFFFFB4AB) else Color(0xFFB3261E)
        warning = if (isDark) Color(0xFFFFCF77) else Color(0xFFC98512)
        info = if (isDark) Color(0xFF9FC9FF) else Color(0xFF2F6FBC)
        success = if (isDark) Color(0xFF90D5A8) else Color(0xFF2F7D5F)
    }

    private fun parseColor(value: String): Color? {
        val cleaned = value.trim().removePrefix("#")
        if (cleaned.isEmpty()) return null
        val parsed = cleaned.toLongOrNull(16) ?: return null
        return when (cleaned.length) {
            6 -> Color(0xFF000000L or parsed)
            8 -> Color(parsed)
            else -> null
        }
    }
}

internal object RepoLensAndroidType {
    fun pageTitle() = TextStyle(
        color = RepoLensAndroidTokens.ink,
        fontSize = 25.sp,
        lineHeight = 30.sp,
        fontWeight = FontWeight.SemiBold,
    )

    fun headline() = TextStyle(
        color = RepoLensAndroidTokens.ink,
        fontSize = 21.sp,
        lineHeight = 26.sp,
        fontWeight = FontWeight.SemiBold,
    )

    fun title() = TextStyle(
        color = RepoLensAndroidTokens.ink,
        fontSize = 17.sp,
        lineHeight = 22.sp,
        fontWeight = FontWeight.SemiBold,
    )

    fun body() = TextStyle(
        color = RepoLensAndroidTokens.ink,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        fontWeight = FontWeight.Normal,
    )

    fun bodyStrong() = body().copy(fontWeight = FontWeight.SemiBold)
    fun bodyMuted() = body().copy(color = RepoLensAndroidTokens.muted)
    fun caption() = body().copy(color = RepoLensAndroidTokens.muted, fontSize = 12.sp, lineHeight = 16.sp)
    fun button() = body().copy(fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
    fun chip() = caption().copy(color = RepoLensAndroidTokens.accent, fontWeight = FontWeight.SemiBold)
    fun navLabel() = caption().copy(fontSize = 10.sp, lineHeight = 12.sp, fontWeight = FontWeight.SemiBold)
}
