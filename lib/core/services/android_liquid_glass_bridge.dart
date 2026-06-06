import 'dart:io';

import 'package:flutter/services.dart';

class AndroidLiquidGlassCapabilities {
  const AndroidLiquidGlassCapabilities({
    required this.library,
    required this.packageAvailable,
    required this.androidSdk,
    required this.renderEffectCapable,
    required this.lensCapable,
    required this.defaultStyle,
    required this.alternateStyle,
  });

  final String library;
  final bool packageAvailable;
  final int androidSdk;
  final bool renderEffectCapable;
  final bool lensCapable;
  final String defaultStyle;
  final String alternateStyle;

  factory AndroidLiquidGlassCapabilities.unavailable() {
    return const AndroidLiquidGlassCapabilities(
      library: 'io.github.kyant0:backdrop:2.0.0',
      packageAvailable: false,
      androidSdk: 0,
      renderEffectCapable: false,
      lensCapable: false,
      defaultStyle: 'liquidGlass',
      alternateStyle: 'jetpackMaterial3',
    );
  }

  factory AndroidLiquidGlassCapabilities.fromMap(Map<Object?, Object?> map) {
    return AndroidLiquidGlassCapabilities(
      library: map['library'] as String? ?? 'io.github.kyant0:backdrop:2.0.0',
      packageAvailable: map['packageAvailable'] as bool? ?? false,
      androidSdk: (map['androidSdk'] as num?)?.toInt() ?? 0,
      renderEffectCapable: map['renderEffectCapable'] as bool? ?? false,
      lensCapable: map['lensCapable'] as bool? ?? false,
      defaultStyle: map['defaultStyle'] as String? ?? 'liquidGlass',
      alternateStyle: map['alternateStyle'] as String? ?? 'jetpackMaterial3',
    );
  }
}

class AndroidLiquidGlassBridge {
  static const _channel = MethodChannel('repolens.ai/android_liquid_glass');

  Future<AndroidLiquidGlassCapabilities> capabilities() async {
    if (!Platform.isAndroid) {
      return AndroidLiquidGlassCapabilities.unavailable();
    }

    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>(
        'capabilities',
      );
      if (result == null) {
        return AndroidLiquidGlassCapabilities.unavailable();
      }
      return AndroidLiquidGlassCapabilities.fromMap(result);
    } catch (_) {
      return AndroidLiquidGlassCapabilities.unavailable();
    }
  }
}
