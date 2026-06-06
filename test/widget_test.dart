import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repolens_ai/app/app_state.dart';
import 'package:repolens_ai/app/providers.dart';
import 'package:repolens_ai/app/repolens_app.dart';
import 'package:repolens_ai/core/models/repolens_models.dart';
import 'package:repolens_ai/core/services/sample_data.dart';

void main() {
  testWidgets('RepoLens app renders the Chinese discovery workspace', (
    tester,
  ) async {
    final projects = SampleData.projects();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appControllerProvider.overrideWithBuild((ref, notifier) {
            return AppState.initial().copyWith(
              isBootstrapping: false,
              projects: projects,
              analyses: SampleData.analyses(),
              selectedProjectFullName: projects.first.fullName,
              settings: AppSettings.defaults().copyWith(
                language: AppLanguage.simplifiedChinese,
                visualStyle: VisualStyle.material3,
              ),
            );
          }),
        ],
        child: const RepoLensApp(),
      ),
    );
    await tester.pump();

    expect(find.text('GitHub AI 工具雷达'), findsOneWidget);
    expect(find.text('发现项目'), findsWidgets);
  });

  testWidgets('RepoLens app renders the English discovery workspace', (
    tester,
  ) async {
    final projects = SampleData.projects();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appControllerProvider.overrideWithBuild((ref, notifier) {
            return AppState.initial().copyWith(
              isBootstrapping: false,
              projects: projects,
              analyses: SampleData.analyses(),
              selectedProjectFullName: projects.first.fullName,
              settings: AppSettings.defaults().copyWith(
                language: AppLanguage.english,
                visualStyle: VisualStyle.material3,
              ),
            );
          }),
        ],
        child: const RepoLensApp(),
      ),
    );
    await tester.pump();

    expect(find.text('GitHub AI Tool Radar'), findsOneWidget);
    expect(find.text('Discover'), findsWidgets);
  });
}
