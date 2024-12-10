// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../settings.dart';
import '../utils/color_utils.dart';

extension DynamicColorX on BuildContext {
  ChipColors? generateChipColors(
    Color? color,
    Settings settings,
  ) =>
      generateChipColorsFromColorScheme(
        color,
        Theme.of(this).colorScheme,
        settings.enableDynamicColoring,
      );
}
