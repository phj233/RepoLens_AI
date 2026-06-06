import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:repolens_ai/core/models/repolens_models.dart';
import 'package:repolens_ai/core/services/ai_analysis_service.dart';

void main() {
  late AiToolProject project;

  setUp(() {
    project = AiToolProject(
      id: 42,
      owner: 'example',
      name: 'rag-tool',
      fullName: 'example/rag-tool',
      htmlUrl: 'https://github.com/example/rag-tool',
      description: '',
      language: 'Python',
      stars: 12,
      forks: 1,
      openIssues: 30,
      topics: const ['rag', 'knowledge-base'],
      license: 'Unknown',
      createdAt: DateTime(2024),
      pushedAt: DateTime(2024),
      rawMetadata: const {'source': 'test'},
    );
  });

  test('local heuristic analysis follows the selected language', () {
    final service = AiAnalysisService();
    final zh = service.localHeuristic(
      project,
      'local-heuristic',
      AppLanguage.simplifiedChinese,
    );
    final en = service.localHeuristic(
      project,
      'local-heuristic',
      AppLanguage.english,
    );

    expect(zh.category, contains('知识库'));
    expect(zh.risks, contains('许可证信息不明确。'));
    expect(en.category, 'RAG / Knowledge Base');
    expect(en.risks, contains('License is not declared clearly.'));
  });

  test(
    'OpenAI-compatible analysis falls back from json_schema to json_object',
    () async {
      final payloads = <Map<String, dynamic>>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      server.listen((request) async {
        final body = await utf8.decoder.bind(request).join();
        final payload = jsonDecode(body) as Map<String, dynamic>;
        payloads.add(payload);

        final responseFormat = payload['response_format'];
        if (responseFormat is Map<String, dynamic> &&
            responseFormat['type'] == 'json_schema') {
          await _writeJson(request.response, HttpStatus.badRequest, {
            'error': {'message': 'json_schema is not supported'},
          });
          return;
        }

        await _writeJson(
          request.response,
          HttpStatus.ok,
          _chatCompletionResponse(_analysisJson(summary: 'Remote summary')),
        );
      });

      final provider = _providerFor(server, supportsStructuredOutput: true);
      final analysis = await AiAnalysisService().analyzeProject(
        project: project,
        settings: _settingsFor(provider),
        apiKey: 'test-key',
      );

      expect(analysis.summary, 'Remote summary');
      expect(payloads, hasLength(3));
      expect(payloads[0]['response_format'], isA<Map>());
      expect(
        (payloads[0]['response_format'] as Map<String, dynamic>)['type'],
        'json_schema',
      );
      expect(
        (payloads[1]['response_format'] as Map<String, dynamic>)['type'],
        'json_schema',
      );
      expect(
        (payloads[2]['response_format'] as Map<String, dynamic>)['type'],
        'json_object',
      );
    },
  );

  test(
    'OpenAI-compatible analysis omits response_format when disabled',
    () async {
      final payloads = <Map<String, dynamic>>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      server.listen((request) async {
        final body = await utf8.decoder.bind(request).join();
        payloads.add(jsonDecode(body) as Map<String, dynamic>);
        await _writeJson(
          request.response,
          HttpStatus.ok,
          _chatCompletionResponse(_analysisJson(summary: 'Plain JSON summary')),
        );
      });

      final provider = _providerFor(server, supportsStructuredOutput: false);
      final analysis = await AiAnalysisService().analyzeProject(
        project: project,
        settings: _settingsFor(provider),
        apiKey: 'test-key',
      );

      expect(analysis.summary, 'Plain JSON summary');
      expect(payloads, hasLength(1));
      expect(payloads.single.containsKey('response_format'), isFalse);
    },
  );

  test(
    'remote provider failures are not silently saved as local analysis',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      server.listen((request) async {
        await request.drain<void>();
        await _writeJson(request.response, HttpStatus.internalServerError, {
          'error': {'message': 'provider failed'},
        });
      });

      final provider = _providerFor(server, supportsStructuredOutput: false);

      await expectLater(
        AiAnalysisService().analyzeProject(
          project: project,
          settings: _settingsFor(provider),
          apiKey: 'test-key',
        ),
        throwsA(isA<AiAnalysisException>()),
      );
    },
  );

  test(
    'missing provider API key fails instead of running local analysis',
    () async {
      final provider = AiProviderConfig.openAiCompatibleDefault();

      await expectLater(
        AiAnalysisService().analyzeProject(
          project: project,
          settings: _settingsFor(provider),
          apiKey: null,
        ),
        throwsA(isA<AiAnalysisException>()),
      );
    },
  );

  test(
    'OpenAI-compatible analysis normalizes common model JSON variants',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      server.listen((request) async {
        await request.drain<void>();
        await _writeJson(
          request.response,
          HttpStatus.ok,
          _chatCompletionResponse({
            'analysis': {
              'category': 'RAG / Knowledge Base',
              'summary': 'Variant summary',
              'useCases': 'Knowledge-grounded answers',
              'techStack': ['Python', 123],
              'risks': ['Needs review'],
              'score': '82',
              'licenseFinding': 'License requires review.',
              'maintenanceActivity': 'Recently active.',
              'dimensions': [
                {
                  'key': 'maturity',
                  'title': 'Maturity',
                  'score': '91%',
                  'summary': 'Good activity and metadata.',
                  'evidence': ['Recent commits'],
                },
              ],
              'architectureNotes': 'RAG-style orchestration',
              'qualitySignals': ['Readable metadata'],
              'securityNotes': ['Review dependencies'],
              'businessFit': 'Useful evaluation reference.',
              'recommendation': 'Review deeply.',
              'nextSteps': ['Read README'],
            },
          }),
        );
      });

      final provider = _providerFor(server, supportsStructuredOutput: false);
      final analysis = await AiAnalysisService().analyzeProject(
        project: project,
        settings: _settingsFor(provider),
        apiKey: 'test-key',
      );

      expect(analysis.summary, 'Variant summary');
      expect(analysis.score, 82);
      expect(analysis.useCases, ['Knowledge-grounded answers']);
      expect(analysis.techStack, ['Python', '123']);
      expect(analysis.dimensions.single.score, 91);
      expect(analysis.architectureNotes, ['RAG-style orchestration']);
      expect(analysis.businessFit, 'Useful evaluation reference.');
    },
  );

  test('OpenAI-compatible analysis reads nested content-part text', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      await request.drain<void>();
      await _writeJson(request.response, HttpStatus.ok, {
        'data': _chatCompletionResponseWithContent([
          {
            'type': 'text',
            'text': {
              'value': jsonEncode(
                _analysisJson(summary: 'Nested part summary'),
              ),
            },
          },
        ]),
      });
    });

    final provider = _providerFor(server, supportsStructuredOutput: false);
    final analysis = await AiAnalysisService().analyzeProject(
      project: project,
      settings: _settingsFor(provider),
      apiKey: 'test-key',
    );

    expect(analysis.summary, 'Nested part summary');
  });

  test('OpenAI-compatible analysis reads tool call arguments', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      await request.drain<void>();
      await _writeJson(
        request.response,
        HttpStatus.ok,
        _chatCompletionResponseWithMessage({
          'role': 'assistant',
          'tool_calls': [
            {
              'id': 'call_test',
              'type': 'function',
              'function': {
                'name': 'repolens_analysis',
                'arguments': jsonEncode(
                  _analysisJson(summary: 'Tool call summary'),
                ),
              },
            },
          ],
        }),
      );
    });

    final provider = _providerFor(server, supportsStructuredOutput: false);
    final analysis = await AiAnalysisService().analyzeProject(
      project: project,
      settings: _settingsFor(provider),
      apiKey: 'test-key',
    );

    expect(analysis.summary, 'Tool call summary');
  });
}

AiProviderConfig _providerFor(
  HttpServer server, {
  required bool supportsStructuredOutput,
}) {
  return AiProviderConfig.openAiCompatibleDefault().copyWith(
    id: 'test-openai',
    name: 'Test OpenAI',
    baseUrl: 'http://${server.address.host}:${server.port}/v1/',
    apiKeyRef: 'test-openai',
    defaultModel: 'test-model',
    supportsStructuredOutput: supportsStructuredOutput,
  );
}

AppSettings _settingsFor(AiProviderConfig provider) {
  return AppSettings.defaults().copyWith(
    providers: [provider],
    selectedProviderId: provider.id,
    language: AppLanguage.english,
  );
}

Map<String, Object?> _analysisJson({required String summary}) {
  return {
    'category': 'RAG / Knowledge Base',
    'summary': summary,
    'useCases': ['Knowledge-grounded answers'],
    'techStack': ['Python'],
    'risks': ['Needs review'],
    'score': 82,
    'licenseFinding': 'License requires review.',
    'maintenanceActivity': 'Recently active.',
    'dimensions': [
      {
        'key': 'maturity',
        'title': 'Maturity',
        'score': 82,
        'summary': 'Recently active.',
        'evidence': ['Recent push'],
      },
    ],
    'architectureNotes': ['RAG-style orchestration'],
    'qualitySignals': ['Readable metadata'],
    'securityNotes': ['Review dependencies'],
    'businessFit': 'Useful evaluation reference.',
    'recommendation': 'Review deeply.',
    'nextSteps': ['Read README'],
  };
}

Map<String, Object?> _chatCompletionResponse(Map<String, Object?> analysis) {
  return _chatCompletionResponseWithContent(jsonEncode(analysis));
}

Map<String, Object?> _chatCompletionResponseWithContent(Object? content) {
  return _chatCompletionResponseWithMessage({
    'role': 'assistant',
    'content': content,
  });
}

Map<String, Object?> _chatCompletionResponseWithMessage(
  Map<String, Object?> message,
) {
  return {
    'id': 'chatcmpl-test',
    'object': 'chat.completion',
    'created': 1710000000,
    'model': 'test-model',
    'choices': [
      {'index': 0, 'message': message, 'finish_reason': 'stop'},
    ],
    'usage': {'prompt_tokens': 12, 'completion_tokens': 24, 'total_tokens': 36},
  };
}

Future<void> _writeJson(
  HttpResponse response,
  int statusCode,
  Object body,
) async {
  response.statusCode = statusCode;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  await response.close();
}
