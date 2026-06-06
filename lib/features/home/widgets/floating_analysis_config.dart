import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import 'analysis_provider_picker.dart';

class FloatingAnalysisConfig extends StatefulWidget {
  const FloatingAnalysisConfig({
    super.key,
    required this.state,
    required this.controller,
  });

  final AppState state;
  final AppController controller;

  @override
  State<FloatingAnalysisConfig> createState() => _FloatingAnalysisConfigState();
}

class _FloatingAnalysisConfigState extends State<FloatingAnalysisConfig> {
  bool _expanded = false;

  @override
  void didUpdateWidget(FloatingAnalysisConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_shouldShow(widget.state)) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow(widget.state)) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = screenWidth < 580 ? screenWidth - 36 : 540.0;

    return Positioned(
      right: 18,
      bottom: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 190),
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuart,
        child: _expanded
            ? SizedBox(
                key: const ValueKey('analysis-config-expanded'),
                width: panelWidth,
                child: NativeGlassSurface(
                  enabled: widget.state.settings.usesLiquidGlass,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.t('analysisConfiguration'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          LiquidGlassIconButton(
                            tooltip: l10n.t('close'),
                            onPressed: () => setState(() {
                              _expanded = false;
                            }),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnalysisProviderPicker(
                        state: widget.state,
                        controller: widget.controller,
                        showAnalyzeButton: true,
                        openAnalysisPage: true,
                        surface: false,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              )
            : LiquidGlassActionButton.icon(
                key: const ValueKey('analysis-config-collapsed'),
                onPressed: () => setState(() {
                  _expanded = true;
                }),
                icon: const Icon(Icons.tune),
                label: Text(l10n.t('analysisConfiguration')),
                prominent: true,
              ),
      ),
    );
  }

  bool _shouldShow(AppState state) {
    return state.navigationIndex == 1 &&
        state.projectDetailOpen &&
        state.selectedProject != null;
  }
}
