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
    KyantCatalogLiquidButton(
        onClick = onClick,
        backdrop = backdrop,
        modifier = modifier,
        tint = if (prominent || selected) RepoLensAndroidPalette.accent else Color.Unspecified,
        surfaceColor = when {
            prominent -> RepoLensAndroidPalette.accent.copy(alpha = 0.18f)
            selected -> RepoLensAndroidPalette.panel.copy(alpha = 0.16f)
            else -> RepoLensAndroidPalette.panel.copy(alpha = 0.20f)
        },
        heightDp = if (compact) 44f else 48f,
        horizontalPaddingDp = if (compact) 10f else 16f,
    ) {
        AppText(
            text = text,
            style = RepoLensAndroidType.button().copy(
                color = if (prominent) RepoLensAndroidPalette.onAccent else RepoLensAndroidPalette.ink,
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
    KyantCatalogLiquidButton(
        onClick = onClick,
        backdrop = backdrop,
        modifier = modifier,
        tint = if (prominent || selected) RepoLensAndroidPalette.accent else Color.Unspecified,
        surfaceColor = when {
            prominent -> RepoLensAndroidPalette.accent.copy(alpha = 0.18f)
            selected -> RepoLensAndroidPalette.panel.copy(alpha = 0.16f)
            else -> RepoLensAndroidPalette.panel.copy(alpha = 0.20f)
        },
        heightDp = if (compact) 44f else 48f,
        horizontalPaddingDp = if (compact) 10f else 16f,
    ) {
        val contentColor =
            if (prominent) RepoLensAndroidPalette.onAccent else RepoLensAndroidPalette.ink
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
    KyantCatalogLiquidButton(
        onClick = onClick,
        backdrop = backdrop,
        modifier = modifier.width(36.dp),
        surfaceColor = RepoLensAndroidPalette.panel.copy(alpha = 0.16f),
        heightDp = 36f,
        horizontalPaddingDp = 0f,
    ) {
        Image(
            painter = rememberVectorPainter(icon),
            contentDescription = text,
            colorFilter = ColorFilter.tint(RepoLensAndroidPalette.ink),
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
    val selectId = remember { Any() }
    var expanded by remember(label, selected, options.size) { mutableStateOf(false) }
    var anchorLeftPx by remember { mutableStateOf(0f) }
    var anchorTopPx by remember { mutableStateOf(0f) }
    var anchorWidthPx by remember { mutableIntStateOf(0) }
    val controllerExpanded = overlayController?.state?.id === selectId
    val isExpanded = controllerExpanded || (overlayController == null && expanded)

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
            KyantCatalogLiquidButton(
                onClick = {
                    if (overlayController != null) {
                        overlayController.toggle(
                            id = selectId,
                            options = options,
                            selected = selected,
                            anchorLeftPx = anchorLeftPx,
                            anchorTopPx = anchorTopPx,
                            anchorWidthPx = anchorWidthPx,
                            onSelected = onSelected,
                        )
                    } else {
                        expanded = !expanded
                    }
                },
                backdrop = backdrop,
                modifier = Modifier.fillMaxWidth(),
                surfaceColor = RepoLensAndroidPalette.panel.copy(alpha = 0.22f),
                heightDp = 48f,
                horizontalPaddingDp = 13f,
            ) {
                selectedOption.icon?.let { icon ->
                    Image(
                        painter = rememberVectorPainter(icon),
                        contentDescription = label,
                        colorFilter = ColorFilter.tint(RepoLensAndroidPalette.accent),
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
                    colorFilter = ColorFilter.tint(RepoLensAndroidPalette.ink),
                    modifier = Modifier.size(20.dp),
                )
            }
            if (expanded && overlayController == null) {
                KyantGlassSelectMenuPanel(
                    backdrop = menuBackdrop,
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
    val shape = rememberKyantShape(24f)
    Box(
        modifier
            .drawBackdrop(
                backdrop = backdrop,
                shape = { shape },
                effects = {
                    vibrancy()
                    blur(0.75f.dp.toPx())
                    lens(
                        refractionHeight = 16f.dp.toPx(),
                        refractionAmount = 30f.dp.toPx(),
                        chromaticAberration = true,
                    )
                },
                highlight = { Highlight.Default.copy(alpha = 0.38f) },
                shadow = { Shadow(alpha = 0.07f) },
                innerShadow = { InnerShadow(radius = 5f.dp, alpha = 0.18f) },
                onDrawSurface = {},
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
                        color = RepoLensAndroidPalette.accent.copy(alpha = 0.10f),
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
                    if (selected) RepoLensAndroidPalette.accent else RepoLensAndroidPalette.muted,
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
                color = if (selected) RepoLensAndroidPalette.accent else RepoLensAndroidPalette.ink,
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
) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        AppText(label, RepoLensAndroidType.caption())
        Box(
            Modifier
                .fillMaxWidth()
                .height(48.dp)
                .drawBehind {
                    val radius = 18.dp.toPx()
                    drawRoundRect(
                        color = RepoLensAndroidPalette.panel.copy(alpha = 0.34f),
                        cornerRadius = CornerRadius(radius, radius),
                    )
                    drawRoundRect(
                        color = Color.White.copy(alpha = 0.72f),
                        cornerRadius = CornerRadius(radius, radius),
                        style = Stroke(width = 1.1.dp.toPx()),
                    )
                }
                .padding(horizontal = 13.dp),
            contentAlignment = Alignment.CenterStart,
        ) {
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
                modifier = Modifier.fillMaxWidth(),
                decorationBox = { inner ->
                    if (value.isEmpty()) {
                        AppText(label, RepoLensAndroidType.bodyMuted(), maxLines = 1)
                    }
                    inner()
                },
            )
        }
    }
}

@Composable
internal fun KyantChip(text: String, backdrop: Backdrop) {
    Box(
        Modifier
            .drawBehind {
                val radius = size.height / 2f
                drawRoundRect(
                    color = RepoLensAndroidPalette.accent.copy(alpha = 0.12f),
                    cornerRadius = CornerRadius(radius, radius),
                )
                drawRoundRect(
                    color = Color.White.copy(alpha = 0.70f),
                    cornerRadius = CornerRadius(radius, radius),
                    style = Stroke(width = 1.dp.toPx()),
                )
                drawRect(RepoLensAndroidPalette.accentSoft, blendMode = BlendMode.Hue)
            }
            .padding(horizontal = 9.dp, vertical = 5.dp),
    ) {
        AppText(text, RepoLensAndroidType.chip(), maxLines = 1)
    }
}
