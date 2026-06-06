import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_state.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/models/repolens_models.dart';
import '../../../ui/widgets/liquid_glass_controls.dart';
import '../../../ui/widgets/native_glass_surface.dart';

class AiProviderSettingsPanel extends StatefulWidget {
  const AiProviderSettingsPanel({
    super.key,
    required this.state,
    required this.controller,
    required this.usesLiquidGlass,
  });

  final AppState state;
  final AppController controller;
  final bool usesLiquidGlass;

  @override
  State<AiProviderSettingsPanel> createState() =>
      _AiProviderSettingsPanelState();
}

class _AiProviderSettingsPanelState extends State<AiProviderSettingsPanel> {
  late final TextEditingController _providerNameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  late final TextEditingController _contextController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _maxTokensController;
  late final TextEditingController _apiKeyController;
  String? _activeProviderId;

  @override
  void initState() {
    super.initState();
    final provider = widget.state.settings.provider;
    _activeProviderId = provider.id;
    _providerNameController = TextEditingController(text: provider.name);
    _baseUrlController = TextEditingController(text: provider.baseUrl);
    _modelController = TextEditingController(text: provider.defaultModel);
    _contextController = TextEditingController(
      text: '${provider.contextLength}',
    );
    _temperatureController = TextEditingController(
      text: '${provider.temperature}',
    );
    _maxTokensController = TextEditingController(
      text: '${provider.maxOutputTokens}',
    );
    _apiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _providerNameController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _contextController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final provider = state.settings.provider;
    final l10n = context.l10n;
    _syncProviderControllers(provider);

    return NativeGlassSurface(
      enabled: widget.usesLiquidGlass,
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in state.settings.providers)
                _ProviderReadChip(
                  provider: item,
                  selected: item.id == state.settings.selectedProviderId,
                  onSelected: () => widget.controller.selectProvider(item.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LiquidGlassActionButton.icon(
                onPressed: _addProvider,
                icon: const Icon(Icons.add),
                label: Text(l10n.t('addProvider')),
              ),
              if (state.settings.providers.length > 1)
                LiquidGlassActionButton.icon(
                  onPressed: () =>
                      widget.controller.deleteProvider(provider.id),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.t('deleteProvider')),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LiquidGlassSegmentedControl<AiProviderProtocol>(
            selected: provider.protocol,
            segments: const [
              LiquidGlassSegment(
                value: AiProviderProtocol.openAiChatCompletions,
                icon: Icons.chat_bubble_outline,
                label: 'OpenAI',
              ),
              LiquidGlassSegment(
                value: AiProviderProtocol.anthropicMessages,
                icon: Icons.forum_outlined,
                label: 'Anthropic',
              ),
            ],
            onChanged: _selectProtocol,
          ),
          const SizedBox(height: 14),
          _SettingsGrid(
            children: [
              LiquidGlassTextField(
                controller: _providerNameController,
                label: l10n.t('providerName'),
              ),
              LiquidGlassTextField(
                controller: _baseUrlController,
                label: 'Base URL',
              ),
              LiquidGlassTextField(
                controller: _apiKeyController,
                obscureText: true,
                label: l10n.t('selectedProviderApiKey'),
              ),
              _ModelSelector(
                provider: provider,
                modelController: _modelController,
                onModelSelected: (model) {
                  _modelController.text = model.id;
                  _contextController.text = '${model.contextLength}';
                },
              ),
              LiquidGlassTextField(
                controller: _contextController,
                keyboardType: TextInputType.number,
                label: l10n.t('contextLength'),
              ),
              LiquidGlassTextField(
                controller: _temperatureController,
                keyboardType: TextInputType.number,
                label: 'temperature',
              ),
              LiquidGlassTextField(
                controller: _maxTokensController,
                keyboardType: TextInputType.number,
                label: 'max output tokens',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LiquidGlassFilterChip(
                label: l10n.t('structuredOutput'),
                selected: provider.supportsStructuredOutput,
                onChanged: (selected) {
                  widget.controller.updateProvider(
                    provider.copyWith(supportsStructuredOutput: selected),
                  );
                },
              ),
              LiquidGlassFilterChip(
                label: l10n.t('toolCalling'),
                selected: provider.supportsToolCalling,
                onChanged: (selected) {
                  widget.controller.updateProvider(
                    provider.copyWith(supportsToolCalling: selected),
                  );
                },
              ),
              LiquidGlassActionButton.icon(
                onPressed: _saveProvider,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.t('saveProvider')),
                prominent: true,
              ),
              LiquidGlassActionButton.icon(
                onPressed: state.isFetchingModels
                    ? null
                    : widget.controller.refreshSelectedProviderModels,
                icon: state.isFetchingModels
                    ? const LiquidGlassSpinner()
                    : const Icon(Icons.cloud_download_outlined),
                label: Text(l10n.t('fetchProviderModels')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectProtocol(AiProviderProtocol protocol) {
    final current = widget.state.settings.provider;
    final defaults = switch (protocol) {
      AiProviderProtocol.openAiChatCompletions => (
        name: 'OpenAI-compatible',
        baseUrl: 'https://api.openai.com/v1',
        model: 'gpt-4.1-mini',
        contextLength: 128000,
      ),
      AiProviderProtocol.anthropicMessages => (
        name: 'Anthropic',
        baseUrl: 'https://api.anthropic.com',
        model: 'claude-sonnet-4-6',
        contextLength: 200000,
      ),
    };

    _providerNameController.text = defaults.name;
    _baseUrlController.text = defaults.baseUrl;
    _modelController.text = defaults.model;
    _contextController.text = '${defaults.contextLength}';

    widget.controller.updateProvider(
      current.copyWith(
        name: defaults.name,
        protocol: protocol,
        baseUrl: defaults.baseUrl,
        defaultModel: defaults.model,
        contextLength: defaults.contextLength,
        availableModels: [
          AiModelConfig(
            id: defaults.model,
            displayName: defaults.model,
            contextLength: defaults.contextLength,
            supportsStructuredOutput: current.supportsStructuredOutput,
            supportsToolCalling: current.supportsToolCalling,
          ),
        ],
      ),
    );
  }

  void _syncProviderControllers(AiProviderConfig provider) {
    if (_activeProviderId == provider.id) {
      return;
    }
    _activeProviderId = provider.id;
    _providerNameController.text = provider.name;
    _baseUrlController.text = provider.baseUrl;
    _modelController.text = provider.defaultModel;
    _contextController.text = '${provider.contextLength}';
    _temperatureController.text = '${provider.temperature}';
    _maxTokensController.text = '${provider.maxOutputTokens}';
    _apiKeyController.clear();
  }

  void _addProvider() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final provider = AiProviderConfig.openAiCompatibleDefault().copyWith(
      id: 'openai-compatible-$timestamp',
      name: 'OpenAI-compatible $timestamp',
      apiKeyRef: 'openai-compatible-$timestamp',
    );
    widget.controller.addProvider(provider);
  }

  void _saveProvider() {
    final current = widget.state.settings.provider;
    final modelId = _modelController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final contextLength =
        int.tryParse(_contextController.text.trim()) ?? current.contextLength;
    final availableModels =
        current.availableModels.any((model) => model.id == modelId)
        ? current.availableModels
        : [
            AiModelConfig(
              id: modelId,
              displayName: modelId,
              contextLength: contextLength,
              supportsStructuredOutput: current.supportsStructuredOutput,
              supportsToolCalling: current.supportsToolCalling,
            ),
            ...current.availableModels,
          ];
    final provider = current.copyWith(
      name: _providerNameController.text.trim(),
      baseUrl: _baseUrlController.text.trim(),
      defaultModel: modelId,
      contextLength: contextLength,
      temperature:
          double.tryParse(_temperatureController.text.trim()) ??
          current.temperature,
      maxOutputTokens:
          int.tryParse(_maxTokensController.text.trim()) ??
          current.maxOutputTokens,
      availableModels: availableModels,
    );
    widget.controller.updateProvider(provider);
    if (apiKey.isNotEmpty) {
      widget.controller.saveProviderApiKey(apiKey);
      _apiKeyController.clear();
    }
  }
}

class _ProviderReadChip extends StatelessWidget {
  const _ProviderReadChip({
    required this.provider,
    required this.selected,
    required this.onSelected,
  });

  final AiProviderConfig provider;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final model = provider.defaultModel.isEmpty ? '-' : provider.defaultModel;
    return LiquidGlassFilterChip(
      label: '${provider.name} · $model',
      selected: selected,
      onChanged: (_) => onSelected(),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector({
    required this.provider,
    required this.modelController,
    required this.onModelSelected,
  });

  final AiProviderConfig provider;
  final TextEditingController modelController;
  final ValueChanged<AiModelConfig> onModelSelected;

  @override
  Widget build(BuildContext context) {
    final models = provider.availableModels
        .where((model) => model.id.trim().isNotEmpty)
        .toList(growable: false);
    if (models.isEmpty) {
      return LiquidGlassTextField(
        controller: modelController,
        label: context.l10n.t('defaultModel'),
      );
    }

    final selected = models.any((model) => model.id == modelController.text)
        ? modelController.text
        : models.first.id;
    if (modelController.text != selected) {
      modelController.text = selected;
    }

    return LiquidGlassSelect<String>(
      value: selected,
      label: context.l10n.t('defaultModel'),
      prefixIcon: Icons.memory,
      items: [
        for (final model in models)
          LiquidGlassSelectItem(
            value: model.id,
            label: model.displayName.isEmpty ? model.id : model.displayName,
          ),
      ],
      onChanged: (modelId) {
        final model = models.firstWhere((item) => item.id == modelId);
        onModelSelected(model);
      },
    );
  }
}

class _SettingsGrid extends StatelessWidget {
  const _SettingsGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last) const SizedBox(height: 10),
              ],
            ],
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final child in children)
              SizedBox(width: (constraints.maxWidth - 10) / 2, child: child),
          ],
        );
      },
    );
  }
}
