// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/theme/theme.dart';

typedef ChipColors = ({
  Color foregroundColor,
  Color backgroundColor,
  Color borderColor,
});

ChipColors? generateChipColorsFromColorScheme(
  Color? color,
  Settings settings,
  ColorScheme colorScheme,
) {
  if (color == null) return null;
  if (settings.themeMode == ThemeMode.light) {
    return (
      backgroundColor: settings.enableDynamicColoring
          ? color.harmonizeWith(colorScheme.primary)
          : color,
      foregroundColor: Colors.white,
      borderColor: color
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
    foregroundColor: settings.enableDynamicColoring
        ? color.harmonizeWith(colorScheme.primary)
        : color,
    backgroundColor: settings.enableDynamicColoring
        ? darkColor.harmonizeWith(colorScheme.primary)
        : darkColor,
    borderColor: settings.enableDynamicColoring
        ? neutralDarkColor.harmonizeWith(colorScheme.primary)
        : neutralDarkColor,
  );
}

@Deprecated('Use generateChipColorsFromColorScheme instead')
ChipColors? generateChipColors(Color? color, ThemeMode themeMode) {
  if (color == null) return null;
  if (themeMode == ThemeMode.light) {
    return (
      backgroundColor: color,
      foregroundColor: Colors.white,
      borderColor: color
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
    foregroundColor: color,
    backgroundColor: darkColor,
    borderColor: neutralDarkColor
  );
}
