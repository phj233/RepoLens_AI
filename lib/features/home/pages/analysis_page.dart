import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import '../widgets/common_widgets.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({
    super.key,
    required this.state,
    required this.controller,
  });

  final AppState state;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final project = state.selectedProject;
    final analysis = state.selectedAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: l10n.t('analysisTitle'),
          subtitle: project?.fullName ?? l10n.t('noProjectSelectedSubtitle'),
          actions: [
            LiquidGlassActionButton.icon(
              onPressed: () => controller.setNavigationIndex(3),
              icon: const Icon(Icons.history),
              label: Text(l10n.t('history')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (project == null)
          NativeGlassSurface(
            enabled: state.settings.usesLiquidGlass,
            child: Text(l10n.t('noAnalyzableProjects')),
          )
        else ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final summary = _AnalysisSummaryPanel(
                project: project,
                analysis: analysis,
                glass: state.settings.usesLiquidGlass,
              );
              final insights = _AnalysisInsightsPanel(
                analysis: analysis,
                glass: state.settings.usesLiquidGlass,
              );
              if (constraints.maxWidth < 940) {
                return Column(
                  children: [summary, const SizedBox(height: 16), insights],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: summary),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: insights),
                ],
              );
            },
          ),
        ],
        if (project != null) ...[
          const SizedBox(height: 16),
          _AnalysisExportPanel(state: state, controller: controller),
        ],
      ],
    );
  }
}

class _AnalysisExportPanel extends StatelessWidget {
  const _AnalysisExportPanel({required this.state, required this.controller});

  final AppState state;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NativeGlassSurface(
      enabled: state.settings.usesLiquidGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('exportThisAnalysis'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AnalysisExportButton(
                label: 'JSON',
                icon: Icons.data_object,
                onPressed: () =>
                    controller.exportSelectedProjectData(ExportFormat.json),
              ),
              _AnalysisExportButton(
                label: 'Markdown',
                icon: Icons.article_outlined,
                onPressed: () =>
                    controller.exportSelectedProjectData(ExportFormat.markdown),
              ),
              _AnalysisExportButton(
                label: 'PDF',
                icon: Icons.picture_as_pdf,
                onPressed: () =>
                    controller.exportSelectedProjectData(ExportFormat.pdf),
              ),
              _AnalysisExportButton(
                label: 'PNG',
                icon: Icons.image_outlined,
                onPressed: () =>
                    controller.exportSelectedProjectData(ExportFormat.png),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalysisExportButton extends StatelessWidget {
  const _AnalysisExportButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassActionButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _AnalysisSummaryPanel extends StatelessWidget {
  const _AnalysisSummaryPanel({
    required this.project,
    required this.analysis,
    required this.glass,
  });

  final AiToolProject project;
  final AiToolAnalysis? analysis;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NativeGlassSurface(
      enabled: glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.fullName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(project.description),
          const Divider(height: 28),
          if (analysis == null)
            Text(l10n.t('noStructuredAnalysis'))
          else ...[
            Row(
              children: [
                ScoreBadge(score: analysis!.score),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    analysis!.category,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(analysis!.summary),
            const SizedBox(height: 18),
            if (analysis!.businessFit.isNotEmpty)
              DetailLine(
                label: l10n.t('businessFit'),
                value: analysis!.businessFit,
              ),
            if (analysis!.recommendation.isNotEmpty)
              DetailLine(
                label: l10n.t('recommendation'),
                value: analysis!.recommendation,
              ),
            SectionList(
              title: l10n.t('nextSteps'),
              values: analysis!.nextSteps,
            ),
            SectionList(title: l10n.t('useCases'), values: analysis!.useCases),
            SectionList(
              title: l10n.t('techStack'),
              values: analysis!.techStack,
            ),
            DetailLine(label: 'License', value: analysis!.licenseFinding),
            DetailLine(
              label: 'Maintenance',
              value: analysis!.maintenanceActivity,
            ),
            DetailLine(label: 'Model', value: analysis!.modelId),
          ],
        ],
      ),
    );
  }
}

class _AnalysisInsightsPanel extends StatelessWidget {
  const _AnalysisInsightsPanel({required this.analysis, required this.glass});

  final AiToolAnalysis? analysis;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NativeGlassSurface(
      enabled: glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('analysisDimensions'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (analysis == null)
            Text(l10n.t('noStructuredAnalysis'))
          else ...[
            for (final dimension in analysis!.dimensions)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dimension.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text('${dimension.score.round()}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LiquidGlassProgressBar(
                      value: (dimension.score / 100).clamp(0, 1),
                    ),
                    const SizedBox(height: 8),
                    Text(dimension.summary),
                    if (dimension.evidence.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      SectionList(
                        title: l10n.t('evidence'),
                        values: dimension.evidence,
                      ),
                    ],
                  ],
                ),
              ),
            SectionList(
              title: l10n.t('architectureNotes'),
              values: analysis!.architectureNotes,
            ),
            SectionList(
              title: l10n.t('qualitySignals'),
              values: analysis!.qualitySignals,
            ),
            SectionList(
              title: l10n.t('securityNotes'),
              values: analysis!.securityNotes,
            ),
            SectionList(title: l10n.t('risks'), values: analysis!.risks),
          ],
        ],
      ),
    );
  }
}
