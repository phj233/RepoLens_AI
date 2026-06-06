import '../models/repolens_models.dart';
import 'ai_analysis_service.dart';

class SampleData {
  static List<AiToolProject> projects() {
    final now = DateTime.now();
    return [
      AiToolProject(
        id: 1,
        owner: 'modelcontextprotocol',
        name: 'servers',
        fullName: 'modelcontextprotocol/servers',
        htmlUrl: 'https://github.com/modelcontextprotocol/servers',
        description:
            'Reference servers and examples for connecting AI tools to data sources.',
        language: 'TypeScript',
        stars: 62000,
        forks: 6900,
        openIssues: 320,
        topics: const ['mcp', 'agent', 'tool-calling', 'llm'],
        license: 'MIT',
        createdAt: now.subtract(const Duration(days: 640)),
        pushedAt: now.subtract(const Duration(days: 2)),
        rawMetadata: const {'source': 'sample'},
      ),
      AiToolProject(
        id: 2,
        owner: 'langchain-ai',
        name: 'langgraph',
        fullName: 'langchain-ai/langgraph',
        htmlUrl: 'https://github.com/langchain-ai/langgraph',
        description:
            'Build resilient language agents as graphs with persistence and control.',
        language: 'Python',
        stars: 16000,
        forks: 2900,
        openIssues: 210,
        topics: const ['agent', 'workflow', 'llm', 'python'],
        license: 'MIT',
        createdAt: now.subtract(const Duration(days: 720)),
        pushedAt: now.subtract(const Duration(days: 1)),
        rawMetadata: const {'source': 'sample'},
      ),
      AiToolProject(
        id: 3,
        owner: 'run-llama',
        name: 'llama_index',
        fullName: 'run-llama/llama_index',
        htmlUrl: 'https://github.com/run-llama/llama_index',
        description:
            'Data framework for building LLM applications over private knowledge.',
        language: 'Python',
        stars: 43000,
        forks: 6100,
        openIssues: 860,
        topics: const ['rag', 'knowledge-base', 'embeddings', 'llm'],
        license: 'MIT',
        createdAt: now.subtract(const Duration(days: 1250)),
        pushedAt: now.subtract(const Duration(days: 3)),
        rawMetadata: const {'source': 'sample'},
      ),
    ];
  }

  static List<AiToolAnalysis> analyses() {
    final service = AiAnalysisService();
    return projects()
        .map((project) => service.localHeuristic(project, 'local-heuristic'))
        .toList(growable: false);
  }
}
