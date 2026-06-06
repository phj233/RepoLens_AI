package top.phj233.repolens_ai

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredHeightIn
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Close
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.key
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import com.kyant.backdrop.Backdrop
import com.kyant.backdrop.backdrops.layerBackdrop
import com.kyant.backdrop.backdrops.rememberCombinedBackdrop
import com.kyant.backdrop.backdrops.rememberCanvasBackdrop
import com.kyant.backdrop.backdrops.rememberLayerBackdrop
import kotlin.math.roundToInt
import top.phj233.repolens_ai.components.*

@Composable
internal fun RepoLensAndroidNativeShell(shellState: AndroidNativeShellState) {
    val snapshot = shellState.snapshot
    val isSystemDark = isSystemInDarkTheme()
    val isDark = when (snapshot.settings.themeMode) {
        "dark" -> true
        "light" -> false
        else -> isSystemDark
    }
    RepoLensAndroidPalette.configure(
        isDark = isDark,
        backgroundOverride = snapshot.settings.androidLiquidGlassBackground,
        themeColor = snapshot.settings.themeColor,
    )
    val backgroundColor = RepoLensAndroidPalette.background
    val backgroundBackdrop = key(backgroundColor) {
        rememberCanvasBackdrop {
            drawRect(backgroundColor)
        }
    }
    val contentBackdrop = key(backgroundColor) {
        rememberLayerBackdrop {
            drawRect(backgroundColor)
            drawContent()
        }
    }
    val bottomBarBackdrop = rememberCombinedBackdrop(backgroundBackdrop, contentBackdrop)
    val selectOverlayController = remember { AndroidSelectOverlayController() }

    CompositionLocalProvider(LocalAndroidSelectOverlayController provides selectOverlayController) {
        Box(
            Modifier
                .fillMaxSize()
                .drawBehind {
                    drawRect(backgroundColor)
                },
        ) {
            if (snapshot.isBootstrapping) {
                KyantGlassPanel(
                    backdrop = backgroundBackdrop,
                    modifier = Modifier
                        .align(Alignment.Center)
                        .padding(28.dp),
                ) {
                    AppText(
                        text = snapshot.strings.loading,
                        style = RepoLensAndroidType.bodyStrong(),
                    )
                }
            } else {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .layerBackdrop(contentBackdrop)
                        .statusBarsPadding()
                        .verticalScroll(rememberScrollState())
                        .padding(start = 16.dp, top = 12.dp, end = 16.dp, bottom = 132.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    when (shellState.selectedIndex) {
                        0 -> AndroidDashboardPage(shellState, backgroundBackdrop)
                        1 -> if (snapshot.projectDetailOpen) {
                            AndroidProjectDetailPage(shellState, backgroundBackdrop)
                        } else {
                            AndroidProjectsPage(shellState, backgroundBackdrop)
                        }
                        2 -> AndroidAnalysisPage(shellState, backgroundBackdrop)
                        3 -> AndroidExportsPage(shellState, backgroundBackdrop)
                        else -> AndroidSettingsPage(shellState, backgroundBackdrop)
                    }
                }
            }

            snapshot.message?.let { message ->
                KyantGlassPanel(
                    backdrop = bottomBarBackdrop,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .statusBarsPadding()
                        .padding(horizontal = 14.dp, vertical = 10.dp)
                        .fillMaxWidth(0.82f),
                    cornerRadius = 24f,
                    surfaceAlpha = 0.34f,
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        AppText(
                            text = message,
                            style = RepoLensAndroidType.body().copy(
                                color = if (snapshot.errorMessage != null) {
                                    RepoLensAndroidPalette.error
                                } else {
                                    RepoLensAndroidPalette.ink
                                },
                            ),
                            modifier = Modifier.weight(1f),
                            maxLines = 3,
                        )
                        Spacer(Modifier.width(8.dp))
                        KyantGlassCircleIconButton(
                            text = snapshot.strings.close,
                            icon = Icons.Outlined.Close,
                            backdrop = bottomBarBackdrop,
                            onClick = shellState::dismissMessage,
                        )
                    }
                }
            }

            if (shellState.selectedIndex == 1 && snapshot.projectDetailOpen && snapshot.selectedProject != null) {
                AndroidFloatingAnalysisConfig(
                    shellState = shellState,
                    backdrop = bottomBarBackdrop,
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .fillMaxWidth(0.92f)
                        .navigationBarsPadding()
                        .padding(end = 18.dp, bottom = 96.dp),
                )
            }

            AndroidLiquidBottomBar(
                selectedIndex = shellState.selectedIndex,
                backdrop = bottomBarBackdrop,
                strings = snapshot.strings,
                onSelected = shellState::select,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .navigationBarsPadding()
                    .padding(start = 12.dp, top = 8.dp, end = 12.dp, bottom = 26.dp),
            )

            if (selectOverlayController.state != null) {
                AndroidSelectOverlayLayer(
                    controller = selectOverlayController,
                    backdrop = bottomBarBackdrop,
                )
            }

            snapshot.previewImagePath?.let { imagePath ->
                AndroidImagePreviewOverlay(
                    path = imagePath,
                    strings = snapshot.strings,
                    backdrop = backgroundBackdrop,
                    onClose = shellState::closeImagePreview,
                )
            }
        }
    }
}

@Composable
private fun AndroidSelectOverlayLayer(
    controller: AndroidSelectOverlayController,
    backdrop: Backdrop,
) {
    val state = controller.state ?: return
    val density = LocalDensity.current
    val textMeasurer = rememberTextMeasurer()
    val menuMaxHeight = if (state.options.size > 5) 292.dp else 248.dp
    val menuHorizontalPadding = 14.dp
    val rowHorizontalPadding = 26.dp
    val leadingSlot = 28.dp
    val minMenuWidth = 176.dp
    val edgePadding = 10.dp
    val longestLabelWidthPx = state.options.maxOfOrNull { option ->
        textMeasurer.measure(option.label, style = RepoLensAndroidType.button()).size.width
    } ?: 0
    val dismissInteraction = remember { MutableInteractionSource() }

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .zIndex(100f),
    ) {
        val maxMenuWidth = (maxWidth * 0.5f).coerceAtMost(maxWidth - edgePadding * 2)
        val measuredMenuWidth = with(density) { longestLabelWidthPx.toDp() } +
            leadingSlot +
            rowHorizontalPadding +
            menuHorizontalPadding
        val menuWidth = measuredMenuWidth
            .coerceAtLeast(minMenuWidth)
            .coerceAtMost(maxMenuWidth)
        val rowHeight = 56.dp
        val rowGap = 3.dp
        val contentHeight = rowHeight * state.options.size +
            rowGap * (state.options.size - 1).coerceAtLeast(0) +
            menuHorizontalPadding
        val menuHeight = contentHeight.coerceAtMost(menuMaxHeight + menuHorizontalPadding)
        val menuWidthPx = with(density) { menuWidth.toPx() }
        val menuHeightPx = with(density) { menuHeight.toPx() }
        val edgePaddingPx = with(density) { edgePadding.toPx() }
        val screenWidthPx = with(density) { maxWidth.toPx() }
        val screenHeightPx = with(density) { maxHeight.toPx() }
        val anchorCenterX = state.anchorLeftPx + state.anchorWidthPx / 2f
        val menuLeftPx = (anchorCenterX - menuWidthPx / 2f)
            .coerceIn(edgePaddingPx, screenWidthPx - menuWidthPx - edgePaddingPx)
        val menuTopPx = state.anchorTopPx
            .coerceIn(edgePaddingPx, screenHeightPx - menuHeightPx - edgePaddingPx)

        Box(
            modifier = Modifier
                .fillMaxSize()
                .clickable(
                    interactionSource = dismissInteraction,
                    indication = null,
                    onClick = controller::dismiss,
                ),
        )
        KyantGlassSelectMenuPanel(
            backdrop = backdrop,
            modifier = Modifier
                .offset {
                    IntOffset(
                        menuLeftPx.roundToInt(),
                        menuTopPx.roundToInt(),
                    )
                }
                .width(menuWidth)
                .requiredHeightIn(max = menuMaxHeight + 14.dp),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .requiredHeightIn(max = menuMaxHeight)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(3.dp),
            ) {
                state.options.forEach { option ->
                    KyantGlassSelectMenuRow(
                        option = option,
                        selected = option.value == state.selected,
                        onClick = { controller.select(option.value) },
                    )
                }
            }
        }
    }
}
