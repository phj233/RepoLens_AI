package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.rememberVectorPainter
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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AutoAwesome

internal data class KyantGlassColorOption(
    val label: String,
    val value: String,
)

@Composable
internal fun KyantGlassColorPalette(
    label: String,
    hint: String,
    value: String,
    options: List<KyantGlassColorOption>,
    backdrop: Backdrop,
    allowDefault: Boolean = false,
    onSelected: (String) -> Unit,
) {
    var customValue by remember(value) { mutableStateOf(value) }

    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        AppText(label, RepoLensAndroidType.bodyStrong())
        AppText(hint, RepoLensAndroidType.caption())
        options.chunked(6).forEach { rowOptions ->
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                rowOptions.forEach { option ->
                    KyantGlassColorSwatch(
                        option = option,
                        selected = colorOptionSelected(option.value, value),
                        backdrop = backdrop,
                        onClick = {
                            customValue = option.value
                            onSelected(option.value)
                        },
                    )
                }
            }
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            KyantSelectedColorPreview(value = value)
            Spacer(Modifier.width(10.dp))
            KyantTextField(
                value = customValue,
                onValueChange = { next ->
                    customValue = next
                    val normalized = normalizeHexColor(next)
                    if (normalized != null) {
                        onSelected(normalized)
                    } else if (allowDefault && next.trim().isEmpty()) {
                        onSelected("")
                    }
                },
                label = if (allowDefault) "#RRGGBB / default" else "#RRGGBB",
                backdrop = backdrop,
                modifier = Modifier.weight(1f),
            )
        }
    }
}

@Composable
private fun KyantGlassColorSwatch(
    option: KyantGlassColorOption,
    selected: Boolean,
    backdrop: Backdrop,
    onClick: () -> Unit,
) {
    val color = parseHexColor(option.value)
    Box(
        modifier = Modifier
            .size(44.dp)
            .clip(Capsule())
            .drawBackdrop(
                backdrop = backdrop,
                shape = { Capsule() },
                effects = {
                    vibrancy()
                    blur(1.2f.dp.toPx())
                    lens(
                        refractionHeight = 5f.dp.toPx(),
                        refractionAmount = 10f.dp.toPx(),
                        chromaticAberration = selected,
                    )
                },
                highlight = { Highlight.Default.copy(alpha = if (selected) 0.42f else 0.22f) },
                shadow = { Shadow(alpha = if (selected) 0.16f else 0.07f) },
                innerShadow = { InnerShadow(radius = 4f.dp, alpha = 0.18f) },
                onDrawSurface = {
                    drawRect(RepoLensAndroidPalette.panel.copy(alpha = 0.22f))
                    if (color != null) {
                        drawRect(color.copy(alpha = 0.76f))
                    }
                },
            )
            .drawBehind {
                val radius = size.height / 2f
                drawRoundRect(
                    color = if (selected) {
                        RepoLensAndroidPalette.accent.copy(alpha = 0.78f)
                    } else {
                        Color.White.copy(alpha = 0.55f)
                    },
                    cornerRadius = CornerRadius(radius, radius),
                    style = Stroke(width = if (selected) 1.7.dp.toPx() else 1.dp.toPx()),
                )
            }
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        if (color == null) {
            Image(
                painter = rememberVectorPainter(Icons.Outlined.AutoAwesome),
                contentDescription = option.label,
                colorFilter = ColorFilter.tint(RepoLensAndroidPalette.accent),
                modifier = Modifier.size(18.dp),
            )
        }
    }
}

@Composable
private fun KyantSelectedColorPreview(value: String) {
    val color = parseHexColor(value)
    Box(
        modifier = Modifier
            .size(48.dp)
            .clip(Capsule())
            .drawBehind {
                val radius = size.height / 2f
                drawRoundRect(
                    color = color ?: RepoLensAndroidPalette.panel.copy(alpha = 0.34f),
                    cornerRadius = CornerRadius(radius, radius),
                )
                drawRoundRect(
                    color = Color.White.copy(alpha = 0.64f),
                    cornerRadius = CornerRadius(radius, radius),
                    style = Stroke(width = 1.dp.toPx()),
                )
            },
        contentAlignment = Alignment.Center,
    ) {
        if (color == null) {
            Image(
                painter = rememberVectorPainter(Icons.Outlined.AutoAwesome),
                contentDescription = value,
                colorFilter = ColorFilter.tint(RepoLensAndroidPalette.accent),
                modifier = Modifier.size(18.dp),
            )
        }
    }
}

private fun colorOptionSelected(optionValue: String, value: String): Boolean {
    if (optionValue.isBlank() && value.isBlank()) {
        return true
    }
    return normalizeHexColor(optionValue) == normalizeHexColor(value)
}

private fun normalizeHexColor(value: String): String? {
    val cleaned = value.trim().removePrefix("#")
    if (cleaned.length != 6 && cleaned.length != 8) {
        return null
    }
    if (cleaned.toLongOrNull(16) == null) {
        return null
    }
    return "#${cleaned.uppercase()}"
}

private fun parseHexColor(value: String): Color? {
    val normalized = normalizeHexColor(value) ?: return null
    val cleaned = normalized.removePrefix("#")
    val parsed = cleaned.toLongOrNull(16) ?: return null
    return when (cleaned.length) {
        6 -> Color(0xFF000000L or parsed)
        8 -> Color(parsed)
        else -> null
    }
}
