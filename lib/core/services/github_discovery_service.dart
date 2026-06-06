import 'package:dio/dio.dart';

import '../models/repolens_models.dart';

class GitHubDiscoveryService {
  GitHubDiscoveryService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.github.com',
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/vnd.github+json'},
            ),
          );

  final Dio _dio;

  Future<List<AiToolProject>> searchProjects({
    required SearchFilters filters,
    String? githubToken,
  }) async {
    final response = await _dio.get<Map<String, Object?>>(
      '/search/repositories',
      queryParameters: {
        'q': filters.toGitHubQuery(),
        'sort': 'stars',
        'order': 'desc',
        'per_page': 30,
      },
      options: Options(
        headers: {
          if (githubToken != null && githubToken.trim().isNotEmpty)
            'Authorization': 'Bearer ${githubToken.trim()}',
        },
      ),
    );

    final items = response.data?['items'];
    if (items is! List) {
      return const [];
    }

    return _dedupe(
      items
          .whereType<Map<String, Object?>>()
          .map(AiToolProject.fromGitHubJson)
          .where((project) => project.fullName.isNotEmpty)
          .toList(),
    );
  }

  List<AiToolProject> _dedupe(List<AiToolProject> projects) {
    final byName = <String, AiToolProject>{};
    for (final project in projects) {
      byName[project.fullName] = project;
    }
    return byName.values.toList(growable: false);
  }
}
