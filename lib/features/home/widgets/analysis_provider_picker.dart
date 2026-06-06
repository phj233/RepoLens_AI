import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';

class AnalysisProviderPicker extends StatelessWidget {
  const AnalysisProviderPicker({
    super.key,
    required this.state,
    required this.controller,
    this.showAnalyzeButton = false,
    this.openAnalysisPage = false,
    this.surface = true,
    this.showTitle = true,
  });

  final AppState state;
  final AppController controller;
  final bool showAnalyzeButton;
  final bool openAnalysisPage;
  final bool surface;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = state.settings.provider;
    final models = _analysisModels(provider);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            l10n.t('analysisConfiguration'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            SizedBox(
              width: 250,
              child: LiquidGlassSelect<String>(
                label: l10n.t('providerName'),
                value: state.settings.selectedProviderId,
                items: [
                  for (final item in state.settings.providers)
                    LiquidGlassSelectItem(value: item.id, label: item.name),
                ],
                onChanged: controller.selectProvider,
                prefixIcon: Icons.hub_outlined,
              ),
            ),
            SizedBox(
              width: 300,
              child: LiquidGlassSelect<String>(
                label: l10n.t('defaultModel'),
                value: provider.defaultModel,
                items: [
                  for (final model in models)
                    LiquidGlassSelectItem(
                      value: model.id,
                      label: model.displayName,
                    ),
                ],
                onChanged: (modelId) {
                  final model = models.firstWhere(
                    (item) => item.id == modelId,
                    orElse: () => models.first,
                  );
                  controller.updateProvider(
                    provider.copyWith(
                      defaultModel: model.id,
                      contextLength: model.contextLength,
                      supportsStructuredOutput: model.supportsStructuredOutput,
                      supportsToolCalling: model.supportsToolCalling,
                    ),
                  );
                },
                prefixIcon: Icons.memory_outlined,
              ),
            ),
            LiquidGlassActionButton.icon(
              onPressed: state.isFetchingModels
                  ? null
                  : controller.refreshSelectedProviderModels,
              icon: state.isFetchingModels
                  ? const LiquidGlassSpinner()
                  : const Icon(Icons.sync),
              label: Text(l10n.t('fetchProviderModels')),
            ),
            if (showAnalyzeButton)
              LiquidGlassActionButton.icon(
                onPressed: state.isAnalyzing || state.selectedProject == null
                    ? null
                    : () {
                        controller.analyzeSelectedProject(
                          openAnalysisPage: openAnalysisPage,
                        );
                      },
                icon: state.isAnalyzing
                    ? const LiquidGlassSpinner()
                    : const Icon(Icons.auto_awesome),
                label: Text(l10n.t('analyzeThisProject')),
                prominent: true,
              ),
          ],
        ),
      ],
    );
    if (!surface) {
      return content;
    }
    return NativeGlassSurface(
      enabled: state.settings.usesLiquidGlass,
      child: content,
    );
  }

  List<AiModelConfig> _analysisModels(AiProviderConfig provider) {
    final models = provider.availableModels;
    if (models.any((model) => model.id == provider.defaultModel)) {
      return models;
    }
    return [
      AiModelConfig(
        id: provider.defaultModel,
        displayName: provider.defaultModel,
        contextLength: provider.contextLength,
        supportsStructuredOutput: provider.supportsStructuredOutput,
        supportsToolCalling: provider.supportsToolCalling,
      ),
      ...models,
    ].where((model) => model.id.trim().isNotEmpty).toList(growable: false);
  }
}
