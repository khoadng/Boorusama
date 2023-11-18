// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

typedef ChipColors = ({
  Color foregroundColor,
  Color backgroundColor,
  Color borderColor,
});

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
