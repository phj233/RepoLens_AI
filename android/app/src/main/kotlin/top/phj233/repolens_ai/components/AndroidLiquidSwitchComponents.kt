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
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import com.kyant.backdrop.Backdrop
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
    val rowShape = rememberKyantShape(20f)
    Row(
        modifier
            .drawBackdrop(
                backdrop = backdrop,
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
                        drawRect(RepoLensAndroidPalette.accent.copy(alpha = 0.10f), blendMode = BlendMode.Hue)
                    }
                    drawRect(RepoLensAndroidPalette.panel.copy(alpha = if (selected) 0.28f else 0.22f))
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
            backdrop = backdrop,
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
            .width(62.dp)
            .height(36.dp),
    ) {
        val density = LocalDensity.current
        val horizontalInsetPx = with(density) { 3.dp.toPx() }
        val thumbSizePx = with(density) { 30.dp.toPx() }
        val travelPx = (constraints.maxWidth.toFloat() - thumbSizePx - horizontalInsetPx * 2f)
            .coerceAtLeast(1f)
        val trackShape = Capsule()

        Box(
            Modifier
                .fillMaxSize()
                .drawBackdrop(
                    backdrop = backdrop,
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
                        if (progress > 0f) {
                            drawRect(RepoLensAndroidPalette.accent.copy(alpha = 0.10f + 0.18f * progress), blendMode = BlendMode.Hue)
                            drawRect(RepoLensAndroidPalette.accent.copy(alpha = 0.04f + 0.10f * progress))
                        }
                        drawRect(RepoLensAndroidPalette.panel.copy(alpha = 0.26f - 0.07f * progress))
                    },
                )
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
                    .size(30.dp)
                    .graphicsLayer {
                        translationX = horizontalInsetPx + travelPx * progress
                        translationY = 3.dp.toPx()
                        scaleX = 1f + 0.10f * pressProgress + 0.18f * dragTension
                        scaleY = 1f + 0.10f * pressProgress - 0.05f * dragTension + 0.02f * progress
                    }
                    .drawBackdrop(
                        backdrop = backdrop,
                        shape = { Capsule() },
                        effects = {
                            vibrancy()
                            blur((0.8f + 0.45f * pressProgress + 0.22f * dragTension).dp.toPx())
                            lens(
                                refractionHeight = (7f + 5f * pressProgress + 4f * dragTension).dp.toPx(),
                                refractionAmount = (15f + 13f * pressProgress + 12f * dragTension).dp.toPx(),
                                chromaticAberration = selected || dragging || pressed || dragTension > 0.05f,
                            )
                        },
                        highlight = {
                            Highlight.Default.copy(alpha = 0.46f + 0.30f * pressProgress + 0.16f * dragTension)
                        },
                        shadow = {
                            Shadow(alpha = 0.18f + 0.10f * progress + 0.20f * pressProgress + 0.12f * dragTension)
                        },
                        innerShadow = {
                            InnerShadow(
                                radius = 3f.dp + 5f.dp * pressProgress + 3f.dp * dragTension,
                                alpha = 0.16f + 0.26f * pressProgress + 0.14f * dragTension,
                            )
                        },
                        layerBlock = {
                            scaleX = 1f + 0.18f * pressProgress + 0.22f * dragTension
                            scaleY = 1f + 0.18f * pressProgress - 0.08f * dragTension
                        },
                        onDrawSurface = {
                            drawRect(
                                RepoLensAndroidPalette.panel.copy(
                                    alpha = 0.030f + 0.035f * pressProgress + 0.025f * dragTension,
                                ),
                            )
                            drawRect(
                                RepoLensAndroidPalette.accentSoft.copy(
                                    alpha = 0.018f + 0.025f * pressProgress + 0.020f * dragTension,
                                ),
                                blendMode = BlendMode.Hue,
                            )
                            if (progress > 0f) {
                                drawRect(
                                    RepoLensAndroidPalette.accent.copy(
                                        alpha = 0.014f + 0.030f * progress + 0.026f * pressProgress + 0.026f * dragTension,
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
