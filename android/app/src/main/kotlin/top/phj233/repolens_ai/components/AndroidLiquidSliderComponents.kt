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
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
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
            KyantSliderValuePill(value = displayedValue, backdrop = backdrop)
        }
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
        ) {
            val density = LocalDensity.current
            val thumbSize = 34.dp
            val thumbSizePx = with(density) { thumbSize.toPx() }
            val travelPx = (constraints.maxWidth.toFloat() - thumbSizePx).coerceAtLeast(1f)
            val thumbX = travelPx * progress
            val trackProgress = ((thumbX + thumbSizePx / 2f) / constraints.maxWidth.toFloat())
                .coerceIn(0f, 1f)

            Box(
                Modifier
                    .fillMaxSize()
                    .pointerInput(valueRange, safeStep, thumbSizePx) {
                        awaitPointerSliderGesture(
                            range = valueRange,
                            step = safeStep,
                            thumbSizePx = thumbSizePx,
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
                KyantSliderTrack(
                    progress = trackProgress,
                    pressed = pressed,
                    backdrop = backdrop,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(18.dp),
                )
                Box(
                    Modifier
                        .size(thumbSize)
                        .offset {
                            IntOffset(
                                x = (thumbX + direction * stretch * 4.dp.toPx()).roundToInt(),
                                y = 0,
                            )
                        }
                        .align(Alignment.CenterStart)
                        .graphicsLayer {
                            scaleX = 1f + 0.10f * pressProgress + 0.30f * stretch
                            scaleY = 1f + 0.10f * pressProgress - 0.10f * stretch
                            rotationZ = direction * stretch * 3.2f
                        }
                        .drawBackdrop(
                            backdrop = backdrop,
                            shape = { Capsule() },
                            effects = {
                                vibrancy()
                                blur((0.9f + 0.50f * pressProgress + 0.28f * stretch).dp.toPx())
                                lens(
                                    refractionHeight = (8f + 6f * pressProgress + 6f * stretch).dp.toPx(),
                                    refractionAmount = (16f + 15f * pressProgress + 16f * stretch).dp.toPx(),
                                    chromaticAberration = pressed || dragging || stretch > 0.05f,
                                )
                            },
                            highlight = {
                                Highlight.Default.copy(alpha = 0.42f + 0.34f * pressProgress + 0.18f * stretch)
                            },
                            shadow = {
                                Shadow(alpha = 0.12f + 0.20f * pressProgress + 0.10f * stretch)
                            },
                            innerShadow = {
                                InnerShadow(
                                    radius = 3f.dp + 5f.dp * pressProgress + 4f.dp * stretch,
                                    alpha = 0.14f + 0.26f * pressProgress + 0.13f * stretch,
                                )
                            },
                            layerBlock = {
                                scaleX = 1f + 0.16f * pressProgress + 0.22f * stretch
                                scaleY = 1f + 0.14f * pressProgress - 0.08f * stretch
                            },
                            onDrawSurface = {
                                drawRect(
                                    RepoLensAndroidPalette.panel.copy(
                                        alpha = 0.025f + 0.045f * pressProgress + 0.024f * stretch,
                                    ),
                                )
                                drawRect(
                                    RepoLensAndroidPalette.accentSoft.copy(
                                        alpha = 0.018f + 0.026f * pressProgress + 0.026f * stretch,
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
    Box(modifier = modifier) {
        Box(
            Modifier
                .fillMaxSize()
                .drawBackdrop(
                    backdrop = backdrop,
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
                        drawRect(RepoLensAndroidPalette.panel.copy(alpha = if (pressed) 0.24f else 0.20f))
                    },
                ),
        )
        Box(
            Modifier
                .fillMaxWidth(progress.coerceIn(0f, 1f))
                .fillMaxSize()
                .drawBackdrop(
                    backdrop = backdrop,
                    shape = { Capsule() },
                    effects = {
                        vibrancy()
                        blur(1.0f.dp.toPx())
                        lens(4f.dp.toPx(), 9f.dp.toPx(), chromaticAberration = pressed)
                    },
                    highlight = { Highlight.Default.copy(alpha = 0.20f + 0.08f * progress) },
                    onDrawSurface = {
                        drawRect(RepoLensAndroidPalette.accent.copy(alpha = 0.08f + 0.11f * progress), blendMode = BlendMode.Hue)
                        drawRect(RepoLensAndroidPalette.accent.copy(alpha = 0.030f + 0.055f * progress))
                    },
                ),
        )
    }
}

@Composable
private fun KyantSliderValuePill(value: Int, backdrop: Backdrop) {
    Box(
        Modifier
            .drawBackdrop(
                backdrop = backdrop,
                shape = { Capsule() },
                effects = {
                    vibrancy()
                    blur(1.0f.dp.toPx())
                    lens(2.5f.dp.toPx(), 5f.dp.toPx(), chromaticAberration = false)
                },
                highlight = { Highlight.Default.copy(alpha = 0.16f) },
                innerShadow = { InnerShadow(radius = 2f.dp, alpha = 0.08f) },
                onDrawSurface = {
                    drawRect(RepoLensAndroidPalette.panel.copy(alpha = 0.22f))
                    drawRect(RepoLensAndroidPalette.accentSoft.copy(alpha = 0.18f), blendMode = BlendMode.Hue)
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
