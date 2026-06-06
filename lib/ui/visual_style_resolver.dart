import 'package:flutter/foundation.dart';

import '../core/models/repolens_models.dart';

VisualStyle resolveVisualStyleForPlatform(VisualStyle requested) {
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => VisualStyle.liquidGlass,
    _ => requested,
  };
}

bool get allowsMaterial3VisualChoice {
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => false,
    _ => true,
  };
}
