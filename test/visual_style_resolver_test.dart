import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repolens_ai/core/models/repolens_models.dart';
import 'package:repolens_ai/ui/visual_style_resolver.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('Apple platforms resolve to Liquid Glass', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(
      resolveVisualStyleForPlatform(VisualStyle.material3),
      VisualStyle.liquidGlass,
    );
    expect(allowsMaterial3VisualChoice, isFalse);

    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    expect(
      resolveVisualStyleForPlatform(VisualStyle.material3),
      VisualStyle.liquidGlass,
    );
    expect(allowsMaterial3VisualChoice, isFalse);
  });

  test('Android can keep Material 3 as an explicit choice', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(
      resolveVisualStyleForPlatform(VisualStyle.material3),
      VisualStyle.material3,
    );
    expect(allowsMaterial3VisualChoice, isTrue);
  });
}
