// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';

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

  final darkColor = Color.fromRGBO(
    (color.red * 0.3).round(),
    (color.green * 0.3).round(),
    (color.blue * 0.3).round(),
    1,
  );

  final neutralDarkColor = Color.fromRGBO(
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

  String get hex => ColorUtils.colorToHex(this);
}

class ColorUtils {
  ColorUtils._();

  static final _random = Random();

  static Color generateRandomColor() {
    final r = _random.nextInt(255);
    final g = _random.nextInt(255);
    final b = _random.nextInt(255);
    return Color.fromRGBO(r, g, b, 1);
  }

  static String colorToHex(
    final Color color, {
    bool includeAlpha = false,
  }) {
    final hexValue = color.value.toRadixString(16).padLeft(8, '0');

    return includeAlpha ? '#$hexValue' : '#${hexValue.substring(2)}';
  }

  static Color? hexToColor(final String? hexString) {
    var hex = hexString?.trim();

    if (hex == null || hex.isEmpty) return null;

    // Check if the input is a named color
    final namedColor = namedColors[hex.toLowerCase()];
    if (namedColor != null) return namedColor;

    // Remove the leading '#' if it exists
    hex = hex.replaceAll('#', '');

    // If the string is too short, return null
    if (hex.length != 6 && hex.length != 8) return null;

    // If the hex string is in the format of 'RRGGBB', assume it is fully opaque
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    final hexValue = int.tryParse(hex, radix: 16);

    if (hexValue == null) return null;

    return Color(hexValue);
  }
}
