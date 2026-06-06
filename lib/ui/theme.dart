import 'package:flutter/material.dart';

import '../core/models/repolens_models.dart';

class RepoLensTheme {
  static ThemeData light(VisualStyle style, String themeColor) {
    return _build(style, Brightness.light, themeColor);
  }

  static ThemeData dark(VisualStyle style, String themeColor) {
    return _build(style, Brightness.dark, themeColor);
  }

  static ThemeData _build(
    VisualStyle style,
    Brightness brightness,
    String themeColor,
  ) {
    final isLiquidGlass = style == VisualStyle.liquidGlass;
    final seed = _parseHexColor(themeColor) ?? const Color(0xFF2F7D5F);
    final tokens = RepoLensVisualTokens.from(
      liquidGlass: isLiquidGlass,
      brightness: brightness,
      accent: seed,
    );
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: tokens.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: tokens.accent,
        onPrimary: tokens.onAccent,
        secondary: tokens.info,
        tertiary: tokens.warning,
        error: tokens.danger,
        surface: tokens.surface,
        surfaceContainer: tokens.surfaceMuted,
        surfaceContainerHighest: tokens.surfaceRaised,
        onSurface: tokens.textPrimary,
        onSurfaceVariant: tokens.textSecondary,
      ),
      scaffoldBackgroundColor: tokens.surface,
      extensions: [tokens],
      fontFamily: null,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 15),
        bodyMedium: TextStyle(fontSize: 14),
        labelLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(44, 42),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(44, 42),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: tokens.accent, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: tokens.panel,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: tokens.navigationSurface,
        indicatorColor: isLiquidGlass
            ? tokens.accentSoft
            : scheme.primaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Color? _parseHexColor(String value) {
    final cleaned = value.trim().replaceFirst('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) {
      return null;
    }
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null) {
      return null;
    }
    return Color(cleaned.length == 6 ? 0xFF000000 | parsed : parsed);
  }
}

class RepoLensVisualTokens extends ThemeExtension<RepoLensVisualTokens> {
  const RepoLensVisualTokens({
    required this.liquidGlass,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.panel,
    required this.inputFill,
    required this.navigationSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.danger,
    required this.warning,
    required this.info,
    required this.success,
    required this.glassTint,
  });

  factory RepoLensVisualTokens.from({
    required bool liquidGlass,
    required Brightness brightness,
    required Color accent,
  }) {
    final isDark = brightness == Brightness.dark;
    return RepoLensVisualTokens(
      liquidGlass: liquidGlass,
      accent: accent,
      accentSoft: accent.withValues(alpha: isDark ? 0.24 : 0.18),
      onAccent: isDark ? const Color(0xFF07111C) : const Color(0xFFF7FBFF),
      surface: liquidGlass
          ? (isDark ? const Color(0xFF101412) : const Color(0xFFF2F6EF))
          : (isDark ? const Color(0xFF111513) : const Color(0xFFF5F7F2)),
      surfaceMuted: liquidGlass
          ? (isDark ? const Color(0xDD171D1A) : const Color(0xDDECF2E9))
          : (isDark ? const Color(0xFF1A1F1C) : const Color(0xFFECEFE7)),
      surfaceRaised: liquidGlass
          ? (isDark ? const Color(0xCC202821) : const Color(0xCCE0E8DF))
          : (isDark ? const Color(0xFF242B26) : const Color(0xFFE1E6DE)),
      panel: liquidGlass
          ? (isDark ? const Color(0xB81C231F) : const Color(0xCCF8FAF4))
          : (isDark ? const Color(0xFF171D1A) : const Color(0xFFF8FAF4)),
      inputFill: liquidGlass
          ? (isDark ? const Color(0x7A1C231F) : const Color(0x9EF8FAF4))
          : (isDark ? const Color(0xFF1A1F1C) : const Color(0xFFECEFE7)),
      navigationSurface: liquidGlass
          ? (isDark ? const Color(0x9E171D1A) : const Color(0xA8F4F8F0))
          : (isDark ? const Color(0xFF1A1F1C) : const Color(0xFFECEFE7)),
      textPrimary: isDark ? const Color(0xFFE9EFEA) : const Color(0xFF1D241F),
      textSecondary: isDark ? const Color(0xFFA8B1AA) : const Color(0xFF637067),
      border: isDark ? const Color(0xFF39443D) : const Color(0xFFC9D2C7),
      danger: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB5473D),
      warning: isDark ? const Color(0xFFFFCF77) : const Color(0xFF9A6D2E),
      info: isDark ? const Color(0xFF9FC9FF) : const Color(0xFF516F9F),
      success: isDark ? const Color(0xFF90D5A8) : const Color(0xFF2F7D5F),
      glassTint: accent.withValues(alpha: isDark ? 0.10 : 0.08),
    );
  }

  final bool liquidGlass;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color panel;
  final Color inputFill;
  final Color navigationSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color danger;
  final Color warning;
  final Color info;
  final Color success;
  final Color glassTint;

  @override
  RepoLensVisualTokens copyWith({
    bool? liquidGlass,
    Color? accent,
    Color? accentSoft,
    Color? onAccent,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceRaised,
    Color? panel,
    Color? inputFill,
    Color? navigationSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? danger,
    Color? warning,
    Color? info,
    Color? success,
    Color? glassTint,
  }) {
    return RepoLensVisualTokens(
      liquidGlass: liquidGlass ?? this.liquidGlass,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      panel: panel ?? this.panel,
      inputFill: inputFill ?? this.inputFill,
      navigationSurface: navigationSurface ?? this.navigationSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      success: success ?? this.success,
      glassTint: glassTint ?? this.glassTint,
    );
  }

  @override
  RepoLensVisualTokens lerp(
    ThemeExtension<RepoLensVisualTokens>? other,
    double t,
  ) {
    if (other is! RepoLensVisualTokens) {
      return this;
    }
    return RepoLensVisualTokens(
      liquidGlass: t < 0.5 ? liquidGlass : other.liquidGlass,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      navigationSurface: Color.lerp(
        navigationSurface,
        other.navigationSurface,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      glassTint: Color.lerp(glassTint, other.glassTint, t)!,
    );
  }
}

extension RepoLensVisualTokenContext on BuildContext {
  RepoLensVisualTokens get repoLensTokens {
    final theme = Theme.of(this);
    return theme.extension<RepoLensVisualTokens>() ??
        RepoLensVisualTokens.from(
          liquidGlass: false,
          brightness: theme.brightness,
          accent: theme.colorScheme.primary,
        );
  }
}
