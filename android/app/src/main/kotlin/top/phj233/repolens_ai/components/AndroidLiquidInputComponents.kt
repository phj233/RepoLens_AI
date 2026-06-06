package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredHeightIn
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Check
import androidx.compose.material.icons.outlined.KeyboardArrowDown
import androidx.compose.runtime.Composable
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
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInRoot
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.kyant.backdrop.Backdrop
import com.kyant.backdrop.drawBackdrop
import com.kyant.backdrop.effects.blur
import com.kyant.backdrop.effects.lens
import com.kyant.backdrop.effects.vibrancy
import com.kyant.backdrop.highlight.Highlight
import com.kyant.backdrop.shadow.InnerShadow
import com.kyant.backdrop.shadow.Shadow
import com.kyant.shapes.Capsule

@Composable
internal fun KyantGlassButton(
    text: String,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
    prominent: Boolean = false,
    selected: Boolean = false,
    compact: Boolean = false,
    onClick: () -> Unit,
) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    KyantCatalogLiquidButton(
        onClick = onClick,
        backdrop = resolvedBackdrop,
        modifier = modifier,
        tint = if (prominent || selected) RepoLensAndroidTokens.accent else Color.Unspecified,
        surfaceColor = when {
            prominent -> RepoLensAndroidTokens.accent.copy(alpha = 0.18f)
            selected -> RepoLensAndroidTokens.panel.copy(alpha = 0.16f)
            else -> RepoLensAndroidTokens.panel.copy(alpha = 0.20f)
        },
        heightDp = if (compact) 44f else 48f,
        horizontalPaddingDp = if (compact) 10f else 16f,
    ) {
        AppText(
            text = text,
            style = RepoLensAndroidType.button().copy(
                color = if (prominent) RepoLensAndroidTokens.onAccent else RepoLensAndroidTokens.ink,
            ),
            maxLines = 1,
        )
    }
}

@Composable
internal fun KyantGlassIconButton(
    text: String,
    icon: ImageVector,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
    prominent: Boolean = false,
    selected: Boolean = false,
    compact: Boolean = false,
    onClick: () -> Unit,
) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    KyantCatalogLiquidButton(
        onClick = onClick,
        backdrop = resolvedBackdrop,
        modifier = modifier,
        tint = if (prominent || selected) RepoLensAndroidTokens.accent else Color.Unspecified,
        surfaceColor = when {
            prominent -> RepoLensAndroidTokens.accent.copy(alpha = 0.18f)
            selected -> RepoLensAndroidTokens.panel.copy(alpha = 0.16f)
            else -> RepoLensAndroidTokens.panel.copy(alpha = 0.20f)
        },
        heightDp = if (compact) 44f else 48f,
        horizontalPaddingDp = if (compact) 10f else 16f,
    ) {
        val contentColor =
            if (prominent) RepoLensAndroidTokens.onAccent else RepoLensAndroidTokens.ink
        Image(
            painter = rememberVectorPainter(icon),
            contentDescription = text,
            colorFilter = ColorFilter.tint(contentColor),
            modifier = Modifier.size(if (compact) 18.dp else 20.dp),
        )
        AppText(
            text = text,
            style = RepoLensAndroidType.button().copy(color = contentColor),
            maxLines = 1,
        )
    }
}

@Composable
internal fun KyantGlassCircleIconButton(
    text: String,
    icon: ImageVector,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
    onClick: () -> Unit,
) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    KyantCatalogLiquidButton(
        onClick = onClick,
        backdrop = resolvedBackdrop,
        modifier = modifier.width(36.dp),
        surfaceColor = RepoLensAndroidTokens.panel.copy(alpha = 0.16f),
        heightDp = 36f,
        horizontalPaddingDp = 0f,
    ) {
        Image(
            painter = rememberVectorPainter(icon),
            contentDescription = text,
            colorFilter = ColorFilter.tint(RepoLensAndroidTokens.ink),
            modifier = Modifier.size(18.dp),
        )
    }
}

internal data class KyantGlassSelectOption(
    val value: String,
    val label: String,
    val icon: ImageVector? = null,
)

@Composable
internal fun KyantGlassSelect(
    label: String,
    options: List<KyantGlassSelectOption>,
    selected: String,
    backdrop: Backdrop,
    menuBackdrop: Backdrop = backdrop,
    modifier: Modifier = Modifier.fillMaxWidth(),
    maxColumns: Int = 3,
    onSelected: (String) -> Unit,
) {
    if (options.isEmpty()) {
        return
    }
    val selectedOption = options.firstOrNull { it.value == selected } ?: options.first()
    val menuMaxHeight = if (options.size > 5) 292.dp else 248.dp
    val overlayController = LocalAndroidSelectOverlayController.current
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    val resolvedMenuBackdrop = LocalAndroidSelectMenuBackdrop.current ?: menuBackdrop
    val selectId = remember { Any() }
    var expanded by remember(label, selected, options.size) { mutableStateOf(false) }
    var anchorLeftPx by remember { mutableStateOf(0f) }
    var anchorTopPx by remember { mutableStateOf(0f) }
    var anchorWidthPx by remember { mutableIntStateOf(0) }
    val controllerExpanded = overlayController?.state?.id === selectId
    val isExpanded = controllerExpanded || (overlayController == null && expanded)
    val selectShape = Capsule()
    val transparentSelectSurfaceColor =
        if (!RepoLensAndroidTokens.isDark) {
            Color.Black.copy(alpha = 0.010f)
        } else {
            Color.White.copy(alpha = 0.014f)
        }

    fun toggleMenu() {
        if (overlayController != null) {
            overlayController.toggle(
                id = selectId,
                options = options,
                selected = selected,
                anchorLeftPx = anchorLeftPx,
                anchorTopPx = anchorTopPx,
                anchorWidthPx = anchorWidthPx,
                menuBackdrop = resolvedMenuBackdrop,
                onSelected = onSelected,
            )
        } else {
            expanded = !expanded
        }
    }

    Column(
        modifier = modifier.zIndex(if (isExpanded) 30f else 0f),
        verticalArrangement = Arrangement.spacedBy(7.dp),
    ) {
        AppText(label, RepoLensAndroidType.caption())
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
                .onGloballyPositioned { coordinates ->
                    val position = coordinates.positionInRoot()
                    anchorLeftPx = position.x
                    anchorTopPx = position.y
                    anchorWidthPx = coordinates.size.width
                },
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .drawBackdrop(
                        backdrop = resolvedBackdrop,
                        shape = { selectShape },
                        effects = {
                            vibrancy()
                            blur(2.2f.dp.toPx())
                            lens(
                                refractionHeight = 22f.dp.toPx(),
                                refractionAmount = 28f.dp.toPx(),
                                chromaticAberration = true,
                            )
                        },
                        highlight = {
                            Highlight.Default.copy(alpha = if (isExpanded) 0.12f else 0.052f)
                        },
                        shadow = { Shadow(alpha = 0f) },
                        innerShadow = {
                            InnerShadow(
                                radius = if (isExpanded) 2.5f.dp else 1.25f.dp,
                                alpha = if (isExpanded) 0.04f else 0.012f,
                            )
                        },
                        onDrawSurface = {
                            drawRect(transparentSelectSurfaceColor)
                        },
                    )
                    .clickable(onClick = ::toggleMenu)
                    .padding(horizontal = 13.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                selectedOption.icon?.let { icon ->
                    Image(
                        painter = rememberVectorPainter(icon),
                        contentDescription = label,
                        colorFilter = ColorFilter.tint(RepoLensAndroidTokens.accent),
                        modifier = Modifier.size(19.dp),
                    )
                }
                AppText(
                    text = selectedOption.label,
                    style = RepoLensAndroidType.button(),
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                )
                Image(
                    painter = rememberVectorPainter(Icons.Outlined.KeyboardArrowDown),
                    contentDescription = label,
                    colorFilter = ColorFilter.tint(RepoLensAndroidTokens.ink),
                    modifier = Modifier.size(20.dp),
                )
            }
            if (expanded && overlayController == null) {
                KyantGlassSelectMenuPanel(
                    backdrop = resolvedMenuBackdrop,
                    modifier = Modifier
                        .fillMaxWidth()
                        .requiredHeightIn(max = menuMaxHeight + 14.dp)
                        .zIndex(1f),
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .requiredHeightIn(max = menuMaxHeight)
                            .verticalScroll(rememberScrollState()),
                        verticalArrangement = Arrangement.spacedBy(3.dp),
                    ) {
                        options.forEach { option ->
                            val selectedItem = option.value == selected
                            KyantGlassSelectMenuRow(
                                option = option,
                                selected = selectedItem,
                                onClick = {
                                    expanded = false
                                    if (!selectedItem) {
                                        onSelected(option.value)
                                    }
                                },
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
internal fun KyantGlassSelectMenuPanel(
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val resolvedBackdrop = backdrop
    val transparentSurfaceColor =
        if (!RepoLensAndroidTokens.isDark) {
            Color.Black.copy(alpha = 0.010f)
        } else {
            Color.White.copy(alpha = 0.014f)
        }
    val shape = rememberKyantShape(24f)
    Box(
        modifier
            .drawBackdrop(
                backdrop = resolvedBackdrop,
                shape = { shape },
                effects = {
                    vibrancy()
                    blur(2.2f.dp.toPx())
                    lens(
                        refractionHeight = 26f.dp.toPx(),
                        refractionAmount = 34f.dp.toPx(),
                        chromaticAberration = true,
                    )
                },
                highlight = { Highlight.Default.copy(alpha = 0.058f) },
                shadow = { Shadow(alpha = 0f) },
                innerShadow = { InnerShadow(radius = 1.6f.dp, alpha = 0.016f) },
                onDrawSurface = {
                    drawRect(transparentSurfaceColor)
                },
            )
            .padding(7.dp),
    ) {
        content()
    }
}

@Composable
internal fun KyantGlassSelectMenuRow(
    option: KyantGlassSelectOption,
    selected: Boolean,
    onClick: () -> Unit,
) {
    Row(
        Modifier
            .fillMaxWidth()
            .heightIn(min = 46.dp)
            .clip(Capsule())
            .drawBehind {
                if (selected) {
                    val radius = size.height / 2f
                    drawRoundRect(
                        color = RepoLensAndroidTokens.accent.copy(alpha = 0.10f),
                        cornerRadius = CornerRadius(radius, radius),
                        style = Stroke(width = 1.dp.toPx()),
                    )
                }
            }
            .clickable(onClick = onClick)
            .padding(horizontal = 13.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        val leadingIcon = if (selected) Icons.Outlined.Check else option.icon
        if (leadingIcon != null) {
            Image(
                painter = rememberVectorPainter(leadingIcon),
                contentDescription = option.label,
                colorFilter = ColorFilter.tint(
                    if (selected) RepoLensAndroidTokens.accent else RepoLensAndroidTokens.muted,
                ),
                modifier = Modifier.size(18.dp),
            )
        } else {
            Spacer(Modifier.size(18.dp))
        }
        Spacer(Modifier.size(10.dp))
        AppText(
            text = option.label,
            style = RepoLensAndroidType.button().copy(
                color = if (selected) RepoLensAndroidTokens.accent else RepoLensAndroidTokens.ink,
            ),
            modifier = Modifier.weight(1f),
        )
    }
}

@Composable
internal fun KyantTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    backdrop: Backdrop,
    modifier: Modifier = Modifier.fillMaxWidth(),
    password: Boolean = false,
    trailingIcon: ImageVector? = null,
    trailingContentDescription: String? = null,
    onTrailingClick: (() -> Unit)? = null,
) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    val shape = rememberKyantShape(18f)
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        AppText(label, RepoLensAndroidType.caption())
        Box(
            Modifier
                .fillMaxWidth()
                .height(48.dp)
                .drawBackdrop(
                    backdrop = resolvedBackdrop,
                    shape = { shape },
                    effects = {
                        vibrancy()
                        blur(1.2f.dp.toPx())
                        lens(
                            refractionHeight = 4f.dp.toPx(),
                            refractionAmount = 8f.dp.toPx(),
                            chromaticAberration = false,
                        )
                    },
                    highlight = { Highlight.Default.copy(alpha = 0.16f) },
                    innerShadow = { InnerShadow(radius = 3f.dp, alpha = 0.08f) },
                    onDrawSurface = {
                        drawRect(RepoLensAndroidTokens.panel.copy(alpha = 0.26f))
                    },
                )
                .padding(horizontal = 13.dp),
            contentAlignment = Alignment.CenterStart,
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                BasicTextField(
                    value = value,
                    onValueChange = onValueChange,
                    singleLine = true,
                    textStyle = RepoLensAndroidType.body(),
                    visualTransformation = if (password) {
                        PasswordVisualTransformation()
                    } else {
                        VisualTransformation.None
                    },
                    modifier = Modifier.weight(1f),
                    decorationBox = { inner ->
                        if (value.isEmpty()) {
                            AppText(label, RepoLensAndroidType.bodyMuted(), maxLines = 1)
                        }
                        inner()
                    },
                )
                if (trailingIcon != null) {
                    Spacer(Modifier.width(8.dp))
                    val iconModifier = if (onTrailingClick == null) {
                        Modifier.size(22.dp)
                    } else {
                        Modifier
                            .size(22.dp)
                            .clickable { onTrailingClick() }
                    }
                    Image(
                        painter = rememberVectorPainter(trailingIcon),
                        contentDescription = trailingContentDescription,
                        colorFilter = ColorFilter.tint(RepoLensAndroidTokens.muted),
                        modifier = iconModifier,
                    )
                }
            }
        }
    }
}

@Composable
internal fun KyantChip(text: String, backdrop: Backdrop) {
    val resolvedBackdrop = LocalAndroidGlassBackdrop.current ?: backdrop
    Box(
        Modifier
            .drawBackdrop(
                backdrop = resolvedBackdrop,
                shape = { Capsule() },
                effects = {
                    vibrancy()
                    blur(0.9f.dp.toPx())
                    lens(
                        refractionHeight = 3f.dp.toPx(),
                        refractionAmount = 7f.dp.toPx(),
                        chromaticAberration = false,
                    )
                },
                highlight = { Highlight.Default.copy(alpha = 0.14f) },
                innerShadow = { InnerShadow(radius = 2f.dp, alpha = 0.08f) },
                onDrawSurface = {
                    drawRect(RepoLensAndroidTokens.accentSoft, blendMode = BlendMode.Hue)
                    drawRect(RepoLensAndroidTokens.accent.copy(alpha = 0.08f))
                    drawRect(RepoLensAndroidTokens.panel.copy(alpha = 0.10f))
                },
            )
            .padding(horizontal = 9.dp, vertical = 5.dp),
    ) {
        AppText(text, RepoLensAndroidType.chip(), maxLines = 1)
    }
}
