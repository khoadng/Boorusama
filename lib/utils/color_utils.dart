// Flutter imports:
import 'package:flutter/material.dart';

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
  BuildContext context,
  Color? color,
  Settings settings,
) {
  if (color == null) return null;
  if (context.themeMode.isLight) {
    return (
      backgroundColor: settings.enableDynamicColoring
          ? color.harmonizeWith(context.colorScheme.primary)
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
        ? color.harmonizeWith(context.colorScheme.primary)
        : color,
    backgroundColor: settings.enableDynamicColoring
        ? darkColor.harmonizeWith(context.colorScheme.primary)
        : darkColor,
    borderColor: settings.enableDynamicColoring
        ? neutralDarkColor.harmonizeWith(context.colorScheme.primary)
        : neutralDarkColor,
  );
}

extension ColorX on Color {
  bool get isWhite => computeLuminance() > 0.6;
}
