import Flutter
import SwiftUI
import UIKit

struct RepoLensNativeSnapshot {
  var navigationIndex = 0
  var isBootstrapping = true
  var isDiscovering = false
  var isAnalyzing = false
  var isExporting = false
  var isFetchingModels = false
  var projectDetailOpen = false
  var settingsProviderDetailOpen = false
  var settingsAppearanceDetailOpen = false
  var selectedProjectFullName: String?
  var errorMessage: String?
  var noticeMessage: String?
  var previewImagePath: String?
  var totalStars = 0
  var averageScore = 0.0
  var filters = RepoLensNativeFilters()
  var settings = RepoLensNativeSettings()
  var projects: [RepoLensNativeProject] = []
  var analyses: [RepoLensNativeAnalysis] = []
  var exports: [RepoLensNativeExport] = []
  var strings = RepoLensNativeStrings.current

  static let empty = RepoLensNativeSnapshot()

  init() {}

  init(map: [String: Any]) {
    navigationIndex = map["navigationIndex"] as? Int ?? 0
    isBootstrapping = map["isBootstrapping"] as? Bool ?? false
    isDiscovering = map["isDiscovering"] as? Bool ?? false
    isAnalyzing = map["isAnalyzing"] as? Bool ?? false
    isExporting = map["isExporting"] as? Bool ?? false
    isFetchingModels = map["isFetchingModels"] as? Bool ?? false
    projectDetailOpen = map["projectDetailOpen"] as? Bool ?? false
    settingsProviderDetailOpen = map["settingsProviderDetailOpen"] as? Bool ?? false
    settingsAppearanceDetailOpen = map["settingsAppearanceDetailOpen"] as? Bool ?? false
    selectedProjectFullName = map["selectedProjectFullName"] as? String
    errorMessage = map["errorMessage"] as? String
    noticeMessage = map["noticeMessage"] as? String
    previewImagePath = map["previewImagePath"] as? String
    totalStars = map["totalStars"] as? Int ?? 0
    averageScore = map["averageScore"] as? Double ?? 0
    filters = RepoLensNativeFilters(map: map["filters"] as? [String: Any] ?? [:])
    settings = RepoLensNativeSettings(map: map["settings"] as? [String: Any] ?? [:])
    projects = (map["projects"] as? [[String: Any]] ?? []).map(RepoLensNativeProject.init)
    analyses = (map["analyses"] as? [[String: Any]] ?? []).map(RepoLensNativeAnalysis.init)
    exports = (map["exports"] as? [[String: Any]] ?? []).map(RepoLensNativeExport.init)
    strings = RepoLensNativeStrings(language: settings.language)
  }

  var selectedProject: RepoLensNativeProject? {
    guard let selectedProjectFullName else {
      return projects.first
    }
    return projects.first { $0.fullName == selectedProjectFullName } ?? projects.first
  }

  var selectedAnalysis: RepoLensNativeAnalysis? {
    guard let fullName = selectedProject?.fullName else {
      return nil
    }
    return analyses.first { $0.projectFullName == fullName }
  }

  var message: String? {
    errorMessage ?? noticeMessage
  }
}

struct RepoLensNativeFilters {
  var keyword = "agent OR LLM OR RAG OR MCP"
  var dateRange = "This week"
  var language = "Any"
  var minStars = 50

  init() {}

  init(map: [String: Any]) {
    keyword = map["keyword"] as? String ?? keyword
    dateRange = map["dateRange"] as? String ?? dateRange
    language = map["language"] as? String ?? language
    minStars = map["minStars"] as? Int ?? minStars
  }
}

struct RepoLensNativeSettings {
  var language = "system"
  var themeMode = "system"
  var themeColor = "#2F7D5F"
  var androidLiquidGlassBackground = ""
  var mcpWriteAccessEnabled = false
  var providerRaw: [String: Any] = [:]
  var providers: [RepoLensNativeProvider] = []
  var selectedProviderId = "openai-compatible-custom"
  var providerName = "OpenAI-compatible"
  var providerProtocol = "openAiChatCompletions"
  var baseUrl = "https://api.openai.com/v1"
  var defaultModel = "gpt-4.1-mini"
  var availableModels: [RepoLensNativeModel] = []
  var contextLength = 128000
  var temperature = 0.2
  var maxOutputTokens = 2200
  var supportsStructuredOutput = true
  var supportsToolCalling = true

  init() {}

  init(map: [String: Any]) {
    language = map["language"] as? String ?? language
    themeMode = map["themeMode"] as? String ?? themeMode
    themeColor = map["themeColor"] as? String ?? themeColor
    androidLiquidGlassBackground = map["androidLiquidGlassBackground"] as? String ?? androidLiquidGlassBackground
    mcpWriteAccessEnabled = map["mcpWriteAccessEnabled"] as? Bool ?? false
    providerRaw = map["provider"] as? [String: Any] ?? [:]
    providers = (map["providers"] as? [[String: Any]] ?? [providerRaw]).map(RepoLensNativeProvider.init)
    selectedProviderId = map["selectedProviderId"] as? String ?? providers.first?.id ?? selectedProviderId
    providerName = providerRaw["name"] as? String ?? providerName
    providerProtocol = providerRaw["protocol"] as? String ?? providerProtocol
    baseUrl = providerRaw["baseUrl"] as? String ?? baseUrl
    defaultModel = providerRaw["defaultModel"] as? String ?? defaultModel
    availableModels = (providerRaw["availableModels"] as? [[String: Any]] ?? []).map(RepoLensNativeModel.init)
    contextLength = providerRaw["contextLength"] as? Int ?? contextLength
    temperature = providerRaw["temperature"] as? Double ?? temperature
    maxOutputTokens = providerRaw["maxOutputTokens"] as? Int ?? maxOutputTokens
    supportsStructuredOutput = providerRaw["supportsStructuredOutput"] as? Bool ?? supportsStructuredOutput
    supportsToolCalling = providerRaw["supportsToolCalling"] as? Bool ?? supportsToolCalling
  }

  var themeAccentColor: Color {
    Color(hex: themeColor) ?? RepoLensNativeTokens.defaultAccent
  }
}

struct RepoLensNativeProvider: Identifiable {
  var id: String
  let name: String
  let defaultModel: String

  init(map: [String: Any]) {
    id = map["id"] as? String ?? "openai-compatible-custom"
    name = map["name"] as? String ?? "OpenAI-compatible"
    defaultModel = map["defaultModel"] as? String ?? "gpt-4.1-mini"
  }
}

struct RepoLensNativeModel: Identifiable {
  var id: String
  let displayName: String
  let contextLength: Int
  let supportsStructuredOutput: Bool
  let supportsToolCalling: Bool

  init(map: [String: Any]) {
    id = map["id"] as? String ?? ""
    displayName = map["displayName"] as? String ?? id
    contextLength = map["contextLength"] as? Int ?? 32000
    supportsStructuredOutput = map["supportsStructuredOutput"] as? Bool ?? true
    supportsToolCalling = map["supportsToolCalling"] as? Bool ?? false
  }

  func toMap() -> [String: Any] {
    [
      "id": id,
      "displayName": displayName,
      "contextLength": contextLength,
      "supportsStructuredOutput": supportsStructuredOutput,
      "supportsToolCalling": supportsToolCalling,
    ]
  }
}

struct RepoLensNativeProject: Identifiable {
  var id: String { fullName }
  let fullName: String
  let htmlUrl: String
  let description: String
  let language: String
  let stars: Int
  let forks: Int
  let openIssues: Int
  let topics: [String]
  let license: String
  let pushedAtDisplay: String
  let isFavorite: Bool

  init(map: [String: Any]) {
    fullName = map["fullName"] as? String ?? ""
    htmlUrl = map["htmlUrl"] as? String ?? ""
    description = map["description"] as? String ?? ""
    language = map["language"] as? String ?? "Unknown"
    stars = map["stars"] as? Int ?? 0
    forks = map["forks"] as? Int ?? 0
    openIssues = map["openIssues"] as? Int ?? 0
    topics = map["topics"] as? [String] ?? []
    license = map["license"] as? String ?? "Unknown"
    pushedAtDisplay = String((map["pushedAt"] as? String ?? "").prefix(10))
    isFavorite = map["isFavorite"] as? Bool ?? false
  }
}

struct RepoLensNativeAnalysis: Identifiable {
  var id: String { projectFullName }
  let projectFullName: String
  let category: String
  let summary: String
  let useCases: [String]
  let techStack: [String]
  let risks: [String]
  let score: Double
  let dimensions: [RepoLensNativeAnalysisDimension]
  let architectureNotes: [String]
  let qualitySignals: [String]
  let securityNotes: [String]
  let businessFit: String
  let recommendation: String
  let nextSteps: [String]
  let companyApiSuggestions: [RepoLensNativeApiMapping]

  init(map: [String: Any]) {
    projectFullName = map["projectFullName"] as? String ?? ""
    category = map["category"] as? String ?? "AI Tool"
    summary = map["summary"] as? String ?? ""
    useCases = map["useCases"] as? [String] ?? []
    techStack = map["techStack"] as? [String] ?? []
    risks = map["risks"] as? [String] ?? []
    score = map["score"] as? Double ?? 0
    dimensions = (map["dimensions"] as? [[String: Any]] ?? [])
      .map(RepoLensNativeAnalysisDimension.init)
    architectureNotes = map["architectureNotes"] as? [String] ?? []
    qualitySignals = map["qualitySignals"] as? [String] ?? []
    securityNotes = map["securityNotes"] as? [String] ?? []
    businessFit = map["businessFit"] as? String ?? ""
    recommendation = map["recommendation"] as? String ?? ""
    nextSteps = map["nextSteps"] as? [String] ?? []
    companyApiSuggestions = (map["companyApiSuggestions"] as? [[String: Any]] ?? [])
      .map(RepoLensNativeApiMapping.init)
  }
}

struct RepoLensNativeAnalysisDimension: Identifiable {
  var id: String { key.isEmpty ? title : key }
  let key: String
  let title: String
  let score: Double
  let summary: String
  let evidence: [String]

  init(map: [String: Any]) {
    key = map["key"] as? String ?? ""
    title = map["title"] as? String ?? key
    score = map["score"] as? Double ?? 0
    summary = map["summary"] as? String ?? ""
    evidence = map["evidence"] as? [String] ?? []
  }
}

struct RepoLensNativeApiMapping {
  let apiName: String
  let rationale: String

  init(map: [String: Any]) {
    apiName = map["apiName"] as? String ?? ""
    rationale = map["rationale"] as? String ?? ""
  }
}

struct RepoLensNativeExport: Identifiable {
  var id: String
  let format: String
  let filePath: String
  let projectCount: Int

  init(map: [String: Any]) {
    id = map["id"] as? String ?? UUID().uuidString
    format = map["format"] as? String ?? "json"
    filePath = map["filePath"] as? String ?? ""
    projectCount = map["projectCount"] as? Int ?? 0
  }
}

struct RepoLensNativeStrings {
  let zh: Bool

  static var current: RepoLensNativeStrings {
    RepoLensNativeStrings(
      language: Locale.preferredLanguages.first?.lowercased().hasPrefix("en") == true
        ? "english"
        : "simplifiedChinese"
    )
  }

  init(language: String) {
    if language == "english" {
      zh = false
    } else if language == "simplifiedChinese" {
      zh = true
    } else {
      zh = !(Locale.preferredLanguages.first?.lowercased().hasPrefix("en") == true)
    }
  }

  var discovery: String { zh ? "发现" : "Discovery" }
  var discoverySubtitle: String { zh ? "直接从 GitHub 搜索 AI 工具项目" : "Search AI tool repositories directly from GitHub" }
  var projectLibrary: String { zh ? "项目库" : "Project Library" }
  var projectLibrarySubtitle: String { zh ? "本地缓存、收藏和项目详情" : "Local cache, favorites, and project details" }
  var analysis: String { zh ? "分析" : "Analysis" }
  var analysisSubtitle: String { zh ? "用自定义 AI 供应商生成结构化判断" : "Generate structured findings with your selected AI provider" }
  var exports: String { zh ? "导出" : "Exports" }
  var exportsSubtitle: String { zh ? "生成 JSON、CSV、Markdown、PDF、PNG 和 TypeScript 模块" : "Generate JSON, CSV, Markdown, PDF, PNG, and TypeScript modules" }
  var settings: String { zh ? "设置" : "Settings" }
  var settingsSubtitle: String { zh ? "语言、供应商、凭据和本地 MCP 权限" : "Language, providers, credentials, and local MCP access" }
  var discover: String { zh ? "发现项目" : "Discover" }
  var refresh: String { zh ? "刷新" : "Refresh" }
  var loading: String { zh ? "处理中" : "Working" }
  var projects: String { zh ? "项目" : "Projects" }
  var stars: String { zh ? "Stars" : "Stars" }
  var analyses: String { zh ? "分析" : "Analyses" }
  var averageScore: String { zh ? "平均分" : "Avg Score" }
  var searchFilters: String { zh ? "搜索过滤" : "Search Filters" }
  var keyword: String { zh ? "关键词" : "Keyword" }
  var date: String { zh ? "时间" : "Date" }
  var language: String { zh ? "语言" : "Language" }
  var today: String { zh ? "今天" : "Today" }
  var thisWeek: String { zh ? "本周" : "This week" }
  var any: String { zh ? "不限" : "Any" }
  var minStars: String { zh ? "最低 Stars" : "Minimum stars" }
  var search: String { zh ? "搜索" : "Search" }
  var emptyProjects: String { zh ? "还没有项目，先运行一次发现。" : "No projects yet. Run discovery first." }
  var projectSearch: String { zh ? "搜索项目" : "Search projects" }
  var noProjectSearchResults: String { zh ? "没有匹配的项目。" : "No matching projects." }
  var noProjectSelected: String { zh ? "未选择项目" : "No project selected" }
  var projectDetail: String { zh ? "项目详情" : "Project details" }
  var backToProjects: String { zh ? "返回项目列表" : "Back to projects" }
  var analyzeThisProject: String { zh ? "分析这个项目" : "Analyze this project" }
  var pushed: String { zh ? "最近推送" : "Pushed" }
  var analyze: String { zh ? "分析当前项目" : "Analyze selected" }
  var noAnalysis: String { zh ? "当前项目还没有分析结果。" : "No analysis for the selected project yet." }
  var analysisConfiguration: String { zh ? "分析配置" : "Analysis configuration" }
  var useCases: String { zh ? "使用场景" : "Use cases" }
  var techStack: String { zh ? "技术栈" : "Tech stack" }
  var risks: String { zh ? "风险" : "Risks" }
  var analysisDimensions: String { zh ? "评估维度" : "Evaluation dimensions" }
  var architectureNotes: String { zh ? "架构观察" : "Architecture notes" }
  var qualitySignals: String { zh ? "质量信号" : "Quality signals" }
  var securityNotes: String { zh ? "安全注意" : "Security notes" }
  var businessFit: String { zh ? "业务适配" : "Business fit" }
  var recommendation: String { zh ? "建议" : "Recommendation" }
  var nextSteps: String { zh ? "下一步" : "Next steps" }
  var evidence: String { zh ? "证据" : "Evidence" }
  var companyApiSuggestions: String { zh ? "公司 API 匹配建议" : "Company API suggestions" }
  var exportThisAnalysis: String { zh ? "导出当前项目" : "Export current project" }
  var exportHistory: String { zh ? "导出历史" : "Export history" }
  var history: String { zh ? "历史" : "History" }
  var emptyExports: String { zh ? "还没有导出记录。" : "No exports yet." }
  var openExportFile: String { zh ? "预览/打开" : "Preview/Open" }
  var deleteExport: String { zh ? "删除" : "Delete" }
  var close: String { zh ? "关闭" : "Close" }
  var imagePreview: String { zh ? "图片预览" : "Image preview" }
  var openExportFileFailed: String { zh ? "无法预览这张图片。" : "Could not preview this image." }
  var displayLanguage: String { zh ? "显示语言" : "Display language" }
  var systemLanguage: String { zh ? "跟随系统" : "System" }
  var themeMode: String { zh ? "主题模式" : "Theme" }
  var themeLight: String { zh ? "浅色" : "Light" }
  var themeDark: String { zh ? "深色" : "Dark" }
  var themeColor: String { zh ? "主题色" : "Theme color" }
  var themeColorHint: String { zh ? "用于按钮、选中态、图标强调和图表强调色。" : "Used for buttons, selected state, emphasized icons, and charts." }
  var appearanceSettings: String { zh ? "外观" : "Appearance" }
  var appearanceSettingsSubtitle: String { zh ? "配置视觉风格、主题色和液态玻璃填色。" : "Configure visual style, theme color, and Liquid Glass fill." }
  var appearanceSummary: String { zh ? "视觉风格、主题色和液态玻璃填色。" : "Visual style, theme color, and Liquid Glass fill." }
  var configureAppearance: String { zh ? "配置外观" : "Configure appearance" }
  var aiProviders: String { zh ? "AI 供应商" : "AI providers" }
  var configureProviders: String { zh ? "配置供应商" : "Configure providers" }
  var providerSettingsDetailSubtitle: String { zh ? "管理供应商、API Key、模型、结构化输出和调用能力。" : "Manage providers, API keys, models, structured output, and calling capabilities." }
  var providerName: String { zh ? "供应商名称" : "Provider name" }
  var addProvider: String { zh ? "新增供应商" : "Add provider" }
  var deleteProvider: String { zh ? "删除供应商" : "Delete provider" }
  var fetchProviderModels: String { zh ? "拉取模型" : "Fetch models" }
  var selectedProviderApiKey: String { zh ? "当前供应商 API Key" : "Selected provider API key" }
  var tokenMixProviderHint: String { zh ? "推荐 API：TokenMix。请到 https://tokenmix.ai 注册并创建 API Key。" : "Recommended API: TokenMix. Register at https://tokenmix.ai and create an API key." }
  var defaultModel: String { zh ? "默认模型" : "Default model" }
  var contextLength: String { zh ? "上下文长度" : "Context length" }
  var structuredOutput: String { zh ? "结构化输出" : "Structured output" }
  var toolCalling: String { zh ? "工具调用" : "Tool calling" }
  var saveProvider: String { zh ? "保存供应商" : "Save provider" }
  var credentials: String { zh ? "凭据" : "Credentials" }
  var saveGithubToken: String { zh ? "保存 GitHub Token" : "Save GitHub token" }
  var githubTokenHint: String { zh ? "不填也能搜索，但 GitHub API 额度较低。可到 https://github.com/settings/tokens 创建 Token，保存后只写入安全存储。" : "Discovery works without one, but GitHub API limits are lower. Create one at https://github.com/settings/tokens; RepoLens stores it only in secure storage." }
  var saveProviderKey: String { zh ? "保存 Provider Key" : "Save provider key" }
  var showSecret: String { zh ? "显示" : "Show" }
  var hideSecret: String { zh ? "隐藏" : "Hide" }
  var mcpWriteAccess: String { zh ? "允许 MCP 写入外部项目" : "Allow MCP writes" }

  func exportLabel(_ format: String) -> String {
    switch format {
    case "json": return "JSON"
    case "csv": return "CSV"
    case "markdown": return "Markdown"
    case "pdf": return "PDF"
    case "png": return "PNG"
    case "typeScriptModule": return "TypeScript"
    default: return format
    }
  }
}
