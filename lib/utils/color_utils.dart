// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

typedef ChipColors = ({
  Color foregroundColor,
  Color backgroundColor,
  Color borderColor,
});

ChipColors? generateChipColorsFromColorScheme(
  Color? color,
  ColorScheme colorScheme,
  AppThemeMode themeMode,
  bool enableDynamicColoring,
) {
  if (color == null) return null;
  if (themeMode.isLight) {
    final backgroundColor = enableDynamicColoring
        ? color.harmonizeWith(colorScheme.primary)
        : color;
    return (
      backgroundColor: backgroundColor,
      foregroundColor: backgroundColor.computeLuminance() > 0.7
          ? Colors.black
          : Colors.white,
      borderColor: enableDynamicColoring
          ? color.harmonizeWith(colorScheme.primary)
          : color,
    );
  }

  var darkColor = Color.fromRGBO(
    (color.red * 0.3).round(),
    (color.green * 0.3).round(),
    (color.blue * 0.3).round(),
    1,
  );

  var neutralDarkColor = Color.fromRGBO(
    (color.red * 0.5).round(),
    (color.green * 0.5).round(),
    (color.blue * 0.5).round(),
    1,
  );

  return (
    foregroundColor: enableDynamicColoring
        ? color.harmonizeWith(colorScheme.primary)
        : color,
    backgroundColor: enableDynamicColoring
        ? darkColor.harmonizeWith(colorScheme.primary)
        : darkColor,
    borderColor: enableDynamicColoring
        ? neutralDarkColor.harmonizeWith(colorScheme.primary)
        : neutralDarkColor,
  );
}

extension ColorX on Color {
  bool get isWhite => computeLuminance() > 0.6;
}

final _random = Random();

Color generateRandomColor() {
  final r = _random.nextInt(255);
  final g = _random.nextInt(255);
  final b = _random.nextInt(255);
  return Color.fromRGBO(r, g, b, 1);
}
