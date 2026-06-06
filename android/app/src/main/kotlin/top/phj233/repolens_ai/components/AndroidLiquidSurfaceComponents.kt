package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.unit.dp
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

@Composable
internal fun KyantGlassPanel(
    backdrop: Backdrop,
    modifier: Modifier = Modifier.fillMaxWidth(),
    cornerRadius: Float = 26f,
    surfaceAlpha: Float = 0.58f,
    contentPadding: Float = 16f,
    selectMenuSamplesPanelContent: Boolean = false,
    content: @Composable () -> Unit,
) {
    val sourceBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    val parentSelectMenuBackdrop = LocalAndroidSelectMenuBackdrop.current ?: sourceBackdrop
    val panelBackdrop = rememberLayerBackdrop()
    val childBackdrop = rememberCombinedBackdrop(sourceBackdrop, panelBackdrop)
    val panelContentBackdrop = rememberLayerBackdrop()
    val panelSelfBackdrop = rememberCombinedBackdrop(childBackdrop, panelContentBackdrop)
    val combinedSelectMenuBackdrop = rememberCombinedBackdrop(parentSelectMenuBackdrop, panelSelfBackdrop)
    val selectMenuBackdrop =
        if (selectMenuSamplesPanelContent) combinedSelectMenuBackdrop else parentSelectMenuBackdrop
    val shape = rememberKyantShape(cornerRadius)
    Box(
        modifier,
    ) {
        Box(
            Modifier
                .matchParentSize()
                .layerBackdrop(panelBackdrop)
                .drawBackdrop(
                    backdrop = sourceBackdrop,
                    shape = { shape },
                    effects = {
                        vibrancy()
                        blur(4f.dp.toPx())
                        lens(
                            refractionHeight = 6f.dp.toPx(),
                            refractionAmount = 12f.dp.toPx(),
                            chromaticAberration = false,
                        )
                    },
                    highlight = { Highlight.Default.copy(alpha = 0.26f) },
                    shadow = { Shadow(alpha = 0.10f) },
                    innerShadow = { InnerShadow(radius = 5f.dp, alpha = 0.16f) },
                    onDrawSurface = {
                        drawRect(RepoLensAndroidTokens.accentSoft, blendMode = BlendMode.Hue)
                        drawRect(RepoLensAndroidTokens.panel.copy(alpha = surfaceAlpha))
                    },
                ),
        )
        Box(
            Modifier
                .layerBackdrop(panelContentBackdrop)
                .padding(contentPadding.dp),
        ) {
            CompositionLocalProvider(
                LocalAndroidGlassBackdrop provides childBackdrop,
                LocalAndroidSelectMenuBackdrop provides selectMenuBackdrop,
            ) {
                content()
            }
        }
    }
}

@Composable
internal fun KyantGlassActionRow(
    title: String,
    subtitle: String,
    actionText: String,
    backdrop: Backdrop,
    modifier: Modifier = Modifier.fillMaxWidth(),
    icon: ImageVector? = null,
    prominent: Boolean = false,
    onClick: () -> Unit,
) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    val rowShape = rememberKyantShape(20f)
    Row(
        modifier
            .drawBackdrop(
                backdrop = resolvedBackdrop,
                shape = { rowShape },
                effects = {
                    vibrancy()
                    blur(1.25f.dp.toPx())
                    lens(
                        refractionHeight = 3f.dp.toPx(),
                        refractionAmount = 6f.dp.toPx(),
                        chromaticAberration = prominent,
                    )
                },
                highlight = { Highlight.Default.copy(alpha = 0.18f) },
                innerShadow = { InnerShadow(radius = 3f.dp, alpha = 0.08f) },
                onDrawSurface = {
                    drawRect(RepoLensAndroidTokens.panel.copy(alpha = 0.22f))
                },
            )
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) {
            Image(
                painter = rememberVectorPainter(icon),
                contentDescription = title,
                colorFilter = ColorFilter.tint(RepoLensAndroidTokens.accent),
                modifier = Modifier.size(21.dp),
            )
            Spacer(Modifier.width(10.dp))
        }
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            AppText(title, RepoLensAndroidType.bodyStrong(), maxLines = 1)
            AppText(subtitle, RepoLensAndroidType.caption(), maxLines = 1)
        }
        Spacer(Modifier.width(10.dp))
        KyantGlassButton(
            text = actionText,
            backdrop = resolvedBackdrop,
            prominent = prominent,
            compact = true,
            onClick = onClick,
        )
    }
}

@Composable
internal fun KyantGlassStat(
    label: String,
    value: String,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
) {
    KyantGlassPanel(backdrop = backdrop, modifier = modifier, cornerRadius = 24f, contentPadding = 14f) {
        Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
            AppText(value, RepoLensAndroidType.headline())
            AppText(label, RepoLensAndroidType.caption(), maxLines = 1)
        }
    }
}

@Composable
internal fun rememberKyantShape(cornerRadius: Float): Shape {
    return if (cornerRadius >= 30f) {
        Capsule()
    } else {
        RoundedRectangle(cornerRadius.dp)
    }
}
