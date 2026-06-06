enum AiProviderType {
  companyApi,
  openAiCompatible,
  anthropic,
  gemini,
  deepSeek,
  volcengineDoubao,
  ollama,
  customEndpoint,
}

enum AiProviderProtocol { openAiChatCompletions, anthropicMessages }

enum VisualStyle { liquidGlass, material3 }

enum AppLanguage { system, simplifiedChinese, english }

enum AppThemeMode { system, light, dark }

enum ExportFormat { json, csv, markdown, pdf, png, typeScriptModule }

enum AnalysisRiskLevel { low, medium, high }

class AiToolProject {
  const AiToolProject({
    required this.id,
    required this.owner,
    required this.name,
    required this.fullName,
    required this.htmlUrl,
    required this.description,
    required this.language,
    required this.stars,
    required this.forks,
    required this.openIssues,
    required this.topics,
    required this.license,
    required this.createdAt,
    required this.pushedAt,
    required this.rawMetadata,
    this.isFavorite = false,
  });

  final int id;
  final String owner;
  final String name;
  final String fullName;
  final String htmlUrl;
  final String description;
  final String language;
  final int stars;
  final int forks;
  final int openIssues;
  final List<String> topics;
  final String license;
  final DateTime createdAt;
  final DateTime pushedAt;
  final Map<String, Object?> rawMetadata;
  final bool isFavorite;

  bool get isRecentlyUpdated {
    return DateTime.now().difference(pushedAt).inDays <= 30;
  }

  AiToolProject copyWith({bool? isFavorite}) {
    return AiToolProject(
      id: id,
      owner: owner,
      name: name,
      fullName: fullName,
      htmlUrl: htmlUrl,
      description: description,
      language: language,
      stars: stars,
      forks: forks,
      openIssues: openIssues,
      topics: topics,
      license: license,
      createdAt: createdAt,
      pushedAt: pushedAt,
      rawMetadata: rawMetadata,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory AiToolProject.fromGitHubJson(Map<String, Object?> json) {
    final ownerMap = _objectMap(json['owner']);
    final licenseMap = _objectMap(json['license']);
    final topicsJson = json['topics'];

    final fullName = (json['full_name'] as String?) ?? 'unknown/unknown';
    final segments = fullName.split('/');

    return AiToolProject(
      id: (json['id'] as num?)?.toInt() ?? fullName.hashCode,
      owner:
          (ownerMap['login'] as String?) ??
          (segments.isNotEmpty ? segments.first : 'unknown'),
      name:
          (json['name'] as String?) ??
          (segments.length > 1 ? segments.last : fullName),
      fullName: fullName,
      htmlUrl: (json['html_url'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      language: (json['language'] as String?) ?? 'Unknown',
      stars: (json['stargazers_count'] as num?)?.toInt() ?? 0,
      forks: (json['forks_count'] as num?)?.toInt() ?? 0,
      openIssues: (json['open_issues_count'] as num?)?.toInt() ?? 0,
      topics: topicsJson is List
          ? topicsJson.whereType<String>().toList(growable: false)
          : const [],
      license:
          (licenseMap['spdx_id'] as String?) ??
          (licenseMap['name'] as String?) ??
          'Unknown',
      createdAt:
          DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.now(),
      pushedAt:
          DateTime.tryParse((json['pushed_at'] as String?) ?? '') ??
          DateTime.now(),
      rawMetadata: json,
    );
  }

  factory AiToolProject.fromJson(Map<String, Object?> json) {
    final topicsJson = json['topics'];
    final rawJson = json['rawMetadata'];

    return AiToolProject(
      id: (json['id'] as num?)?.toInt() ?? 0,
      owner: json['owner'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      htmlUrl: json['htmlUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      language: json['language'] as String? ?? 'Unknown',
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      forks: (json['forks'] as num?)?.toInt() ?? 0,
      openIssues: (json['openIssues'] as num?)?.toInt() ?? 0,
      topics: topicsJson is List
          ? topicsJson.whereType<String>().toList(growable: false)
          : const [],
      license: json['license'] as String? ?? 'Unknown',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      pushedAt:
          DateTime.tryParse(json['pushedAt'] as String? ?? '') ??
          DateTime.now(),
      rawMetadata: _objectMap(rawJson),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'owner': owner,
      'name': name,
      'fullName': fullName,
      'htmlUrl': htmlUrl,
      'description': description,
      'language': language,
      'stars': stars,
      'forks': forks,
      'openIssues': openIssues,
      'topics': topics,
      'license': license,
      'createdAt': createdAt.toIso8601String(),
      'pushedAt': pushedAt.toIso8601String(),
      'rawMetadata': rawMetadata,
      'isFavorite': isFavorite,
    };
  }
}

class AiToolAnalysis {
  const AiToolAnalysis({
    required this.projectFullName,
    required this.category,
    required this.summary,
    required this.useCases,
    required this.techStack,
    required this.risks,
    required this.score,
    required this.licenseFinding,
    required this.maintenanceActivity,
    required this.dimensions,
    required this.architectureNotes,
    required this.qualitySignals,
    required this.securityNotes,
    required this.businessFit,
    required this.recommendation,
    required this.nextSteps,
    required this.createdAt,
    required this.modelId,
    this.companyApiSuggestions = const [],
  });

  final String projectFullName;
  final String category;
  final String summary;
  final List<String> useCases;
  final List<String> techStack;
  final List<String> risks;
  final double score;
  final String licenseFinding;
  final String maintenanceActivity;
  final List<AnalysisDimension> dimensions;
  final List<String> architectureNotes;
  final List<String> qualitySignals;
  final List<String> securityNotes;
  final String businessFit;
  final String recommendation;
  final List<String> nextSteps;
  final List<CompanyApiMapping> companyApiSuggestions;
  final DateTime createdAt;
  final String modelId;

  AnalysisRiskLevel get riskLevel {
    if (risks.length >= 4 || score < 55) {
      return AnalysisRiskLevel.high;
    }
    if (risks.length >= 2 || score < 72) {
      return AnalysisRiskLevel.medium;
    }
    return AnalysisRiskLevel.low;
  }

  factory AiToolAnalysis.fromJson(Map<String, Object?> json) {
    final mappingsJson = json['companyApiSuggestions'];
    final dimensions = _analysisDimensionList(json['dimensions']);

    return AiToolAnalysis(
      projectFullName: json['projectFullName'] as String? ?? '',
      category: json['category'] as String? ?? 'AI Tool',
      summary: json['summary'] as String? ?? '',
      useCases: _stringList(json['useCases']),
      techStack: _stringList(json['techStack']),
      risks: _stringList(json['risks']),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      licenseFinding: json['licenseFinding'] as String? ?? 'Unknown',
      maintenanceActivity: json['maintenanceActivity'] as String? ?? 'Unknown',
      dimensions: dimensions.isEmpty ? _legacyDimensionList(json) : dimensions,
      architectureNotes: _stringList(json['architectureNotes']),
      qualitySignals: _stringList(json['qualitySignals']),
      securityNotes: _stringList(json['securityNotes']),
      businessFit: json['businessFit'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      nextSteps: _stringList(json['nextSteps']),
      companyApiSuggestions: _objectMapList(
        mappingsJson,
      ).map(CompanyApiMapping.fromJson).toList(growable: false),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      modelId: json['modelId'] as String? ?? 'local-heuristic',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'projectFullName': projectFullName,
      'category': category,
      'summary': summary,
      'useCases': useCases,
      'techStack': techStack,
      'risks': risks,
      'score': score,
      'licenseFinding': licenseFinding,
      'maintenanceActivity': maintenanceActivity,
      'dimensions': dimensions.map((dimension) => dimension.toJson()).toList(),
      'architectureNotes': architectureNotes,
      'qualitySignals': qualitySignals,
      'securityNotes': securityNotes,
      'businessFit': businessFit,
      'recommendation': recommendation,
      'nextSteps': nextSteps,
      'createdAt': createdAt.toIso8601String(),
      'modelId': modelId,
    };
  }
}

class AnalysisDimension {
  const AnalysisDimension({
    required this.key,
    required this.title,
    required this.score,
    required this.summary,
    required this.evidence,
  });

  final String key;
  final String title;
  final double score;
  final String summary;
  final List<String> evidence;

  factory AnalysisDimension.fromJson(Map<String, Object?> json) {
    final title = _stringValue(json['title']);
    final key = _stringValue(json['key'], fallback: title);
    return AnalysisDimension(
      key: key,
      title: title.isEmpty ? key : title,
      score: _scoreFromJson(json['score']),
      summary: _stringValue(json['summary']),
      evidence: _stringList(json['evidence']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'key': key,
      'title': title,
      'score': score,
      'summary': summary,
      'evidence': evidence,
    };
  }
}

class AiProviderConfig {
  const AiProviderConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.protocol,
    required this.baseUrl,
    required this.availableModels,
    required this.defaultModel,
    required this.contextLength,
    required this.temperature,
    required this.maxOutputTokens,
    required this.supportsStructuredOutput,
    required this.supportsToolCalling,
    this.apiKeyRef,
  });

  final String id;
  final String name;
  final AiProviderType type;
  final AiProviderProtocol protocol;
  final String baseUrl;
  final String? apiKeyRef;
  final List<AiModelConfig> availableModels;
  final String defaultModel;
  final int contextLength;
  final double temperature;
  final int maxOutputTokens;
  final bool supportsStructuredOutput;
  final bool supportsToolCalling;

  AiProviderConfig copyWith({
    String? id,
    String? name,
    AiProviderType? type,
    AiProviderProtocol? protocol,
    String? baseUrl,
    String? apiKeyRef,
    List<AiModelConfig>? availableModels,
    String? defaultModel,
    int? contextLength,
    double? temperature,
    int? maxOutputTokens,
    bool? supportsStructuredOutput,
    bool? supportsToolCalling,
  }) {
    return AiProviderConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      protocol: protocol ?? this.protocol,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKeyRef: apiKeyRef ?? this.apiKeyRef,
      availableModels: availableModels ?? this.availableModels,
      defaultModel: defaultModel ?? this.defaultModel,
      contextLength: contextLength ?? this.contextLength,
      temperature: temperature ?? this.temperature,
      maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
      supportsStructuredOutput:
          supportsStructuredOutput ?? this.supportsStructuredOutput,
      supportsToolCalling: supportsToolCalling ?? this.supportsToolCalling,
    );
  }

  factory AiProviderConfig.openAiCompatibleDefault() {
    return const AiProviderConfig(
      id: 'openai-compatible-custom',
      name: 'OpenAI',
      type: AiProviderType.openAiCompatible,
      protocol: AiProviderProtocol.openAiChatCompletions,
      baseUrl: 'https://api.openai.com/v1',
      apiKeyRef: 'openai-compatible-custom',
      availableModels: [
        AiModelConfig(
          id: 'gpt-4.1-mini',
          displayName: 'gpt-4.1-mini',
          contextLength: 128000,
          supportsStructuredOutput: true,
          supportsToolCalling: true,
        ),
      ],
      defaultModel: 'gpt-4.1-mini',
      contextLength: 128000,
      temperature: 0.2,
      maxOutputTokens: 2200,
      supportsStructuredOutput: true,
      supportsToolCalling: true,
    );
  }

  factory AiProviderConfig.tokenMixDefault() {
    return const AiProviderConfig(
      id: 'tokenmix',
      name: 'TokenMix',
      type: AiProviderType.companyApi,
      protocol: AiProviderProtocol.openAiChatCompletions,
      baseUrl: 'https://api.tokenmix.ai/v1',
      apiKeyRef: 'tokenmix-api-key',
      availableModels: [
        AiModelConfig(
          id: 'gpt-4o-mini',
          displayName: 'gpt-4o-mini',
          contextLength: 128000,
          supportsStructuredOutput: true,
          supportsToolCalling: true,
        ),
      ],
      defaultModel: 'gpt-4o-mini',
      contextLength: 128000,
      temperature: 0.2,
      maxOutputTokens: 2200,
      supportsStructuredOutput: true,
      supportsToolCalling: true,
    );
  }

  factory AiProviderConfig.deepSeekDefault() {
    return const AiProviderConfig(
      id: 'deepseek',
      name: 'DeepSeek',
      type: AiProviderType.deepSeek,
      protocol: AiProviderProtocol.openAiChatCompletions,
      baseUrl: 'https://api.deepseek.com',
      apiKeyRef: 'deepseek-api-key',
      availableModels: [
        AiModelConfig(
          id: 'deepseek-chat',
          displayName: 'deepseek-chat',
          contextLength: 64000,
          supportsStructuredOutput: true,
          supportsToolCalling: true,
        ),
      ],
      defaultModel: 'deepseek-chat',
      contextLength: 64000,
      temperature: 0.2,
      maxOutputTokens: 2200,
      supportsStructuredOutput: true,
      supportsToolCalling: true,
    );
  }

  factory AiProviderConfig.anthropicDefault() {
    return const AiProviderConfig(
      id: 'anthropic',
      name: 'Anthropic',
      type: AiProviderType.anthropic,
      protocol: AiProviderProtocol.anthropicMessages,
      baseUrl: 'https://api.anthropic.com',
      apiKeyRef: 'anthropic-api-key',
      availableModels: [
        AiModelConfig(
          id: 'claude-sonnet-4-6',
          displayName: 'claude-sonnet-4-6',
          contextLength: 200000,
          supportsStructuredOutput: true,
          supportsToolCalling: true,
        ),
      ],
      defaultModel: 'claude-sonnet-4-6',
      contextLength: 200000,
      temperature: 0.2,
      maxOutputTokens: 2200,
      supportsStructuredOutput: true,
      supportsToolCalling: true,
    );
  }

  factory AiProviderConfig.geminiDefault() {
    return const AiProviderConfig(
      id: 'gemini-openai',
      name: 'Gemini',
      type: AiProviderType.gemini,
      protocol: AiProviderProtocol.openAiChatCompletions,
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
      apiKeyRef: 'gemini-api-key',
      availableModels: [
        AiModelConfig(
          id: 'gemini-2.5-flash',
          displayName: 'gemini-2.5-flash',
          contextLength: 1000000,
          supportsStructuredOutput: true,
          supportsToolCalling: true,
        ),
      ],
      defaultModel: 'gemini-2.5-flash',
      contextLength: 1000000,
      temperature: 0.2,
      maxOutputTokens: 2200,
      supportsStructuredOutput: true,
      supportsToolCalling: true,
    );
  }

  factory AiProviderConfig.xiaomiMiMoDefault() {
    return const AiProviderConfig(
      id: 'xiaomi-mimo',
      name: 'Xiaomi MiMo',
      type: AiProviderType.openAiCompatible,
      protocol: AiProviderProtocol.openAiChatCompletions,
      baseUrl: 'https://api.xiaomimimo.com/v1',
      apiKeyRef: 'xiaomi-mimo-api-key',
      availableModels: [
        AiModelConfig(
          id: 'mimo-v2.5-pro',
          displayName: 'mimo-v2.5-pro',
          contextLength: 1000000,
          supportsStructuredOutput: true,
          supportsToolCalling: true,
        ),
        AiModelConfig(
          id: 'mimo-v2.5',
          displayName: 'mimo-v2.5',
          contextLength: 1000000,
          supportsStructuredOutput: true,
          supportsToolCalling: true,
        ),
      ],
      defaultModel: 'mimo-v2.5-pro',
      contextLength: 1000000,
      temperature: 0.2,
      maxOutputTokens: 2200,
      supportsStructuredOutput: true,
      supportsToolCalling: true,
    );
  }

  factory AiProviderConfig.xiaomiMiMoTokenPlanSgpDefault() {
    return AiProviderConfig.xiaomiMiMoDefault().copyWith(
      id: 'xiaomi-mimo-token-plan-sgp',
      name: 'Xiaomi MiMo Token Plan SGP',
      baseUrl: 'https://token-plan-sgp.xiaomimimo.com/v1',
      apiKeyRef: 'xiaomi-mimo-token-plan-sgp-api-key',
    );
  }

  factory AiProviderConfig.xiaomiMiMoTokenPlanCnDefault() {
    return AiProviderConfig.xiaomiMiMoDefault().copyWith(
      id: 'xiaomi-mimo-token-plan-cn',
      name: 'Xiaomi MiMo Token Plan CN',
      baseUrl: 'https://token-plan-cn.xiaomimimo.com/v1',
      apiKeyRef: 'xiaomi-mimo-token-plan-cn-api-key',
    );
  }

  factory AiProviderConfig.xiaomiMiMoTokenPlanAmsDefault() {
    return AiProviderConfig.xiaomiMiMoDefault().copyWith(
      id: 'xiaomi-mimo-token-plan-ams',
      name: 'Xiaomi MiMo Token Plan AMS',
      baseUrl: 'https://token-plan-ams.xiaomimimo.com/v1',
      apiKeyRef: 'xiaomi-mimo-token-plan-ams-api-key',
    );
  }

  static List<AiProviderConfig> builtInDefaults() {
    return [
      AiProviderConfig.tokenMixDefault(),
      AiProviderConfig.openAiCompatibleDefault(),
      AiProviderConfig.deepSeekDefault(),
      AiProviderConfig.anthropicDefault(),
      AiProviderConfig.geminiDefault(),
      AiProviderConfig.xiaomiMiMoDefault(),
      AiProviderConfig.xiaomiMiMoTokenPlanCnDefault(),
      AiProviderConfig.xiaomiMiMoTokenPlanSgpDefault(),
      AiProviderConfig.xiaomiMiMoTokenPlanAmsDefault(),
    ];
  }

  factory AiProviderConfig.fromJson(Map<String, Object?> json) {
    final modelsJson = json['availableModels'];

    return AiProviderConfig(
      id: json['id'] as String? ?? 'openai-compatible-custom',
      name: json['name'] as String? ?? 'OpenAI-compatible',
      type: AiProviderType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AiProviderType.openAiCompatible,
      ),
      protocol: AiProviderProtocol.values.firstWhere(
        (protocol) => protocol.name == json['protocol'],
        orElse: () => AiProviderProtocol.openAiChatCompletions,
      ),
      baseUrl: json['baseUrl'] as String? ?? '',
      apiKeyRef: json['apiKeyRef'] as String?,
      availableModels: _objectMapList(
        modelsJson,
      ).map(AiModelConfig.fromJson).toList(growable: false),
      defaultModel: json['defaultModel'] as String? ?? '',
      contextLength: (json['contextLength'] as num?)?.toInt() ?? 32000,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.2,
      maxOutputTokens: (json['maxOutputTokens'] as num?)?.toInt() ?? 2200,
      supportsStructuredOutput:
          json['supportsStructuredOutput'] as bool? ?? true,
      supportsToolCalling: json['supportsToolCalling'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'protocol': protocol.name,
      'baseUrl': baseUrl,
      'apiKeyRef': apiKeyRef,
      'availableModels': availableModels
          .map((model) => model.toJson())
          .toList(),
      'defaultModel': defaultModel,
      'contextLength': contextLength,
      'temperature': temperature,
      'maxOutputTokens': maxOutputTokens,
      'supportsStructuredOutput': supportsStructuredOutput,
      'supportsToolCalling': supportsToolCalling,
    };
  }
}

class AiModelConfig {
  const AiModelConfig({
    required this.id,
    required this.displayName,
    required this.contextLength,
    required this.supportsStructuredOutput,
    required this.supportsToolCalling,
  });

  final String id;
  final String displayName;
  final int contextLength;
  final bool supportsStructuredOutput;
  final bool supportsToolCalling;

  factory AiModelConfig.fromJson(Map<String, Object?> json) {
    return AiModelConfig(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      contextLength: (json['contextLength'] as num?)?.toInt() ?? 32000,
      supportsStructuredOutput:
          json['supportsStructuredOutput'] as bool? ?? true,
      supportsToolCalling: json['supportsToolCalling'] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'contextLength': contextLength,
      'supportsStructuredOutput': supportsStructuredOutput,
      'supportsToolCalling': supportsToolCalling,
    };
  }
}

class CompanyApiMapping {
  const CompanyApiMapping({
    required this.apiName,
    required this.capability,
    required this.fit,
    required this.rationale,
    required this.implementationHint,
  });

  final String apiName;
  final String capability;
  final double fit;
  final String rationale;
  final String implementationHint;

  factory CompanyApiMapping.fromJson(Map<String, Object?> json) {
    return CompanyApiMapping(
      apiName: json['apiName'] as String? ?? '',
      capability: json['capability'] as String? ?? '',
      fit: (json['fit'] as num?)?.toDouble() ?? 0,
      rationale: json['rationale'] as String? ?? '',
      implementationHint: json['implementationHint'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'apiName': apiName,
      'capability': capability,
      'fit': fit,
      'rationale': rationale,
      'implementationHint': implementationHint,
    };
  }
}

class TrendSnapshot {
  const TrendSnapshot({
    required this.label,
    required this.projectCount,
    required this.totalStars,
    required this.averageScore,
  });

  final String label;
  final int projectCount;
  final int totalStars;
  final double averageScore;
}

class ExportBundle {
  const ExportBundle({
    required this.id,
    required this.format,
    required this.filePath,
    required this.createdAt,
    required this.projectCount,
  });

  final String id;
  final ExportFormat format;
  final String filePath;
  final DateTime createdAt;
  final int projectCount;

  factory ExportBundle.fromJson(Map<String, Object?> json) {
    return ExportBundle(
      id: json['id'] as String? ?? '',
      format: ExportFormat.values.firstWhere(
        (format) => format.name == json['format'],
        orElse: () => ExportFormat.json,
      ),
      filePath: json['filePath'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      projectCount: (json['projectCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'format': format.name,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'projectCount': projectCount,
    };
  }
}

class SearchFilters {
  const SearchFilters({
    required this.keyword,
    required this.dateRange,
    required this.language,
    required this.minStars,
  });

  final String keyword;
  final String dateRange;
  final String language;
  final int minStars;

  SearchFilters copyWith({
    String? keyword,
    String? dateRange,
    String? language,
    int? minStars,
  }) {
    return SearchFilters(
      keyword: keyword ?? this.keyword,
      dateRange: dateRange ?? this.dateRange,
      language: language ?? this.language,
      minStars: minStars ?? this.minStars,
    );
  }

  String toGitHubQuery() {
    final terms = <String>[
      if (keyword.trim().isNotEmpty) keyword.trim() else 'AI',
      if (language != 'Any') 'language:$language',
      if (minStars > 0) 'stars:>=$minStars',
      if (dateRange == 'Today')
        'created:>=${_dateOnly(DateTime.now())}'
      else if (dateRange == 'This week')
        'created:>=${_dateOnly(DateTime.now().subtract(const Duration(days: 7)))}',
      'topic:ai',
    ];

    return terms.join(' ');
  }

  static const defaults = SearchFilters(
    keyword: 'agent OR LLM OR RAG OR MCP',
    dateRange: 'This week',
    language: 'Any',
    minStars: 50,
  );
}

class AppSettings {
  const AppSettings({
    required this.visualStyle,
    required this.language,
    required this.themeMode,
    required this.themeColor,
    required this.androidLiquidGlassBackground,
    required this.mcpWriteAccessEnabled,
    required this.githubTokenKeyRef,
    required this.providers,
    required this.selectedProviderId,
  });

  static const defaultThemeColor = '#2F7D5F';

  final VisualStyle visualStyle;
  final AppLanguage language;
  final AppThemeMode themeMode;
  final String themeColor;
  final String androidLiquidGlassBackground;
  final bool mcpWriteAccessEnabled;
  final String githubTokenKeyRef;
  final List<AiProviderConfig> providers;
  final String selectedProviderId;

  bool get usesLiquidGlass => visualStyle == VisualStyle.liquidGlass;
  AiProviderConfig get provider {
    return providers.firstWhere(
      (item) => item.id == selectedProviderId,
      orElse: () => providers.isEmpty
          ? AiProviderConfig.openAiCompatibleDefault()
          : providers.first,
    );
  }

  AppSettings copyWith({
    VisualStyle? visualStyle,
    AppLanguage? language,
    AppThemeMode? themeMode,
    String? themeColor,
    String? androidLiquidGlassBackground,
    bool? mcpWriteAccessEnabled,
    String? githubTokenKeyRef,
    List<AiProviderConfig>? providers,
    String? selectedProviderId,
  }) {
    final nextProviders = providers ?? this.providers;
    final nextSelectedProviderId =
        selectedProviderId ??
        (nextProviders.any((item) => item.id == this.selectedProviderId)
            ? this.selectedProviderId
            : nextProviders.isEmpty
            ? ''
            : nextProviders.first.id);
    return AppSettings(
      visualStyle: visualStyle ?? this.visualStyle,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      themeColor: themeColor ?? this.themeColor,
      androidLiquidGlassBackground:
          androidLiquidGlassBackground ?? this.androidLiquidGlassBackground,
      mcpWriteAccessEnabled:
          mcpWriteAccessEnabled ?? this.mcpWriteAccessEnabled,
      githubTokenKeyRef: githubTokenKeyRef ?? this.githubTokenKeyRef,
      providers: nextProviders,
      selectedProviderId: nextSelectedProviderId,
    );
  }

  factory AppSettings.defaults() {
    final providers = AiProviderConfig.builtInDefaults();
    final provider = providers.first;
    return AppSettings(
      visualStyle: VisualStyle.liquidGlass,
      language: AppLanguage.system,
      themeMode: AppThemeMode.system,
      themeColor: defaultThemeColor,
      androidLiquidGlassBackground: '',
      mcpWriteAccessEnabled: false,
      githubTokenKeyRef: 'github-token',
      providers: providers,
      selectedProviderId: provider.id,
    );
  }

  factory AppSettings.fromJson(Map<String, Object?> json) {
    final providerJson = json['provider'];
    final providersJson = json['providers'];
    final loadedProviders = providersJson is List
        ? _objectMapList(
            providersJson,
          ).map(AiProviderConfig.fromJson).toList(growable: false)
        : _objectMap(providerJson).isNotEmpty
        ? [AiProviderConfig.fromJson(_objectMap(providerJson))]
        : AiProviderConfig.builtInDefaults();
    final providers = _mergeBuiltInProviders(loadedProviders);
    final selectedProviderId =
        json['selectedProviderId'] as String? ??
        (providers.isEmpty ? '' : providers.first.id);

    return AppSettings(
      visualStyle: VisualStyle.values.firstWhere(
        (style) => style.name == json['visualStyle'],
        orElse: () => VisualStyle.liquidGlass,
      ),
      language: AppLanguage.values.firstWhere(
        (language) => language.name == json['language'],
        orElse: () => AppLanguage.system,
      ),
      themeMode: AppThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      themeColor: json['themeColor'] as String? ?? defaultThemeColor,
      androidLiquidGlassBackground:
          json['androidLiquidGlassBackground'] as String? ?? '',
      mcpWriteAccessEnabled: json['mcpWriteAccessEnabled'] as bool? ?? false,
      githubTokenKeyRef: json['githubTokenKeyRef'] as String? ?? 'github-token',
      providers: providers.isEmpty
          ? AiProviderConfig.builtInDefaults()
          : providers,
      selectedProviderId: selectedProviderId,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'visualStyle': visualStyle.name,
      'language': language.name,
      'themeMode': themeMode.name,
      'themeColor': themeColor,
      'androidLiquidGlassBackground': androidLiquidGlassBackground,
      'mcpWriteAccessEnabled': mcpWriteAccessEnabled,
      'githubTokenKeyRef': githubTokenKeyRef,
      'providers': providers.map((provider) => provider.toJson()).toList(),
      'selectedProviderId': selectedProviderId,
      'provider': provider.toJson(),
    };
  }
}

List<String> _stringList(Object? value) {
  return value is List ? value.whereType<String>().toList(growable: false) : [];
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is! Map) {
    return const {};
  }
  return value.map((key, value) => MapEntry('$key', value));
}

List<Map<String, Object?>> _objectMapList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map(_objectMap)
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

List<AiProviderConfig> _mergeBuiltInProviders(
  List<AiProviderConfig> providers,
) {
  final byId = <String, AiProviderConfig>{
    for (final provider in providers) provider.id: provider,
  };
  for (final provider in AiProviderConfig.builtInDefaults()) {
    byId.putIfAbsent(provider.id, () => provider);
  }
  return byId.values.toList(growable: false);
}

List<AnalysisDimension> _analysisDimensionList(Object? value) {
  return _objectMapList(value)
      .map(AnalysisDimension.fromJson)
      .where((dimension) => dimension.title.trim().isNotEmpty)
      .toList(growable: false);
}

List<AnalysisDimension> _legacyDimensionList(Map<String, Object?> json) {
  final dimensions = <AnalysisDimension>[
    AnalysisDimension(
      key: 'maintenance',
      title: 'Maintenance',
      score: _scoreFromJson(json['score']),
      summary: _stringValue(json['maintenanceActivity']),
      evidence: const [],
    ),
    AnalysisDimension(
      key: 'license',
      title: 'License',
      score: 0,
      summary: _stringValue(json['licenseFinding']),
      evidence: const [],
    ),
  ];
  return dimensions
      .where((dimension) => dimension.summary.isNotEmpty)
      .toList(growable: false);
}

String _stringValue(Object? value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
  if (value is num || value is bool) {
    return '$value';
  }
  return fallback;
}

double _scoreFromJson(Object? value) {
  if (value is num) {
    return value.toDouble().clamp(0, 100).toDouble();
  }
  if (value is String) {
    final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(value);
    if (match != null) {
      final parsed = double.tryParse(match.group(0) ?? '') ?? 0;
      return parsed.clamp(0, 100).toDouble();
    }
  }
  return 0;
}

String _dateOnly(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
