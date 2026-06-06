import 'dart:async';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:dio/dio.dart';
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
      baseUrl: _normalizedBaseUrl(provider.baseUrl),
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
      if (models.isEmpty) {
        return _fetchOpenAiModelsWithDio(
          provider,
          apiKey,
          sdkError: const AiModelCatalogException('sdk_empty_models'),
        );
      }
      return models;
    } catch (error) {
      return _fetchOpenAiModelsWithDio(provider, apiKey, sdkError: error);
    } finally {
      client.close();
    }
  }

  Future<List<AiModelConfig>> _fetchOpenAiModelsWithDio(
    AiProviderConfig provider,
    String apiKey, {
    required Object sdkError,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: _normalizedBaseUrl(provider.baseUrl),
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${apiKey.trim()}',
        },
        validateStatus: (_) => true,
      ),
    );
    try {
      final response = await _requestWithTransientRetry<Object?>(
        () => dio.get<Object?>('/models'),
      );
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw AiModelCatalogException(
          'http_${response.statusCode ?? 'unknown'}: ${_responsePreview(response.data)}; sdk=$sdkError',
        );
      }

      final models =
          _modelItems(response.data)
              .map((item) => _modelFromMap(item, provider))
              .where((model) => model.id.isNotEmpty)
              .where((model) => !_isNonChatOpenAiModel(model.id))
              .toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
      return models;
    } on AiModelCatalogException {
      rethrow;
    } catch (error) {
      throw AiModelCatalogException('dio_models_failed: $error; sdk=$sdkError');
    } finally {
      dio.close(force: true);
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

  String _normalizedBaseUrl(String baseUrl) {
    return baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  Iterable<Map<String, Object?>> _modelItems(Object? value) {
    final root = _objectMap(value);
    final candidates = <Object?>[
      if (value is List) value,
      root['data'],
      root['models'],
      root['items'],
    ];
    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate.map(_objectMap).where((item) => item.isNotEmpty);
      }
    }
    return const [];
  }

  AiModelConfig _modelFromMap(
    Map<String, Object?> json,
    AiProviderConfig provider,
  ) {
    final id = _firstString(json, const ['id', 'model', 'model_id', 'name']);
    final displayName = _firstString(json, const [
      'displayName',
      'display_name',
      'name',
      'id',
      'model',
    ]);
    return AiModelConfig(
      id: id,
      displayName: displayName.isEmpty ? id : displayName,
      contextLength:
          _intValue(json['contextLength']) ??
          _intValue(json['context_length']) ??
          _intValue(json['max_context_length']) ??
          _intValue(json['maxInputTokens']) ??
          _contextLengthFor(id, provider),
      supportsStructuredOutput:
          json['supportsStructuredOutput'] as bool? ??
          json['supports_structured_output'] as bool? ??
          provider.supportsStructuredOutput,
      supportsToolCalling:
          json['supportsToolCalling'] as bool? ??
          json['supports_tool_calling'] as bool? ??
          provider.supportsToolCalling,
    );
  }

  String _firstString(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  int? _intValue(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  Map<String, Object?> _objectMap(Object? value) {
    if (value is! Map) {
      return const {};
    }
    return value.map((key, value) => MapEntry('$key', value));
  }

  String _responsePreview(Object? value) {
    final text = value.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length <= 220) {
      return text;
    }
    return '${text.substring(0, 220)}...';
  }

  Future<Response<T>> _requestWithTransientRetry<T>(
    Future<Response<T>> Function() request,
  ) async {
    Object? lastError;
    const delays = [
      Duration(milliseconds: 650),
      Duration(seconds: 2),
      Duration(seconds: 5),
    ];
    for (var attempt = 0; attempt < delays.length + 1; attempt++) {
      try {
        final response = await request();
        if (!_isRetryableStatus(response.statusCode) ||
            attempt == delays.length) {
          return response;
        }
        lastError = AiModelCatalogException(
          'retryable_http_${response.statusCode}',
        );
      } catch (error) {
        if (!_isTransientNetworkError(error) || attempt == delays.length) {
          rethrow;
        }
        lastError = error;
      }
      await Future<void>.delayed(delays[attempt]);
    }
    throw AiModelCatalogException('network_retry_exhausted: $lastError');
  }

  bool _isRetryableStatus(int? statusCode) {
    return statusCode == 429 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }

  bool _isTransientNetworkError(Object error) {
    if (error is! DioException) {
      return false;
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    final message = error.toString().toLowerCase();
    return message.contains('failed host lookup') ||
        message.contains('connection reset') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused');
  }
}

class AiModelCatalogException implements Exception {
  const AiModelCatalogException(this.code);

  final String code;

  @override
  String toString() => 'AiModelCatalogException($code)';
}
