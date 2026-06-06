import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../widgets/common_widgets.dart';
import '../widgets/project_list_panel.dart';
import 'project_detail_page.dart';

class ProjectLibraryPage extends StatefulWidget {
  const ProjectLibraryPage({
    super.key,
    required this.state,
    required this.controller,
  });

  final AppState state;
  final AppController controller;

  @override
  State<ProjectLibraryPage> createState() => _ProjectLibraryPageState();
}

class _ProjectLibraryPageState extends State<ProjectLibraryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    final controller = widget.controller;
    if (state.projectDetailOpen) {
      return ProjectDetailPage(state: state, controller: controller);
    }

    final query = _searchController.text.trim();
    final filteredProjects = query.isEmpty
        ? state.projects
        : state.projects
              .where((project) => _projectMatchesQuery(project, query))
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: l10n.t('projectLibraryTitle'),
          subtitle: l10n.t('projectLibrarySubtitle'),
          actions: [
            LiquidGlassActionButton.icon(
              onPressed: controller.discover,
              icon: const Icon(Icons.sync),
              label: Text(l10n.t('refresh')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LiquidGlassTextField(
          controller: _searchController,
          label: l10n.t('projectSearch'),
          prefixIcon: Icons.search,
        ),
        const SizedBox(height: 12),
        ProjectListPanel(
          state: state,
          controller: controller,
          projectsOverride: filteredProjects,
          emptyMessage: query.isEmpty
              ? l10n.t('noProjects')
              : l10n.t('noProjectSearchResults'),
        ),
      ],
    );
  }

  bool _projectMatchesQuery(AiToolProject project, String query) {
    final normalizedQuery = query.toLowerCase();
    final searchable = [
      project.fullName,
      project.description,
      project.language,
      project.license,
      ...project.topics,
    ].join(' ').toLowerCase();
    return searchable.contains(normalizedQuery);
  }
}
