import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

part 'liquid_glass_buttons.dart';
part 'liquid_glass_text_fields.dart';
part 'liquid_glass_color_palette.dart';
part 'liquid_glass_select.dart';
part 'liquid_glass_segments.dart';
part 'liquid_glass_inputs.dart';
part 'liquid_glass_private.dart';

bool usesLiquidGlassControls(BuildContext context) {
  return Theme.of(context).extension<RepoLensVisualTokens>()?.liquidGlass ??
      false;
}
