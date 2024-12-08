// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/dart.dart';

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
