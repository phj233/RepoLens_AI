import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../app/providers.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../core/services/android_liquid_glass_bridge.dart';
import '../../../ui/visual_style_resolver.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import '../widgets/common_widgets.dart';

class SettingsAppearancePage extends ConsumerWidget {
  const SettingsAppearancePage({
    super.key,
    required this.state,
    required this.controller,
    required this.usesLiquidGlass,
  });

  final AppState state;
  final AppController controller;
  final bool usesLiquidGlass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final visualStyle = resolveVisualStyleForPlatform(
      state.settings.visualStyle,
    );

    return NativeGlassSurface(
      enabled: usesLiquidGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('visualMode'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LiquidGlassSegmentedControl<VisualStyle>(
            selected: visualStyle,
            segments: [
              LiquidGlassSegment(
                value: VisualStyle.liquidGlass,
                icon: Icons.blur_on,
                label: l10n.t('liquidGlass'),
              ),
              if (allowsMaterial3VisualChoice)
                const LiquidGlassSegment(
                  value: VisualStyle.material3,
                  icon: Icons.layers_outlined,
                  label: 'Material 3',
                ),
            ],
            onChanged: controller.updateVisualStyle,
          ),
          const SizedBox(height: 16),
          LiquidGlassColorPalette(
            label: l10n.t('themeColor'),
            hint: l10n.t('themeColorHint'),
            value: state.settings.themeColor,
            options: _themeColorOptions,
            onChanged: controller.updateThemeColor,
          ),
          const SizedBox(height: 16),
          FutureBuilder<AndroidLiquidGlassCapabilities>(
            future: ref.read(androidLiquidGlassBridgeProvider).capabilities(),
            builder: (context, snapshot) {
              final capabilities =
                  snapshot.data ?? AndroidLiquidGlassCapabilities.unavailable();
              return _AndroidGlassStatus(capabilities: capabilities);
            },
          ),
          if (defaultTargetPlatform == TargetPlatform.android &&
              visualStyle == VisualStyle.liquidGlass) ...[
            const SizedBox(height: 16),
            LiquidGlassColorPalette(
              label: l10n.t('liquidGlassFillColor'),
              hint: l10n.t('androidGlassBackgroundHint'),
              value: state.settings.androidLiquidGlassBackground,
              options: [
                LiquidGlassColorOption(
                  label: l10n.t('defaultColor'),
                  value: '',
                ),
                ..._liquidGlassFillOptions,
              ],
              allowDefault: true,
              onChanged: controller.updateAndroidLiquidGlassBackground,
            ),
          ],
        ],
      ),
    );
  }

  static const _themeColorOptions = [
    LiquidGlassColorOption(
      label: 'RepoLens',
      value: AppSettings.defaultThemeColor,
    ),
    LiquidGlassColorOption(label: 'Azure', value: '#0088FF'),
    LiquidGlassColorOption(label: 'Violet', value: '#7C3AED'),
    LiquidGlassColorOption(label: 'Amber', value: '#D97706'),
    LiquidGlassColorOption(label: 'Coral', value: '#C2410C'),
    LiquidGlassColorOption(label: 'Teal', value: '#0F766E'),
  ];

  static const _liquidGlassFillOptions = [
    LiquidGlassColorOption(label: 'Paper', value: '#FFFFFF'),
    LiquidGlassColorOption(label: 'Mist', value: '#F2F6EF'),
    LiquidGlassColorOption(label: 'Ice', value: '#EEF5FF'),
    LiquidGlassColorOption(label: 'Ink', value: '#101412'),
    LiquidGlassColorOption(label: 'Graphite', value: '#080A0D'),
  ];
}

class _AndroidGlassStatus extends StatelessWidget {
  const _AndroidGlassStatus({required this.capabilities});

  final AndroidLiquidGlassCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InfoChip(label: capabilities.library, icon: Icons.android),
        InfoChip(
          label: capabilities.packageAvailable
              ? l10n.t('backdropReady')
              : l10n.t('nativeBridgeIdle'),
          icon: capabilities.packageAvailable ? Icons.check_circle : Icons.info,
        ),
        InfoChip(
          label: capabilities.renderEffectCapable
              ? l10n.t('renderEffect')
              : l10n.t('flutterFallback'),
          icon: Icons.blur_on,
        ),
        InfoChip(
          label: capabilities.lensCapable ? l10n.t('lens') : l10n.t('noLens'),
          icon: Icons.lens_blur,
        ),
      ],
    );
  }
}
