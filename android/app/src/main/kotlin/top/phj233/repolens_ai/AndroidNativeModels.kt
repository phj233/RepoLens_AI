package top.phj233.repolens_ai

import android.view.View
import androidx.fragment.app.FragmentActivity

internal data class AndroidNativeSnapshot(
    val navigationIndex: Int = 0,
    val isBootstrapping: Boolean = true,
    val isDiscovering: Boolean = false,
    val isAnalyzing: Boolean = false,
    val isExporting: Boolean = false,
    val isFetchingModels: Boolean = false,
    val projectDetailOpen: Boolean = false,
    val settingsProviderDetailOpen: Boolean = false,
    val settingsAppearanceDetailOpen: Boolean = false,
    val selectedProjectFullName: String? = null,
    val errorMessage: String? = null,
    val noticeMessage: String? = null,
    val previewImagePath: String? = null,
    val totalStars: Int = 0,
    val averageScore: Double = 0.0,
    val filters: AndroidNativeFilters = AndroidNativeFilters(),
    val settings: AndroidNativeSettings = AndroidNativeSettings(),
    val projects: List<AndroidNativeProject> = emptyList(),
    val analyses: List<AndroidNativeAnalysis> = emptyList(),
    val exports: List<AndroidNativeExport> = emptyList(),
    val trendSnapshots: List<AndroidNativeTrendSnapshot> = emptyList(),
) {
    val strings: AndroidNativeStrings = AndroidNativeStrings.forLanguage(settings.language)
    val selectedProject: AndroidNativeProject?
        get() = projects.firstOrNull { it.fullName == selectedProjectFullName } ?: projects.firstOrNull()
    val selectedAnalysis: AndroidNativeAnalysis?
        get() = analyses.firstOrNull { it.projectFullName == selectedProject?.fullName }
    val message: String?
        get() = errorMessage ?: noticeMessage

    companion object {
        val empty = AndroidNativeSnapshot()

        fun from(value: Any?): AndroidNativeSnapshot {
            val map = value.asStringMap()
            return AndroidNativeSnapshot(
                navigationIndex = map["navigationIndex"].intValue(),
                isBootstrapping = map["isBootstrapping"] as? Boolean ?: false,
                isDiscovering = map["isDiscovering"] as? Boolean ?: false,
                isAnalyzing = map["isAnalyzing"] as? Boolean ?: false,
                isExporting = map["isExporting"] as? Boolean ?: false,
                isFetchingModels = map["isFetchingModels"] as? Boolean ?: false,
                projectDetailOpen = map["projectDetailOpen"] as? Boolean ?: false,
                settingsProviderDetailOpen = map["settingsProviderDetailOpen"] as? Boolean ?: false,
                settingsAppearanceDetailOpen = map["settingsAppearanceDetailOpen"] as? Boolean ?: false,
                selectedProjectFullName = map["selectedProjectFullName"] as? String,
                errorMessage = map["errorMessage"] as? String,
                noticeMessage = map["noticeMessage"] as? String,
                previewImagePath = map["previewImagePath"] as? String,
                totalStars = map["totalStars"].intValue(),
                averageScore = map["averageScore"].doubleValue(),
                filters = AndroidNativeFilters.from(map["filters"]),
                settings = AndroidNativeSettings.from(map["settings"]),
                projects = map["projects"].asMapList().map(AndroidNativeProject::from),
                analyses = map["analyses"].asMapList().map(AndroidNativeAnalysis::from),
                exports = map["exports"].asMapList().map(AndroidNativeExport::from),
                trendSnapshots = map["trendSnapshots"].asMapList().map(AndroidNativeTrendSnapshot::from),
            )
        }
    }
}

internal data class AndroidNativeFilters(
    val keyword: String = "agent OR LLM OR RAG OR MCP",
    val dateRange: String = "This week",
    val language: String = "Any",
    val minStars: Int = 50,
) {
    companion object {
        fun from(value: Any?): AndroidNativeFilters {
            val map = value.asStringMap()
            return AndroidNativeFilters(
                keyword = map["keyword"] as? String ?: "agent OR LLM OR RAG OR MCP",
                dateRange = map["dateRange"] as? String ?: "This week",
                language = map["language"] as? String ?: "Any",
                minStars = map["minStars"].intValue(50),
            )
        }
    }
}

internal data class AndroidNativeSettings(
    val visualStyle: String = "liquidGlass",
    val language: String = "system",
    val themeMode: String = "system",
    val themeColor: String = "#2F7D5F",
    val androidLiquidGlassBackground: String = "",
    val mcpWriteAccessEnabled: Boolean = false,
    val providerRaw: Map<String, Any?> = emptyMap(),
    val providers: List<AndroidNativeProvider> = emptyList(),
    val selectedProviderId: String = "openai-compatible-custom",
    val providerName: String = "OpenAI-compatible",
    val providerProtocol: String = "openAiChatCompletions",
    val baseUrl: String = "https://api.openai.com/v1",
    val defaultModel: String = "gpt-4.1-mini",
    val availableModels: List<AndroidNativeModel> = emptyList(),
    val contextLength: Int = 128000,
    val temperature: Double = 0.2,
    val maxOutputTokens: Int = 2200,
    val supportsStructuredOutput: Boolean = true,
    val supportsToolCalling: Boolean = true,
) {
    companion object {
        fun from(value: Any?): AndroidNativeSettings {
            val map = value.asStringMap()
            val provider = map["provider"].asStringMap()
            val providers = map["providers"].asMapList().map(AndroidNativeProvider::from)
            val selectedProviderId = map["selectedProviderId"] as? String ?: (providers.firstOrNull()?.id ?: "openai-compatible-custom")
            return AndroidNativeSettings(
                visualStyle = map["visualStyle"] as? String ?: "liquidGlass",
                language = map["language"] as? String ?: "system",
                themeMode = map["themeMode"] as? String ?: "system",
                themeColor = map["themeColor"] as? String ?: "#2F7D5F",
                androidLiquidGlassBackground = map["androidLiquidGlassBackground"] as? String ?: "",
                mcpWriteAccessEnabled = map["mcpWriteAccessEnabled"] as? Boolean ?: false,
                providerRaw = provider,
                providers = providers.ifEmpty { listOf(AndroidNativeProvider.from(provider)) },
                selectedProviderId = selectedProviderId,
                providerName = provider["name"] as? String ?: "OpenAI-compatible",
                providerProtocol = provider["protocol"] as? String ?: "openAiChatCompletions",
                baseUrl = provider["baseUrl"] as? String ?: "https://api.openai.com/v1",
                defaultModel = provider["defaultModel"] as? String ?: "gpt-4.1-mini",
                availableModels = provider["availableModels"]
                    .asMapList()
                    .map(AndroidNativeModel::from),
                contextLength = provider["contextLength"].intValue(128000),
                temperature = provider["temperature"].doubleValue(0.2),
                maxOutputTokens = provider["maxOutputTokens"].intValue(2200),
                supportsStructuredOutput = provider["supportsStructuredOutput"] as? Boolean ?: true,
                supportsToolCalling = provider["supportsToolCalling"] as? Boolean ?: true,
            )
        }
    }
}

internal data class AndroidNativeModel(
    val id: String,
    val displayName: String,
    val contextLength: Int,
    val supportsStructuredOutput: Boolean,
    val supportsToolCalling: Boolean,
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "id" to id,
            "displayName" to displayName,
            "contextLength" to contextLength,
            "supportsStructuredOutput" to supportsStructuredOutput,
            "supportsToolCalling" to supportsToolCalling,
        )
    }

    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeModel {
            val id = map["id"] as? String ?: ""
            return AndroidNativeModel(
                id = id,
                displayName = map["displayName"] as? String ?: id,
                contextLength = map["contextLength"].intValue(32000),
                supportsStructuredOutput = map["supportsStructuredOutput"] as? Boolean ?: true,
                supportsToolCalling = map["supportsToolCalling"] as? Boolean ?: false,
            )
        }
    }
}

internal data class AndroidNativeProvider(
    val id: String,
    val name: String,
    val defaultModel: String,
) {
    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeProvider {
            return AndroidNativeProvider(
                id = map["id"] as? String ?: "openai-compatible-custom",
                name = map["name"] as? String ?: "OpenAI-compatible",
                defaultModel = map["defaultModel"] as? String ?: "gpt-4.1-mini",
            )
        }
    }
}

internal data class AndroidNativeTrendSnapshot(
    val label: String,
    val projectCount: Int,
    val totalStars: Int,
    val averageScore: Double,
) {
    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeTrendSnapshot {
            return AndroidNativeTrendSnapshot(
                label = map["label"] as? String ?: "",
                projectCount = map["projectCount"].intValue(),
                totalStars = map["totalStars"].intValue(),
                averageScore = map["averageScore"].doubleValue(),
            )
        }
    }
}

internal data class AndroidNativeProject(
    val fullName: String,
    val htmlUrl: String,
    val description: String,
    val language: String,
    val stars: Int,
    val forks: Int,
    val openIssues: Int,
    val topics: List<String>,
    val license: String,
    val pushedAtDisplay: String,
    val isFavorite: Boolean,
) {
    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeProject {
            return AndroidNativeProject(
                fullName = map["fullName"] as? String ?: "",
                htmlUrl = map["htmlUrl"] as? String ?: "",
                description = map["description"] as? String ?: "",
                language = map["language"] as? String ?: "Unknown",
                stars = map["stars"].intValue(),
                forks = map["forks"].intValue(),
                openIssues = map["openIssues"].intValue(),
                topics = map["topics"].stringList(),
                license = map["license"] as? String ?: "Unknown",
                pushedAtDisplay = (map["pushedAt"] as? String)?.take(10) ?: "",
                isFavorite = map["isFavorite"] as? Boolean ?: false,
            )
        }
    }
}

internal data class AndroidNativeAnalysis(
    val projectFullName: String,
    val category: String,
    val summary: String,
    val useCases: List<String>,
    val techStack: List<String>,
    val risks: List<String>,
    val score: Double,
    val licenseFinding: String,
    val maintenanceActivity: String,
    val dimensions: List<AndroidNativeAnalysisDimension>,
    val architectureNotes: List<String>,
    val qualitySignals: List<String>,
    val securityNotes: List<String>,
    val businessFit: String,
    val recommendation: String,
    val nextSteps: List<String>,
    val modelId: String,
    val companyApiSuggestions: List<AndroidNativeApiSuggestion>,
) {
    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeAnalysis {
            return AndroidNativeAnalysis(
                projectFullName = map["projectFullName"] as? String ?: "",
                category = map["category"] as? String ?: "AI Tool",
                summary = map["summary"] as? String ?: "",
                useCases = map["useCases"].stringList(),
                techStack = map["techStack"].stringList(),
                risks = map["risks"].stringList(),
                score = map["score"].doubleValue(),
                licenseFinding = map["licenseFinding"] as? String ?: "",
                maintenanceActivity = map["maintenanceActivity"] as? String ?: "",
                dimensions = map["dimensions"]
                    .asMapList()
                    .map(AndroidNativeAnalysisDimension::from),
                architectureNotes = map["architectureNotes"].stringList(),
                qualitySignals = map["qualitySignals"].stringList(),
                securityNotes = map["securityNotes"].stringList(),
                businessFit = map["businessFit"] as? String ?: "",
                recommendation = map["recommendation"] as? String ?: "",
                nextSteps = map["nextSteps"].stringList(),
                modelId = map["modelId"] as? String ?: "",
                companyApiSuggestions = map["companyApiSuggestions"]
                    .asMapList()
                    .map(AndroidNativeApiSuggestion::from),
            )
        }
    }
}

internal data class AndroidNativeAnalysisDimension(
    val key: String,
    val title: String,
    val score: Double,
    val summary: String,
    val evidence: List<String>,
) {
    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeAnalysisDimension {
            return AndroidNativeAnalysisDimension(
                key = map["key"] as? String ?: "",
                title = map["title"] as? String ?: map["key"] as? String ?: "",
                score = map["score"].doubleValue(),
                summary = map["summary"] as? String ?: "",
                evidence = map["evidence"].stringList(),
            )
        }
    }
}

internal data class AndroidNativeApiSuggestion(
    val apiName: String,
    val rationale: String,
) {
    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeApiSuggestion {
            return AndroidNativeApiSuggestion(
                apiName = map["apiName"] as? String ?: "",
                rationale = map["rationale"] as? String ?: "",
            )
        }
    }
}

internal data class AndroidNativeExport(
    val id: String,
    val format: String,
    val filePath: String,
    val projectCount: Int,
) {
    companion object {
        fun from(map: Map<String, Any?>): AndroidNativeExport {
            return AndroidNativeExport(
                id = map["id"] as? String ?: "",
                format = map["format"] as? String ?: "json",
                filePath = map["filePath"] as? String ?: "",
                projectCount = map["projectCount"].intValue(),
            )
        }
    }
}

internal data class AndroidNativeStrings(
    val loading: String,
    val discovery: String,
    val discoverySubtitle: String,
    val discover: String,
    val projects: String,
    val stars: String,
    val analyses: String,
    val averageScore: String,
    val languageHeat: String,
    val noTrendData: String,
    val searchFilters: String,
    val keyword: String,
    val date: String,
    val today: String,
    val thisWeek: String,
    val any: String,
    val language: String,
    val minStars: String,
    val search: String,
    val projectSearch: String,
    val noProjectSearchResults: String,
    val emptyProjects: String,
    val projectLibrary: String,
    val projectLibrarySubtitle: String,
    val refresh: String,
    val noProjectSelected: String,
    val projectDetail: String,
    val backToProjects: String,
    val analyzeThisProject: String,
    val pushed: String,
    val openIssues: String,
    val topics: String,
    val analysis: String,
    val analysisSubtitle: String,
    val analysisConfiguration: String,
    val analyze: String,
    val noAnalysis: String,
    val useCases: String,
    val techStack: String,
    val risks: String,
    val licenseFinding: String,
    val maintenanceActivity: String,
    val analysisDimensions: String,
    val architectureNotes: String,
    val qualitySignals: String,
    val securityNotes: String,
    val businessFit: String,
    val recommendation: String,
    val nextSteps: String,
    val evidence: String,
    val model: String,
    val companyApiSuggestions: String,
    val exportThisAnalysis: String,
    val exports: String,
    val exportsSubtitle: String,
    val exportHistory: String,
    val history: String,
    val emptyExports: String,
    val openExportFile: String,
    val deleteExport: String,
    val close: String,
    val imagePreview: String,
    val openExportFileFailed: String,
    val settings: String,
    val settingsSubtitle: String,
    val displayLanguage: String,
    val systemLanguage: String,
    val themeMode: String,
    val themeLight: String,
    val themeDark: String,
    val themeColor: String,
    val themeColorHint: String,
    val appearanceSettings: String,
    val appearanceSettingsSubtitle: String,
    val appearanceSummary: String,
    val configureAppearance: String,
    val visualStyle: String,
    val liquidGlassFillColor: String,
    val defaultColor: String,
    val androidGlassBackground: String,
    val androidGlassBackgroundHint: String,
    val saveAppearance: String,
    val aiProviders: String,
    val configureProviders: String,
    val providerSettingsDetailSubtitle: String,
    val providerName: String,
    val addProvider: String,
    val deleteProvider: String,
    val fetchProviderModels: String,
    val selectedProviderApiKey: String,
    val tokenMixProviderHint: String,
    val defaultModel: String,
    val protocol: String,
    val baseUrl: String,
    val contextLength: String,
    val temperature: String,
    val maxOutputTokens: String,
    val structuredOutput: String,
    val toolCalling: String,
    val enabled: String,
    val disabled: String,
    val saveProvider: String,
    val credentials: String,
    val saveGithubToken: String,
    val githubTokenHint: String,
    val saveProviderKey: String,
    val showSecret: String,
    val hideSecret: String,
    val mcpWriteAccess: String,
    val desktopOnly: String,
    val navItems: List<String>,
) {
    fun exportLabel(format: String): String {
        return when (format) {
            "json" -> "JSON"
            "csv" -> "CSV"
            "markdown" -> "Markdown"
            "pdf" -> "PDF"
            "png" -> "PNG"
            "typeScriptModule" -> "TypeScript"
            else -> format
        }
    }

    companion object {
        fun forLanguage(language: String): AndroidNativeStrings {
            val isEnglish = language == "english"
            return if (isEnglish) {
                AndroidNativeStrings(
                    loading = "Loading",
                    discovery = "Discovery",
                    discoverySubtitle = "Find AI tools on GitHub and keep promising projects close.",
                    discover = "Discover",
                    projects = "Projects",
                    stars = "Stars",
                    analyses = "Analyses",
                    averageScore = "Avg score",
                    languageHeat = "Language heat",
                    noTrendData = "No trend data",
                    searchFilters = "Search filters",
                    keyword = "Keyword",
                    date = "Date",
                    today = "Today",
                    thisWeek = "This week",
                    any = "Any",
                    language = "Language",
                    minStars = "Min stars",
                    search = "Search",
                    projectSearch = "Search projects",
                    noProjectSearchResults = "No matching projects.",
                    emptyProjects = "No projects yet.",
                    projectLibrary = "Project Library",
                    projectLibrarySubtitle = "Review saved repositories, metadata, favorites, and topics.",
                    refresh = "Refresh",
                    noProjectSelected = "Select a project first.",
                    projectDetail = "Project details",
                    backToProjects = "Back",
                    analyzeThisProject = "Analyze this project",
                    pushed = "Pushed",
                    openIssues = "Open issues",
                    topics = "Topics",
                    analysis = "Analysis",
                    analysisSubtitle = "Use the selected provider and model to produce structured evaluation.",
                    analysisConfiguration = "Analysis configuration",
                    analyze = "Analyze",
                    noAnalysis = "No analysis for the selected project yet.",
                    useCases = "Use cases",
                    techStack = "Tech stack",
                    risks = "Risks",
                    licenseFinding = "License finding",
                    maintenanceActivity = "Maintenance activity",
                    analysisDimensions = "Evaluation dimensions",
                    architectureNotes = "Architecture notes",
                    qualitySignals = "Quality signals",
                    securityNotes = "Security notes",
                    businessFit = "Business fit",
                    recommendation = "Recommendation",
                    nextSteps = "Next steps",
                    evidence = "Evidence",
                    model = "Model",
                    companyApiSuggestions = "Company API suggestions",
                    exportThisAnalysis = "Export current project",
                    exports = "Exports",
                    exportsSubtitle = "Generate local JSON, CSV, Markdown, PDF, PNG, or TypeScript modules.",
                    exportHistory = "Export history",
                    history = "History",
                    emptyExports = "No exports yet.",
                    openExportFile = "Open",
                    deleteExport = "Delete",
                    close = "Close",
                    imagePreview = "Image preview",
                    openExportFileFailed = "Could not preview this image.",
                    settings = "Settings",
                    settingsSubtitle = "Configure language, visual style, providers, credentials, and MCP access.",
                    displayLanguage = "Display language",
                    systemLanguage = "System",
                    themeMode = "Theme",
                    themeLight = "Light",
                    themeDark = "Dark",
                    themeColor = "Theme color",
                    themeColorHint = "Used for buttons, selected state, emphasized icons, and charts.",
                    appearanceSettings = "Appearance",
                    appearanceSettingsSubtitle = "Configure visual style, theme color, and Liquid Glass fill.",
                    appearanceSummary = "Visual style, theme color, and Liquid Glass fill.",
                    configureAppearance = "Configure appearance",
                    visualStyle = "Visual style",
                    liquidGlassFillColor = "Liquid Glass fill",
                    defaultColor = "Default",
                    androidGlassBackground = "Android Liquid Glass background",
                    androidGlassBackgroundHint = "Use #RRGGBB. Empty uses white in light mode and black in dark mode.",
                    saveAppearance = "Save appearance",
                    aiProviders = "AI providers",
                    configureProviders = "Configure providers",
                    providerSettingsDetailSubtitle = "Manage providers, API keys, models, structured output, and calling capabilities.",
                    providerName = "Provider name",
                    addProvider = "Add provider",
                    deleteProvider = "Delete provider",
                    fetchProviderModels = "Fetch models",
                    selectedProviderApiKey = "Selected provider API key",
                    tokenMixProviderHint = "Recommended API: TokenMix. Register at https://tokenmix.ai and create an API key.",
                    defaultModel = "Default model",
                    protocol = "Protocol",
                    baseUrl = "Base URL",
                    contextLength = "Context length",
                    temperature = "temperature",
                    maxOutputTokens = "Max output tokens",
                    structuredOutput = "Structured output",
                    toolCalling = "Tool calling",
                    enabled = "ON",
                    disabled = "OFF",
                    saveProvider = "Save provider",
                    credentials = "Credentials",
                    saveGithubToken = "Save GitHub",
                    githubTokenHint = "Discovery works without one, but GitHub API limits are lower. Create one at https://github.com/settings/tokens; RepoLens stores it only in secure storage.",
                    saveProviderKey = "Save AI key",
                    showSecret = "Show",
                    hideSecret = "Hide",
                    mcpWriteAccess = "MCP write access",
                    desktopOnly = "Desktop-only local integration.",
                    navItems = listOf("Discover", "Projects", "Analysis", "Exports", "Settings"),
                )
            } else {
                AndroidNativeStrings(
                    loading = "加载中",
                    discovery = "发现",
                    discoverySubtitle = "发现 GitHub 上的 AI 工具项目，并把值得跟进的项目留在本地。",
                    discover = "发现项目",
                    projects = "项目",
                    stars = "Stars",
                    analyses = "分析",
                    averageScore = "平均分",
                    languageHeat = "语言热度",
                    noTrendData = "暂无趋势数据",
                    searchFilters = "搜索条件",
                    keyword = "关键词",
                    date = "时间",
                    today = "今天",
                    thisWeek = "本周",
                    any = "不限",
                    language = "语言",
                    minStars = "最低 Stars",
                    search = "搜索",
                    projectSearch = "搜索项目",
                    noProjectSearchResults = "没有匹配的项目。",
                    emptyProjects = "还没有项目。",
                    projectLibrary = "项目库",
                    projectLibrarySubtitle = "查看已保存仓库、元数据、收藏和 topics。",
                    refresh = "刷新",
                    noProjectSelected = "先选择一个项目。",
                    projectDetail = "项目详情",
                    backToProjects = "返回",
                    analyzeThisProject = "分析这个项目",
                    pushed = "最近推送",
                    openIssues = "Open issues",
                    topics = "Topics",
                    analysis = "分析",
                    analysisSubtitle = "使用选定供应商和模型生成结构化评估。",
                    analysisConfiguration = "分析配置",
                    analyze = "分析",
                    noAnalysis = "当前项目还没有分析。",
                    useCases = "使用场景",
                    techStack = "技术栈",
                    risks = "风险",
                    licenseFinding = "许可证判断",
                    maintenanceActivity = "维护活跃度",
                    analysisDimensions = "评估维度",
                    architectureNotes = "架构观察",
                    qualitySignals = "质量信号",
                    securityNotes = "安全注意",
                    businessFit = "业务适配",
                    recommendation = "建议",
                    nextSteps = "下一步",
                    evidence = "证据",
                    model = "模型",
                    companyApiSuggestions = "公司 API 建议",
                    exportThisAnalysis = "导出当前项目",
                    exports = "导出",
                    exportsSubtitle = "生成本地 JSON、CSV、Markdown、PDF、PNG 或 TypeScript 模块。",
                    exportHistory = "导出历史",
                    history = "历史",
                    emptyExports = "还没有导出记录。",
                    openExportFile = "打开",
                    deleteExport = "删除",
                    close = "关闭",
                    imagePreview = "图片预览",
                    openExportFileFailed = "无法预览这张图片。",
                    settings = "设置",
                    settingsSubtitle = "配置语言、视觉风格、供应商、凭据和 MCP 权限。",
                    displayLanguage = "显示语言",
                    systemLanguage = "系统",
                    themeMode = "主题模式",
                    themeLight = "浅色",
                    themeDark = "深色",
                    themeColor = "主题色",
                    themeColorHint = "用于按钮、选中态、图标强调和图表强调色。",
                    appearanceSettings = "外观",
                    appearanceSettingsSubtitle = "配置视觉风格、主题色和液态玻璃填色。",
                    appearanceSummary = "视觉风格、主题色和液态玻璃填色。",
                    configureAppearance = "配置外观",
                    visualStyle = "视觉风格",
                    liquidGlassFillColor = "液态玻璃填色",
                    defaultColor = "默认",
                    androidGlassBackground = "Android 液态玻璃背景",
                    androidGlassBackgroundHint = "可填 #RRGGBB；留空时浅色默认白色，深色默认黑色。",
                    saveAppearance = "保存外观",
                    aiProviders = "AI 供应商",
                    configureProviders = "配置供应商",
                    providerSettingsDetailSubtitle = "管理供应商、API Key、模型、结构化输出和调用能力。",
                    providerName = "供应商名称",
                    addProvider = "新增供应商",
                    deleteProvider = "删除供应商",
                    fetchProviderModels = "拉取模型",
                    selectedProviderApiKey = "当前供应商 API Key",
                    tokenMixProviderHint = "推荐 API：TokenMix。请到 https://tokenmix.ai 注册并创建 API Key。",
                    defaultModel = "默认模型",
                    protocol = "协议",
                    baseUrl = "Base URL",
                    contextLength = "上下文长度",
                    temperature = "temperature",
                    maxOutputTokens = "最大输出 Token",
                    structuredOutput = "结构化输出",
                    toolCalling = "工具调用",
                    enabled = "开",
                    disabled = "关",
                    saveProvider = "保存供应商",
                    credentials = "凭据",
                    saveGithubToken = "保存 GitHub",
                    githubTokenHint = "不填也能搜索，但 GitHub API 额度较低。可到 https://github.com/settings/tokens 创建 Token，保存后只写入安全存储。",
                    saveProviderKey = "保存 AI Key",
                    showSecret = "显示",
                    hideSecret = "隐藏",
                    mcpWriteAccess = "MCP 写入权限",
                    desktopOnly = "仅桌面本地集成。",
                    navItems = listOf("发现", "项目", "分析", "导出", "设置"),
                )
            }
        }
    }
}

internal fun View.attachShellAndroidXViewTreeOwners(activity: FragmentActivity) {
    setTag(androidx.lifecycle.runtime.R.id.view_tree_lifecycle_owner, activity)
    setTag(androidx.lifecycle.viewmodel.R.id.view_tree_view_model_store_owner, activity)
    setTag(androidx.savedstate.R.id.view_tree_saved_state_registry_owner, activity)
}

internal fun Any?.asStringMap(): Map<String, Any?> {
    return (this as? Map<*, *>)
        ?.mapKeys { "${it.key}" }
        ?.mapValues { it.value }
        ?: emptyMap()
}

internal fun Any?.asMapList(): List<Map<String, Any?>> {
    return (this as? List<*>)
        ?.map { it.asStringMap() }
        ?: emptyList()
}

internal fun Any?.stringList(): List<String> {
    return (this as? List<*>)?.mapNotNull { it as? String } ?: emptyList()
}

internal fun Any?.intValue(defaultValue: Int = 0): Int {
    return (this as? Number)?.toInt() ?: defaultValue
}

internal fun Any?.doubleValue(defaultValue: Double = 0.0): Double {
    return (this as? Number)?.toDouble() ?: defaultValue
}

internal fun Int.compactString(): String {
    return when {
        this >= 1_000_000 -> String.format("%.1fM", this / 1_000_000.0)
        this >= 1_000 -> String.format("%.1fK", this / 1_000.0)
        else -> toString()
    }
}
