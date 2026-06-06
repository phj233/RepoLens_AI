import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'liquid_glass_controls.dart';

const _nativeGlassViewType = 'repolens.ai/native_liquid_glass_surface';

class NativeGlassSurface extends StatelessWidget {
  const NativeGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.enabled = true,
    this.borderRadius = 8,
    this.surfaceAlpha = 0.55,
    this.tintAlpha = 0.20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool enabled;
  final double borderRadius;
  final double surfaceAlpha;
  final double tintAlpha;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!enabled) {
      return Card(
        margin: margin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: Padding(padding: padding, child: child),
      );
    }

    final nativeView = _nativeGlassView(context);
    if (nativeView == null) {
      return Card(
        margin: margin,
        color: scheme.surface.withValues(alpha: surfaceAlpha),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: Padding(padding: padding, child: child),
      );
    }

    return Padding(
      padding: margin,
      child: Stack(
        children: [
          Positioned.fill(child: nativeView),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }

  Widget? _nativeGlassView(BuildContext context) {
    final direction = Directionality.of(context);
    final scheme = Theme.of(context).colorScheme;
    final params = <String, Object?>{
      'cornerRadius': borderRadius,
      'tintColor': _argb32(scheme.primary.withValues(alpha: tintAlpha)),
      'surfaceColor': _argb32(scheme.surface.withValues(alpha: surfaceAlpha)),
    };

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => null,
      TargetPlatform.iOS => UiKitView(
        viewType: _nativeGlassViewType,
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        layoutDirection: direction,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      ),
      TargetPlatform.macOS => AppKitView(
        viewType: _nativeGlassViewType,
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        layoutDirection: direction,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      ),
      _ => null,
    };
  }

  int _argb32(Color color) {
    return color.toARGB32();
  }
}

class MetricPill extends StatelessWidget {
  const MetricPill({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final liquidGlass =
        Theme.of(context).extension<RepoLensVisualTokens>()?.liquidGlass ??
        false;
    return Container(
      constraints: const BoxConstraints(minWidth: 136),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: liquidGlass
            ? Colors.transparent
            : scheme.surfaceContainerHighest.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: liquidGlass ? Colors.transparent : scheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiquidGlassSymbol(icon: icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
