package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
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
import androidx.compose.ui.unit.IntOffset
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
import kotlin.math.roundToInt
import kotlin.math.sign

@Composable
internal fun KyantGlassSlider(
    label: String,
    value: Int,
    valueRange: IntRange,
    step: Int,
    backdrop: Backdrop,
    modifier: Modifier = Modifier.fillMaxWidth(),
    onValueChange: (Int) -> Unit,
) {
    val sourceBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    val safeStep = step.coerceAtLeast(1)
    val safeValue = value.coerceIn(valueRange.first, valueRange.last)
    var liveValue by remember(label) { mutableIntStateOf(safeValue) }
    var pressed by remember { mutableStateOf(false) }
    var dragging by remember { mutableStateOf(false) }
    var stretchTarget by remember { mutableFloatStateOf(0f) }
    var directionTarget by remember { mutableFloatStateOf(0f) }

    LaunchedEffect(safeValue, dragging) {
        if (!dragging) {
            liveValue = safeValue
        }
    }

    val displayedValue = if (dragging) liveValue else safeValue
    val displayedProgress = sliderProgress(displayedValue, valueRange)
    val progress by animateFloatAsState(
        targetValue = displayedProgress,
        animationSpec = spring(0.78f, 720f, 0.001f),
        label = "KyantGlassSliderProgress",
    )
    val pressProgress by animateFloatAsState(
        targetValue = if (pressed) 1f else 0f,
        animationSpec = spring(0.58f, 780f, 0.001f),
        label = "KyantGlassSliderPress",
    )
    val stretch by animateFloatAsState(
        targetValue = stretchTarget,
        animationSpec = spring(0.44f, 620f, 0.001f),
        label = "KyantGlassSliderStretch",
    )
    val direction by animateFloatAsState(
        targetValue = directionTarget,
        animationSpec = spring(0.48f, 680f, 0.001f),
        label = "KyantGlassSliderDirection",
    )

    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(7.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            AppText(label, RepoLensAndroidType.caption(), modifier = Modifier.weight(1f), maxLines = 1)
            KyantSliderValuePill(value = displayedValue, backdrop = sourceBackdrop)
        }
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
        ) {
            val density = LocalDensity.current
            val thumbWidth = 38.dp
            val thumbHeight = 32.dp
            val thumbWidthPx = with(density) { thumbWidth.toPx() }
            val sliderTrackBackdrop = rememberLayerBackdrop()
            val sliderThumbBackdrop = rememberCombinedBackdrop(sourceBackdrop, sliderTrackBackdrop)
            val travelPx = (constraints.maxWidth.toFloat() - thumbWidthPx).coerceAtLeast(1f)
            val thumbX = travelPx * progress
            val thumbShape = Capsule()
            val solidThumbColor = if (RepoLensAndroidTokens.isDark) {
                Color(0xFFF3F6FA)
            } else {
                Color(0xFFFFFFFF)
            }
            val trackProgress = ((thumbX + thumbWidthPx / 2f) / constraints.maxWidth.toFloat())
                .coerceIn(0f, 1f)

            Box(
                Modifier
                    .fillMaxSize()
                    .pointerInput(valueRange, safeStep, thumbWidthPx) {
                        awaitPointerSliderGesture(
                            range = valueRange,
                            step = safeStep,
                            thumbSizePx = thumbWidthPx,
                            onPressed = { isPressed ->
                                pressed = isPressed
                                dragging = isPressed
                                if (!isPressed) {
                                    stretchTarget = 0f
                                    directionTarget = 0f
                                }
                            },
                            onDragPulse = { velocityPxPerMs, deltaX ->
                                if (abs(deltaX) > 0.05f) {
                                    directionTarget = sign(deltaX)
                                }
                                stretchTarget = (
                                    abs(velocityPxPerMs) * 0.080f +
                                        abs(deltaX) / travelPx * 2.25f
                                    ).coerceIn(0f, 0.62f)
                            },
                            onValueChange = { nextValue ->
                                liveValue = nextValue
                                if (nextValue != value) {
                                    onValueChange(nextValue)
                                }
                            },
                        )
                    },
                contentAlignment = Alignment.CenterStart,
            ) {
                Box(
                    Modifier
                        .fillMaxWidth()
                        .height(18.dp)
                        .align(Alignment.CenterStart)
                        .layerBackdrop(sliderTrackBackdrop),
                ) {
                    KyantSliderTrack(
                        progress = trackProgress,
                        pressed = pressed,
                        backdrop = sourceBackdrop,
                        modifier = Modifier.fillMaxSize(),
                    )
                }
                Box(
                    Modifier
                        .size(width = thumbWidth, height = thumbHeight)
                        .offset {
                            IntOffset(
                                x = (thumbX + direction * stretch * 4.dp.toPx()).roundToInt(),
                                y = 0,
                            )
                        }
                        .align(Alignment.CenterStart)
                        .graphicsLayer {
                            scaleX = 1f + 0.055f * pressProgress + 0.060f * stretch
                            scaleY = 1f + 0.018f * pressProgress - 0.010f * stretch
                            rotationZ = direction * stretch * 1.2f
                        }
                        .drawBackdrop(
                            backdrop = sliderThumbBackdrop,
                            shape = { thumbShape },
                            effects = {
                                vibrancy()
                                blur((0.18f + 0.14f * pressProgress + 0.08f * stretch).dp.toPx())
                                lens(
                                    refractionHeight = (10f + 8f * pressProgress + 7f * stretch).dp.toPx(),
                                    refractionAmount = (24f + 24f * pressProgress + 18f * stretch).dp.toPx(),
                                    chromaticAberration = pressed || dragging || stretch > 0.05f,
                                )
                            },
                            highlight = {
                                Highlight.Default.copy(alpha = 0.24f + 0.46f * pressProgress + 0.20f * stretch)
                            },
                            shadow = {
                                Shadow(alpha = 0.025f + 0.060f * pressProgress + 0.035f * stretch)
                            },
                            innerShadow = {
                                InnerShadow(
                                    radius = 2f.dp + 7f.dp * pressProgress + 4f.dp * stretch,
                                    alpha = 0.07f + 0.28f * pressProgress + 0.13f * stretch,
                                )
                            },
                            layerBlock = {
                                scaleX = 1f + 0.046f * pressProgress + 0.048f * stretch
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
                                        alpha = 0.003f + 0.006f * pressProgress + 0.004f * stretch,
                                    ),
                                )
                                drawRect(
                                    RepoLensAndroidTokens.accentSoft.copy(
                                        alpha = 0.010f + 0.020f * pressProgress + 0.018f * stretch,
                                    ),
                                    blendMode = BlendMode.Hue,
                                )
                                drawRect(
                                    RepoLensAndroidTokens.accent.copy(
                                        alpha = 0.004f + 0.012f * progress + 0.014f * pressProgress + 0.014f * stretch,
                                    ),
                                    blendMode = BlendMode.Hue,
                                )
                            },
                        ),
                )
            }
        }
    }
}

@Composable
private fun KyantSliderTrack(
    progress: Float,
    pressed: Boolean,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    Box(modifier = modifier) {
        Box(
            Modifier
                .fillMaxSize()
                .drawBackdrop(
                    backdrop = resolvedBackdrop,
                    shape = { Capsule() },
                    effects = {
                        vibrancy()
                        blur(1.4f.dp.toPx())
                        lens(
                            refractionHeight = (3.5f + if (pressed) 1.5f else 0f).dp.toPx(),
                            refractionAmount = (7f + if (pressed) 5f else 0f).dp.toPx(),
                            chromaticAberration = pressed,
                        )
                    },
                    highlight = { Highlight.Default.copy(alpha = if (pressed) 0.30f else 0.18f) },
                    shadow = { Shadow(alpha = if (pressed) 0.08f else 0.04f) },
                    innerShadow = { InnerShadow(radius = 3f.dp, alpha = if (pressed) 0.16f else 0.08f) },
                    onDrawSurface = {
                        drawRect(RepoLensAndroidTokens.accentSoft.copy(alpha = if (pressed) 0.12f else 0.08f), blendMode = BlendMode.Hue)
                        drawRect(RepoLensAndroidTokens.panel.copy(alpha = if (pressed) 0.20f else 0.17f))
                    },
                ),
        )
        Box(
            Modifier
                .fillMaxWidth(progress.coerceIn(0f, 1f))
                .fillMaxSize()
                .drawBackdrop(
                    backdrop = resolvedBackdrop,
                    shape = { Capsule() },
                    effects = {
                        vibrancy()
                        blur(1.0f.dp.toPx())
                        lens(4f.dp.toPx(), 9f.dp.toPx(), chromaticAberration = pressed)
                    },
                    highlight = { Highlight.Default.copy(alpha = 0.20f + 0.08f * progress) },
                    onDrawSurface = {
                        drawRect(RepoLensAndroidTokens.accent.copy(alpha = 0.14f + 0.18f * progress), blendMode = BlendMode.Hue)
                        drawRect(RepoLensAndroidTokens.accent.copy(alpha = 0.055f + 0.085f * progress))
                    },
                ),
        )
    }
}

@Composable
private fun KyantSliderValuePill(value: Int, backdrop: Backdrop) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    Box(
        Modifier
            .drawBackdrop(
                backdrop = resolvedBackdrop,
                shape = { Capsule() },
                effects = {
                    vibrancy()
                    blur(1.0f.dp.toPx())
                    lens(2.5f.dp.toPx(), 5f.dp.toPx(), chromaticAberration = false)
                },
                highlight = { Highlight.Default.copy(alpha = 0.16f) },
                innerShadow = { InnerShadow(radius = 2f.dp, alpha = 0.08f) },
                onDrawSurface = {
                    drawRect(RepoLensAndroidTokens.panel.copy(alpha = 0.18f))
                    drawRect(RepoLensAndroidTokens.accentSoft.copy(alpha = 0.26f), blendMode = BlendMode.Hue)
                    drawRect(RepoLensAndroidTokens.accent.copy(alpha = 0.040f))
                },
            )
            .padding(horizontal = 10.dp, vertical = 4.dp),
    ) {
        AppText(value.toString(), RepoLensAndroidType.chip(), maxLines = 1)
    }
}

private suspend fun androidx.compose.ui.input.pointer.PointerInputScope.awaitPointerSliderGesture(
    range: IntRange,
    step: Int,
    thumbSizePx: Float,
    onPressed: (Boolean) -> Unit,
    onDragPulse: (velocityPxPerMs: Float, deltaX: Float) -> Unit,
    onValueChange: (Int) -> Unit,
) {
    awaitEachGesture {
        val down = awaitFirstDown(requireUnconsumed = false)
        var lastX = down.position.x
        var lastTime = down.uptimeMillis
        var gestureValue = sliderValueAt(
            x = down.position.x,
            widthPx = size.width.toFloat(),
            thumbSizePx = thumbSizePx,
            range = range,
            step = step,
        )
        onPressed(true)
        onValueChange(gestureValue)
        down.consume()

        while (true) {
            val event = awaitPointerEvent()
            val change = event.changes.firstOrNull { it.id == down.id }
                ?: event.changes.firstOrNull()
                ?: continue
            if (change.pressed) {
                val deltaX = change.position.x - lastX
                val elapsedMs = (change.uptimeMillis - lastTime).coerceAtLeast(1L)
                val velocity = deltaX / elapsedMs.toFloat()
                val nextValue = sliderValueAt(
                    x = change.position.x,
                    widthPx = size.width.toFloat(),
                    thumbSizePx = thumbSizePx,
                    range = range,
                    step = step,
                )
                if (nextValue != gestureValue) {
                    gestureValue = nextValue
                    onValueChange(nextValue)
                }
                onDragPulse(velocity, deltaX)
                lastX = change.position.x
                lastTime = change.uptimeMillis
                change.consume()
            } else {
                onPressed(false)
                onDragPulse(0f, 0f)
                change.consume()
                break
            }
        }
    }
}

private fun sliderProgress(value: Int, range: IntRange): Float {
    val min = range.first
    val max = range.last
    val span = (max - min).coerceAtLeast(1)
    return ((value.coerceIn(min, max) - min).toFloat() / span.toFloat()).coerceIn(0f, 1f)
}

private fun sliderValueAt(
    x: Float,
    widthPx: Float,
    thumbSizePx: Float,
    range: IntRange,
    step: Int,
): Int {
    val travelPx = (widthPx - thumbSizePx).coerceAtLeast(1f)
    val progress = ((x - thumbSizePx / 2f) / travelPx).coerceIn(0f, 1f)
    val min = range.first
    val max = range.last
    val span = (max - min).coerceAtLeast(1)
    val raw = min + span * progress
    return (min + ((raw - min) / step).roundToInt() * step).coerceIn(min, max)
}
