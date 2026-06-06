import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import '../widgets/common_widgets.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({
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

    if (project == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.t('projectDetail'),
            subtitle: l10n.t('projectDetailEmpty'),
            actions: [
              LiquidGlassActionButton.icon(
                onPressed: controller.closeProjectDetail,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.t('backToProjects')),
              ),
            ],
          ),
        ],
      );
    }

    final analysis = state.analysisByProject[project.fullName];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: project.fullName,
          subtitle: project.description.isEmpty
              ? l10n.t('noDescription')
              : project.description,
          actions: [
            LiquidGlassActionButton.icon(
              onPressed: controller.closeProjectDetail,
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.t('backToProjects')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final metadata = _ProjectMetadataPanel(
              project: project,
              analysis: analysis,
              state: state,
              controller: controller,
            );
            final topics = _ProjectTopicsPanel(project: project, state: state);
            if (constraints.maxWidth < 900) {
              return Column(
                children: [metadata, const SizedBox(height: 16), topics],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: metadata),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: topics),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProjectMetadataPanel extends StatelessWidget {
  const _ProjectMetadataPanel({
    required this.project,
    required this.analysis,
    required this.state,
    required this.controller,
  });

  final AiToolProject project;
  final AiToolAnalysis? analysis;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.t('projectDetail'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              LiquidGlassIconButton(
                tooltip: project.isFavorite
                    ? l10n.t('unfavorite')
                    : l10n.t('favorite'),
                onPressed: () => controller.toggleFavorite(project),
                selected: project.isFavorite,
                icon: Icon(project.isFavorite ? Icons.star : Icons.star_border),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DetailLine(label: 'URL', value: project.htmlUrl),
          DetailLine(label: 'Language', value: project.language),
          DetailLine(label: 'License', value: project.license),
          DetailLine(label: 'Stars', value: '${project.stars}'),
          DetailLine(label: 'Forks', value: '${project.forks}'),
          DetailLine(
            label: l10n.t('openIssues'),
            value: '${project.openIssues}',
          ),
          DetailLine(
            label: l10n.t('pushed'),
            value: project.pushedAt.toLocal().toString().split('.').first,
          ),
          const Divider(height: 28),
          if (analysis == null)
            Text(l10n.t('noStructuredAnalysis'))
          else
            Row(
              children: [
                ScoreBadge(score: analysis!.score),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis!.category,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis!.summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProjectTopicsPanel extends StatelessWidget {
  const _ProjectTopicsPanel({required this.project, required this.state});

  final AiToolProject project;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return NativeGlassSurface(
      enabled: state.settings.usesLiquidGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Topics', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final topic in project.topics.take(16))
                InfoChip(label: topic, icon: Icons.sell_outlined),
              if (project.topics.isEmpty)
                InfoChip(label: project.language, icon: Icons.code),
            ],
          ),
        ],
      ),
    );
  }
}
