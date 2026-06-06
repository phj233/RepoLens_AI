import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/app_localizations.dart';
import '../core/models/repolens_models.dart';
import '../features/home/repolens_home.dart';
import '../ui/theme.dart';
import '../ui/visual_style_resolver.dart';
import 'native_shell_bridge.dart';
import 'providers.dart';

class RepoLensApp extends ConsumerWidget {
  const RepoLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      appControllerProvider.select((state) => state.settings),
    );
    final visualStyle = resolveVisualStyleForPlatform(settings.visualStyle);
    final locale = _localeFor(settings.language);
    final themeMode = _themeModeFor(settings.themeMode);

    if (_usesNativeLiquidGlassShell(visualStyle)) {
      return WidgetsApp(
        debugShowCheckedModeBanner: false,
        title: 'RepoLens AI',
        color: Colors.transparent,
        textStyle: TextStyle(
          color: settings.themeMode == AppThemeMode.dark
              ? const Color(0xFFE9EFEA)
              : const Color(0xFF1D241F),
        ),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: _localizationDelegates,
        pageRouteBuilder: <T>(settings, builder) {
          return PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              return builder(context);
            },
          );
        },
        home: const RepoLensNativeBridgeHost(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RepoLens AI',
      theme: RepoLensTheme.light(visualStyle, settings.themeColor),
      darkTheme: RepoLensTheme.dark(visualStyle, settings.themeColor),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _localizationDelegates,
      home: const RepoLensHome(),
    );
  }

  Locale? _localeFor(AppLanguage language) {
    return switch (language) {
      AppLanguage.system => null,
      AppLanguage.simplifiedChinese => const Locale('zh', 'CN'),
      AppLanguage.english => const Locale('en'),
    };
  }

  ThemeMode _themeModeFor(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }

  bool _usesNativeLiquidGlassShell(VisualStyle visualStyle) {
    return visualStyle == VisualStyle.liquidGlass &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.android);
  }
}

const List<LocalizationsDelegate<dynamic>> _localizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];
