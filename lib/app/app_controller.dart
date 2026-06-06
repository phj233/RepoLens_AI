import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../core/i18n/app_localizations.dart';
import '../core/models/repolens_models.dart';
import '../core/services/ai_analysis_service.dart';
import '../core/services/ai_model_catalog_service.dart';
import '../core/services/credential_store.dart';
import '../core/services/export_service.dart';
import '../core/services/file_opening_service.dart';
import '../core/services/github_discovery_service.dart';
import '../core/services/local_repository.dart';
import '../core/services/sample_data.dart';
import '../ui/visual_style_resolver.dart';
import 'app_state.dart';

class AppController extends Notifier<AppState> {
  static const _bootstrapIoTimeout = Duration(seconds: 2);

  final LocalRepository _repository = LocalRepository();
  final CredentialStore _credentialStore = CredentialStore();
  final GitHubDiscoveryService _discoveryService = GitHubDiscoveryService();
  final AiAnalysisService _analysisService = AiAnalysisService();
  final AiModelCatalogService _modelCatalogService = AiModelCatalogService();
  final ExportService _exportService = ExportService();
  final FileOpeningService _fileOpeningService = FileOpeningService();
  bool _bootstrapped = false;

  @override
  AppState build() {
    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(bootstrap);
    }
    return _visibleInitialState();
  }

  Future<void> bootstrap() async {
    try {
      final loadedSettings = await _withBootstrapTimeout(
        _repository.loadSettings(),
        AppSettings.defaults(),
      );
      final settings = _settingsForCurrentPlatform(loadedSettings);
      if (settings.visualStyle != loadedSettings.visualStyle) {
        unawaited(_saveSettingsBestEffort(settings));
      }
      var projects = await _withBootstrapTimeout(
        _repository.loadProjects(),
        <AiToolProject>[],
      );
      var analyses = await _withBootstrapTimeout(
        _repository.loadAnalyses(),
        <AiToolAnalysis>[],
      );
      final exports = await _withBootstrapTimeout(
        _repository.loadExports(),
        <ExportBundle>[],
      );

      if (projects.isEmpty) {
        projects = SampleData.projects();
        analyses = SampleData.analyses();
        unawaited(_persistSampleDataBestEffort(projects, analyses));
      }

      state = state.copyWith(
        settings: settings,
        projects: _sortProjects(projects),
        analyses: analyses,
        exports: exports,
        selectedProjectFullName: projects.isNotEmpty
            ? projects.first.fullName
            : null,
        isBootstrapping: false,
        clearError: true,
      );
    } catch (_) {
      final projects = SampleData.projects();
      state = state.copyWith(
        projects: projects,
        analyses: SampleData.analyses(),
        selectedProjectFullName: projects.first.fullName,
        isBootstrapping: false,
        errorMessage: _message('databaseFallback'),
      );
    }
  }

  AppState _visibleInitialState() {
    final projects = SampleData.projects();
    return AppState.initial().copyWith(
      projects: _sortProjects(projects),
      analyses: SampleData.analyses(),
      selectedProjectFullName: projects.first.fullName,
      isBootstrapping: false,
    );
  }

  Future<T> _withBootstrapTimeout<T>(Future<T> future, T fallback) {
    return future.timeout(_bootstrapIoTimeout, onTimeout: () => fallback);
  }

  Future<void> _saveSettingsBestEffort(AppSettings settings) async {
    try {
      await _repository.saveSettings(settings).timeout(_bootstrapIoTimeout);
    } catch (_) {
      // Startup must not be blocked by local storage.
    }
  }

  Future<void> _persistSampleDataBestEffort(
    List<AiToolProject> projects,
    List<AiToolAnalysis> analyses,
  ) async {
    try {
      await _repository.saveProjects(projects).timeout(_bootstrapIoTimeout);
      for (final analysis in analyses) {
        await _repository.saveAnalysis(analysis).timeout(_bootstrapIoTimeout);
      }
    } catch (_) {
      // Sample data can stay in memory until storage becomes available.
    }
  }

  void setNavigationIndex(int index) {
    state = state.copyWith(
      navigationIndex: index,
      projectDetailOpen: false,
      settingsProviderDetailOpen: false,
      settingsAppearanceDetailOpen: false,
      clearNotice: true,
    );
  }

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(
      filters: filters,
      clearError: true,
      clearNotice: true,
    );
  }

  void selectProject(String fullName) {
    state = state.copyWith(selectedProjectFullName: fullName);
  }

  void openProjectDetail(String fullName) {
    state = state.copyWith(
      navigationIndex: 1,
      selectedProjectFullName: fullName,
      projectDetailOpen: true,
      settingsProviderDetailOpen: false,
      settingsAppearanceDetailOpen: false,
      clearNotice: true,
    );
  }

  void closeProjectDetail() {
    state = state.copyWith(projectDetailOpen: false, clearNotice: true);
  }

  void openSettingsProviderDetail() {
    state = state.copyWith(
      navigationIndex: 4,
      projectDetailOpen: false,
      settingsProviderDetailOpen: true,
      settingsAppearanceDetailOpen: false,
      clearNotice: true,
    );
  }

  void closeSettingsProviderDetail() {
    state = state.copyWith(
      settingsProviderDetailOpen: false,
      clearNotice: true,
    );
  }

  void openSettingsAppearanceDetail() {
    state = state.copyWith(
      navigationIndex: 4,
      projectDetailOpen: false,
      settingsProviderDetailOpen: false,
      settingsAppearanceDetailOpen: true,
      clearNotice: true,
    );
  }

  void closeSettingsAppearanceDetail() {
    state = state.copyWith(
      settingsAppearanceDetailOpen: false,
      clearNotice: true,
    );
  }

  void dismissMessage() {
    state = state.copyWith(clearError: true, clearNotice: true);
  }

  void closeImagePreview() {
    state = state.copyWith(clearPreviewImage: true, clearNotice: true);
  }

  bool handleSystemBack() {
    if (state.previewImagePath != null) {
      closeImagePreview();
      return true;
    }
    if (state.projectDetailOpen) {
      closeProjectDetail();
      return true;
    }
    if (state.settingsProviderDetailOpen) {
      closeSettingsProviderDetail();
      return true;
    }
    if (state.settingsAppearanceDetailOpen) {
      closeSettingsAppearanceDetail();
      return true;
    }
    if (state.navigationIndex != 0) {
      setNavigationIndex(0);
      return true;
    }
    return false;
  }

  Future<void> discover() async {
    state = state.copyWith(
      isDiscovering: true,
      clearError: true,
      noticeMessage: _message('loadingGithub'),
    );
    try {
      final token = await _credentialStore.read(
        state.settings.githubTokenKeyRef,
      );
      final found = await _discoveryService.searchProjects(
        filters: state.filters,
        githubToken: token,
      );
      final merged = _mergeProjects(state.projects, found);
      await _repository.saveProjects(merged);
      state = state.copyWith(
        projects: _sortProjects(merged),
        selectedProjectFullName: found.isNotEmpty
            ? found.first.fullName
            : state.selectedProjectFullName,
        isDiscovering: false,
        noticeMessage: _localizations().updatedProjects(found.length),
      );
    } catch (_) {
      state = state.copyWith(
        isDiscovering: false,
        errorMessage: _message('githubSearchFailed'),
        clearNotice: true,
      );
    }
  }

  Future<void> analyzeSelectedProject({bool openAnalysisPage = false}) async {
    final project = state.selectedProject;
    if (project == null) {
      return;
    }

    state = state.copyWith(
      isAnalyzing: true,
      clearError: true,
      noticeMessage: _message('generatingAnalysis'),
    );

    try {
      final apiKey = await _readProviderApiKey(state.settings.provider);
      final analysis = await _analysisService.analyzeProject(
        project: project,
        settings: state.settings,
        apiKey: apiKey,
      );
      await _repository.saveAnalysis(analysis);

      final nextAnalyses = [
        analysis,
        ...state.analyses.where(
          (item) => item.projectFullName != analysis.projectFullName,
        ),
      ];

      state = state.copyWith(
        analyses: nextAnalyses,
        navigationIndex: openAnalysisPage ? 2 : state.navigationIndex,
        projectDetailOpen: openAnalysisPage ? false : state.projectDetailOpen,
        settingsProviderDetailOpen: openAnalysisPage
            ? false
            : state.settingsProviderDetailOpen,
        settingsAppearanceDetailOpen: openAnalysisPage
            ? false
            : state.settingsAppearanceDetailOpen,
        isAnalyzing: false,
        noticeMessage: _localizations().generatedAnalysis(project.fullName),
      );
    } catch (error) {
      final detail = _safeErrorDetail(error);
      debugPrint('[RepoLensAI] analysis failed: $detail');
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: _localizations().analysisFailedWithDetail(detail),
        clearNotice: true,
      );
    }
  }

  Future<void> analyzeSelectedProjectAndOpenAnalysis() {
    return analyzeSelectedProject(openAnalysisPage: true);
  }

  Future<void> toggleFavorite(AiToolProject project) async {
    final next = state.projects
        .map(
          (item) => item.fullName == project.fullName
              ? item.copyWith(isFavorite: !item.isFavorite)
              : item,
        )
        .toList(growable: false);
    await _repository.saveProjects(next);
    state = state.copyWith(projects: _sortProjects(next));
  }

  Future<void> updateVisualStyle(VisualStyle style) async {
    final settings = state.settings.copyWith(
      visualStyle: resolveVisualStyleForPlatform(style),
    );
    await _repository.saveSettings(settings);
    state = state.copyWith(settings: settings);
  }

  Future<void> updateLanguage(AppLanguage language) async {
    final settings = state.settings.copyWith(language: language);
    await _repository.saveSettings(settings);
    state = state.copyWith(settings: settings);
  }

  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final settings = state.settings.copyWith(themeMode: themeMode);
    await _repository.saveSettings(settings);
    state = state.copyWith(settings: settings);
  }

  Future<void> updateThemeColor(String color) async {
    final settings = state.settings.copyWith(themeColor: color.trim());
    await _repository.saveSettings(settings);
    state = state.copyWith(settings: settings);
  }

  Future<void> updateAndroidLiquidGlassBackground(String background) async {
    final settings = state.settings.copyWith(
      androidLiquidGlassBackground: background.trim(),
    );
    await _repository.saveSettings(settings);
    state = state.copyWith(settings: settings);
  }

  Future<void> updateMcpWriteAccess(bool enabled) async {
    final settings = state.settings.copyWith(mcpWriteAccessEnabled: enabled);
    await _repository.saveSettings(settings);
    state = state.copyWith(settings: settings);
  }

  Future<void> updateProvider(AiProviderConfig provider) async {
    final settings = state.settings.copyWith(
      providers: _upsertProvider(state.settings.providers, provider),
      selectedProviderId: provider.id,
    );
    await _repository.saveSettings(settings);
    state = state.copyWith(
      settings: settings,
      noticeMessage: _message('providerSaved'),
    );
  }

  Future<void> addProvider(AiProviderConfig provider) async {
    final settings = state.settings.copyWith(
      providers: _upsertProvider(state.settings.providers, provider),
      selectedProviderId: provider.id,
    );
    await _repository.saveSettings(settings);
    state = state.copyWith(
      settings: settings,
      noticeMessage: _message('providerSaved'),
    );
  }

  Future<void> selectProvider(String providerId) async {
    if (state.settings.providers.every((item) => item.id != providerId)) {
      return;
    }
    final settings = state.settings.copyWith(selectedProviderId: providerId);
    await _repository.saveSettings(settings);
    state = state.copyWith(settings: settings, clearNotice: true);
  }

  Future<void> deleteProvider(String providerId) async {
    if (state.settings.providers.length <= 1) {
      state = state.copyWith(
        errorMessage: _message('cannotDeleteLastProvider'),
        clearNotice: true,
      );
      return;
    }
    final providers = state.settings.providers
        .where((provider) => provider.id != providerId)
        .toList(growable: false);
    final settings = state.settings.copyWith(
      providers: providers,
      selectedProviderId: providers.first.id,
    );
    await _repository.saveSettings(settings);
    state = state.copyWith(
      settings: settings,
      noticeMessage: _message('providerDeleted'),
    );
  }

  Future<void> refreshSelectedProviderModels() async {
    final provider = state.settings.provider;
    state = state.copyWith(
      isFetchingModels: true,
      clearError: true,
      noticeMessage: _message('fetchingProviderModels'),
    );
    try {
      final apiKey = await _readProviderApiKey(provider);
      final models = await _modelCatalogService.fetchModels(
        provider: provider,
        apiKey: apiKey,
      );
      if (models.isEmpty) {
        throw const AiModelCatalogException('empty_models');
      }
      final currentModelStillAvailable = models.any(
        (model) => model.id == provider.defaultModel,
      );
      final updated = provider.copyWith(
        availableModels: models,
        defaultModel: currentModelStillAvailable
            ? provider.defaultModel
            : models.first.id,
        contextLength: currentModelStillAvailable
            ? provider.contextLength
            : models.first.contextLength,
      );
      final settings = state.settings.copyWith(
        providers: _upsertProvider(state.settings.providers, updated),
        selectedProviderId: updated.id,
      );
      await _repository.saveSettings(settings);
      state = state.copyWith(
        settings: settings,
        isFetchingModels: false,
        noticeMessage: _localizations().providerModelsFetched(models.length),
      );
    } catch (error) {
      final detail = _safeErrorDetail(error);
      debugPrint('[RepoLensAI] fetch provider models failed: $detail');
      state = state.copyWith(
        isFetchingModels: false,
        errorMessage: _localizations().fetchProviderModelsFailedWithDetail(
          detail,
        ),
        clearNotice: true,
      );
    }
  }

  Future<void> saveGithubToken(String token) async {
    await _credentialStore.write(state.settings.githubTokenKeyRef, token);
    state = state.copyWith(noticeMessage: _message('githubTokenSaved'));
  }

  Future<String> readSelectedProviderApiKey() async {
    final apiKey = await _readProviderApiKey(state.settings.provider);
    return apiKey ?? '';
  }

  Future<void> saveProviderApiKey(String apiKey, {String? apiKeyRef}) async {
    for (final ref in _providerCredentialRefs(
      state.settings.provider,
      preferredRef: apiKeyRef,
    )) {
      await _credentialStore.write(ref, apiKey);
    }
    state = state.copyWith(noticeMessage: _message('providerKeySaved'));
  }

  Future<void> exportCurrentData(ExportFormat format) async {
    state = state.copyWith(
      isExporting: true,
      clearError: true,
      noticeMessage: _message('generatingExport'),
    );
    try {
      final bundle = await _exportService.export(
        format: format,
        projects: state.projects,
        analyses: state.analyses,
        repository: _repository,
      );
      state = state.copyWith(
        exports: [bundle, ...state.exports],
        isExporting: false,
        noticeMessage: _localizations().exportedTo(bundle.filePath),
      );
    } catch (_) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: _message('exportFailed'),
        clearNotice: true,
      );
    }
  }

  Future<void> exportSelectedProjectData(ExportFormat format) async {
    final project = state.selectedProject;
    if (project == null) {
      state = state.copyWith(
        errorMessage: _message('noProjectSelected'),
        clearNotice: true,
      );
      return;
    }

    state = state.copyWith(
      isExporting: true,
      clearError: true,
      noticeMessage: _message('generatingExport'),
    );
    try {
      final analysis = state.analysisByProject[project.fullName];
      final bundle = await _exportService.export(
        format: format,
        projects: [project],
        analyses: analysis == null ? const [] : [analysis],
        repository: _repository,
      );
      state = state.copyWith(
        exports: [bundle, ...state.exports],
        isExporting: false,
        noticeMessage: _localizations().exportedTo(bundle.filePath),
      );
    } catch (_) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: _message('exportFailed'),
        clearNotice: true,
      );
    }
  }

  Future<void> openExportFile(String filePath) async {
    state = state.copyWith(
      clearError: true,
      noticeMessage: _message('openingExportFile'),
    );
    try {
      if (_isPreviewableImage(filePath)) {
        final file = File(filePath);
        if (!file.existsSync()) {
          throw const FileOpeningException('missing_file');
        }
        state = state.copyWith(
          previewImagePath: filePath,
          noticeMessage: _message('previewingExportImage'),
        );
        return;
      }
      await _fileOpeningService.open(filePath);
      state = state.copyWith(noticeMessage: _message('exportFileOpened'));
    } catch (_) {
      state = state.copyWith(
        errorMessage: _message('openExportFileFailed'),
        clearNotice: true,
      );
    }
  }

  Future<void> deleteExport(ExportBundle bundle) async {
    final deletingPreviewedFile = state.previewImagePath == bundle.filePath;
    try {
      final file = File(bundle.filePath);
      if (file.existsSync()) {
        await file.delete();
      }
      await _repository.deleteExport(bundle.id);
      state = state.copyWith(
        exports: state.exports
            .where((item) => item.id != bundle.id)
            .toList(growable: false),
        clearPreviewImage: deletingPreviewedFile,
        noticeMessage: _message('exportDeleted'),
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: _message('deleteExportFailed'),
        clearNotice: true,
      );
    }
  }

  List<AiToolProject> _mergeProjects(
    List<AiToolProject> existing,
    List<AiToolProject> incoming,
  ) {
    final favoriteByName = {
      for (final project in existing) project.fullName: project.isFavorite,
    };
    final byName = {
      for (final project in existing) project.fullName: project,
      for (final project in incoming)
        project.fullName: project.copyWith(
          isFavorite: favoriteByName[project.fullName],
        ),
    };
    return byName.values.toList(growable: false);
  }

  List<AiToolProject> _sortProjects(List<AiToolProject> projects) {
    return [...projects]..sort((a, b) {
      if (a.isFavorite != b.isFavorite) {
        return a.isFavorite ? -1 : 1;
      }
      return b.stars.compareTo(a.stars);
    });
  }

  AppLocalizations _localizations() {
    return AppLocalizations(switch (state.settings.language) {
      AppLanguage.english => const Locale('en'),
      AppLanguage.simplifiedChinese => const Locale('zh', 'CN'),
      AppLanguage.system =>
        WidgetsBinding.instance.platformDispatcher.locale.languageCode
                    .toLowerCase() ==
                'en'
            ? const Locale('en')
            : const Locale('zh', 'CN'),
    });
  }

  String _message(String key) => _localizations().t(key);

  Future<String?> _readProviderApiKey(AiProviderConfig provider) async {
    for (final ref in _providerCredentialRefs(provider)) {
      final value = await _credentialStore.read(ref);
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  List<String> _providerCredentialRefs(
    AiProviderConfig provider, {
    String? preferredRef,
  }) {
    final refs = <String>[
      ?preferredRef,
      ?provider.apiKeyRef,
      provider.id,
    ];
    return refs
        .map((ref) => ref.trim())
        .where((ref) => ref.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String _safeErrorDetail(Object error) {
    final raw = error.toString();
    final sanitized = raw
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+'), 'Bearer ***')
        .replaceAll(RegExp(r'sk-[A-Za-z0-9._-]{12,}'), 'sk-***')
        .replaceAllMapped(
          RegExp(r'(api[_-]?key["=: ]+)[^,\s}]+', caseSensitive: false),
          (match) => '${match.group(1)}***',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.length <= 260) {
      return sanitized;
    }
    return '${sanitized.substring(0, 260)}...';
  }

  List<AiProviderConfig> _upsertProvider(
    List<AiProviderConfig> providers,
    AiProviderConfig provider,
  ) {
    final exists = providers.any((item) => item.id == provider.id);
    if (!exists) {
      return [...providers, provider];
    }
    return providers
        .map((item) => item.id == provider.id ? provider : item)
        .toList(growable: false);
  }

  bool _isPreviewableImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  AppSettings _settingsForCurrentPlatform(AppSettings settings) {
    final resolved = resolveVisualStyleForPlatform(settings.visualStyle);
    if (resolved == settings.visualStyle) {
      return settings;
    }
    return settings.copyWith(visualStyle: resolved);
  }
}
