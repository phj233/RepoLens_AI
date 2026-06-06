import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import '../widgets/common_widgets.dart';
import '../widgets/project_list_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.state,
    required this.controller,
  });

  final AppState state;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalStars = state.projects.fold<int>(
      0,
      (sum, project) => sum + project.stars,
    );
    final averageScore = state.analyses.isEmpty
        ? 0.0
        : state.analyses
                  .map((analysis) => analysis.score)
                  .reduce((sum, score) => sum + score) /
              state.analyses.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: l10n.t('dashboardTitle'),
          subtitle: l10n.t('dashboardSubtitle'),
          actions: [
            LiquidGlassActionButton.icon(
              onPressed: state.isDiscovering ? null : controller.discover,
              icon: state.isDiscovering
                  ? const LiquidGlassSpinner()
                  : const Icon(Icons.travel_explore),
              label: Text(l10n.t('discoverProjects')),
              prominent: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MetricPill(
              label: l10n.t('projectsMetric'),
              value: '${state.projects.length}',
              icon: Icons.folder,
            ),
            MetricPill(
              label: l10n.t('starsMetric'),
              value: compactNumber(totalStars),
              icon: Icons.star,
            ),
            MetricPill(
              label: l10n.t('analysesMetric'),
              value: '${state.analyses.length}',
              icon: Icons.psychology_alt,
            ),
            MetricPill(
              label: l10n.t('avgScoreMetric'),
              value: averageScore.toStringAsFixed(1),
              icon: Icons.speed,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SearchPanel(state: state, controller: controller),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final chart = _TrendPanel(state: state);
            final list = ProjectListPanel(
              state: state,
              controller: controller,
              limit: 8,
            );
            if (constraints.maxWidth < 900) {
              return Column(
                children: [chart, const SizedBox(height: 16), list],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: chart),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: list),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SearchPanel extends StatefulWidget {
  const _SearchPanel({required this.state, required this.controller});

  final AppState state;
  final AppController controller;

  @override
  State<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<_SearchPanel> {
  late final TextEditingController _keywordController;
  late String _dateRange;
  late String _language;
  late int _minStars;

  @override
  void initState() {
    super.initState();
    final filters = widget.state.filters;
    _keywordController = TextEditingController(text: filters.keyword);
    _dateRange = filters.dateRange;
    _language = filters.language;
    _minStars = filters.minStars;
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NativeGlassSurface(
      enabled: widget.state.settings.usesLiquidGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('searchFilters'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final keywordField = LiquidGlassTextField(
                controller: _keywordController,
                label: l10n.t('keyword'),
                prefixIcon: Icons.search,
                onSubmitted: (_) => _applyAndDiscover(),
              );
              final dateField = LiquidGlassSelect<String>(
                value: _dateRange,
                label: l10n.t('date'),
                items: [
                  LiquidGlassSelectItem(
                    value: 'Today',
                    label: l10n.dateRangeLabel('Today'),
                  ),
                  LiquidGlassSelectItem(
                    value: 'This week',
                    label: l10n.dateRangeLabel('This week'),
                  ),
                  LiquidGlassSelectItem(
                    value: 'Any',
                    label: l10n.dateRangeLabel('Any'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _dateRange = value);
                },
              );
              final languageField = LiquidGlassSelect<String>(
                value: _language,
                label: l10n.t('language'),
                items: [
                  LiquidGlassSelectItem(
                    value: 'Any',
                    label: l10n.languageFilterLabel('Any'),
                  ),
                  const LiquidGlassSelectItem(value: 'Dart', label: 'Dart'),
                  const LiquidGlassSelectItem(value: 'Python', label: 'Python'),
                  const LiquidGlassSelectItem(
                    value: 'TypeScript',
                    label: 'TypeScript',
                  ),
                  const LiquidGlassSelectItem(value: 'Kotlin', label: 'Kotlin'),
                  const LiquidGlassSelectItem(value: 'Swift', label: 'Swift'),
                ],
                onChanged: (value) {
                  setState(() => _language = value);
                },
              );

              if (constraints.maxWidth < 720) {
                return Column(
                  children: [
                    keywordField,
                    const SizedBox(height: 10),
                    dateField,
                    const SizedBox(height: 10),
                    languageField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: keywordField),
                  const SizedBox(width: 10),
                  Expanded(child: dateField),
                  const SizedBox(width: 10),
                  Expanded(child: languageField),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final minStarsLabel = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiquidGlassSymbol(
                    icon: Icons.star_rate,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.minStars(_minStars),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
              final slider = LiquidGlassSlider(
                value: _minStars.toDouble(),
                min: 0,
                max: 1000,
                divisions: 200,
                label: '$_minStars',
                onChanged: (value) => setState(() => _minStars = value.toInt()),
              );
              final searchButton = LiquidGlassActionButton.icon(
                onPressed: widget.state.isDiscovering
                    ? null
                    : _applyAndDiscover,
                icon: const Icon(Icons.travel_explore),
                label: Text(l10n.t('search')),
                prominent: true,
              );

              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    minStarsLabel,
                    slider,
                    Align(
                      alignment: Alignment.centerRight,
                      child: searchButton,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  minStarsLabel,
                  Expanded(child: slider),
                  searchButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _applyAndDiscover() {
    widget.controller.updateFilters(
      SearchFilters(
        keyword: _keywordController.text,
        dateRange: _dateRange,
        language: _language,
        minStars: _minStars,
      ),
    );
    widget.controller.discover();
  }
}

class _TrendPanel extends StatelessWidget {
  const _TrendPanel({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final snapshots = state.trendSnapshots.take(6).toList(growable: false);
    final maxStars = snapshots.fold<int>(
      1,
      (maxValue, snapshot) =>
          snapshot.totalStars > maxValue ? snapshot.totalStars : maxValue,
    );

    return NativeGlassSurface(
      enabled: state.settings.usesLiquidGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('languageHeat'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 280,
            child: snapshots.isEmpty
                ? Center(child: Text(l10n.t('noTrendData')))
                : BarChart(
                    BarChartData(
                      maxY: maxStars.toDouble() * 1.15,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= snapshots.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  snapshots[index].label,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var index = 0; index < snapshots.length; index++)
                          BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: snapshots[index].totalStars.toDouble(),
                                width: 24,
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
