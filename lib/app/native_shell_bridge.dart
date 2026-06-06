import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/repolens_models.dart';
import 'app_state.dart';
import 'providers.dart';

const _nativeShellChannel = MethodChannel('repolens.ai/native_shell');

class RepoLensNativeBridgeHost extends ConsumerStatefulWidget {
  const RepoLensNativeBridgeHost({super.key});

  @override
  ConsumerState<RepoLensNativeBridgeHost> createState() =>
      _RepoLensNativeBridgeHostState();
}

class _RepoLensNativeBridgeHostState
    extends ConsumerState<RepoLensNativeBridgeHost> {
  Timer? _startupPushTimer;
  int _startupPushCount = 0;

  @override
  void initState() {
    super.initState();
    _nativeShellChannel.setMethodCallHandler(_handleNativeShellCall);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushState();
      _startupPushTimer = Timer.periodic(const Duration(milliseconds: 350), (
        timer,
      ) {
        if (!mounted || _startupPushCount >= 16) {
          timer.cancel();
          return;
        }
        _startupPushCount += 1;
        _pushState();
      });
    });
  }

  @override
  void dispose() {
    _startupPushTimer?.cancel();
    _nativeShellChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    ref.listen<AppState>(appControllerProvider, (previous, next) {
      _pushState(next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushState(state);
    });

    return const SizedBox.shrink();
  }

  Future<void> _pushState([AppState? state]) async {
    final AppState next = state ?? ref.read(appControllerProvider);
    try {
      await _nativeShellChannel.invokeMethod<void>(
        'stateChanged',
        nativeShellSnapshot(next),
      );
    } on PlatformException {
      // The native shell may not be attached during the first Flutter frame.
    } on MissingPluginException {
      // Desktop and tests do not always install the native channel endpoint.
    }
  }

  Future<Object?> _handleNativeShellCall(MethodCall call) async {
    return handleNativeShellCall(call, ref);
  }
}

Future<Object?> handleNativeShellCall(MethodCall call, WidgetRef ref) async {
  final controller = ref.read(appControllerProvider.notifier);
  final state = ref.read(appControllerProvider);

  switch (call.method) {
    case 'requestState':
      return nativeShellSnapshot(state);
    case 'setNavigationIndex':
      controller.setNavigationIndex((call.arguments as num?)?.toInt() ?? 0);
      return nativeShellSnapshot(ref.read(appControllerProvider));
    case 'dismissMessage':
      controller.dismissMessage();
      return null;
    case 'closeImagePreview':
      controller.closeImagePreview();
      return null;
    case 'updateFilters':
      final args = _asMap(call.arguments);
      controller.updateFilters(
        SearchFilters(
          keyword: args['keyword'] as String? ?? state.filters.keyword,
          dateRange: args['dateRange'] as String? ?? state.filters.dateRange,
          language: args['language'] as String? ?? state.filters.language,
          minStars:
              (args['minStars'] as num?)?.toInt() ?? state.filters.minStars,
        ),
      );
      return null;
    case 'discover':
      await controller.discover();
      return null;
    case 'selectProject':
      final fullName = call.arguments as String?;
      if (fullName != null) {
        controller.selectProject(fullName);
      }
      return null;
    case 'openProjectDetail':
      final fullName = call.arguments as String?;
      if (fullName != null) {
        controller.openProjectDetail(fullName);
      }
      return null;
    case 'closeProjectDetail':
      controller.closeProjectDetail();
      return null;
    case 'openSettingsProviderDetail':
      controller.openSettingsProviderDetail();
      return null;
    case 'closeSettingsProviderDetail':
      controller.closeSettingsProviderDetail();
      return null;
    case 'openSettingsAppearanceDetail':
      controller.openSettingsAppearanceDetail();
      return null;
    case 'closeSettingsAppearanceDetail':
      controller.closeSettingsAppearanceDetail();
      return null;
    case 'toggleFavorite':
      final fullName = call.arguments as String?;
      final project = state.projects
          .where((item) => item.fullName == fullName)
          .firstOrNull;
      if (project != null) {
        await controller.toggleFavorite(project);
      }
      return null;
    case 'analyzeSelectedProject':
      await controller.analyzeSelectedProject();
      return null;
    case 'analyzeSelectedProjectAndOpenAnalysis':
      await controller.analyzeSelectedProjectAndOpenAnalysis();
      return null;
    case 'exportCurrentData':
      final formatName = call.arguments as String? ?? ExportFormat.json.name;
      final format = ExportFormat.values.firstWhere(
        (item) => item.name == formatName,
        orElse: () => ExportFormat.json,
      );
      await controller.exportCurrentData(format);
      return null;
    case 'exportSelectedProjectData':
      final formatName = call.arguments as String? ?? ExportFormat.json.name;
      final format = ExportFormat.values.firstWhere(
        (item) => item.name == formatName,
        orElse: () => ExportFormat.json,
      );
      await controller.exportSelectedProjectData(format);
      return null;
    case 'openExportFile':
      final path = call.arguments as String?;
      if (path != null && path.isNotEmpty) {
        await controller.openExportFile(path);
      }
      return null;
    case 'deleteExport':
      final args = _asMap(call.arguments);
      final id = args['id'] as String?;
      final bundle = state.exports.where((item) => item.id == id).firstOrNull;
      if (bundle != null) {
        await controller.deleteExport(bundle);
      }
      return null;
    case 'updateLanguage':
      final languageName = call.arguments as String? ?? AppLanguage.system.name;
      final language = AppLanguage.values.firstWhere(
        (item) => item.name == languageName,
        orElse: () => AppLanguage.system,
      );
      await controller.updateLanguage(language);
      return null;
    case 'updateThemeMode':
      final modeName = call.arguments as String? ?? AppThemeMode.system.name;
      final mode = AppThemeMode.values.firstWhere(
        (item) => item.name == modeName,
        orElse: () => AppThemeMode.system,
      );
      await controller.updateThemeMode(mode);
      return null;
    case 'updateThemeColor':
      await controller.updateThemeColor(call.arguments as String? ?? '');
      return null;
    case 'updateAndroidLiquidGlassBackground':
      await controller.updateAndroidLiquidGlassBackground(
        call.arguments as String? ?? '',
      );
      return null;
    case 'updateVisualStyle':
      final styleName =
          call.arguments as String? ?? VisualStyle.liquidGlass.name;
      final style = VisualStyle.values.firstWhere(
        (item) => item.name == styleName,
        orElse: () => VisualStyle.liquidGlass,
      );
      await controller.updateVisualStyle(style);
      return null;
    case 'updateMcpWriteAccess':
      await controller.updateMcpWriteAccess(call.arguments == true);
      return null;
    case 'updateProvider':
      final provider = AiProviderConfig.fromJson(_asMap(call.arguments));
      await controller.updateProvider(provider);
      return null;
    case 'addProvider':
      final provider = AiProviderConfig.fromJson(_asMap(call.arguments));
      await controller.addProvider(provider);
      return null;
    case 'selectProvider':
      final providerId = call.arguments as String?;
      if (providerId != null && providerId.isNotEmpty) {
        await controller.selectProvider(providerId);
      }
      return null;
    case 'deleteProvider':
      final providerId = call.arguments as String?;
      if (providerId != null && providerId.isNotEmpty) {
        await controller.deleteProvider(providerId);
      }
      return null;
    case 'refreshSelectedProviderModels':
      await controller.refreshSelectedProviderModels();
      return null;
    case 'saveGithubToken':
      final token = (call.arguments as String?)?.trim();
      if (token != null && token.isNotEmpty) {
        await controller.saveGithubToken(token);
      }
      return null;
    case 'saveProviderApiKey':
      final apiKey = (call.arguments as String?)?.trim();
      if (apiKey != null && apiKey.isNotEmpty) {
        await controller.saveProviderApiKey(apiKey);
      }
      return null;
    default:
      throw PlatformException(
        code: 'unimplemented',
        message: 'Unknown native shell method: ${call.method}',
      );
  }
}

Map<String, Object?> nativeShellSnapshot(AppState state) {
  final totalStars = state.projects.fold<int>(
    0,
    (sum, project) => sum + project.stars,
  );
  final averageScore = state.analyses.isEmpty
      ? 0.0
      : state.analyses
                .map((analysis) => analysis.score)
                .reduce((sum, score) => sum + score) /
            state.analyses.length;

  return {
    'navigationIndex': state.navigationIndex,
    'isBootstrapping': state.isBootstrapping,
    'isDiscovering': state.isDiscovering,
    'isAnalyzing': state.isAnalyzing,
    'isExporting': state.isExporting,
    'isFetchingModels': state.isFetchingModels,
    'projectDetailOpen': state.projectDetailOpen,
    'settingsProviderDetailOpen': state.settingsProviderDetailOpen,
    'settingsAppearanceDetailOpen': state.settingsAppearanceDetailOpen,
    'selectedProjectFullName': state.selectedProjectFullName,
    'errorMessage': state.errorMessage,
    'noticeMessage': state.noticeMessage,
    'previewImagePath': state.previewImagePath,
    'totalStars': totalStars,
    'averageScore': averageScore,
    'filters': {
      'keyword': state.filters.keyword,
      'dateRange': state.filters.dateRange,
      'language': state.filters.language,
      'minStars': state.filters.minStars,
    },
    'projects': state.projects.map((project) => project.toJson()).toList(),
    'analyses': state.analyses.map((analysis) => analysis.toJson()).toList(),
    'exports': state.exports.map((bundle) => bundle.toJson()).toList(),
    'trendSnapshots': state.trendSnapshots
        .map(
          (snapshot) => {
            'label': snapshot.label,
            'projectCount': snapshot.projectCount,
            'totalStars': snapshot.totalStars,
            'averageScore': snapshot.averageScore,
          },
        )
        .toList(),
    'settings': state.settings.toJson(),
    'providers': state.settings.providers
        .map((provider) => provider.toJson())
        .toList(),
    'selectedProvider': state.settings.provider.toJson(),
    'selectedProject': state.selectedProject?.toJson(),
    'selectedAnalysis': state.selectedAnalysis?.toJson(),
  };
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry('$key', value));
  }
  return const {};
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
