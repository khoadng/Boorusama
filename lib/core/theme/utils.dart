// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../dart.dart';
import '../settings.dart';

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
