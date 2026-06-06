import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:repolens_ai/core/models/repolens_models.dart';
import 'package:repolens_ai/core/services/ai_model_catalog_service.dart';

void main() {
  test('OpenAI-compatible model catalog accepts gateway model variants', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      await request.drain<void>();
      await _writeJson(request.response, HttpStatus.ok, {
        'models': [
          {
            'model_id': 'chat-alpha',
            'display_name': 'Chat Alpha',
            'context_length': 64000,
            'supports_tool_calling': true,
          },
          {'id': 'text-embedding-3-small'},
        ],
      });
    });

    final provider = AiProviderConfig.tokenMixDefault().copyWith(
      baseUrl: 'http://${server.address.host}:${server.port}/v1/',
      contextLength: 32000,
      supportsStructuredOutput: true,
      supportsToolCalling: false,
    );

    final models = await AiModelCatalogService().fetchModels(
      provider: provider,
      apiKey: 'test-key',
    );

    expect(models, hasLength(1));
    expect(models.single.id, 'chat-alpha');
    expect(models.single.displayName, 'Chat Alpha');
    expect(models.single.contextLength, 64000);
    expect(models.single.supportsStructuredOutput, isTrue);
    expect(models.single.supportsToolCalling, isTrue);
  });

  test('missing model API key is explicit', () async {
    final provider = AiProviderConfig.tokenMixDefault();

    await expectLater(
      AiModelCatalogService().fetchModels(provider: provider, apiKey: ''),
      throwsA(isA<AiModelCatalogException>()),
    );
  });
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
