import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/visual_style_resolver.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';
import '../widgets/common_widgets.dart';
import 'settings_ai_provider_panel.dart';
import 'settings_appearance_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.state,
    required this.controller,
  });

  final AppState state;
  final AppController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _githubTokenController = TextEditingController();

  @override
  void dispose() {
    _githubTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = context.l10n;
    final visualStyle = resolveVisualStyleForPlatform(
      state.settings.visualStyle,
    );
    final usesLiquidGlass = visualStyle == VisualStyle.liquidGlass;

    if (state.settingsProviderDetailOpen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.t('aiProviders'),
            subtitle: l10n.t('providerSettingsDetailSubtitle'),
            actions: [
              LiquidGlassActionButton.icon(
                onPressed: widget.controller.closeSettingsProviderDetail,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.t('navSettings')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AiProviderSettingsPanel(
            state: state,
            controller: widget.controller,
            usesLiquidGlass: usesLiquidGlass,
          ),
        ],
      );
    }

    if (state.settingsAppearanceDetailOpen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: l10n.t('appearanceSettings'),
            subtitle: l10n.t('appearanceSettingsSubtitle'),
            actions: [
              LiquidGlassActionButton.icon(
                onPressed: widget.controller.closeSettingsAppearanceDetail,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.t('navSettings')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsAppearancePage(
            state: state,
            controller: widget.controller,
            usesLiquidGlass: usesLiquidGlass,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: l10n.t('navSettings'),
          subtitle: l10n.t('settingsSubtitle'),
          actions: const [],
        ),
        const SizedBox(height: 16),
        NativeGlassSurface(
          enabled: usesLiquidGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LiquidGlassSelect<AppLanguage>(
                value: state.settings.language,
                label: l10n.t('displayLanguage'),
                prefixIcon: Icons.translate,
                items: [
                  for (final language in AppLanguage.values)
                    LiquidGlassSelectItem(
                      value: language,
                      label: l10n.languageName(language),
                    ),
                ],
                onChanged: widget.controller.updateLanguage,
              ),
              const SizedBox(height: 14),
              LiquidGlassSelect<AppThemeMode>(
                value: state.settings.themeMode,
                label: l10n.t('themeMode'),
                prefixIcon: Icons.contrast,
                items: [
                  for (final mode in AppThemeMode.values)
                    LiquidGlassSelectItem(
                      value: mode,
                      label: l10n.themeModeName(mode),
                    ),
                ],
                onChanged: widget.controller.updateThemeMode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _AppearanceSettingsEntry(
          state: state,
          usesLiquidGlass: usesLiquidGlass,
          onOpen: widget.controller.openSettingsAppearanceDetail,
        ),
        const SizedBox(height: 16),
        _ProviderSettingsEntry(
          state: state,
          usesLiquidGlass: usesLiquidGlass,
          onOpen: widget.controller.openSettingsProviderDetail,
        ),
        const SizedBox(height: 16),
        NativeGlassSurface(
          enabled: usesLiquidGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GitHub Token',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('githubTokenHint'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              LiquidGlassTextField(
                controller: _githubTokenController,
                obscureText: true,
                label: 'GitHub Token',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  LiquidGlassActionButton.icon(
                    onPressed: () {
                      if (_githubTokenController.text.trim().isNotEmpty) {
                        widget.controller.saveGithubToken(
                          _githubTokenController.text.trim(),
                        );
                        _githubTokenController.clear();
                      }
                    },
                    icon: const Icon(Icons.key),
                    label: Text(l10n.t('saveGithubToken')),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        NativeGlassSurface(
          enabled: usesLiquidGlass,
          child: LiquidGlassSwitchTile(
            title: l10n.t('mcpWriteAccess'),
            subtitle: l10n.t('mcpWriteAccessSubtitle'),
            value: state.settings.mcpWriteAccessEnabled,
            onChanged: widget.controller.updateMcpWriteAccess,
          ),
        ),
      ],
    );
  }
}

class _AppearanceSettingsEntry extends StatelessWidget {
  const _AppearanceSettingsEntry({
    required this.state,
    required this.usesLiquidGlass,
    required this.onOpen,
  });

  final AppState state;
  final bool usesLiquidGlass;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visualStyle = resolveVisualStyleForPlatform(
      state.settings.visualStyle,
    );
    final visualStyleLabel = visualStyle == VisualStyle.liquidGlass
        ? l10n.t('liquidGlass')
        : 'Material 3';

    return NativeGlassSurface(
      enabled: usesLiquidGlass,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('appearanceSettings'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('appearanceSummary'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(label: visualStyleLabel, icon: Icons.blur_on),
                    InfoChip(
                      label: state.settings.themeColor,
                      icon: Icons.palette_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          LiquidGlassActionButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.chevron_right),
            label: Text(l10n.t('configureAppearance')),
          ),
        ],
      ),
    );
  }
}

class _ProviderSettingsEntry extends StatelessWidget {
  const _ProviderSettingsEntry({
    required this.state,
    required this.usesLiquidGlass,
    required this.onOpen,
  });

  final AppState state;
  final bool usesLiquidGlass;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = state.settings.provider;
    return NativeGlassSurface(
      enabled: usesLiquidGlass,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('aiProviders'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('tokenMixProviderHint'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(label: provider.name, icon: Icons.hub_outlined),
                    InfoChip(
                      label: provider.defaultModel,
                      icon: Icons.memory_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          LiquidGlassActionButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.chevron_right),
            label: Text(l10n.t('configureProviders')),
          ),
        ],
      ),
    );
  }
}
