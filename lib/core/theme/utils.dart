// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../utils/color_utils.dart';

extension DynamicColorX on BuildContext {
  ChipColors? generateChipColors(
    Color? color,
    bool enableDynamicColoring,
  ) =>
      generateChipColorsFromColorScheme(
        color,
        Theme.of(this).colorScheme,
        enableDynamicColoring,
      );
}
