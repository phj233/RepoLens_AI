package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import android.os.SystemClock
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.LocalIndication
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.isSpecified
import androidx.compose.ui.input.pointer.changedToUp
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.util.fastCoerceAtMost
import androidx.compose.ui.util.fastCoerceIn
import androidx.compose.ui.util.fastRoundToInt
import androidx.compose.ui.util.lerp
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
import kotlinx.coroutines.launch
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sign
import kotlin.math.sin
import kotlin.math.tanh

// Component structure adapted from Kyant0/AndroidLiquidGlass catalog samples.
// The library ships backdrop primitives; these app-level components keep the sample layer model.
@Composable
internal fun KyantCatalogLiquidButton(
    onClick: () -> Unit,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
    isInteractive: Boolean = true,
    tint: Color = Color.Unspecified,
    surfaceColor: Color = Color.Unspecified,
    heightDp: Float = 48f,
    horizontalPaddingDp: Float = 16f,
    content: @Composable RowScope.() -> Unit,
) {
    val animationScope = rememberCoroutineScope()
    val pressProgress = remember { Animatable(0f) }
    val dragOffsetX = remember { Animatable(0f) }
    val dragOffsetY = remember { Animatable(0f) }

    Row(
        modifier
            .drawBackdrop(
                backdrop = backdrop,
                shape = { Capsule() },
                effects = {
                    vibrancy()
                    blur(2f.dp.toPx())
                    lens(12f.dp.toPx(), 24f.dp.toPx(), chromaticAberration = tint.isSpecified)
                },
                layerBlock = if (isInteractive) {
                    {
                        val width = size.width
                        val height = size.height
                        val progress = pressProgress.value
                        val scale = lerp(1f, 1f + 4f.dp.toPx() / height, progress)
                        val maxOffset = size.minDimension
                        val initialDerivative = 0.05f
                        val offset = Offset(dragOffsetX.value, dragOffsetY.value)

                        translationX = maxOffset * tanh(initialDerivative * offset.x / maxOffset)
                        translationY = maxOffset * tanh(initialDerivative * offset.y / maxOffset)

                        val maxDragScale = 4f.dp.toPx() / height
                        val offsetAngle = atan2(offset.y, offset.x)
                        scaleX =
                            scale +
                                maxDragScale * abs(cos(offsetAngle) * offset.x / size.maxDimension) *
                                (width / height).fastCoerceAtMost(1f)
                        scaleY =
                            scale +
                                maxDragScale * abs(sin(offsetAngle) * offset.y / size.maxDimension) *
                                (height / width).fastCoerceAtMost(1f)
                    }
                } else {
                    null
                },
                highlight = {
                    Highlight.Default.copy(alpha = 0.18f + 0.42f * pressProgress.value)
                },
                shadow = {
                    Shadow(alpha = 0.08f + 0.22f * pressProgress.value)
                },
                innerShadow = {
                    InnerShadow(radius = 6f.dp * pressProgress.value, alpha = 0.32f * pressProgress.value)
                },
                onDrawSurface = {
                    if (tint.isSpecified) {
                        drawRect(tint, blendMode = BlendMode.Hue)
                        drawRect(tint.copy(alpha = 0.54f + 0.16f * pressProgress.value))
                    }
                    if (surfaceColor.isSpecified) {
                        drawRect(surfaceColor)
                    }
                },
            )
            .clickable(
                interactionSource = null,
                indication = if (isInteractive) null else LocalIndication.current,
                role = Role.Button,
                onClick = onClick,
            )
            .then(
                if (isInteractive) {
                    Modifier.pointerLiquidPress(
                        onPressChanged = { pressed ->
                            animationScope.launch {
                                pressProgress.animateTo(
                                    if (pressed) 1f else 0f,
                                    spring(0.5f, 300f, 0.001f),
                                )
                            }
                            if (!pressed) {
                                animationScope.launch {
                                    launch { dragOffsetX.animateTo(0f, spring(0.5f, 300f, 0.001f)) }
                                    launch { dragOffsetY.animateTo(0f, spring(0.5f, 300f, 0.001f)) }
                                }
                            }
                        },
                        onDrag = { dragAmount ->
                            animationScope.launch {
                                dragOffsetX.snapTo(dragOffsetX.value + dragAmount.x)
                                dragOffsetY.snapTo(dragOffsetY.value + dragAmount.y)
                            }
                        },
                    )
                } else {
                    Modifier
                },
            )
            .height(heightDp.dp)
            .padding(horizontal = horizontalPaddingDp.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically,
        content = content,
    )
}

@Composable
internal fun KyantCatalogLiquidBottomTabs(
    selectedTabIndex: () -> Int,
    onTabSelected: (index: Int) -> Unit,
    backdrop: Backdrop,
    tabsCount: Int,
    modifier: Modifier = Modifier,
    content: @Composable RowScope.() -> Unit,
) {
    val isLightTheme = !RepoLensAndroidTokens.isDark
    val accentColor = RepoLensAndroidTokens.accent
    val transparentSurfaceColor =
        if (isLightTheme) Color.Black.copy(alpha = 0.018f)
        else Color.White.copy(alpha = 0.022f)
    val navContentBackdrop = rememberLayerBackdrop()
    BoxWithConstraints(
        modifier,
        contentAlignment = Alignment.CenterStart,
    ) {
        val density = LocalDensity.current
        val containerWidthPx = constraints.maxWidth.toFloat().coerceAtLeast(1f)
        val tabWidth = with(density) {
            ((containerWidthPx - 8f.dp.toPx()) / tabsCount).coerceAtLeast(1f)
        }
        val safeSelected = selectedTabIndex().coerceIn(0, tabsCount - 1)

        val pressProgress = remember { Animatable(0f) }
        var isDraggingTabs by remember { mutableStateOf(false) }
        var dragOffsetPx by remember { mutableFloatStateOf(0f) }
        var dragTabPosition by remember { mutableFloatStateOf(safeSelected.toFloat()) }
        var dragTensionTarget by remember { mutableFloatStateOf(0f) }
        var dragVelocityTarget by remember { mutableFloatStateOf(0f) }

        val selectedTabPosition by animateFloatAsState(
            targetValue = safeSelected.toFloat(),
            animationSpec = spring(1f, 1000f, 0.001f),
            label = "RepoLensBottomTabPosition",
        )
        val dragTension by animateFloatAsState(
            targetValue = dragTensionTarget,
            animationSpec = spring(0.74f, 720f, 0.001f),
            label = "RepoLensBottomDragTension",
        )
        val dragVelocity by animateFloatAsState(
            targetValue = dragVelocityTarget,
            animationSpec = spring(0.68f, 520f, 0.001f),
            label = "RepoLensBottomDragVelocity",
        )
        val shapeTension = if (isDraggingTabs) dragTensionTarget else dragTension
        val velocityStretch = if (isDraggingTabs) dragVelocityTarget else dragVelocity
        val activeTabPosition =
            if (isDraggingTabs) dragTabPosition else selectedTabPosition
        val activeOffsetPx = if (isDraggingTabs) dragOffsetPx else 0f
        val panelOffset = with(density) {
            val width = constraints.maxWidth.toFloat().coerceAtLeast(1f)
            val fraction = (activeOffsetPx / width).fastCoerceIn(-1f, 1f)
            4f.dp.toPx() * fraction.sign * EaseOut.transform(abs(fraction))
        }

        val isLtr = LocalLayoutDirection.current == LayoutDirection.Ltr
        val animationScope = rememberCoroutineScope()
        val horizontalInsetPx = with(density) { 4f.dp.toPx() }

        fun tabIndexForPosition(position: Offset): Int {
            val rawX =
                if (isLtr) {
                    position.x - horizontalInsetPx
                } else {
                    constraints.maxWidth.toFloat() - position.x - horizontalInsetPx
                }
            return (rawX / tabWidth).toInt().fastCoerceIn(0, tabsCount - 1)
        }

        LaunchedEffect(safeSelected, tabsCount, isDraggingTabs) {
            if (!isDraggingTabs) {
                dragTabPosition = safeSelected.toFloat()
                dragOffsetPx = 0f
                dragTensionTarget = 0f
                dragVelocityTarget = 0f
            }
        }

        Box(
            Modifier
                .height(64.dp)
                .fillMaxWidth()
                .then(
                    Modifier.pointerLiquidDrag(
                        dragStartThresholdPx = with(density) { 8.dp.toPx() },
                        onPressStarted = { position ->
                            isDraggingTabs = true
                            dragTabPosition = tabIndexForPosition(position).toFloat()
                            dragOffsetPx = 0f
                            dragTensionTarget = 0f
                        },
                        onPressChanged = { pressed ->
                            if (!pressed) {
                                dragOffsetPx = 0f
                                dragTensionTarget = 0f
                                dragVelocityTarget = 0f
                                isDraggingTabs = false
                            }
                            animationScope.launch {
                                pressProgress.animateTo(
                                    if (pressed) 1f else 0f,
                                    spring(1f, 1000f, 0.001f),
                                )
                            }
                        },
                        onDrag = { dragAmount, velocityX ->
                            val direction = if (isLtr) 1f else -1f
                            val nextOffset = dragOffsetPx + dragAmount.x
                            val velocityTension =
                                (tanh(abs(velocityX) / (tabWidth * 5.5f)) * 0.68f)
                                    .fastCoerceIn(0f, 0.68f)
                            val impulseTension =
                                (tanh(abs(dragAmount.x) / tabWidth * 7f) * 0.08f)
                                    .fastCoerceIn(0f, 0.08f)
                            val distanceTension =
                                (tanh(abs(nextOffset) / tabWidth * 1.1f) * 0.15f)
                                    .fastCoerceIn(0f, 0.15f)
                            dragTensionTarget =
                                (velocityTension + impulseTension + distanceTension)
                                    .fastCoerceIn(0f, 0.62f)
                            dragVelocityTarget =
                                (velocityX / (tabWidth * 6f))
                                    .fastCoerceIn(-0.32f, 0.32f) * direction
                            dragTabPosition =
                                (dragTabPosition + dragAmount.x / tabWidth * direction)
                                    .fastCoerceIn(0f, (tabsCount - 1).toFloat())
                            dragOffsetPx = nextOffset
                        },
                        onDragStopped = {
                            val targetIndex =
                                dragTabPosition.fastRoundToInt().fastCoerceIn(0, tabsCount - 1)
                            onTabSelected(targetIndex)
                            dragTabPosition = targetIndex.toFloat()
                            dragOffsetPx = 0f
                            dragTensionTarget = 0f
                            dragVelocityTarget = 0f
                        },
                        onTap = { position ->
                            onTabSelected(tabIndexForPosition(position))
                        },
                    )
                )
        ) {
            Row(
                Modifier
                    .graphicsLayer {
                        translationX = panelOffset
                    }
                    .layerBackdrop(navContentBackdrop)
                    .drawBackdrop(
                        backdrop = backdrop,
                        shape = { Capsule() },
                        effects = {
                            vibrancy()
                            blur(2.2f.dp.toPx())
                            lens(20f.dp.toPx(), 22f.dp.toPx(), chromaticAberration = true)
                        },
                        layerBlock = {
                            val progress = pressProgress.value
                            val scale = lerp(1f, 1f + 12f.dp.toPx() / size.width, progress)
                            scaleX = scale
                            scaleY = scale
                        },
                        highlight = { Highlight.Default.copy(alpha = 0.045f + 0.06f * pressProgress.value) },
                        shadow = { Shadow(alpha = 0.0f) },
                        innerShadow = { InnerShadow(radius = 1.25f.dp, alpha = 0.012f + 0.02f * pressProgress.value) },
                        onDrawSurface = {
                            drawRect(transparentSurfaceColor)
                        },
                    )
                    .height(64.dp)
                    .fillMaxWidth()
                    .padding(4.dp),
                verticalAlignment = Alignment.CenterVertically,
                content = content,
            )

            Box(
                Modifier
                    .padding(horizontal = 4.dp)
                    .graphicsLayer {
                        translationX =
                            if (isLtr) {
                                activeTabPosition * tabWidth + (tabWidth - size.width) / 2f + panelOffset
                            } else {
                                containerWidthPx - (activeTabPosition + 1f) * tabWidth +
                                    (tabWidth - size.width) / 2f + panelOffset
                            }
                    }
                    .drawBackdrop(
                        backdrop = rememberCombinedBackdrop(backdrop, navContentBackdrop),
                        shape = { Capsule() },
                        effects = {
                            val progress = pressProgress.value
                            vibrancy()
                            blur(0.22f.dp.toPx() * (1f - progress * 0.40f))
                            lens(
                                (5f + 11f * progress + 6f * shapeTension).dp.toPx(),
                                (8f + 18f * progress + 10f * shapeTension).dp.toPx(),
                                chromaticAberration = true,
                            )
                        },
                        highlight = {
                            Highlight.Default.copy(alpha = 0.12f + 0.48f * pressProgress.value + 0.18f * shapeTension)
                        },
                        shadow = {
                            Shadow(alpha = 0.0f + 0.10f * pressProgress.value + 0.035f * shapeTension)
                        },
                        innerShadow = {
                            val progress = pressProgress.value
                            val tension = shapeTension
                            InnerShadow(
                                radius = 1f.dp + 7f.dp * progress + 2f.dp * tension,
                                alpha = 0.03f + 0.34f * progress + 0.10f * tension,
                            )
                        },
                        layerBlock = {
                            val progress = pressProgress.value
                            val tension = shapeTension
                            val velocity = velocityStretch.fastCoerceIn(-0.30f, 0.30f)
                            val velocityMagnitude = abs(velocity)
                            val baseScale = lerp(1f, 74f / 58f, progress)
                            translationX = velocity * 11f.dp.toPx()
                            scaleX = baseScale + 0.13f * tension + 0.48f * velocityMagnitude
                            scaleY = baseScale - 0.05f * tension - 0.20f * velocityMagnitude
                        },
                        onDrawSurface = {
                            val progress = pressProgress.value
                            val tension = shapeTension
                            drawRect(
                                accentColor.copy(alpha = 0.0015f + 0.002f * progress + 0.002f * tension),
                                blendMode = BlendMode.Hue,
                            )
                        },
                    )
                    .height(56.dp)
                    .width(58.dp),
            )
        }
    }
}

@Composable
internal fun RowScope.KyantCatalogLiquidBottomTab(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier
            .clip(Capsule())
            .clickable(
                interactionSource = null,
                indication = null,
                role = Role.Tab,
                onClick = onClick,
            )
            .fillMaxHeight()
            .weight(1f),
        verticalArrangement = Arrangement.spacedBy(2.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
        content = content,
    )
}

private fun Modifier.pointerLiquidPress(
    onPressChanged: (Boolean) -> Unit,
    onDrag: (Offset) -> Unit,
): Modifier {
    return this.then(
        Modifier.pointerLiquidDrag(
            dragStartThresholdPx = 0f,
            onPressStarted = {},
            onPressChanged = onPressChanged,
            onDrag = { dragAmount, _ -> onDrag(dragAmount) },
            onDragStopped = {},
            onTap = {},
        ),
    )
}

private fun Modifier.pointerLiquidDrag(
    dragStartThresholdPx: Float = 0f,
    onPressStarted: (Offset) -> Unit,
    onPressChanged: (Boolean) -> Unit,
    onDrag: (Offset, velocityX: Float) -> Unit,
    onDragStopped: () -> Unit,
    onTap: (Offset) -> Unit = {},
): Modifier {
    return this.then(
        Modifier.detectLiquidDragGestures(
            dragStartThresholdPx = dragStartThresholdPx,
            onPressStarted = onPressStarted,
            onPressChanged = onPressChanged,
            onDrag = onDrag,
            onDragStopped = onDragStopped,
            onTap = onTap,
        ),
    )
}

private fun Modifier.detectLiquidDragGestures(
    dragStartThresholdPx: Float,
    onPressStarted: (Offset) -> Unit,
    onPressChanged: (Boolean) -> Unit,
    onDrag: (Offset, velocityX: Float) -> Unit,
    onDragStopped: () -> Unit,
    onTap: (Offset) -> Unit,
): Modifier {
    return pointerInput(Unit) {
        awaitEachGesture {
            val down = awaitFirstDown(requireUnconsumed = false)
            var lastPosition = down.position
            var lastEmitMillis = SystemClock.uptimeMillis()
            var pendingDrag = Offset.Zero
            var totalDrag = Offset.Zero
            var hasDragged = false
            onPressStarted(down.position)
            onPressChanged(true)

            try {
                while (true) {
                    val event = awaitPointerEvent()
                    val change = event.changes.firstOrNull { it.id == down.id }
                        ?: event.changes.firstOrNull()
                        ?: break
                    if (change.changedToUp() || !change.pressed) {
                        break
                    }

                    val dragAmount = change.position - lastPosition
                    if (dragAmount != Offset.Zero) {
                        val now = SystemClock.uptimeMillis()
                        pendingDrag += dragAmount
                        totalDrag += dragAmount
                        val crossedDragThreshold =
                            abs(totalDrag.x) >= dragStartThresholdPx ||
                                abs(totalDrag.y) >= dragStartThresholdPx
                        if (!crossedDragThreshold) {
                            lastPosition = change.position
                            continue
                        }

                        change.consume()
                        val emitDeltaMillis = now - lastEmitMillis
                        if (emitDeltaMillis >= 8L) {
                            val dtMillis = emitDeltaMillis.coerceAtLeast(1L).toFloat()
                            onDrag(pendingDrag, pendingDrag.x / dtMillis * 1000f)
                            hasDragged = true
                            pendingDrag = Offset.Zero
                            lastEmitMillis = now
                        }
                        lastPosition = change.position
                    }
                }
            } finally {
                if (
                    pendingDrag != Offset.Zero &&
                    (abs(totalDrag.x) >= dragStartThresholdPx || abs(totalDrag.y) >= dragStartThresholdPx)
                ) {
                    val now = SystemClock.uptimeMillis()
                    val dtMillis = (now - lastEmitMillis).coerceAtLeast(1L).toFloat()
                    onDrag(pendingDrag, pendingDrag.x / dtMillis * 1000f)
                    hasDragged = true
                }
                if (hasDragged) {
                    onDragStopped()
                } else {
                    onTap(down.position)
                }
                onPressChanged(false)
            }
        }
    }
}
