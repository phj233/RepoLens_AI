package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.Role
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
import kotlin.math.abs

@Composable
internal fun KyantGlassToggleRow(
    label: String,
    selected: Boolean,
    backdrop: Backdrop,
    modifier: Modifier = Modifier.fillMaxWidth(),
    subtitle: String? = null,
    enabledText: String = "ON",
    disabledText: String = "OFF",
    onChanged: (Boolean) -> Unit,
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
                    blur(1.5f.dp.toPx())
                    lens(
                        refractionHeight = 3f.dp.toPx(),
                        refractionAmount = 7f.dp.toPx(),
                        chromaticAberration = selected,
                    )
                },
                highlight = { Highlight.Default.copy(alpha = if (selected) 0.30f else 0.18f) },
                shadow = { Shadow(alpha = if (selected) 0.10f else 0.04f) },
                innerShadow = { InnerShadow(radius = 3f.dp, alpha = if (selected) 0.18f else 0.08f) },
                onDrawSurface = {
                    if (selected) {
                        drawRect(RepoLensAndroidTokens.accent.copy(alpha = 0.16f), blendMode = BlendMode.Hue)
                        drawRect(RepoLensAndroidTokens.accentSoft.copy(alpha = 0.10f))
                    }
                    drawRect(RepoLensAndroidTokens.panel.copy(alpha = if (selected) 0.24f else 0.20f))
                },
            )
            .clickable(role = Role.Switch) { onChanged(!selected) }
            .padding(horizontal = 12.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
            AppText(label, RepoLensAndroidType.bodyStrong(), maxLines = 1)
            if (!subtitle.isNullOrBlank()) {
                AppText(subtitle, RepoLensAndroidType.caption(), maxLines = 2)
            }
        }
        Spacer(Modifier.width(10.dp))
        KyantLiquidSwitch(
            selected = selected,
            backdrop = resolvedBackdrop,
            onChanged = onChanged,
        )
    }
}

@Composable
internal fun KyantLiquidSwitch(
    selected: Boolean,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
    onChanged: (Boolean) -> Unit,
) {
    val sourceBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    var dragging by remember { mutableStateOf(false) }
    var pressed by remember { mutableStateOf(false) }
    var dragTensionTarget by remember { mutableStateOf(0f) }
    var dragProgress by remember { mutableStateOf(if (selected) 1f else 0f) }
    val targetProgress = if (dragging) {
        dragProgress
    } else if (selected) {
        1f
    } else {
        0f
    }
    val progress by animateFloatAsState(
        targetValue = targetProgress,
        animationSpec = spring(0.75f, 650f, 0.001f),
        label = "KyantLiquidSwitchProgress",
    )
    val pressProgress by animateFloatAsState(
        targetValue = if (pressed) 1f else 0f,
        animationSpec = spring(0.65f, 850f, 0.001f),
        label = "KyantLiquidSwitchPress",
    )
    val dragTension by animateFloatAsState(
        targetValue = dragTensionTarget,
        animationSpec = spring(0.50f, 620f, 0.001f),
        label = "KyantLiquidSwitchDragTension",
    )

    LaunchedEffect(selected, dragging) {
        if (!dragging) {
            dragProgress = if (selected) 1f else 0f
        }
    }

    BoxWithConstraints(
        modifier = modifier
            .width(60.dp)
            .height(36.dp),
    ) {
        val density = LocalDensity.current
        val switchTrackBackdrop = rememberLayerBackdrop()
        val switchThumbBackdrop = rememberCombinedBackdrop(sourceBackdrop, switchTrackBackdrop)
        val horizontalInsetPx = with(density) { 3.dp.toPx() }
        val thumbWidth = 34.dp
        val thumbHeight = 30.dp
        val thumbWidthPx = with(density) { thumbWidth.toPx() }
        val travelPx = (constraints.maxWidth.toFloat() - thumbWidthPx - horizontalInsetPx * 2f)
            .coerceAtLeast(1f)
        val trackShape = Capsule()
        val pressShape = Capsule()
        val thumbShape = Capsule()
        val solidThumbColor = if (RepoLensAndroidTokens.isDark) {
            Color(0xFFF3F6FA)
        } else {
            Color(0xFFFFFFFF)
        }
        val inactiveTrackColor = if (RepoLensAndroidTokens.isDark) {
            Color(0xFF343A42)
        } else {
            Color(0xFFDDE2E8)
        }

        Box(
            Modifier
                .fillMaxSize()
                .pointerInput(selected) {
                    awaitEachGesture {
                        val down = awaitFirstDown(requireUnconsumed = false)
                        val tapSlop = 4.dp.toPx()
                        var lastX = down.position.x
                        var totalDelta = 0f
                        pressed = true
                        dragging = true
                        dragTensionTarget = 0f
                        dragProgress = if (selected) 1f else 0f
                        down.consume()

                        while (true) {
                            val event = awaitPointerEvent()
                            val change = event.changes.firstOrNull { it.id == down.id }
                                ?: event.changes.firstOrNull()
                                ?: continue
                            val deltaX = change.position.x - lastX
                            lastX = change.position.x
                            if (change.pressed) {
                                if (deltaX != 0f) {
                                    totalDelta += deltaX
                                    dragTensionTarget = (abs(deltaX) / travelPx * 5.5f)
                                        .coerceIn(0f, 1f)
                                    dragProgress = (dragProgress + deltaX / travelPx)
                                        .coerceIn(0f, 1f)
                                    change.consume()
                                }
                            } else {
                                val nextSelected = if (abs(totalDelta) < tapSlop) {
                                    !selected
                                } else {
                                    dragProgress >= 0.5f
                                }
                                pressed = false
                                dragging = false
                                dragTensionTarget = 0f
                                onChanged(nextSelected)
                                change.consume()
                                break
                            }
                        }
                    }
                },
        ) {
            Box(
                Modifier
                    .fillMaxSize()
                    .layerBackdrop(switchTrackBackdrop)
                    .drawBackdrop(
                        backdrop = sourceBackdrop,
                        shape = { trackShape },
                        effects = {
                            vibrancy()
                            blur(1.5f.dp.toPx())
                            lens(
                                refractionHeight = 4f.dp.toPx() + 2f.dp.toPx() * progress,
                                refractionAmount = 7f.dp.toPx() + 9f.dp.toPx() * progress,
                                chromaticAberration = selected || dragging,
                            )
                        },
                        highlight = { Highlight.Default.copy(alpha = 0.20f + 0.16f * progress) },
                        shadow = { Shadow(alpha = 0.04f + 0.07f * progress) },
                        innerShadow = { InnerShadow(radius = 4f.dp, alpha = 0.10f + 0.14f * progress) },
                        onDrawSurface = {
                            drawRect(
                                inactiveTrackColor.copy(
                                    alpha = (0.50f * (1f - progress) + 0.08f).coerceIn(0f, 0.50f),
                                ),
                            )
                            if (progress > 0f) {
                                drawRect(RepoLensAndroidTokens.accent.copy(alpha = 0.14f + 0.24f * progress), blendMode = BlendMode.Hue)
                                drawRect(RepoLensAndroidTokens.accent.copy(alpha = 0.06f + 0.14f * progress))
                            }
                            drawRect(RepoLensAndroidTokens.panel.copy(alpha = 0.12f - 0.04f * progress))
                        },
                    ),
            )
            Box(
                Modifier
                    .size(width = 38.dp, height = 34.dp)
                    .graphicsLayer {
                        alpha = (0.02f + 0.62f * pressProgress + 0.18f * dragTension)
                            .coerceIn(0f, 1f)
                        translationX = horizontalInsetPx + travelPx * progress - 2.dp.toPx()
                        translationY = 1.dp.toPx()
                        scaleX = 1f + 0.06f * pressProgress + 0.04f * dragTension
                        scaleY = 1f + 0.02f * pressProgress - 0.004f * dragTension
                    }
                    .drawBackdrop(
                        backdrop = switchThumbBackdrop,
                        shape = { pressShape },
                        effects = {
                            vibrancy()
                            blur((0.10f + 0.10f * pressProgress + 0.04f * dragTension).dp.toPx())
                            lens(
                                refractionHeight = (10f + 10f * pressProgress + 5f * dragTension).dp.toPx(),
                                refractionAmount = (24f + 28f * pressProgress + 12f * dragTension).dp.toPx(),
                                chromaticAberration = pressed || dragging || dragTension > 0.04f,
                            )
                        },
                        highlight = {
                            Highlight.Default.copy(alpha = 0.16f + 0.36f * pressProgress + 0.14f * dragTension)
                        },
                        shadow = {
                            Shadow(alpha = 0.010f + 0.020f * pressProgress + 0.014f * dragTension)
                        },
                        innerShadow = {
                            InnerShadow(
                                radius = 2f.dp + 5f.dp * pressProgress + 2f.dp * dragTension,
                                alpha = 0.035f + 0.18f * pressProgress + 0.08f * dragTension,
                            )
                        },
                        layerBlock = {
                            scaleX = 1f + 0.05f * pressProgress + 0.035f * dragTension
                            scaleY = 1f + 0.012f * pressProgress
                        },
                        onDrawSurface = {
                            drawRect(
                                RepoLensAndroidTokens.panel.copy(
                                    alpha = 0.002f + 0.003f * pressProgress + 0.002f * dragTension,
                                ),
                            )
                            drawRect(
                                RepoLensAndroidTokens.accentSoft.copy(
                                    alpha = 0.008f + 0.018f * pressProgress + 0.012f * dragTension,
                                ),
                                blendMode = BlendMode.Hue,
                            )
                            drawRect(
                                RepoLensAndroidTokens.accent.copy(
                                    alpha = 0.004f + 0.010f * progress + 0.012f * pressProgress + 0.010f * dragTension,
                                ),
                                blendMode = BlendMode.Hue,
                            )
                        },
                    ),
            )
            Box(
                Modifier
                    .size(width = thumbWidth, height = thumbHeight)
                    .graphicsLayer {
                        translationX = horizontalInsetPx + travelPx * progress
                        translationY = 3.dp.toPx()
                        scaleX = 1f + 0.045f * pressProgress + 0.04f * dragTension
                        scaleY = 1f + 0.016f * pressProgress - 0.004f * dragTension + 0.006f * progress
                    }
                    .drawBackdrop(
                        backdrop = switchThumbBackdrop,
                        shape = { thumbShape },
                        effects = {
                            vibrancy()
                            blur((0.18f + 0.12f * pressProgress + 0.08f * dragTension).dp.toPx())
                            lens(
                                refractionHeight = (8f + 8f * pressProgress + 5f * dragTension).dp.toPx(),
                                refractionAmount = (18f + 20f * pressProgress + 14f * dragTension).dp.toPx(),
                                chromaticAberration = selected || dragging || pressed || dragTension > 0.05f,
                            )
                        },
                        highlight = {
                            Highlight.Default.copy(alpha = 0.28f + 0.46f * pressProgress + 0.18f * dragTension)
                        },
                        shadow = {
                            Shadow(alpha = 0.025f + 0.030f * progress + 0.055f * pressProgress + 0.030f * dragTension)
                        },
                        innerShadow = {
                            InnerShadow(
                                radius = 2f.dp + 7f.dp * pressProgress + 3f.dp * dragTension,
                                alpha = 0.07f + 0.28f * pressProgress + 0.10f * dragTension,
                            )
                        },
                        layerBlock = {
                            scaleX = 1f + 0.04f * pressProgress + 0.032f * dragTension
                            scaleY = 1f + 0.010f * pressProgress
                        },
                        onDrawSurface = {
                            drawRect(
                                solidThumbColor.copy(
                                    alpha = (0.94f * (1f - pressProgress)).coerceIn(0f, 0.94f),
                                ),
                            )
                            drawRect(
                                RepoLensAndroidTokens.panel.copy(
                                    alpha = 0.004f + 0.006f * pressProgress + 0.004f * dragTension,
                                ),
                            )
                            drawRect(
                                RepoLensAndroidTokens.accentSoft.copy(
                                    alpha = 0.010f + 0.020f * pressProgress + 0.014f * dragTension,
                                ),
                                blendMode = BlendMode.Hue,
                            )
                            if (progress > 0f) {
                                drawRect(
                                    RepoLensAndroidTokens.accent.copy(
                                        alpha = 0.006f + 0.012f * progress + 0.014f * pressProgress + 0.012f * dragTension,
                                    ),
                                    blendMode = BlendMode.Hue,
                                )
                            }
                        },
                    ),
            )
        }
    }
}
