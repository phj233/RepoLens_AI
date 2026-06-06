package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Analytics
import androidx.compose.material.icons.outlined.FileDownload
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.unit.dp
import com.kyant.backdrop.Backdrop
import kotlin.math.cos
import kotlin.math.sin

@Composable
internal fun AndroidLiquidBottomBar(
    selectedIndex: Int,
    backdrop: Backdrop,
    strings: AndroidNativeStrings,
    onSelected: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    val items = remember(strings.navItems) {
        strings.navItems.mapIndexed { index, label ->
            RepoLensBottomTabItem(
                label = label,
                icon = RepoLensBottomTabIcons.materialIconFor(index),
            )
        }
    }
    RepoLensLiquidBottomTabs(
        selectedIndex = selectedIndex.coerceIn(0, items.lastIndex),
        onTabSelected = onSelected,
        backdrop = backdrop,
        items = items,
        modifier = modifier.fillMaxWidth(),
    )
}

internal data class RepoLensBottomTabItem(
    val label: String,
    val icon: ImageVector? = null,
)

private object RepoLensBottomTabIcons {
    fun materialIconFor(index: Int): ImageVector? {
        return when (index) {
            0 -> Icons.Outlined.Search
            1 -> Icons.Outlined.Folder
            2 -> Icons.Outlined.Analytics
            3 -> Icons.Outlined.FileDownload
            4 -> Icons.Outlined.Settings
            else -> null
        }
    }
}

@Composable
internal fun RepoLensLiquidBottomTabs(
    selectedIndex: Int,
    onTabSelected: (index: Int) -> Unit,
    backdrop: Backdrop,
    items: List<RepoLensBottomTabItem>,
    modifier: Modifier = Modifier,
) {
    val safeItems = items.ifEmpty { listOf(RepoLensBottomTabItem("")) }
    val tabsCount = safeItems.size
    val safeSelectedIndex = selectedIndex.coerceIn(0, tabsCount - 1)

    KyantCatalogLiquidBottomTabs(
        selectedTabIndex = { safeSelectedIndex },
        onTabSelected = onTabSelected,
        backdrop = backdrop,
        tabsCount = tabsCount,
        modifier = modifier.fillMaxWidth(),
    ) {
        safeItems.forEachIndexed { index, item ->
            KyantCatalogLiquidBottomTab(
                onClick = { onTabSelected(index) },
            ) {
                RepoLensBottomTabContent(
                    item = item,
                    fallbackIndex = index,
                    selected = safeSelectedIndex == index,
                )
            }
        }
    }
}

@Composable
private fun RepoLensBottomTabContent(
    item: RepoLensBottomTabItem,
    fallbackIndex: Int,
    selected: Boolean,
) {
    RepoLensBottomTabIcon(
        item = item,
        fallbackIndex = fallbackIndex,
        selected = selected,
    )
    AppText(
        text = item.label,
        style = RepoLensAndroidType.navLabel().copy(
            color = if (selected) {
                RepoLensAndroidPalette.accent
            } else {
                RepoLensAndroidPalette.muted
            },
        ),
        maxLines = 1,
    )
}

@Composable
private fun RepoLensBottomTabIcon(
    item: RepoLensBottomTabItem,
    fallbackIndex: Int,
    selected: Boolean,
) {
    val color = if (selected) RepoLensAndroidPalette.accent else RepoLensAndroidPalette.muted
    val icon = item.icon
    if (icon == null) {
        RepoLensFallbackBottomTabGlyph(index = fallbackIndex, color = color)
        return
    }

    Image(
        painter = rememberVectorPainter(icon),
        contentDescription = item.label,
        colorFilter = ColorFilter.tint(color),
        modifier = Modifier.size(23.dp),
    )
}

@Composable
private fun RepoLensFallbackBottomTabGlyph(index: Int, color: Color) {
    Canvas(Modifier.size(22.dp)) {
        val stroke = Stroke(width = 2.1.dp.toPx(), cap = StrokeCap.Round)
        val inset = 3.5.dp.toPx()
        val center = Offset(size.width / 2f, size.height / 2f)
        when (index) {
            0 -> {
                drawCircle(color, radius = 6.8.dp.toPx(), center = center, style = stroke)
                drawCircle(color, radius = 2.2.dp.toPx(), center = center)
            }
            1 -> {
                drawRoundRect(
                    color = color,
                    topLeft = Offset(inset, inset + 1.dp.toPx()),
                    size = Size(size.width - inset * 2f, size.height - inset * 2.2f),
                    cornerRadius = CornerRadius(4.dp.toPx(), 4.dp.toPx()),
                    style = stroke,
                )
                drawLine(
                    color = color,
                    start = Offset(inset + 4.dp.toPx(), inset - 0.5.dp.toPx()),
                    end = Offset(size.width - inset - 4.dp.toPx(), inset - 0.5.dp.toPx()),
                    strokeWidth = 2.1.dp.toPx(),
                    cap = StrokeCap.Round,
                )
            }
            2 -> {
                drawLine(
                    color = color,
                    start = Offset(inset, size.height - inset),
                    end = Offset(size.width - inset, inset + 1.dp.toPx()),
                    strokeWidth = 2.1.dp.toPx(),
                    cap = StrokeCap.Round,
                )
                drawCircle(color, radius = 2.2.dp.toPx(), center = Offset(inset + 1.dp.toPx(), size.height - inset))
                drawCircle(color, radius = 2.2.dp.toPx(), center = Offset(size.width / 2f, size.height / 2f))
                drawCircle(color, radius = 2.2.dp.toPx(), center = Offset(size.width - inset, inset + 1.dp.toPx()))
            }
            3 -> {
                drawLine(
                    color = color,
                    start = Offset(size.width / 2f, inset),
                    end = Offset(size.width / 2f, size.height - inset - 4.dp.toPx()),
                    strokeWidth = 2.1.dp.toPx(),
                    cap = StrokeCap.Round,
                )
                drawLine(
                    color = color,
                    start = Offset(size.width / 2f, size.height - inset - 4.dp.toPx()),
                    end = Offset(size.width / 2f - 4.dp.toPx(), size.height - inset - 8.dp.toPx()),
                    strokeWidth = 2.1.dp.toPx(),
                    cap = StrokeCap.Round,
                )
                drawLine(
                    color = color,
                    start = Offset(size.width / 2f, size.height - inset - 4.dp.toPx()),
                    end = Offset(size.width / 2f + 4.dp.toPx(), size.height - inset - 8.dp.toPx()),
                    strokeWidth = 2.1.dp.toPx(),
                    cap = StrokeCap.Round,
                )
                drawRoundRect(
                    color = color,
                    topLeft = Offset(inset + 1.dp.toPx(), size.height - inset - 3.dp.toPx()),
                    size = Size(size.width - inset * 2f - 2.dp.toPx(), 3.dp.toPx()),
                    cornerRadius = CornerRadius(2.dp.toPx(), 2.dp.toPx()),
                )
            }
            else -> {
                repeat(6) { spoke ->
                    val angle = (spoke / 6f) * 6.28318f
                    val start = Offset(
                        x = center.x + cos(angle) * 5.8.dp.toPx(),
                        y = center.y + sin(angle) * 5.8.dp.toPx(),
                    )
                    val end = Offset(
                        x = center.x + cos(angle) * 8.2.dp.toPx(),
                        y = center.y + sin(angle) * 8.2.dp.toPx(),
                    )
                    drawLine(color, start, end, strokeWidth = 2.dp.toPx(), cap = StrokeCap.Round)
                }
                drawCircle(color, radius = 5.1.dp.toPx(), center = center, style = stroke)
                drawCircle(color, radius = 1.8.dp.toPx(), center = center)
            }
        }
    }
}
