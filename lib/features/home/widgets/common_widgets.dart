import 'package:flutter/material.dart';

import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/theme.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(subtitle),
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ],
    );
  }
}

class DetailLine extends StatelessWidget {
  const DetailLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}

class SectionList extends StatelessWidget {
  const SectionList({super.key, required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final value in values)
                InfoChip(label: value, icon: Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }
}

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final liquidGlass =
        Theme.of(context).extension<RepoLensVisualTokens>()?.liquidGlass ??
        false;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(
          alpha: liquidGlass ? 0.66 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary),
      ),
      child: Center(
        child: Text(
          score.toStringAsFixed(0),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final liquidGlass =
        Theme.of(context).extension<RepoLensVisualTokens>()?.liquidGlass ??
        false;
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(
          alpha: liquidGlass ? 0.44 : 0.7,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiquidGlassSymbol(icon: icon, size: 15, color: scheme.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectRow extends StatelessWidget {
  const ProjectRow({
    super.key,
    required this.project,
    required this.analysis,
    required this.selected,
    required this.onSelected,
    required this.onFavorite,
  });

  final AiToolProject project;
  final AiToolAnalysis? analysis;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final liquidGlass =
        Theme.of(context).extension<RepoLensVisualTokens>()?.liquidGlass ??
        false;
    final row = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primaryContainer.withValues(
                alpha: liquidGlass ? 0.48 : 0.6,
              )
            : scheme.surfaceContainerHighest.withValues(
                alpha: liquidGlass ? 0.28 : 0.42,
              ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LiquidGlassIconButton(
            tooltip: project.isFavorite
                ? l10n.t('unfavorite')
                : l10n.t('favorite'),
            onPressed: onFavorite,
            selected: project.isFavorite,
            icon: Icon(project.isFavorite ? Icons.star : Icons.star_border),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  project.description.isEmpty
                      ? l10n.t('noDescription')
                      : project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    InfoChip(
                      label: compactNumber(project.stars),
                      icon: Icons.star,
                    ),
                    InfoChip(label: project.language, icon: Icons.code),
                    InfoChip(
                      label: analysis == null
                          ? l10n.t('pending')
                          : analysis!.score.toStringAsFixed(0),
                      icon: Icons.speed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (liquidGlass) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected,
        child: row,
      );
    }

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}

String compactNumber(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}m';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
  return '$value';
}

IconData formatIcon(ExportFormat format) {
  return switch (format) {
    ExportFormat.json => Icons.data_object,
    ExportFormat.csv => Icons.table_chart,
    ExportFormat.markdown => Icons.article_outlined,
    ExportFormat.pdf => Icons.picture_as_pdf,
    ExportFormat.png => Icons.image_outlined,
    ExportFormat.typeScriptModule => Icons.integration_instructions,
  };
}
