import 'package:flutter_test/flutter_test.dart';
import 'package:repolens_ai/app/app_state.dart';

void main() {
  test('app state reports in-app back destinations', () {
    final initial = AppState.initial();

    expect(initial.hasInAppBackDestination, isFalse);
    expect(
      initial.copyWith(navigationIndex: 2).hasInAppBackDestination,
      isTrue,
    );
    expect(
      initial.copyWith(projectDetailOpen: true).hasInAppBackDestination,
      isTrue,
    );
    expect(
      initial
          .copyWith(settingsProviderDetailOpen: true)
          .hasInAppBackDestination,
      isTrue,
    );
    expect(
      initial
          .copyWith(settingsAppearanceDetailOpen: true)
          .hasInAppBackDestination,
      isTrue,
    );
    expect(
      initial
          .copyWith(previewImagePath: '/tmp/repolens-preview.png')
          .hasInAppBackDestination,
      isTrue,
    );
  });
}
