import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/android_liquid_glass_bridge.dart';
import 'app_controller.dart';
import 'app_state.dart';

final androidLiquidGlassBridgeProvider = Provider<AndroidLiquidGlassBridge>((
  ref,
) {
  return AndroidLiquidGlassBridge();
});

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);
