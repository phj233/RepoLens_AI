import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:openai_dart/openai_dart.dart' as openai;

import '../models/repolens_models.dart';

class AiModelCatalogService {
  Future<List<AiModelConfig>> fetchModels({
    required AiProviderConfig provider,
    required String? apiKey,
  }) async {
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiModelCatalogException('missing_api_key');
    }

    return switch (provider.protocol) {
      AiProviderProtocol.openAiChatCompletions => _fetchOpenAiModels(
        provider,
        apiKey,
      ),
      AiProviderProtocol.anthropicMessages => _fetchAnthropicModels(
        provider,
        apiKey,
      ),
    };
  }

  Future<List<AiModelConfig>> _fetchOpenAiModels(
    AiProviderConfig provider,
    String apiKey,
  ) async {
    final client = openai.OpenAIClient.withApiKey(
      apiKey.trim(),
      baseUrl: provider.baseUrl.trim(),
    );
    try {
      final response = await client.models.list();
      final models =
          response.data
              .where((model) => !_isNonChatOpenAiModel(model.id))
              .map(
                (model) => AiModelConfig(
                  id: model.id,
                  displayName: model.id,
                  contextLength: _contextLengthFor(model.id, provider),
                  supportsStructuredOutput: provider.supportsStructuredOutput,
                  supportsToolCalling: provider.supportsToolCalling,
                ),
              )
              .toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
      return models;
    } finally {
      client.close();
    }
  }

  Future<List<AiModelConfig>> _fetchAnthropicModels(
    AiProviderConfig provider,
    String apiKey,
  ) async {
    final client = anthropic.AnthropicClient.withApiKey(
      apiKey.trim(),
      baseUrl: provider.baseUrl.trim().isEmpty ? null : provider.baseUrl.trim(),
    );
    try {
      final response = await client.models.list(limit: 100);
      return response.data
          .map(
            (model) => AiModelConfig(
              id: model.id,
              displayName: model.displayName,
              contextLength: model.maxInputTokens ?? provider.contextLength,
              supportsStructuredOutput: provider.supportsStructuredOutput,
              supportsToolCalling: provider.supportsToolCalling,
            ),
          )
          .toList(growable: false);
    } finally {
      client.close();
    }
  }

  bool _isNonChatOpenAiModel(String id) {
    final lower = id.toLowerCase();
    return lower.contains('embedding') ||
        lower.contains('whisper') ||
        lower.contains('tts') ||
        lower.contains('dall-e') ||
        lower.contains('moderation');
  }

  int _contextLengthFor(String id, AiProviderConfig provider) {
    final lower = id.toLowerCase();
    if (lower.contains('4.1') ||
        lower.contains('4o') ||
        lower.contains('o3') ||
        lower.contains('o4') ||
        lower.contains('128k')) {
      return 128000;
    }
    if (lower.contains('32k')) {
      return 32000;
    }
    return provider.contextLength;
  }
}

class AiModelCatalogException implements Exception {
  const AiModelCatalogException(this.code);

  final String code;

  @override
  String toString() => 'AiModelCatalogException($code)';
}
