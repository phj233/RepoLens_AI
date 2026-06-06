import 'package:flutter/widgets.dart';

import '../models/repolens_models.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('zh', 'CN'), Locale('en')];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? AppLocalizations(const Locale('zh', 'CN'));
  }

  bool get isEnglish => locale.languageCode == 'en';

  String t(String key) {
    return (isEnglish ? _en : _zh)[key] ?? _zh[key] ?? key;
  }

  String dateRangeLabel(String value) {
    return switch (value) {
      'Today' => t('dateToday'),
      'This week' => t('dateThisWeek'),
      'Any' => t('dateAny'),
      _ => value,
    };
  }

  String languageFilterLabel(String value) {
    if (value == 'Any') {
      return t('languageAny');
    }
    return value;
  }

  String minStars(int value) {
    return isEnglish ? 'Minimum stars: $value' : '最低 stars: $value';
  }

  String languageCode(AppLanguage language) {
    return switch (language) {
      AppLanguage.system => isEnglish ? 'System' : '系统',
      AppLanguage.simplifiedChinese => '中',
      AppLanguage.english => 'EN',
    };
  }

  String projectCountSummary(int projects, int analyses) {
    return isEnglish
        ? '$projects projects, $analyses analyses'
        : '$projects 个项目，$analyses 个分析';
  }

  String updatedProjects(int count) {
    return isEnglish
        ? 'Updated $count GitHub projects.'
        : '已更新 $count 个 GitHub 项目。';
  }

  String generatedAnalysis(String fullName) {
    return isEnglish
        ? 'Generated analysis for $fullName.'
        : '已生成 $fullName 的分析结果。';
  }

  String analysisFailedWithDetail(String detail) {
    final trimmed = detail.trim();
    if (trimmed.isEmpty) {
      return t('analysisFailed');
    }
    return isEnglish
        ? '${t('analysisFailed')}\nDetail: $trimmed'
        : '${t('analysisFailed')}\n详情：$trimmed';
  }

  String fetchProviderModelsFailedWithDetail(String detail) {
    final trimmed = detail.trim();
    if (trimmed.isEmpty) {
      return t('fetchProviderModelsFailed');
    }
    return isEnglish
        ? '${t('fetchProviderModelsFailed')}\nDetail: $trimmed'
        : '${t('fetchProviderModelsFailed')}\n详情：$trimmed';
  }

  String exportedTo(String path) {
    return isEnglish ? 'Exported to $path' : '已导出到 $path';
  }

  String providerModelsFetched(int count) {
    return isEnglish ? 'Fetched $count provider models.' : '已拉取 $count 个供应商模型。';
  }

  String settingSaved(String target) {
    return isEnglish ? '$target saved.' : '$target 已保存。';
  }

  String languageName(AppLanguage language) {
    return switch (language) {
      AppLanguage.system => t('languageSystem'),
      AppLanguage.simplifiedChinese => '简体中文',
      AppLanguage.english => 'English',
    };
  }

  String themeModeName(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => t('themeSystem'),
      AppThemeMode.light => t('themeLight'),
      AppThemeMode.dark => t('themeDark'),
    };
  }

  static String messageForLanguage(AppLanguage language, String key) {
    final localizations = AppLocalizations(
      language == AppLanguage.english
          ? const Locale('en')
          : const Locale('zh', 'CN'),
    );
    return localizations.t(key);
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const _zh = {
  'appSubtitle': '本地优先智能工作台',
  'navDiscoveryShort': '发现',
  'navProjectsShort': '项目',
  'navAnalysisShort': '分析',
  'navExportsShort': '导出',
  'navSettingsShort': '设置',
  'navDiscovery': 'GitHub 发现',
  'navProjects': '项目库',
  'navAnalysis': 'AI 分析',
  'navExports': '导出',
  'navSettings': '设置',
  'dashboardTitle': 'GitHub AI 工具雷达',
  'dashboardSubtitle': '发现、分析、导出适合公司 API 能力复用的开源项目。',
  'discoverProjects': '发现项目',
  'projectsMetric': 'Projects',
  'starsMetric': 'Stars',
  'analysesMetric': 'Analyses',
  'avgScoreMetric': 'Avg score',
  'searchFilters': '搜索条件',
  'keyword': '关键词',
  'date': '时间',
  'dateToday': '今天',
  'dateThisWeek': '本周',
  'dateAny': '全部',
  'language': '语言',
  'languageAny': '任意',
  'search': '搜索',
  'projectSearch': '搜索项目',
  'noProjectSearchResults': '没有匹配的项目',
  'languageHeat': '语言热度',
  'noTrendData': '暂无趋势数据',
  'projectCandidates': '项目候选',
  'noProjects': '暂无项目',
  'favorite': '收藏',
  'unfavorite': '取消收藏',
  'noDescription': '暂无描述',
  'pending': 'Pending',
  'projectLibraryTitle': '项目库',
  'projectLibrarySubtitle': '本地缓存按 GitHub full name 去重，收藏会优先展示。',
  'refresh': '刷新',
  'noProjectSelected': '未选择项目',
  'projectDetailEmpty': '选择一个项目查看 GitHub 元数据和本地分析上下文。',
  'projectDetail': '项目详情',
  'backToProjects': '返回项目列表',
  'analyzeThisProject': '分析这个项目',
  'openIssues': 'Open issues',
  'pushed': 'Pushed',
  'analysisTitle': 'AI 分析',
  'noProjectSelectedSubtitle': '未选择项目',
  'generateAnalysis': '生成分析',
  'noAnalyzableProjects': '暂无可分析项目',
  'noStructuredAnalysis': '该项目还没有结构化分析。',
  'useCases': '使用场景',
  'techStack': '技术栈',
  'risks': '风险',
  'companyApiMapping': '公司 API 匹配',
  'noMappingSuggestions': '暂无匹配建议',
  'exportThisAnalysis': '导出当前项目',
  'exportTitle': '导出',
  'exportSubtitle': '所有导出都从本地结构化数据生成。',
  'exportHistory': '导出记录',
  'history': '历史',
  'noExports': '暂无导出记录',
  'openExportFile': '预览/打开',
  'deleteExport': '删除',
  'openingExportFile': '正在打开导出文件...',
  'previewingExportImage': '正在应用内预览图片。',
  'exportFileOpened': '已请求系统打开导出文件。',
  'openExportFileFailed': '无法打开导出文件。文件可能已被移动，或系统没有可用应用。',
  'exportDeleted': '导出记录和对应文件已删除。',
  'deleteExportFailed': '删除导出失败，请检查文件权限。',
  'close': '关闭',
  'imagePreview': '图片预览',
  'settingsSubtitle': '密钥写入安全存储，SQLite 只保存非敏感配置。',
  'displayLanguage': '显示语言',
  'languageSystem': '跟随系统',
  'simplifiedChinese': '简体中文',
  'english': 'English',
  'visualMode': '视觉模式',
  'liquidGlass': '液态玻璃',
  'themeMode': '主题模式',
  'themeSystem': '跟随系统',
  'themeLight': '浅色',
  'themeDark': '深色',
  'themeColor': '主题色',
  'themeColorHint': '用于按钮、选中态、图标强调和图表强调色。',
  'appearanceSettings': '外观',
  'appearanceSettingsSubtitle': '配置视觉风格、主题色和液态玻璃填色。',
  'appearanceSummary': '视觉风格、主题色和液态玻璃填色。',
  'configureAppearance': '配置外观',
  'defaultColor': '默认',
  'androidGlassBackground': 'Android 液态玻璃背景',
  'liquidGlassFillColor': '液态玻璃填色',
  'androidGlassBackgroundHint': '可填 #RRGGBB；留空时浅色默认白色，深色默认黑色。',
  'saveAppearance': '保存外观',
  'aiProviders': 'AI 供应商',
  'configureProviders': '配置供应商',
  'providerSettingsDetailSubtitle': '管理供应商、API Key、模型、结构化输出和调用能力。',
  'addProvider': '新增供应商',
  'deleteProvider': '删除供应商',
  'fetchProviderModels': '拉取模型',
  'selectedProviderApiKey': '当前供应商 API Key',
  'tokenMixProviderHint':
      '推荐 API：TokenMix。请到 https://tokenmix.ai 注册并创建 API Key；它通过一个 OpenAI-compatible endpoint 接入多家模型。',
  'providerName': '供应商名称',
  'defaultModel': '默认模型',
  'contextLength': '上下文长度',
  'structuredOutput': '结构化输出',
  'toolCalling': 'Tool calling',
  'saveProvider': '保存 Provider',
  'credentials': '凭据',
  'saveGithubToken': '保存 GitHub Token',
  'githubTokenHint':
      '不填也能搜索，但 GitHub API 额度较低。可到 https://github.com/settings/tokens 创建 Token，保存后只写入安全存储。',
  'saveProviderKey': '保存 Provider Key',
  'showSecret': '显示',
  'hideSecret': '隐藏',
  'mcpWriteAccess': 'MCP write_import_file 写入权限',
  'mcpWriteAccessSubtitle': '关闭时，本地 MCP sidecar 不能写入外部项目文件。',
  'backdropReady': 'Backdrop ready',
  'nativeBridgeIdle': 'Native bridge idle',
  'renderEffect': 'RenderEffect',
  'flutterFallback': 'Flutter fallback',
  'lens': 'Lens',
  'noLens': 'No lens',
  'loadingGithub': '正在从 GitHub 拉取项目...',
  'githubSearchFailed': 'GitHub 搜索失败。请检查网络、搜索条件或 GitHub Token。',
  'generatingAnalysis': '正在生成结构化分析...',
  'analysisFailed': '分析失败，请检查 AI Provider、模型或 API Key。',
  'analysisConfiguration': '分析配置',
  'analysisDimensions': '评估维度',
  'architectureNotes': '架构观察',
  'qualitySignals': '质量信号',
  'securityNotes': '安全注意',
  'businessFit': '业务适配',
  'recommendation': '建议',
  'nextSteps': '下一步',
  'evidence': '证据',
  'providerSaved': 'AI Provider 已保存。',
  'providerDeleted': 'AI Provider 已删除。',
  'cannotDeleteLastProvider': '至少需要保留一个 AI Provider。',
  'fetchingProviderModels': '正在从当前供应商拉取模型列表...',
  'fetchProviderModelsFailed': '拉取模型失败，请检查 Base URL、协议和当前供应商 API Key。',
  'githubTokenSaved': 'GitHub Token 已写入安全存储。',
  'providerKeySaved': 'AI Provider Key 已写入安全存储。',
  'generatingExport': '正在生成导出文件...',
  'exportFailed': '导出失败，请稍后重试或检查文件权限。',
  'databaseFallback': '本地数据库暂时不可用，已加载示例数据；不会影响密钥安全。',
};

const _en = {
  'appSubtitle': 'Local-first intelligence',
  'navDiscoveryShort': 'Discover',
  'navProjectsShort': 'Projects',
  'navAnalysisShort': 'Analysis',
  'navExportsShort': 'Exports',
  'navSettingsShort': 'Settings',
  'navDiscovery': 'GitHub Discovery',
  'navProjects': 'Project Library',
  'navAnalysis': 'AI Analysis',
  'navExports': 'Exports',
  'navSettings': 'Settings',
  'dashboardTitle': 'GitHub AI Tool Radar',
  'dashboardSubtitle':
      'Discover, analyze, and export open-source projects that fit company API reuse.',
  'discoverProjects': 'Discover',
  'projectsMetric': 'Projects',
  'starsMetric': 'Stars',
  'analysesMetric': 'Analyses',
  'avgScoreMetric': 'Avg score',
  'searchFilters': 'Search filters',
  'keyword': 'Keyword',
  'date': 'Date',
  'dateToday': 'Today',
  'dateThisWeek': 'This week',
  'dateAny': 'Any',
  'language': 'Language',
  'languageAny': 'Any',
  'search': 'Search',
  'projectSearch': 'Search projects',
  'noProjectSearchResults': 'No matching projects',
  'languageHeat': 'Language heat',
  'noTrendData': 'No trend data',
  'projectCandidates': 'Project candidates',
  'noProjects': 'No projects',
  'favorite': 'Favorite',
  'unfavorite': 'Remove favorite',
  'noDescription': 'No description',
  'pending': 'Pending',
  'projectLibraryTitle': 'Project Library',
  'projectLibrarySubtitle':
      'Local cache deduplicates by GitHub full name. Favorites appear first.',
  'refresh': 'Refresh',
  'noProjectSelected': 'No project selected',
  'projectDetailEmpty':
      'Select a project to inspect GitHub metadata and local analysis context.',
  'projectDetail': 'Project details',
  'backToProjects': 'Back to projects',
  'analyzeThisProject': 'Analyze this project',
  'openIssues': 'Open issues',
  'pushed': 'Pushed',
  'analysisTitle': 'AI Analysis',
  'noProjectSelectedSubtitle': 'No project selected',
  'generateAnalysis': 'Analyze',
  'noAnalyzableProjects': 'No project available for analysis',
  'noStructuredAnalysis': 'This project does not have structured analysis yet.',
  'useCases': 'Use cases',
  'techStack': 'Tech stack',
  'risks': 'Risks',
  'companyApiMapping': 'Company API mapping',
  'noMappingSuggestions': 'No mapping suggestions',
  'exportThisAnalysis': 'Export current project',
  'exportTitle': 'Exports',
  'exportSubtitle': 'All exports are generated from structured local data.',
  'exportHistory': 'Export history',
  'history': 'History',
  'noExports': 'No exports yet',
  'openExportFile': 'Preview/Open',
  'deleteExport': 'Delete',
  'openingExportFile': 'Opening export file...',
  'previewingExportImage': 'Previewing image in RepoLens AI.',
  'exportFileOpened': 'Asked the system to open the export file.',
  'openExportFileFailed':
      'Could not open the export file. It may have moved, or no app can handle it.',
  'exportDeleted': 'Export history item and file deleted.',
  'deleteExportFailed': 'Could not delete export. Check file permissions.',
  'close': 'Close',
  'imagePreview': 'Image preview',
  'settingsSubtitle':
      'Secrets go to secure storage. SQLite stores only non-sensitive settings.',
  'displayLanguage': 'Display language',
  'languageSystem': 'System',
  'simplifiedChinese': '简体中文',
  'english': 'English',
  'visualMode': 'Visual mode',
  'liquidGlass': 'Liquid Glass',
  'themeMode': 'Theme',
  'themeSystem': 'System',
  'themeLight': 'Light',
  'themeDark': 'Dark',
  'themeColor': 'Theme color',
  'themeColorHint':
      'Used for buttons, selected state, emphasized icons, and charts.',
  'appearanceSettings': 'Appearance',
  'appearanceSettingsSubtitle':
      'Configure visual style, theme color, and Liquid Glass fill.',
  'appearanceSummary': 'Visual style, theme color, and Liquid Glass fill.',
  'configureAppearance': 'Configure appearance',
  'defaultColor': 'Default',
  'androidGlassBackground': 'Android Liquid Glass background',
  'liquidGlassFillColor': 'Liquid Glass fill',
  'androidGlassBackgroundHint':
      'Use #RRGGBB. Empty uses white in light mode and black in dark mode.',
  'saveAppearance': 'Save appearance',
  'aiProviders': 'AI providers',
  'configureProviders': 'Configure providers',
  'providerSettingsDetailSubtitle':
      'Manage providers, API keys, models, structured output, and calling capabilities.',
  'addProvider': 'Add provider',
  'deleteProvider': 'Delete provider',
  'fetchProviderModels': 'Fetch models',
  'selectedProviderApiKey': 'Selected provider API key',
  'tokenMixProviderHint':
      'Recommended API: TokenMix. Register at https://tokenmix.ai and create an API key. It exposes many providers through one OpenAI-compatible endpoint.',
  'providerName': 'Provider name',
  'defaultModel': 'Default model',
  'contextLength': 'Context length',
  'structuredOutput': 'Structured output',
  'toolCalling': 'Tool calling',
  'saveProvider': 'Save provider',
  'credentials': 'Credentials',
  'saveGithubToken': 'Save GitHub token',
  'githubTokenHint':
      'Discovery works without one, but GitHub API limits are lower. Create a token at https://github.com/settings/tokens; RepoLens stores it only in secure storage.',
  'saveProviderKey': 'Save provider key',
  'showSecret': 'Show',
  'hideSecret': 'Hide',
  'mcpWriteAccess': 'MCP write_import_file access',
  'mcpWriteAccessSubtitle':
      'When disabled, the local MCP sidecar cannot write to external projects.',
  'backdropReady': 'Backdrop ready',
  'nativeBridgeIdle': 'Native bridge idle',
  'renderEffect': 'RenderEffect',
  'flutterFallback': 'Flutter fallback',
  'lens': 'Lens',
  'noLens': 'No lens',
  'loadingGithub': 'Fetching projects from GitHub...',
  'githubSearchFailed':
      'GitHub search failed. Check network, filters, or GitHub token.',
  'generatingAnalysis': 'Generating structured analysis...',
  'analysisFailed': 'Analysis failed. Check AI provider, model, or API key.',
  'analysisConfiguration': 'Analysis configuration',
  'analysisDimensions': 'Evaluation dimensions',
  'architectureNotes': 'Architecture notes',
  'qualitySignals': 'Quality signals',
  'securityNotes': 'Security notes',
  'businessFit': 'Business fit',
  'recommendation': 'Recommendation',
  'nextSteps': 'Next steps',
  'evidence': 'Evidence',
  'providerSaved': 'AI Provider saved.',
  'providerDeleted': 'AI Provider deleted.',
  'cannotDeleteLastProvider': 'Keep at least one AI Provider.',
  'fetchingProviderModels': 'Fetching models from the selected provider...',
  'fetchProviderModelsFailed':
      'Could not fetch models. Check Base URL, protocol, and provider API key.',
  'githubTokenSaved': 'GitHub token saved to secure storage.',
  'providerKeySaved': 'AI Provider key saved to secure storage.',
  'generatingExport': 'Generating export file...',
  'exportFailed': 'Export failed. Retry or check file permissions.',
  'databaseFallback':
      'Local database is temporarily unavailable. Sample data loaded; secrets remain safe.',
};
