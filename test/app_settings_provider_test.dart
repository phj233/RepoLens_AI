import 'package:flutter_test/flutter_test.dart';
import 'package:repolens_ai/core/models/repolens_models.dart';

void main() {
  test('legacy single provider settings migrate to provider list', () {
    final settings = AppSettings.fromJson({
      'language': 'english',
      'provider': AiProviderConfig.openAiCompatibleDefault().toJson(),
    });

    expect(
      settings.providers.map((provider) => provider.id),
      contains('tokenmix'),
    );
    expect(
      settings.providers.map((provider) => provider.id),
      contains('openai-compatible-custom'),
    );
    expect(settings.selectedProviderId, settings.provider.id);
    expect(settings.provider.defaultModel, 'gpt-4.1-mini');
  });

  test('TokenMix is the default built-in provider', () {
    final settings = AppSettings.defaults();

    expect(settings.selectedProviderId, 'tokenmix');
    expect(settings.provider.name, 'TokenMix');
    expect(settings.provider.baseUrl, 'https://api.tokenmix.ai/v1');
    expect(
      settings.providers.map((provider) => provider.name),
      contains('DeepSeek'),
    );
    expect(
      settings.providers.map((provider) => provider.name),
      contains('Anthropic'),
    );
    expect(
      settings.providers.map((provider) => provider.baseUrl),
      contains('https://api.xiaomimimo.com/v1'),
    );
    expect(
      settings.providers.map((provider) => provider.baseUrl),
      contains('https://token-plan-cn.xiaomimimo.com/v1'),
    );
    expect(
      settings.providers.map((provider) => provider.baseUrl),
      contains('https://token-plan-sgp.xiaomimimo.com/v1'),
    );
    expect(
      settings.providers.map((provider) => provider.baseUrl),
      contains('https://token-plan-ams.xiaomimimo.com/v1'),
    );
  });

  test('selected provider controls the active analysis provider', () {
    final openAi = AiProviderConfig.openAiCompatibleDefault();
    final anthropic = openAi.copyWith(
      id: 'anthropic-main',
      name: 'Anthropic',
      type: AiProviderType.anthropic,
      protocol: AiProviderProtocol.anthropicMessages,
      baseUrl: 'https://api.anthropic.com',
      defaultModel: 'claude-sonnet-4-6',
    );
    final settings = AppSettings.defaults().copyWith(
      providers: [openAi, anthropic],
      selectedProviderId: anthropic.id,
    );

    expect(settings.provider.id, anthropic.id);
    expect(settings.provider.protocol, AiProviderProtocol.anthropicMessages);
    expect(settings.provider.defaultModel, 'claude-sonnet-4-6');
  });

  test('provider models survive native channel map payloads', () {
    final provider = AiProviderConfig.fromJson(<String, Object?>{
      'id': 'openai-compatible-custom',
      'name': 'OpenAI-compatible',
      'type': 'openAiCompatible',
      'protocol': 'openAiChatCompletions',
      'baseUrl': 'https://api.openai.com/v1',
      'defaultModel': 'gpt-4.1-mini',
      'availableModels': <Object?>[
        <Object?, Object?>{
          'id': 'gpt-4.1-mini',
          'displayName': 'gpt-4.1-mini',
          'contextLength': 128000,
          'supportsStructuredOutput': true,
          'supportsToolCalling': true,
        },
        <Object?, Object?>{
          'id': 'gpt-4.1',
          'displayName': 'gpt-4.1',
          'contextLength': 128000,
          'supportsStructuredOutput': true,
          'supportsToolCalling': true,
        },
      ],
    });

    expect(provider.availableModels.map((model) => model.id), [
      'gpt-4.1-mini',
      'gpt-4.1',
    ]);
  });

  test('provider list survives native channel map payloads', () {
    final settings = AppSettings.fromJson(<String, Object?>{
      'selectedProviderId': 'anthropic-main',
      'providers': <Object?>[
        AiProviderConfig.openAiCompatibleDefault().toJson(),
        <Object?, Object?>{
          'id': 'anthropic-main',
          'name': 'Anthropic',
          'type': 'anthropic',
          'protocol': 'anthropicMessages',
          'baseUrl': 'https://api.anthropic.com',
          'defaultModel': 'claude-sonnet-4-6',
          'availableModels': <Object?>[
            <Object?, Object?>{
              'id': 'claude-sonnet-4-6',
              'displayName': 'claude-sonnet-4-6',
              'contextLength': 200000,
            },
          ],
        },
      ],
    });

    expect(
      settings.providers.map((provider) => provider.id),
      contains('tokenmix'),
    );
    expect(
      settings.providers.map((provider) => provider.id),
      contains('anthropic-main'),
    );
    expect(settings.provider.id, 'anthropic-main');
    expect(settings.provider.availableModels.single.id, 'claude-sonnet-4-6');
  });

  test('appearance settings survive serialization', () {
    final settings = AppSettings.defaults().copyWith(
      themeMode: AppThemeMode.dark,
      androidLiquidGlassBackground: '#101010',
    );
    final restored = AppSettings.fromJson(settings.toJson());

    expect(restored.themeMode, AppThemeMode.dark);
    expect(restored.androidLiquidGlassBackground, '#101010');
  });
}
