import '../core/models/repolens_models.dart';

class AppState {
  const AppState({
    required this.navigationIndex,
    required this.filters,
    required this.projects,
    required this.analyses,
    required this.exports,
    required this.settings,
    required this.isBootstrapping,
    required this.isDiscovering,
    required this.isAnalyzing,
    required this.isExporting,
    required this.isFetchingModels,
    required this.projectDetailOpen,
    required this.settingsProviderDetailOpen,
    required this.settingsAppearanceDetailOpen,
    this.selectedProjectFullName,
    this.errorMessage,
    this.noticeMessage,
    this.previewImagePath,
  });

  final int navigationIndex;
  final SearchFilters filters;
  final List<AiToolProject> projects;
  final List<AiToolAnalysis> analyses;
  final List<ExportBundle> exports;
  final AppSettings settings;
  final bool isBootstrapping;
  final bool isDiscovering;
  final bool isAnalyzing;
  final bool isExporting;
  final bool isFetchingModels;
  final bool projectDetailOpen;
  final bool settingsProviderDetailOpen;
  final bool settingsAppearanceDetailOpen;
  final String? selectedProjectFullName;
  final String? errorMessage;
  final String? noticeMessage;
  final String? previewImagePath;

  factory AppState.initial() {
    return AppState(
      navigationIndex: 0,
      filters: SearchFilters.defaults,
      projects: const [],
      analyses: const [],
      exports: const [],
      settings: AppSettings.defaults(),
      isBootstrapping: true,
      isDiscovering: false,
      isAnalyzing: false,
      isExporting: false,
      isFetchingModels: false,
      projectDetailOpen: false,
      settingsProviderDetailOpen: false,
      settingsAppearanceDetailOpen: false,
    );
  }

  AiToolProject? get selectedProject {
    if (projects.isEmpty) {
      return null;
    }
    if (selectedProjectFullName == null) {
      return projects.first;
    }
    return projects
        .where((project) => project.fullName == selectedProjectFullName)
        .firstOrNull;
  }

  AiToolAnalysis? get selectedAnalysis {
    final project = selectedProject;
    if (project == null) {
      return null;
    }
    return analysisByProject[project.fullName];
  }

  bool get hasInAppBackDestination {
    return previewImagePath != null ||
        projectDetailOpen ||
        settingsProviderDetailOpen ||
        settingsAppearanceDetailOpen ||
        navigationIndex != 0;
  }

  Map<String, AiToolAnalysis> get analysisByProject {
    return {
      for (final analysis in analyses) analysis.projectFullName: analysis,
    };
  }

  List<TrendSnapshot> get trendSnapshots {
    final byLanguage = <String, List<AiToolProject>>{};
    for (final project in projects) {
      byLanguage.putIfAbsent(project.language, () => []).add(project);
    }

    return byLanguage.entries
        .map((entry) {
          final scores = entry.value
              .map((project) => analysisByProject[project.fullName]?.score)
              .whereType<double>()
              .toList(growable: false);
          return TrendSnapshot(
            label: entry.key,
            projectCount: entry.value.length,
            totalStars: entry.value.fold<int>(
              0,
              (sum, project) => sum + project.stars,
            ),
            averageScore: scores.isEmpty
                ? 0
                : scores.reduce((sum, score) => sum + score) / scores.length,
          );
        })
        .toList(growable: false)
      ..sort((a, b) => b.totalStars.compareTo(a.totalStars));
  }

  AppState copyWith({
    int? navigationIndex,
    SearchFilters? filters,
    List<AiToolProject>? projects,
    List<AiToolAnalysis>? analyses,
    List<ExportBundle>? exports,
    AppSettings? settings,
    bool? isBootstrapping,
    bool? isDiscovering,
    bool? isAnalyzing,
    bool? isExporting,
    bool? isFetchingModels,
    bool? projectDetailOpen,
    bool? settingsProviderDetailOpen,
    bool? settingsAppearanceDetailOpen,
    String? selectedProjectFullName,
    bool clearSelectedProject = false,
    String? errorMessage,
    bool clearError = false,
    String? noticeMessage,
    bool clearNotice = false,
    String? previewImagePath,
    bool clearPreviewImage = false,
  }) {
    return AppState(
      navigationIndex: navigationIndex ?? this.navigationIndex,
      filters: filters ?? this.filters,
      projects: projects ?? this.projects,
      analyses: analyses ?? this.analyses,
      exports: exports ?? this.exports,
      settings: settings ?? this.settings,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isExporting: isExporting ?? this.isExporting,
      isFetchingModels: isFetchingModels ?? this.isFetchingModels,
      projectDetailOpen: projectDetailOpen ?? this.projectDetailOpen,
      settingsProviderDetailOpen:
          settingsProviderDetailOpen ?? this.settingsProviderDetailOpen,
      settingsAppearanceDetailOpen:
          settingsAppearanceDetailOpen ?? this.settingsAppearanceDetailOpen,
      selectedProjectFullName: clearSelectedProject
          ? null
          : selectedProjectFullName ?? this.selectedProjectFullName,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      noticeMessage: clearNotice ? null : noticeMessage ?? this.noticeMessage,
      previewImagePath: clearPreviewImage
          ? null
          : previewImagePath ?? this.previewImagePath,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
