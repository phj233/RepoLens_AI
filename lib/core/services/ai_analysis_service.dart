import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:ui';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:dio/dio.dart';
import 'package:openai_dart/openai_dart.dart' as openai;

import '../models/repolens_models.dart';

class AiAnalysisException implements Exception {
  const AiAnalysisException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) {
      return message;
    }
    return '$message: $cause';
  }
}

class _OpenAiResponseFormatAttempt {
  const _OpenAiResponseFormatAttempt(this.sdkFormat, this.payload);

  final openai.ResponseFormat? sdkFormat;
  final Map<String, Object?>? payload;
}

class AiAnalysisService {
  Future<AiToolAnalysis> analyzeProject({
    required AiToolProject project,
    required AppSettings settings,
    required String? apiKey,
  }) async {
    final provider = settings.provider;
    if (provider.baseUrl.trim().isEmpty) {
      throw const AiAnalysisException('AI provider base URL is empty');
    }
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiAnalysisException('AI provider API key is missing');
    }
    if (provider.defaultModel.trim().isEmpty) {
      throw const AiAnalysisException('AI provider model is empty');
    }

    try {
      return switch (provider.protocol) {
        AiProviderProtocol.openAiChatCompletions => _analyzeWithOpenAiProtocol(
          project: project,
          provider: provider,
          apiKey: apiKey,
          language: settings.language,
        ),
        AiProviderProtocol.anthropicMessages => _analyzeWithAnthropicProtocol(
          project: project,
          provider: provider,
          apiKey: apiKey,
          language: settings.language,
        ),
      };
    } on AiAnalysisException {
      rethrow;
    } catch (error) {
      throw AiAnalysisException('AI provider analysis failed', error);
    }
  }

  AiToolAnalysis localHeuristic(
    AiToolProject project,
    String modelId, [
    AppLanguage language = AppLanguage.english,
  ]) {
    final useEnglish = _useEnglishPrompt(language);
    final searchable = [
      project.name,
      project.description,
      ...project.topics,
      project.language,
    ].join(' ').toLowerCase();

    final category = _categoryFor(searchable);
    final stack = <String>{
      if (project.language != 'Unknown') project.language,
      if (searchable.contains('python')) 'Python',
      if (searchable.contains('typescript')) 'TypeScript',
      if (searchable.contains('next')) 'Next.js',
      if (searchable.contains('langchain')) 'LangChain',
      if (searchable.contains('rag')) 'RAG',
      if (searchable.contains('mcp')) 'MCP',
      if (searchable.contains('ollama')) 'Ollama',
    }.toList(growable: false);

    final risks = <String>[
      if (project.license == 'Unknown')
        useEnglish ? 'License is not declared clearly.' : '许可证信息不明确。',
      if (project.openIssues > max(25, project.stars ~/ 20))
        useEnglish
            ? 'Open issue count looks high relative to repository size.'
            : 'Open issue 数量相对仓库规模偏高。',
      if (!project.isRecentlyUpdated)
        useEnglish
            ? 'Repository has not been updated in the last 30 days.'
            : '仓库最近 30 天内没有更新。',
      if (project.stars < 100)
        useEnglish ? 'Adoption signal is still early.' : '采用度信号仍处于早期。',
    ];

    final score = _score(project, risks.length);

    return AiToolAnalysis(
      projectFullName: project.fullName,
      category: useEnglish ? category : _localizedCategory(category),
      summary: project.description.isNotEmpty
          ? project.description
          : useEnglish
          ? '${project.fullName} appears to be an AI tool project worth manual review.'
          : '${project.fullName} 看起来是一个值得人工复核的 AI 工具项目。',
      useCases: _useCasesFor(searchable, useEnglish),
      techStack: stack.isEmpty ? const ['Unknown'] : stack,
      risks: risks,
      score: score,
      licenseFinding: project.license == 'Unknown'
          ? useEnglish
                ? 'License requires manual confirmation before reuse.'
                : '复用前需要人工确认许可证。'
          : useEnglish
          ? '${project.license} detected from GitHub metadata.'
          : 'GitHub 元数据中检测到 ${project.license} 许可证。',
      maintenanceActivity: project.isRecentlyUpdated
          ? useEnglish
                ? 'Recently updated, good maintenance signal.'
                : '近期有更新，维护活跃度信号较好。'
          : useEnglish
          ? 'No recent update in the last 30 days.'
          : '最近 30 天内没有更新。',
      dimensions: _heuristicDimensions(project, searchable, score, useEnglish),
      architectureNotes: _architectureNotesFor(searchable, useEnglish),
      qualitySignals: _qualitySignalsFor(project, searchable, useEnglish),
      securityNotes: _securityNotesFor(project, useEnglish),
      businessFit: useEnglish
          ? 'Useful as a product and architecture reference after manual validation.'
          : '适合作为产品和架构参考，复用前需要人工验证。',
      recommendation: score >= 76
          ? useEnglish
                ? 'Prioritize a deeper technical review.'
                : '建议优先做深入技术评审。'
          : useEnglish
          ? 'Keep as a watchlist candidate.'
          : '建议先放入观察列表。',
      nextSteps: useEnglish
          ? const [
              'Read README and license terms.',
              'Check recent issues and release cadence.',
              'Run a small local proof of concept.',
            ]
          : const ['阅读 README 和许可证条款。', '检查近期 issue 和发布节奏。', '做一个小型本地 POC。'],
      createdAt: DateTime.now(),
      modelId: modelId.isEmpty ? 'local-heuristic' : modelId,
    );
  }

  Future<AiToolAnalysis> _analyzeWithOpenAiProtocol({
    required AiToolProject project,
    required AiProviderConfig provider,
    required String apiKey,
    required AppLanguage language,
  }) async {
    final client = openai.OpenAIClient.withApiKey(
      apiKey.trim(),
      baseUrl: _normalizedBaseUrl(provider.baseUrl),
    );
    try {
      Object? lastError;
      for (final responseFormat in _openAiResponseFormatFallbacks(provider)) {
        try {
          final response = await client.chat.completions.create(
            openai.ChatCompletionCreateRequest(
              model: provider.defaultModel.trim(),
              messages: [
                openai.ChatMessage.system(_systemPrompt(language)),
                openai.ChatMessage.user(_analysisPrompt(project, language)),
              ],
              temperature: provider.temperature,
              maxTokens: provider.maxOutputTokens,
              responseFormat: responseFormat.sdkFormat,
            ),
          );
          final content = _contentFromOpenAiResponse(response.toJson());
          if (content.trim().isEmpty) {
            throw const AiAnalysisException(
              'OpenAI SDK response did not contain analysis content',
            );
          }
          return _analysisFromContent(
            content,
            project: project,
            modelId: provider.defaultModel.trim(),
          );
        } catch (error) {
          lastError = error;
          try {
            final content = await _createOpenAiChatCompletionWithDio(
              project: project,
              provider: provider,
              apiKey: apiKey,
              language: language,
              responseFormat: responseFormat,
              sdkError: error,
            );
            return _analysisFromContent(
              content,
              project: project,
              modelId: provider.defaultModel.trim(),
            );
          } catch (fallbackError) {
            lastError = fallbackError;
          }
        }
      }

      throw AiAnalysisException('OpenAI-compatible analysis failed', lastError);
    } finally {
      client.close();
    }
  }

  Future<AiToolAnalysis> _analyzeWithAnthropicProtocol({
    required AiToolProject project,
    required AiProviderConfig provider,
    required String apiKey,
    required AppLanguage language,
  }) async {
    final client = anthropic.AnthropicClient.withApiKey(
      apiKey.trim(),
      baseUrl: provider.baseUrl.trim().isEmpty
          ? null
          : _normalizedBaseUrl(provider.baseUrl),
    );
    try {
      Object? lastError;
      for (final outputConfig in _anthropicOutputConfigFallbacks(provider)) {
        try {
          final response = await client.messages.create(
            anthropic.MessageCreateRequest(
              model: provider.defaultModel.trim(),
              maxTokens: provider.maxOutputTokens,
              temperature: provider.temperature,
              system: anthropic.SystemPrompt.text(_systemPrompt(language)),
              messages: [
                anthropic.InputMessage.user(_analysisPrompt(project, language)),
              ],
              outputConfig: outputConfig,
            ),
          );
          return _analysisFromContent(
            response.text,
            project: project,
            modelId: provider.defaultModel.trim(),
          );
        } catch (error) {
          lastError = error;
        }
      }

      throw AiAnalysisException('Anthropic analysis failed', lastError);
    } finally {
      client.close();
    }
  }

  Future<String> _createOpenAiChatCompletionWithDio({
    required AiToolProject project,
    required AiProviderConfig provider,
    required String apiKey,
    required AppLanguage language,
    required _OpenAiResponseFormatAttempt responseFormat,
    required Object sdkError,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: _normalizedBaseUrl(provider.baseUrl),
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 45),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${apiKey.trim()}',
        },
        validateStatus: (_) => true,
      ),
    );
    try {
      final payload = <String, Object?>{
        'model': provider.defaultModel.trim(),
        'messages': [
          {'role': 'system', 'content': _systemPrompt(language)},
          {'role': 'user', 'content': _analysisPrompt(project, language)},
        ],
        'temperature': provider.temperature,
        'max_tokens': provider.maxOutputTokens,
        if (responseFormat.payload != null)
          'response_format': responseFormat.payload,
      };
      final response = await _requestWithTransientRetry<Object?>(
        () => dio.post<Object?>('/chat/completions', data: payload),
      );
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw AiAnalysisException(
          'OpenAI-compatible HTTP ${response.statusCode ?? 'unknown'}: ${_responsePreview(response.data)}; sdk=$sdkError',
        );
      }
      final content = _contentFromOpenAiResponse(response.data);
      if (content.trim().isEmpty) {
        throw AiAnalysisException(
          'OpenAI-compatible response did not contain message content: ${_responsePreview(response.data)}',
        );
      }
      return content;
    } on AiAnalysisException {
      rethrow;
    } catch (error) {
      throw AiAnalysisException(
        'OpenAI-compatible HTTP fallback failed',
        '$error; sdk=$sdkError',
      );
    } finally {
      dio.close(force: true);
    }
  }

  List<_OpenAiResponseFormatAttempt> _openAiResponseFormatFallbacks(
    AiProviderConfig provider,
  ) {
    if (!provider.supportsStructuredOutput) {
      return const [_OpenAiResponseFormatAttempt(null, null)];
    }
    return [
      _OpenAiResponseFormatAttempt(
        openai.ResponseFormat.jsonSchema(
          name: 'repolens_analysis',
          schema: _analysisJsonSchema(),
        ),
        {
          'type': 'json_schema',
          'json_schema': {
            'name': 'repolens_analysis',
            'schema': _analysisJsonSchema(),
          },
        },
      ),
      _OpenAiResponseFormatAttempt(openai.ResponseFormat.jsonObject(), {
        'type': 'json_object',
      }),
      const _OpenAiResponseFormatAttempt(null, null),
    ];
  }

  List<anthropic.OutputConfig?> _anthropicOutputConfigFallbacks(
    AiProviderConfig provider,
  ) {
    if (!provider.supportsStructuredOutput) {
      return const [null];
    }
    return [
      anthropic.OutputConfig(
        format: anthropic.JsonOutputFormat(schema: _analysisJsonSchema()),
      ),
      null,
    ];
  }

  String _analysisPrompt(AiToolProject project, AppLanguage language) {
    final projectJson = jsonEncode(project.toJson());
    if (_useEnglishPrompt(language)) {
      return '''
Analyze this repository and return JSON with:
category, summary, useCases[], techStack[], risks[], score,
licenseFinding, maintenanceActivity, dimensions[], architectureNotes[],
qualitySignals[], securityNotes[], businessFit, recommendation, nextSteps[].

Each dimensions item must include:
key, title, score, summary, evidence[].

Evaluate at least these dimensions:
maturity, adoption, integration, architecture, maintainability, security, license, businessFit.

Write all natural-language JSON values in English. Keep JSON property names exactly as specified.
Do not return company API suggestions.

Repository:
$projectJson
''';
    }

    return '''
请分析这个 GitHub 仓库，并只返回 JSON 对象，字段必须包含：
category, summary, useCases[], techStack[], risks[], score,
licenseFinding, maintenanceActivity, dimensions[], architectureNotes[],
qualitySignals[], securityNotes[], businessFit, recommendation, nextSteps[]。

dimensions 中每一项必须包含：
key, title, score, summary, evidence[]。

请至少评估这些维度：
maturity, adoption, integration, architecture, maintainability, security, license, businessFit。

所有自然语言字段值请使用简体中文。JSON 字段名必须保持英文且严格一致。
不要返回公司 API 建议。

仓库：
$projectJson
''';
  }

  AiToolAnalysis _analysisFromContent(
    String content, {
    required AiToolProject project,
    required String modelId,
  }) {
    final json = _analysisPayload(_decodeJsonObject(content));
    return AiToolAnalysis.fromJson(
      _normalizeAnalysisJson(json, project: project, modelId: modelId),
    );
  }

  Map<String, Object?> _normalizeAnalysisJson(
    Map<String, Object?> json, {
    required AiToolProject project,
    required String modelId,
  }) {
    return {
      'category': _stringValue(json['category'], fallback: 'AI Tool'),
      'summary': _stringValue(json['summary'], fallback: project.description),
      'useCases': _stringValues(json['useCases']),
      'techStack': _stringValues(json['techStack']),
      'risks': _stringValues(json['risks']),
      'score': _scoreValue(json['score']),
      'licenseFinding': _stringValue(
        json['licenseFinding'],
        fallback: 'Unknown',
      ),
      'maintenanceActivity': _stringValue(
        json['maintenanceActivity'],
        fallback: 'Unknown',
      ),
      'dimensions': _dimensionValues(json['dimensions']),
      'architectureNotes': _stringValues(json['architectureNotes']),
      'qualitySignals': _stringValues(json['qualitySignals']),
      'securityNotes': _stringValues(json['securityNotes']),
      'businessFit': _stringValue(json['businessFit']),
      'recommendation': _stringValue(json['recommendation']),
      'nextSteps': _stringValues(json['nextSteps']),
      'projectFullName': project.fullName,
      'createdAt': DateTime.now().toIso8601String(),
      'modelId': modelId,
    };
  }

  Map<String, Object?> _analysisPayload(Map<String, Object?> json) {
    var current = json;
    for (final key in ['analysis', 'data', 'result', 'output']) {
      final value = current[key];
      if (value is Map) {
        current = value.map((key, value) => MapEntry('$key', value));
      } else if (value is String) {
        final decoded = _decodeJsonObject(value);
        if (decoded.isNotEmpty) {
          current = decoded;
        }
      }
    }
    return current;
  }

  List<String> _stringValues(Object? value) {
    if (value is List) {
      return value
          .map((item) => _stringValue(item))
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String) {
      return _splitStringValue(value);
    }
    final text = _stringValue(value);
    return text.isEmpty ? const [] : [text];
  }

  List<String> _splitStringValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    final parts = trimmed
        .split(RegExp(r'\r?\n|;'))
        .map((part) => part.replaceFirst(RegExp(r'^\s*[-*•]\s*'), '').trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    return parts.isEmpty ? [trimmed] : parts;
  }

  List<Map<String, Object?>> _dimensionValues(Object? value) {
    final rawItems = switch (value) {
      List<Object?> items => items,
      Map<Object?, Object?> item => [item],
      _ => const <Object?>[],
    };

    return rawItems
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .map(
          (item) => {
            'key': _firstString(item, ['key', 'id', 'name']),
            'title': _firstString(item, ['title', 'label', 'name', 'key']),
            'score': _scoreValue(item['score']),
            'summary': _firstString(item, ['summary', 'finding', 'rationale']),
            'evidence': _stringValues(item['evidence']),
          },
        )
        .where((item) => (item['title'] as String).isNotEmpty)
        .toList(growable: false);
  }

  String _firstString(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = _stringValue(json[key]);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  String _stringValue(Object? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }
    if (value is num || value is bool) {
      return '$value';
    }
    return jsonEncode(value);
  }

  double _scoreValue(Object? value) {
    final parsed = _numberValue(value);
    final score = parsed <= 1 && parsed > 0 ? parsed * 100 : parsed;
    return score.clamp(0, 100).toDouble();
  }

  double _numberValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(0) ?? '') ?? 0;
      }
    }
    return 0;
  }

  Map<String, Object?> _decodeJsonObject(String content) {
    final cleaned = content
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\s*```$', multiLine: true), '')
        .trim();
    try {
      final decoded = _decodeJson(cleaned);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } catch (error) {
      throw AiAnalysisException(
        'AI response did not contain a valid JSON object: ${_contentPreview(content)}',
        error,
      );
    }
    return const {};
  }

  Object? _decodeJson(String cleaned) {
    try {
      return jsonDecode(cleaned);
    } on FormatException {
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start >= 0 && end > start) {
        return jsonDecode(cleaned.substring(start, end + 1));
      }
      rethrow;
    }
  }

  String _contentPreview(String content) {
    final compact = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 160) {
      return compact;
    }
    return '${compact.substring(0, 160)}...';
  }

  String _normalizedBaseUrl(String baseUrl) {
    return baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  String _contentFromOpenAiResponse(Object? value) {
    final root = _objectMap(value);
    if (root.isEmpty) {
      return _contentPartText(value);
    }

    final outputText = _stringValue(root['output_text']);
    if (outputText.isNotEmpty) {
      return outputText;
    }

    for (final key in ['data', 'result', 'response']) {
      final nested = root[key];
      if (nested == null || identical(nested, value)) {
        continue;
      }
      final nestedContent = _contentFromOpenAiResponse(nested);
      if (nestedContent.trim().isNotEmpty) {
        return nestedContent;
      }
    }

    final choices = root['choices'];
    if (choices is List && choices.isNotEmpty) {
      for (final choice in choices) {
        final firstChoice = _objectMap(choice);
        final message = _objectMap(firstChoice['message']);
        final candidates = [
          _messageContentText(message['content']),
          _contentPartText(message['parsed']),
          _toolCallArgumentsText(message['tool_calls']),
          _functionCallArgumentsText(message['function_call']),
          _contentPartText(firstChoice['text']),
        ];
        for (final candidate in candidates) {
          if (candidate.trim().isNotEmpty) {
            return candidate;
          }
        }
      }
    }

    final output = root['output'];
    if (output is List) {
      final parts = output
          .map(_objectMap)
          .map((item) {
            final content = _contentPartText(item['content']);
            if (content.trim().isNotEmpty) {
              return content;
            }
            final toolArguments = _toolCallArgumentsText(item['tool_calls']);
            if (toolArguments.trim().isNotEmpty) {
              return toolArguments;
            }
            return _functionCallArgumentsText(item);
          })
          .where((text) => text.isNotEmpty)
          .toList(growable: false);
      if (parts.isNotEmpty) {
        return parts.join('\n');
      }
    }

    final directContent = _contentPartText(root['content']);
    if (directContent.trim().isNotEmpty) {
      return directContent;
    }

    return '';
  }

  String _messageContentText(Object? content) {
    return _contentPartText(content);
  }

  String _toolCallArgumentsText(Object? toolCalls) {
    final calls = switch (toolCalls) {
      List<Object?> items => items,
      Map<Object?, Object?> item => [item],
      _ => const <Object?>[],
    };
    for (final call in calls) {
      final map = _objectMap(call);
      final function = _objectMap(map['function']);
      final candidates = [
        function['arguments'],
        map['arguments'],
        map['input'],
      ];
      for (final candidate in candidates) {
        final text = _contentPartText(candidate);
        if (text.trim().isNotEmpty) {
          return text;
        }
      }
    }
    return '';
  }

  String _functionCallArgumentsText(Object? functionCall) {
    final map = _objectMap(functionCall);
    if (map.isEmpty) {
      return '';
    }
    return _contentPartText(map['arguments']);
  }

  String _contentPartText(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    if (value is num || value is bool) {
      return '$value';
    }
    if (value is List) {
      return value
          .map(_contentPartText)
          .where((text) => text.trim().isNotEmpty)
          .join('\n');
    }
    final map = _objectMap(value);
    if (map.isEmpty) {
      return '';
    }
    for (final key in [
      'text',
      'content',
      'value',
      'json',
      'arguments',
      'input',
    ]) {
      final text = _contentPartText(map[key]);
      if (text.trim().isNotEmpty) {
        return text;
      }
    }
    if (map.containsKey('category') ||
        map.containsKey('summary') ||
        map.containsKey('analysis')) {
      return jsonEncode(map);
    }
    return '';
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
        lastError = AiAnalysisException(
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
    throw AiAnalysisException('network_retry_exhausted', lastError);
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

  Map<String, dynamic> _analysisJsonSchema() {
    return {
      'type': 'object',
      'additionalProperties': false,
      'required': [
        'category',
        'summary',
        'useCases',
        'techStack',
        'risks',
        'score',
        'licenseFinding',
        'maintenanceActivity',
        'dimensions',
        'architectureNotes',
        'qualitySignals',
        'securityNotes',
        'businessFit',
        'recommendation',
        'nextSteps',
      ],
      'properties': {
        'category': {'type': 'string'},
        'summary': {'type': 'string'},
        'useCases': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'techStack': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'risks': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'score': {'type': 'number', 'minimum': 0, 'maximum': 100},
        'licenseFinding': {'type': 'string'},
        'maintenanceActivity': {'type': 'string'},
        'dimensions': {
          'type': 'array',
          'items': {
            'type': 'object',
            'additionalProperties': false,
            'required': ['key', 'title', 'score', 'summary', 'evidence'],
            'properties': {
              'key': {'type': 'string'},
              'title': {'type': 'string'},
              'score': {'type': 'number', 'minimum': 0, 'maximum': 100},
              'summary': {'type': 'string'},
              'evidence': {
                'type': 'array',
                'items': {'type': 'string'},
              },
            },
          },
        },
        'architectureNotes': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'qualitySignals': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'securityNotes': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'businessFit': {'type': 'string'},
        'recommendation': {'type': 'string'},
        'nextSteps': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
    };
  }

  String _categoryFor(String value) {
    if (value.contains('rag') || value.contains('retrieval')) {
      return 'RAG / Knowledge Base';
    }
    if (value.contains('agent') || value.contains('workflow')) {
      return 'Agent Workflow';
    }
    if (value.contains('mcp')) {
      return 'MCP Integration';
    }
    if (value.contains('image') || value.contains('vision')) {
      return 'Multimodal';
    }
    if (value.contains('coding') || value.contains('code')) {
      return 'Developer Tooling';
    }
    return 'AI Application';
  }

  String _localizedCategory(String category) {
    return switch (category) {
      'RAG / Knowledge Base' => 'RAG / 知识库',
      'Agent Workflow' => 'Agent 工作流',
      'MCP Integration' => 'MCP 集成',
      'Multimodal' => '多模态',
      'Developer Tooling' => '开发者工具',
      _ => 'AI 应用',
    };
  }

  List<String> _useCasesFor(String value, bool useEnglish) {
    final useCases = <String>[
      if (value.contains('agent'))
        useEnglish ? 'Automated agent workflow' : '自动化 Agent 工作流',
      if (value.contains('rag'))
        useEnglish ? 'Knowledge-grounded answers' : '基于知识库的问答',
      if (value.contains('mcp'))
        useEnglish ? 'Developer tool integration' : '开发工具集成',
      if (value.contains('chat'))
        useEnglish ? 'Conversational product surface' : '对话式产品界面',
      if (value.contains('image'))
        useEnglish ? 'Image understanding or generation' : '图像理解或生成',
      if (value.contains('coding') || value.contains('code'))
        useEnglish ? 'Coding assistant experience' : '编程助手体验',
    ];

    return useCases.isEmpty
        ? [
            useEnglish
                ? 'Evaluate product pattern and reusable architecture'
                : '评估产品模式和可复用架构',
          ]
        : useCases;
  }

  List<AnalysisDimension> _heuristicDimensions(
    AiToolProject project,
    String searchable,
    double score,
    bool useEnglish,
  ) {
    final adoptionScore = min(100, log(max(project.stars, 1)) / log(10) * 24);
    final maintenanceScore = project.isRecentlyUpdated ? 86.0 : 48.0;
    final licenseScore = project.license == 'Unknown' ? 42.0 : 78.0;
    final integrationScore =
        searchable.contains('mcp') ||
            searchable.contains('api') ||
            searchable.contains('workflow')
        ? 82.0
        : 64.0;
    final architectureScore =
        searchable.contains('agent') ||
            searchable.contains('rag') ||
            searchable.contains('workflow')
        ? 80.0
        : 62.0;

    return [
      _dimension(
        key: 'maturity',
        title: useEnglish ? 'Maturity' : '成熟度',
        score: score,
        summary: useEnglish
            ? 'Estimated from repository activity, adoption, and metadata completeness.'
            : '基于仓库活跃度、采用度和元数据完整度估算。',
        evidence: [
          if (project.isRecentlyUpdated)
            useEnglish ? 'Recent push detected.' : '检测到近期推送。',
          if (project.openIssues > 0)
            useEnglish
                ? '${project.openIssues} open issues need review.'
                : '${project.openIssues} 个 open issue 需要复核。',
        ],
      ),
      _dimension(
        key: 'adoption',
        title: useEnglish ? 'Adoption' : '采用度',
        score: adoptionScore.toDouble(),
        summary: useEnglish
            ? 'GitHub stars and forks show external interest.'
            : 'GitHub stars 和 forks 反映外部关注度。',
        evidence: ['${project.stars} stars', '${project.forks} forks'],
      ),
      _dimension(
        key: 'maintainability',
        title: useEnglish ? 'Maintainability' : '可维护性',
        score: maintenanceScore,
        summary: project.isRecentlyUpdated
            ? useEnglish
                  ? 'Recent activity suggests the project is still maintained.'
                  : '近期活跃说明项目仍在维护。'
            : useEnglish
            ? 'No recent push was detected.'
            : '未检测到近期推送。',
        evidence: [project.pushedAt.toIso8601String().split('T').first],
      ),
      _dimension(
        key: 'integration',
        title: useEnglish ? 'Integration' : '集成难度',
        score: integrationScore,
        summary: useEnglish
            ? 'Topics and language suggest the likely integration surface.'
            : 'topics 和语言反映可能的集成入口。',
        evidence: project.topics.take(4).toList(growable: false),
      ),
      _dimension(
        key: 'architecture',
        title: useEnglish ? 'Architecture' : '架构参考',
        score: architectureScore,
        summary: useEnglish
            ? 'Useful for studying product structure and orchestration patterns.'
            : '适合研究产品结构和编排模式。',
        evidence: _architectureNotesFor(
          searchable,
          useEnglish,
        ).take(2).toList(),
      ),
      _dimension(
        key: 'security',
        title: useEnglish ? 'Security' : '安全性',
        score: project.license == 'Unknown' ? 56.0 : 70.0,
        summary: useEnglish
            ? 'Security requires source and dependency review before reuse.'
            : '复用前需要审查源码和依赖安全。',
        evidence: _securityNotesFor(project, useEnglish),
      ),
      _dimension(
        key: 'license',
        title: useEnglish ? 'License' : '许可证',
        score: licenseScore,
        summary: project.license == 'Unknown'
            ? useEnglish
                  ? 'License is not declared clearly.'
                  : '许可证信息不明确。'
            : useEnglish
            ? '${project.license} detected.'
            : '检测到 ${project.license} 许可证。',
        evidence: [project.license],
      ),
    ];
  }

  AnalysisDimension _dimension({
    required String key,
    required String title,
    required double score,
    required String summary,
    required List<String> evidence,
  }) {
    return AnalysisDimension(
      key: key,
      title: title,
      score: score.clamp(0, 100).toDouble(),
      summary: summary,
      evidence: evidence
          .where((item) => item.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  List<String> _architectureNotesFor(String value, bool useEnglish) {
    return [
      if (value.contains('agent') || value.contains('workflow'))
        useEnglish
            ? 'Contains agent or workflow orchestration signals.'
            : '包含 Agent 或工作流编排信号。',
      if (value.contains('rag') || value.contains('knowledge'))
        useEnglish
            ? 'Contains retrieval or knowledge-base architecture signals.'
            : '包含检索或知识库架构信号。',
      if (value.contains('mcp'))
        useEnglish ? 'Mentions MCP integration patterns.' : '包含 MCP 集成模式。',
      if (value.contains('typescript') || value.contains('python'))
        useEnglish
            ? 'Primary stack is common enough for internal adaptation.'
            : '主技术栈常见，便于内部改造。',
    ];
  }

  List<String> _qualitySignalsFor(
    AiToolProject project,
    String value,
    bool useEnglish,
  ) {
    return [
      if (project.stars >= 1000)
        useEnglish ? 'Strong public adoption signal.' : '公开采用度信号较强。',
      if (project.isRecentlyUpdated)
        useEnglish ? 'Repository was updated recently.' : '仓库近期有更新。',
      if (value.contains('test'))
        useEnglish ? 'Repository metadata mentions tests.' : '仓库元数据提到测试。',
      if (project.topics.isNotEmpty)
        useEnglish
            ? 'Topics provide usable project classification.'
            : 'topics 可辅助项目分类。',
    ];
  }

  List<String> _securityNotesFor(AiToolProject project, bool useEnglish) {
    return [
      useEnglish
          ? 'Review dependency tree and runtime permissions before reuse.'
          : '复用前审查依赖树和运行时权限。',
      if (project.license == 'Unknown')
        useEnglish
            ? 'Unknown license increases legal and security review effort.'
            : '未知许可证会增加法务和安全审查成本。',
    ];
  }

  double _score(AiToolProject project, int riskCount) {
    final starScore = min(35, log(max(project.stars, 1)) / log(10) * 11);
    final forkScore = min(15, log(max(project.forks, 1)) / log(10) * 6);
    final activityScore = project.isRecentlyUpdated ? 28 : 12;
    final licenseScore = project.license == 'Unknown' ? 4 : 12;
    return (starScore +
            forkScore +
            activityScore +
            licenseScore -
            riskCount * 5)
        .clamp(0, 100)
        .toDouble();
  }
}

String _systemPrompt(AppLanguage language) {
  if (_useEnglishPrompt(language)) {
    return 'You analyze GitHub AI tool repositories across product, technical, maintenance, security, license, and adoption dimensions. Return strict JSON only. Write natural-language values in English. Do not include company API suggestions.';
  }
  return '你负责从产品、技术、维护、安全、许可证、采用度等维度分析 GitHub AI 工具仓库。只返回严格 JSON，自然语言字段值使用简体中文。不要包含公司 API 建议。';
}

bool _useEnglishPrompt(AppLanguage language) {
  return switch (language) {
    AppLanguage.english => true,
    AppLanguage.simplifiedChinese => false,
    AppLanguage.system =>
      PlatformDispatcher.instance.locale.languageCode.toLowerCase() == 'en',
  };
}
