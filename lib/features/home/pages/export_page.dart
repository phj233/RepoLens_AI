import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import '../widgets/common_widgets.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key, required this.state, required this.controller});

  final AppState state;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: l10n.t('exportTitle'),
          subtitle: l10n.t('exportSubtitle'),
          actions: [if (state.isExporting) const LiquidGlassSpinner(size: 24)],
        ),
        const SizedBox(height: 16),
        NativeGlassSurface(
          enabled: state.settings.usesLiquidGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('exportHistory'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (state.exports.isEmpty)
                Text(l10n.t('noExports'))
              else
                for (final bundle in state.exports.take(12))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        LiquidGlassSymbol(
                          icon: formatIcon(bundle.format),
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            bundle.filePath,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(bundle.format.name),
                        const SizedBox(width: 8),
                        LiquidGlassIconButton(
                          tooltip: l10n.t('openExportFile'),
                          onPressed: () =>
                              controller.openExportFile(bundle.filePath),
                          icon: const Icon(Icons.open_in_new),
                        ),
                        const SizedBox(width: 4),
                        LiquidGlassIconButton(
                          tooltip: l10n.t('deleteExport'),
                          onPressed: () => controller.deleteExport(bundle),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
