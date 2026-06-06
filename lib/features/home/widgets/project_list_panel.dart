import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import 'common_widgets.dart';

class ProjectListPanel extends StatelessWidget {
  const ProjectListPanel({
    super.key,
    required this.state,
    required this.controller,
    this.limit,
    this.projectsOverride,
    this.emptyMessage,
  });

  final AppState state;
  final AppController controller;
  final int? limit;
  final List<AiToolProject>? projectsOverride;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sourceProjects = projectsOverride ?? state.projects;
    final projects = limit == null
        ? sourceProjects
        : sourceProjects.take(limit!).toList();

    return NativeGlassSurface(
      enabled: state.settings.usesLiquidGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('projectCandidates'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text(emptyMessage ?? l10n.t('noProjects'))),
            )
          else
            for (final project in projects)
              ProjectRow(
                project: project,
                analysis: state.analysisByProject[project.fullName],
                selected: state.selectedProjectFullName == project.fullName,
                onSelected: () {
                  controller.openProjectDetail(project.fullName);
                },
                onFavorite: () => controller.toggleFavorite(project),
              ),
        ],
      ),
    );
  }
}
