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
    final isDark = brightness == Brightness.dark;
    final liquidSurface = isDark
        ? const Color(0xFF101412)
        : const Color(0xFFF2F6EF);
    final materialSurface = isDark
        ? const Color(0xFF111513)
        : const Color(0xFFF5F7F2);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: isLiquidGlass ? liquidSurface : materialSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: seed,
        secondary: const Color(0xFF516F9F),
        tertiary: const Color(0xFF9A6D2E),
        error: const Color(0xFFB5473D),
        surface: isLiquidGlass ? liquidSurface : materialSurface,
        surfaceContainer: isLiquidGlass
            ? (isDark ? const Color(0xDD171D1A) : const Color(0xDDECF2E9))
            : (isDark ? const Color(0xFF1A1F1C) : const Color(0xFFECEFE7)),
        surfaceContainerHighest: isLiquidGlass
            ? (isDark ? const Color(0xCC202821) : const Color(0xCCE0E8DF))
            : (isDark ? const Color(0xFF242B26) : const Color(0xFFE1E6DE)),
      ),
      scaffoldBackgroundColor: isLiquidGlass ? liquidSurface : materialSurface,
      extensions: [RepoLensVisualTokens(liquidGlass: isLiquidGlass)],
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
        fillColor: isLiquidGlass
            ? (isDark ? const Color(0x7A1C231F) : const Color(0x9EF8FAF4))
            : (isDark ? const Color(0xFF1A1F1C) : const Color(0xFFECEFE7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF39443D) : const Color(0xFFC9D2C7),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF39443D) : const Color(0xFFC9D2C7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: seed, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: isLiquidGlass
            ? (isDark ? const Color(0xB81C231F) : const Color(0xCCF8FAF4))
            : (isDark ? const Color(0xFF171D1A) : const Color(0xFFF8FAF4)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: isLiquidGlass
            ? (isDark ? const Color(0x9E171D1A) : const Color(0xA8F4F8F0))
            : (isDark ? const Color(0xFF1A1F1C) : const Color(0xFFECEFE7)),
        indicatorColor: isLiquidGlass
            ? seed.withValues(alpha: 0.18)
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
  const RepoLensVisualTokens({required this.liquidGlass});

  final bool liquidGlass;

  @override
  RepoLensVisualTokens copyWith({bool? liquidGlass}) {
    return RepoLensVisualTokens(liquidGlass: liquidGlass ?? this.liquidGlass);
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
    );
  }
}
