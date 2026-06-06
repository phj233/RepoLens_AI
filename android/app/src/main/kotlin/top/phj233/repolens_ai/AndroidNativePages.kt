package top.phj233.repolens_ai

import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.outlined.Add
import androidx.compose.material.icons.outlined.Analytics
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.FileDownload
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.History
import androidx.compose.material.icons.outlined.Save
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material.icons.outlined.Visibility
import androidx.compose.material.icons.outlined.VisibilityOff
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import com.kyant.backdrop.Backdrop
import com.kyant.shapes.RoundedRectangle
import top.phj233.repolens_ai.components.*

@Composable
internal fun AndroidDashboardPage(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    val strings = snapshot.strings
    PageHeader(
        title = strings.discovery,
        subtitle = strings.discoverySubtitle,
        action = {
            KyantGlassIconButton(
                text = if (snapshot.isDiscovering) strings.loading else strings.discover,
                icon = Icons.Outlined.Search,
                backdrop = backdrop,
                prominent = true,
                onClick = shellState::discover,
            )
        },
    )
    MetricGrid(snapshot, backdrop)
    AndroidTrendPanel(snapshot, backdrop)
    AndroidFilterPanel(shellState, backdrop)
    ProjectListPanel(shellState, backdrop, limit = 8)
}

@Composable
internal fun AndroidImagePreviewOverlay(
    path: String,
    strings: AndroidNativeStrings,
    backdrop: Backdrop,
    onClose: () -> Unit,
) {
    val bitmap = remember(path) {
        BitmapFactory.decodeFile(path)?.asImageBitmap()
    }
    Box(
        modifier = Modifier
            .fillMaxSize()
            .drawBehind { drawRect(Color.Black.copy(alpha = 0.38f)) }
            .padding(horizontal = 16.dp, vertical = 34.dp),
        contentAlignment = Alignment.Center,
    ) {
        KyantGlassPanel(backdrop = backdrop, surfaceAlpha = 0.76f) {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    AppText(strings.imagePreview, RepoLensAndroidType.title(), Modifier.weight(1f))
                    KyantGlassButton(
                        text = strings.close,
                        backdrop = backdrop,
                        compact = true,
                        onClick = onClose,
                    )
                }
                if (bitmap == null) {
                    AppText(strings.openExportFileFailed, RepoLensAndroidType.bodyMuted())
                } else {
                    Image(
                        bitmap = bitmap,
                        contentDescription = strings.imagePreview,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(420.dp)
                            .clip(RoundedRectangle(18.dp)),
                        contentScale = ContentScale.Fit,
                    )
                }
            }
        }
    }
}

@Composable
internal fun AndroidProjectsPage(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    var projectQuery by remember { mutableStateOf("") }
    PageHeader(
        title = snapshot.strings.projectLibrary,
        subtitle = snapshot.strings.projectLibrarySubtitle,
        action = {
            KyantGlassButton(
                text = snapshot.strings.refresh,
                backdrop = backdrop,
                onClick = shellState::discover,
            )
        },
    )
    KyantTextField(
        value = projectQuery,
        onValueChange = { projectQuery = it },
        label = snapshot.strings.projectSearch,
        backdrop = backdrop,
    )
    ProjectListPanel(shellState, backdrop, limit = null, searchQuery = projectQuery)
}

@Composable
internal fun AndroidProjectDetailPage(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    val project = snapshot.selectedProject
    PageHeader(
        title = project?.fullName ?: snapshot.strings.projectDetail,
        subtitle = project?.description?.takeIf { it.isNotBlank() } ?: snapshot.strings.noProjectSelected,
        action = {
            KyantGlassButton(
                text = snapshot.strings.backToProjects,
                backdrop = backdrop,
                onClick = shellState::closeProjectDetail,
            )
        },
    )
    ProjectDetailPanel(shellState, backdrop)
    ProjectTopicsPanel(snapshot, backdrop)
}

@Composable
internal fun AndroidAnalysisPage(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    PageHeader(
        title = snapshot.strings.analysis,
        subtitle = snapshot.strings.analysisSubtitle,
        action = {
            KyantGlassIconButton(
                text = snapshot.strings.history,
                icon = Icons.Outlined.History,
                backdrop = backdrop,
                onClick = { shellState.select(3) },
            )
        },
    )
    KyantGlassPanel(backdrop = backdrop) {
        val analysis = snapshot.selectedAnalysis
        if (analysis == null) {
            AppText(snapshot.strings.noAnalysis, RepoLensAndroidType.bodyMuted())
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    AppText(
                        text = analysis.category,
                        style = RepoLensAndroidType.title(),
                        modifier = Modifier.weight(1f),
                    )
                    AppText(
                        text = analysis.score.toInt().toString(),
                        style = RepoLensAndroidType.headline().copy(
                            color = RepoLensAndroidTokens.accent,
                        ),
                    )
                }
                AppText(analysis.summary, RepoLensAndroidType.bodyMuted())
                if (analysis.modelId.isNotBlank()) {
                    DetailLine(snapshot.strings.model, analysis.modelId)
                }
                if (analysis.licenseFinding.isNotBlank()) {
                    DetailLine(snapshot.strings.licenseFinding, analysis.licenseFinding)
                }
                if (analysis.maintenanceActivity.isNotBlank()) {
                    DetailLine(snapshot.strings.maintenanceActivity, analysis.maintenanceActivity)
                }
                if (analysis.businessFit.isNotBlank()) {
                    DetailLine(snapshot.strings.businessFit, analysis.businessFit)
                }
                if (analysis.recommendation.isNotBlank()) {
                    DetailLine(snapshot.strings.recommendation, analysis.recommendation)
                }
                TextSection(snapshot.strings.nextSteps, analysis.nextSteps)
                TextSection(snapshot.strings.useCases, analysis.useCases)
                TextSection(snapshot.strings.techStack, analysis.techStack)
                TextSection(
                    snapshot.strings.analysisDimensions,
                    analysis.dimensions.map { "${it.title} ${it.score.toInt()}: ${it.summary}" },
                )
                TextSection(snapshot.strings.architectureNotes, analysis.architectureNotes)
                TextSection(snapshot.strings.qualitySignals, analysis.qualitySignals)
                TextSection(snapshot.strings.securityNotes, analysis.securityNotes)
                TextSection(snapshot.strings.risks, analysis.risks)
            }
        }
    }
    AnalysisExportPanel(shellState, backdrop)
}

@Composable
internal fun AndroidAnalysisProviderPanel(
    shellState: AndroidNativeShellState,
    backdrop: Backdrop,
    showAnalyzeButton: Boolean = false,
    wrapPanel: Boolean = true,
    showTitle: Boolean = true,
) {
    if (wrapPanel) {
        KyantGlassPanel(backdrop = backdrop) {
            AndroidAnalysisProviderControls(shellState, backdrop, showAnalyzeButton, showTitle)
        }
    } else {
        AndroidAnalysisProviderControls(shellState, backdrop, showAnalyzeButton, showTitle)
    }
}

@Composable
internal fun AndroidAnalysisProviderControls(
    shellState: AndroidNativeShellState,
    backdrop: Backdrop,
    showAnalyzeButton: Boolean,
    showTitle: Boolean,
) {
    val snapshot = shellState.snapshot
    val settings = snapshot.settings
    val models = analysisModels(settings)
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        if (showTitle) {
            AppText(snapshot.strings.analysisConfiguration, RepoLensAndroidType.title())
        }
        if (settings.providers.isNotEmpty()) {
            KyantGlassSelect(
                label = snapshot.strings.providerName,
                options = settings.providers.map {
                    KyantGlassSelectOption(
                        value = it.id,
                        label = it.name,
                        icon = Icons.Outlined.Settings,
                    )
                },
                selected = settings.selectedProviderId,
                backdrop = backdrop,
                maxColumns = 1,
                onSelected = shellState::selectProvider,
            )
        }
        if (models.isNotEmpty()) {
            KyantGlassSelect(
                label = snapshot.strings.defaultModel,
                options = models.map {
                    KyantGlassSelectOption(
                        value = it.id,
                        label = it.displayName,
                        icon = Icons.Outlined.Analytics,
                    )
                },
                selected = settings.defaultModel,
                backdrop = backdrop,
                maxColumns = 1,
                onSelected = { modelId ->
                    val selectedModel = models.firstOrNull { it.id == modelId } ?: models.first()
                    val payload = settings.providerRaw.toMutableMap()
                    payload["defaultModel"] = selectedModel.id
                    payload["contextLength"] = selectedModel.contextLength
                    payload["supportsStructuredOutput"] = selectedModel.supportsStructuredOutput
                    payload["supportsToolCalling"] = selectedModel.supportsToolCalling
                    payload["availableModels"] = models.map { it.toMap() }
                    shellState.saveProvider(payload)
                },
            )
        }
        KyantGlassIconButton(
            text = if (snapshot.isFetchingModels) snapshot.strings.loading else snapshot.strings.fetchProviderModels,
            icon = Icons.Outlined.FileDownload,
            backdrop = backdrop,
            modifier = Modifier.fillMaxWidth(),
            onClick = shellState::refreshSelectedProviderModels,
        )
        if (showAnalyzeButton) {
            KyantGlassIconButton(
                text = if (snapshot.isAnalyzing) snapshot.strings.loading else snapshot.strings.analyzeThisProject,
                icon = Icons.Outlined.Analytics,
                backdrop = backdrop,
                modifier = Modifier.fillMaxWidth(),
                prominent = true,
                onClick = shellState::analyzeSelectedProjectAndOpenAnalysis,
            )
        }
    }
}

private fun analysisModels(settings: AndroidNativeSettings): List<AndroidNativeModel> {
    if (settings.availableModels.any { it.id == settings.defaultModel }) {
        return settings.availableModels
    }
    return listOf(
        AndroidNativeModel(
            id = settings.defaultModel,
            displayName = settings.defaultModel,
            contextLength = settings.contextLength,
            supportsStructuredOutput = settings.supportsStructuredOutput,
            supportsToolCalling = settings.supportsToolCalling,
        ),
    ) + settings.availableModels
}

@Composable
internal fun AnalysisExportPanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            AppText(snapshot.strings.exportThisAnalysis, RepoLensAndroidType.title())
            listOf("json", "markdown", "pdf", "png")
                .chunked(2)
                .forEach { row ->
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        row.forEach { format ->
                            KyantGlassIconButton(
                                text = snapshot.strings.exportLabel(format),
                                icon = Icons.Outlined.FileDownload,
                                backdrop = backdrop,
                                modifier = Modifier.weight(1f),
                                onClick = { shellState.exportSelected(format) },
                            )
                        }
                    }
                }
        }
    }
}

@Composable
internal fun AndroidExportsPage(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    PageHeader(snapshot.strings.exports, snapshot.strings.exportsSubtitle)
    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            AppText(snapshot.strings.exportHistory, RepoLensAndroidType.title())
            if (snapshot.exports.isEmpty()) {
                AppText(snapshot.strings.emptyExports, RepoLensAndroidType.bodyMuted())
            } else {
                snapshot.exports.forEach { export ->
                    ExportHistoryRow(
                        export = export,
                        strings = snapshot.strings,
                        backdrop = backdrop,
                        onOpen = { shellState.openExportFile(export.filePath) },
                        onDelete = { shellState.deleteExport(export) },
                    )
                }
            }
        }
    }
}

@Composable
internal fun ExportHistoryRow(
    export: AndroidNativeExport,
    strings: AndroidNativeStrings,
    backdrop: Backdrop,
    onOpen: () -> Unit,
    onDelete: () -> Unit,
) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            AppText(
                text = "${strings.exportLabel(export.format)} · ${export.projectCount}",
                style = RepoLensAndroidType.bodyStrong(),
                maxLines = 1,
            )
            AppText(
                text = export.filePath,
                style = RepoLensAndroidType.caption(),
                maxLines = 1,
            )
        }
        Spacer(Modifier.width(8.dp))
        KyantGlassIconButton(
            text = strings.openExportFile,
            icon = Icons.Outlined.FileDownload,
            backdrop = backdrop,
            compact = true,
            onClick = onOpen,
        )
        Spacer(Modifier.width(6.dp))
        KyantGlassIconButton(
            text = strings.deleteExport,
            icon = Icons.Outlined.Delete,
            backdrop = backdrop,
            compact = true,
            onClick = onDelete,
        )
    }
}

@Composable
internal fun AndroidSettingsPage(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    if (snapshot.settingsProviderDetailOpen) {
        PageHeader(
            title = snapshot.strings.aiProviders,
            subtitle = snapshot.strings.providerSettingsDetailSubtitle,
            action = {
                KyantGlassIconButton(
                    text = snapshot.strings.settings,
                    icon = Icons.AutoMirrored.Outlined.ArrowBack,
                    backdrop = backdrop,
                    onClick = shellState::closeSettingsProviderDetail,
                )
            },
        )
        AndroidProviderPanel(shellState, backdrop)
    } else if (snapshot.settingsAppearanceDetailOpen) {
        PageHeader(
            title = snapshot.strings.appearanceSettings,
            subtitle = snapshot.strings.appearanceSettingsSubtitle,
            action = {
                KyantGlassIconButton(
                    text = snapshot.strings.settings,
                    icon = Icons.AutoMirrored.Outlined.ArrowBack,
                    backdrop = backdrop,
                    onClick = shellState::closeSettingsAppearanceDetail,
                )
            },
        )
        AndroidAppearancePanel(shellState, backdrop)
    } else {
        PageHeader(snapshot.strings.settings, snapshot.strings.settingsSubtitle)
        KyantGlassPanel(backdrop = backdrop) {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                AppText(snapshot.strings.displayLanguage, RepoLensAndroidType.title())
                OptionRow(
                    label = snapshot.strings.displayLanguage,
                    options = listOf("system", "simplifiedChinese", "english"),
                    selected = snapshot.settings.language,
                    labels = listOf(snapshot.strings.systemLanguage, "简体中文", "English"),
                    backdrop = backdrop,
                    onSelected = shellState::updateLanguage,
                )
                OptionRow(
                    label = snapshot.strings.themeMode,
                    options = listOf("system", "light", "dark"),
                    selected = snapshot.settings.themeMode,
                    labels = listOf(snapshot.strings.systemLanguage, snapshot.strings.themeLight, snapshot.strings.themeDark),
                    backdrop = backdrop,
                    onSelected = shellState::updateThemeMode,
                )
            }
        }
        AndroidAppearanceEntryPanel(shellState, backdrop)
        AndroidProviderEntryPanel(shellState, backdrop)
        AndroidCredentialsPanel(shellState, backdrop)
        KyantGlassPanel(backdrop = backdrop) {
            KyantGlassToggleRow(
                label = snapshot.strings.mcpWriteAccess,
                subtitle = snapshot.strings.desktopOnly,
                selected = snapshot.settings.mcpWriteAccessEnabled,
                backdrop = backdrop,
                enabledText = snapshot.strings.enabled,
                disabledText = snapshot.strings.disabled,
                onChanged = shellState::updateMcpWriteAccess,
            )
        }
    }
}

@Composable
internal fun AndroidAppearancePanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    var androidBackground by remember(snapshot.settings.androidLiquidGlassBackground) {
        mutableStateOf(snapshot.settings.androidLiquidGlassBackground)
    }
    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            AppText(snapshot.strings.visualStyle, RepoLensAndroidType.title())
            OptionRow(
                label = snapshot.strings.visualStyle,
                options = listOf("liquidGlass", "material3"),
                selected = snapshot.settings.visualStyle,
                labels = listOf("Kyant Liquid Glass", "Jetpack Material 3"),
                backdrop = backdrop,
                onSelected = shellState::updateVisualStyle,
            )
            KyantGlassColorPalette(
                label = snapshot.strings.themeColor,
                hint = snapshot.strings.themeColorHint,
                value = snapshot.settings.themeColor,
                options = androidThemeColorOptions(),
                backdrop = backdrop,
                onSelected = shellState::updateThemeColor,
            )
            if (snapshot.settings.visualStyle == "liquidGlass") {
                KyantGlassColorPalette(
                    label = snapshot.strings.liquidGlassFillColor,
                    hint = snapshot.strings.androidGlassBackgroundHint,
                    value = androidBackground,
                    options = androidLiquidGlassFillOptions(snapshot.strings),
                    backdrop = backdrop,
                    allowDefault = true,
                    onSelected = {
                        androidBackground = it
                        shellState.updateAndroidLiquidGlassBackground(it)
                    },
                )
            }
        }
    }
}

private fun androidThemeColorOptions(): List<KyantGlassColorOption> {
    return listOf(
        KyantGlassColorOption("RepoLens", "#2F7D5F"),
        KyantGlassColorOption("Azure", "#0088FF"),
        KyantGlassColorOption("Violet", "#7C3AED"),
        KyantGlassColorOption("Amber", "#D97706"),
        KyantGlassColorOption("Coral", "#C2410C"),
        KyantGlassColorOption("Teal", "#0F766E"),
    )
}

private fun androidLiquidGlassFillOptions(strings: AndroidNativeStrings): List<KyantGlassColorOption> {
    return listOf(
        KyantGlassColorOption(strings.defaultColor, ""),
        KyantGlassColorOption("Paper", "#FFFFFF"),
        KyantGlassColorOption("Mist", "#F2F6EF"),
        KyantGlassColorOption("Ice", "#EEF5FF"),
        KyantGlassColorOption("Ink", "#101412"),
        KyantGlassColorOption("Graphite", "#080A0D"),
    )
}

@Composable
internal fun AndroidAppearanceEntryPanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    val settings = snapshot.settings
    val visualStyleLabel =
        if (settings.visualStyle == "liquidGlass") "Kyant Liquid Glass" else "Jetpack Material 3"
    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            AppText(snapshot.strings.appearanceSettings, RepoLensAndroidType.title())
            AppText(snapshot.strings.appearanceSummary, RepoLensAndroidType.caption())
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    KyantChip(visualStyleLabel, backdrop)
                    KyantChip(settings.themeColor, backdrop)
                }
                Spacer(Modifier.width(10.dp))
                KyantGlassIconButton(
                    text = snapshot.strings.configureAppearance,
                    icon = Icons.Outlined.Settings,
                    backdrop = backdrop,
                    onClick = shellState::openSettingsAppearanceDetail,
                )
            }
        }
    }
}

@Composable
internal fun AndroidProviderEntryPanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    val settings = snapshot.settings
    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            AppText(snapshot.strings.aiProviders, RepoLensAndroidType.title())
            AppText(snapshot.strings.tokenMixProviderHint, RepoLensAndroidType.caption())
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    KyantChip(settings.providerName, backdrop)
                    KyantChip(settings.defaultModel, backdrop)
                }
                Spacer(Modifier.width(10.dp))
                KyantGlassIconButton(
                    text = snapshot.strings.configureProviders,
                    icon = Icons.Outlined.Settings,
                    backdrop = backdrop,
                    onClick = shellState::openSettingsProviderDetail,
                )
            }
        }
    }
}

@Composable
internal fun MetricGrid(snapshot: AndroidNativeSnapshot, backdrop: Backdrop) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            MetricPill(snapshot.strings.projects, "${snapshot.projects.size}", backdrop, Modifier.weight(1f))
            MetricPill(snapshot.strings.stars, snapshot.totalStars.compactString(), backdrop, Modifier.weight(1f))
        }
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            MetricPill(snapshot.strings.analyses, "${snapshot.analyses.size}", backdrop, Modifier.weight(1f))
            MetricPill(
                snapshot.strings.averageScore,
                String.format("%.1f", snapshot.averageScore),
                backdrop,
                Modifier.weight(1f),
            )
        }
    }
}

@Composable
internal fun MetricPill(label: String, value: String, backdrop: Backdrop, modifier: Modifier) {
    KyantGlassStat(label = label, value = value, backdrop = backdrop, modifier = modifier)
}

@Composable
internal fun AndroidTrendPanel(snapshot: AndroidNativeSnapshot, backdrop: Backdrop) {
    val trends = snapshot.trendSnapshots.take(6)
    val maxStars = trends.maxOfOrNull { it.totalStars }?.coerceAtLeast(1) ?: 1
    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            AppText(snapshot.strings.languageHeat, RepoLensAndroidType.title())
            if (trends.isEmpty()) {
                AppText(snapshot.strings.noTrendData, RepoLensAndroidType.bodyMuted())
            } else {
                trends.forEach { trend ->
                    val fraction = (trend.totalStars.toFloat() / maxStars.toFloat()).coerceIn(0.05f, 1f)
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            AppText(
                                text = trend.label.ifBlank { "Unknown" },
                                style = RepoLensAndroidType.bodyStrong(),
                                modifier = Modifier.weight(1f),
                                maxLines = 1,
                            )
                            AppText(
                                text = "${trend.totalStars.compactString()} · ${trend.projectCount}",
                                style = RepoLensAndroidType.caption(),
                                maxLines = 1,
                            )
                        }
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(10.dp)
                                .drawBehind {
                                    val radius = 10.dp.toPx()
                                    drawRoundRect(
                                        color = RepoLensAndroidTokens.panel.copy(alpha = 0.34f),
                                        cornerRadius = CornerRadius(radius, radius),
                                    )
                                },
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth(fraction)
                                    .height(10.dp)
                                    .drawBehind {
                                        val radius = 10.dp.toPx()
                                        drawRoundRect(
                                            color = RepoLensAndroidTokens.accent.copy(alpha = 0.72f),
                                            cornerRadius = CornerRadius(radius, radius),
                                        )
                                    },
                            )
                        }
                        if (trend.averageScore > 0) {
                            AppText(
                                text = "${snapshot.strings.averageScore} ${String.format("%.1f", trend.averageScore)}",
                                style = RepoLensAndroidType.caption(),
                                maxLines = 1,
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
internal fun AndroidFilterPanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    var keyword by remember { mutableStateOf(snapshot.filters.keyword) }
    var dateRange by remember { mutableStateOf(snapshot.filters.dateRange) }
    var language by remember { mutableStateOf(snapshot.filters.language) }
    var minStars by remember { mutableIntStateOf(snapshot.filters.minStars) }

    LaunchedEffect(snapshot.filters) {
        keyword = snapshot.filters.keyword
        dateRange = snapshot.filters.dateRange
        language = snapshot.filters.language
        minStars = snapshot.filters.minStars
    }

    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            AppText(snapshot.strings.searchFilters, RepoLensAndroidType.title())
            KyantTextField(
                value = keyword,
                onValueChange = { keyword = it },
                label = snapshot.strings.keyword,
                backdrop = backdrop,
            )
            OptionRow(
                label = snapshot.strings.date,
                options = listOf("Today", "This week", "Any"),
                selected = dateRange,
                labels = listOf(snapshot.strings.today, snapshot.strings.thisWeek, snapshot.strings.any),
                backdrop = backdrop,
                onSelected = { dateRange = it },
            )
            OptionRow(
                label = snapshot.strings.language,
                options = listOf("Any", "Dart", "Python", "TypeScript", "Kotlin", "Swift"),
                selected = language,
                labels = listOf(snapshot.strings.any, "Dart", "Python", "TypeScript", "Kotlin", "Swift"),
                backdrop = backdrop,
                onSelected = { language = it },
            )
            KyantGlassSlider(
                label = snapshot.strings.minStars,
                value = minStars,
                valueRange = 0..1000,
                step = 5,
                backdrop = backdrop,
                onValueChange = { minStars = it },
            )
            Row(horizontalArrangement = Arrangement.End, modifier = Modifier.fillMaxWidth()) {
                KyantGlassIconButton(
                    text = snapshot.strings.search,
                    icon = Icons.Outlined.Search,
                    backdrop = backdrop,
                    prominent = true,
                    onClick = {
                        shellState.updateFilters(
                            keyword = keyword,
                            dateRange = dateRange,
                            language = language,
                            minStars = minStars,
                        )
                        shellState.discover()
                    },
                )
            }
        }
    }
}

@Composable
internal fun OptionRow(
    label: String,
    options: List<String>,
    selected: String,
    labels: List<String>,
    backdrop: Backdrop,
    menuBackdrop: Backdrop = backdrop,
    onSelected: (String) -> Unit,
) {
    KyantGlassSelect(
        label = label,
        options = options.mapIndexed { index, option ->
            KyantGlassSelectOption(value = option, label = labels.getOrElse(index) { option })
        },
        selected = selected,
        backdrop = backdrop,
        menuBackdrop = menuBackdrop,
        maxColumns = if (options.size > 3) 3 else options.size.coerceAtLeast(1),
        onSelected = onSelected,
    )
}

@Composable
internal fun ProjectListPanel(
    shellState: AndroidNativeShellState,
    backdrop: Backdrop,
    limit: Int?,
    searchQuery: String = "",
) {
    val snapshot = shellState.snapshot
    val sourceProjects = if (limit == null) snapshot.projects else snapshot.projects.take(limit)
    val normalizedQuery = searchQuery.trim()
    val projects = if (normalizedQuery.isEmpty()) {
        sourceProjects
    } else {
        sourceProjects.filter { it.matchesProjectQuery(normalizedQuery) }
    }
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(11.dp),
    ) {
        AppText(snapshot.strings.projects, RepoLensAndroidType.title())
        if (projects.isEmpty()) {
            KyantGlassPanel(backdrop = backdrop) {
                AppText(
                    text = if (sourceProjects.isEmpty() || normalizedQuery.isEmpty()) {
                        snapshot.strings.emptyProjects
                    } else {
                        snapshot.strings.noProjectSearchResults
                    },
                    style = RepoLensAndroidType.bodyMuted(),
                )
            }
        } else {
            projects.forEach { project ->
                ProjectRow(
                    project = project,
                    selected = project.fullName == snapshot.selectedProjectFullName,
                    backdrop = backdrop,
                    onClick = { shellState.openProjectDetail(project.fullName) },
                )
            }
        }
    }
}

private fun AndroidNativeProject.matchesProjectQuery(query: String): Boolean {
    val normalizedQuery = query.lowercase()
    val searchable = buildString {
        append(fullName)
        append(' ')
        append(description)
        append(' ')
        append(language)
        append(' ')
        append(license)
        topics.forEach { topic ->
            append(' ')
            append(topic)
        }
    }.lowercase()
    return searchable.contains(normalizedQuery)
}

@Composable
internal fun ProjectRow(
    project: AndroidNativeProject,
    selected: Boolean,
    backdrop: Backdrop,
    onClick: () -> Unit,
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .drawBehind {
                val radius = 18.dp.toPx()
                drawRoundRect(
                    color = if (selected) {
                        RepoLensAndroidTokens.accent.copy(alpha = 0.16f)
                    } else {
                        RepoLensAndroidTokens.panel.copy(alpha = 0.32f)
                    },
                    cornerRadius = CornerRadius(radius, radius),
                )
                drawRoundRect(
                    color = Color.White.copy(alpha = if (selected) 0.82f else 0.62f),
                    cornerRadius = CornerRadius(radius, radius),
                    style = Stroke(width = 1.15.dp.toPx()),
                )
                if (selected) {
                    drawRoundRect(
                        color = RepoLensAndroidTokens.accent.copy(alpha = 0.18f),
                        cornerRadius = CornerRadius(radius, radius),
                        style = Stroke(width = 1.35.dp.toPx()),
                    )
                }
            }
            .clickable(onClick = onClick)
            .padding(12.dp),
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                AppText(
                    text = if (project.isFavorite) "★ ${project.fullName}" else project.fullName,
                    style = RepoLensAndroidType.bodyStrong().copy(
                        color = if (selected) RepoLensAndroidTokens.accent else RepoLensAndroidTokens.ink,
                    ),
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                )
                KyantChip(project.stars.compactString(), backdrop)
            }
            if (project.description.isNotBlank()) {
                AppText(project.description, RepoLensAndroidType.bodyMuted(), maxLines = 2)
            }
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                KyantChip(project.language.ifBlank { "Unknown" }, backdrop)
                KyantChip("${project.forks} forks", backdrop)
            }
        }
    }
}

@Composable
internal fun ProjectDetailPanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    val project = snapshot.selectedProject
    val analysis = snapshot.selectedAnalysis
    KyantGlassPanel(backdrop = backdrop) {
        if (project == null) {
            AppText(snapshot.strings.noProjectSelected, RepoLensAndroidType.bodyMuted())
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(9.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    AppText(project.fullName, RepoLensAndroidType.title(), Modifier.weight(1f))
                    KyantGlassButton(
                        text = if (project.isFavorite) "★" else "☆",
                        backdrop = backdrop,
                        selected = project.isFavorite,
                        onClick = { shellState.toggleFavorite(project.fullName) },
                    )
                }
                AppText(project.description, RepoLensAndroidType.bodyMuted())
                DetailLine("URL", project.htmlUrl)
                DetailLine("Language", project.language)
                DetailLine("License", project.license)
                DetailLine("Stars", project.stars.toString())
                DetailLine("Forks", project.forks.toString())
                DetailLine(snapshot.strings.openIssues, project.openIssues.toString())
                DetailLine(snapshot.strings.pushed, project.pushedAtDisplay)
                if (analysis == null) {
                    AppText(snapshot.strings.noAnalysis, RepoLensAndroidType.caption())
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column(
                            modifier = Modifier.weight(1f),
                            verticalArrangement = Arrangement.spacedBy(4.dp),
                        ) {
                            AppText(analysis.category, RepoLensAndroidType.bodyStrong(), maxLines = 1)
                            AppText(analysis.summary, RepoLensAndroidType.bodyMuted(), maxLines = 3)
                        }
                        Spacer(Modifier.width(10.dp))
                        KyantChip(analysis.score.toInt().toString(), backdrop)
                    }
                }
            }
        }
    }
}

@Composable
internal fun ProjectTopicsPanel(snapshot: AndroidNativeSnapshot, backdrop: Backdrop) {
    val project = snapshot.selectedProject ?: return
    val topics = project.topics.take(16).ifEmpty { listOf(project.language.ifBlank { "Unknown" }) }
    KyantGlassPanel(backdrop = backdrop) {
        TextSection(snapshot.strings.topics, topics)
    }
}

@Composable
internal fun AndroidProviderPanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val snapshot = shellState.snapshot
    val settings = snapshot.settings
    val models = analysisModels(settings)
    var name by remember { mutableStateOf(settings.providerName) }
    var baseUrl by remember { mutableStateOf(settings.baseUrl) }
    var model by remember { mutableStateOf(settings.defaultModel) }
    var protocol by remember { mutableStateOf(settings.providerProtocol) }
    var contextLength by remember { mutableStateOf(settings.contextLength.toString()) }
    var temperature by remember { mutableStateOf(settings.temperature.toString()) }
    var maxOutputTokens by remember { mutableStateOf(settings.maxOutputTokens.toString()) }
    var structuredOutput by remember { mutableStateOf(settings.supportsStructuredOutput) }
    var toolCalling by remember { mutableStateOf(settings.supportsToolCalling) }
    var providerKey by remember { mutableStateOf("") }
    var providerKeyVisible by remember { mutableStateOf(true) }

    LaunchedEffect(settings) {
        name = settings.providerName
        baseUrl = settings.baseUrl
        model = settings.defaultModel
        protocol = settings.providerProtocol
        contextLength = settings.contextLength.toString()
        temperature = settings.temperature.toString()
        maxOutputTokens = settings.maxOutputTokens.toString()
        structuredOutput = settings.supportsStructuredOutput
        toolCalling = settings.supportsToolCalling
    }

    LaunchedEffect(settings.selectedProviderId, settings.providerRaw["apiKeyRef"]) {
        val providerId = settings.selectedProviderId
        providerKeyVisible = true
        providerKey = ""
        shellState.readSelectedProviderApiKey { apiKey ->
            if (shellState.snapshot.settings.selectedProviderId == providerId) {
                providerKey = apiKey
            }
        }
    }

    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            AppText(snapshot.strings.aiProviders, RepoLensAndroidType.title())
            AppText(snapshot.strings.tokenMixProviderHint, RepoLensAndroidType.caption())
            if (settings.providers.isNotEmpty()) {
                KyantGlassSelect(
                    label = snapshot.strings.providerName,
                    options = settings.providers.map {
                        KyantGlassSelectOption(
                            value = it.id,
                            label = "${it.name} · ${it.defaultModel}",
                            icon = Icons.Outlined.Settings,
                        )
                    },
                    selected = settings.selectedProviderId,
                    backdrop = backdrop,
                    maxColumns = 1,
                    onSelected = shellState::selectProvider,
                )
            }
            OptionRow(
                label = snapshot.strings.protocol,
                options = listOf("openAiChatCompletions", "anthropicMessages"),
                selected = protocol,
                labels = listOf("OpenAI", "Anthropic"),
                backdrop = backdrop,
                onSelected = { protocol = it },
            )
            KyantTextField(name, { name = it }, snapshot.strings.providerName, backdrop)
            KyantTextField(baseUrl, { baseUrl = it }, snapshot.strings.baseUrl, backdrop)
            KyantTextField(
                value = providerKey,
                onValueChange = { providerKey = it },
                label = snapshot.strings.selectedProviderApiKey,
                backdrop = backdrop,
                password = !providerKeyVisible,
                trailingIcon = if (providerKeyVisible) Icons.Outlined.VisibilityOff else Icons.Outlined.Visibility,
                trailingContentDescription = if (providerKeyVisible) {
                    snapshot.strings.hideSecret
                } else {
                    snapshot.strings.showSecret
                },
                onTrailingClick = { providerKeyVisible = !providerKeyVisible },
            )
            if (settings.availableModels.isNotEmpty()) {
                KyantGlassSelect(
                    label = snapshot.strings.defaultModel,
                    options = models.map {
                        KyantGlassSelectOption(
                            value = it.id,
                            label = it.displayName,
                            icon = Icons.Outlined.Analytics,
                        )
                    },
                    selected = model,
                    backdrop = backdrop,
                    maxColumns = 1,
                    onSelected = { modelId ->
                        val selectedModel = models.firstOrNull { it.id == modelId } ?: models.first()
                        model = selectedModel.id
                        contextLength = selectedModel.contextLength.toString()
                        structuredOutput = selectedModel.supportsStructuredOutput
                        toolCalling = selectedModel.supportsToolCalling
                    },
                )
            } else {
                KyantTextField(model, { model = it }, snapshot.strings.defaultModel, backdrop)
            }
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                KyantTextField(
                    value = contextLength,
                    onValueChange = { value -> contextLength = value.filter(Char::isDigit).take(7) },
                    label = snapshot.strings.contextLength,
                    backdrop = backdrop,
                    modifier = Modifier.weight(1f),
                )
                KyantTextField(
                    value = maxOutputTokens,
                    onValueChange = { value -> maxOutputTokens = value.filter(Char::isDigit).take(6) },
                    label = snapshot.strings.maxOutputTokens,
                    backdrop = backdrop,
                    modifier = Modifier.weight(1f),
                )
            }
            KyantTextField(
                value = temperature,
                onValueChange = { value ->
                    temperature = value.filter { it.isDigit() || it == '.' }.take(5)
                },
                label = snapshot.strings.temperature,
                backdrop = backdrop,
            )
            KyantGlassToggleRow(
                label = snapshot.strings.structuredOutput,
                selected = structuredOutput,
                backdrop = backdrop,
                enabledText = snapshot.strings.enabled,
                disabledText = snapshot.strings.disabled,
                onChanged = { structuredOutput = it },
            )
            KyantGlassToggleRow(
                label = snapshot.strings.toolCalling,
                selected = toolCalling,
                backdrop = backdrop,
                enabledText = snapshot.strings.enabled,
                disabledText = snapshot.strings.disabled,
                onChanged = { toolCalling = it },
            )
            KyantGlassIconButton(
                text = snapshot.strings.saveProvider,
                icon = Icons.Outlined.Save,
                backdrop = backdrop,
                prominent = true,
                modifier = Modifier.fillMaxWidth(),
                onClick = {
                    val selectedModelId = model.ifBlank { settings.defaultModel }
                    val parsedContextLength =
                        contextLength.toIntOrNull() ?: settings.contextLength
                    val parsedTemperature =
                        temperature.toDoubleOrNull()?.coerceIn(0.0, 2.0) ?: settings.temperature
                    val parsedMaxOutputTokens =
                        maxOutputTokens.toIntOrNull() ?: settings.maxOutputTokens
                    val availableModels = if (settings.availableModels.any { it.id == selectedModelId }) {
                        settings.availableModels
                    } else {
                        listOf(
                            AndroidNativeModel(
                                id = selectedModelId,
                                displayName = selectedModelId,
                                contextLength = parsedContextLength,
                                supportsStructuredOutput = structuredOutput,
                                supportsToolCalling = toolCalling,
                            ),
                        ) + settings.availableModels
                    }
                    val payload = settings.providerRaw.toMutableMap()
                    payload["name"] = name
                    payload["protocol"] = protocol
                    payload["baseUrl"] = baseUrl
                    payload["defaultModel"] = selectedModelId
                    payload["contextLength"] = parsedContextLength
                    payload["temperature"] = parsedTemperature
                    payload["maxOutputTokens"] = parsedMaxOutputTokens
                    payload["supportsStructuredOutput"] = structuredOutput
                    payload["supportsToolCalling"] = toolCalling
                    payload["availableModels"] = availableModels.map { it.toMap() }
                    if (providerKey.isNotBlank()) {
                        payload["apiKey"] = providerKey.trim()
                    }
                    shellState.saveProvider(payload)
                    if (providerKey.isNotBlank()) {
                        providerKeyVisible = true
                    }
                },
            )
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                KyantGlassIconButton(
                    text = snapshot.strings.addProvider,
                    icon = Icons.Outlined.Add,
                    backdrop = backdrop,
                    modifier = Modifier.weight(1f),
                    onClick = {
                        val id = "openai-compatible-${System.currentTimeMillis()}"
                        shellState.addProvider(
                            mapOf(
                                "id" to id,
                                "name" to "OpenAI-compatible",
                                "type" to "openAiCompatible",
                                "protocol" to "openAiChatCompletions",
                                "baseUrl" to "https://api.openai.com/v1",
                                "apiKeyRef" to id,
                                "defaultModel" to "gpt-4.1-mini",
                                "contextLength" to 128000,
                                "temperature" to 0.2,
                                "maxOutputTokens" to 2200,
                                "supportsStructuredOutput" to true,
                                "supportsToolCalling" to true,
                                "availableModels" to listOf(
                                    mapOf(
                                        "id" to "gpt-4.1-mini",
                                        "displayName" to "gpt-4.1-mini",
                                        "contextLength" to 128000,
                                        "supportsStructuredOutput" to true,
                                        "supportsToolCalling" to true,
                                    ),
                                ),
                            ),
                        )
                    },
                )
                KyantGlassIconButton(
                    text = if (snapshot.isFetchingModels) snapshot.strings.loading else snapshot.strings.fetchProviderModels,
                    icon = Icons.Outlined.FileDownload,
                    backdrop = backdrop,
                    modifier = Modifier.weight(1f),
                    onClick = shellState::refreshSelectedProviderModels,
                )
            }
            if (settings.providers.size > 1) {
                KyantGlassIconButton(
                    text = snapshot.strings.deleteProvider,
                    icon = Icons.Outlined.Delete,
                    backdrop = backdrop,
                    compact = true,
                    modifier = Modifier.fillMaxWidth(),
                    onClick = { shellState.deleteProvider(settings.selectedProviderId) },
                )
            }
        }
    }
}

@Composable
internal fun AndroidCredentialsPanel(shellState: AndroidNativeShellState, backdrop: Backdrop) {
    val strings = shellState.snapshot.strings
    var githubToken by remember { mutableStateOf("") }
    var githubTokenVisible by remember { mutableStateOf(true) }
    KyantGlassPanel(backdrop = backdrop) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            AppText("GitHub Token", RepoLensAndroidType.title())
            AppText(strings.githubTokenHint, RepoLensAndroidType.caption())
            KyantTextField(
                value = githubToken,
                onValueChange = { githubToken = it },
                label = "GitHub Token",
                backdrop = backdrop,
                password = !githubTokenVisible,
                trailingIcon = if (githubTokenVisible) Icons.Outlined.VisibilityOff else Icons.Outlined.Visibility,
                trailingContentDescription = if (githubTokenVisible) strings.hideSecret else strings.showSecret,
                onTrailingClick = { githubTokenVisible = !githubTokenVisible },
            )
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                KyantGlassButton(
                    text = strings.saveGithubToken,
                    backdrop = backdrop,
                    modifier = Modifier.weight(1f),
                    onClick = {
                        shellState.saveGithubToken(githubToken)
                        githubToken = ""
                        githubTokenVisible = true
                    },
                )
            }
        }
    }
}
