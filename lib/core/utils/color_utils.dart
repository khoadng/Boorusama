// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import '../theme.dart';

typedef ChipColors = ({
  Color foregroundColor,
  Color backgroundColor,
  Color borderColor,
});

ChipColors? generateChipColorsFromColorScheme(
  Color? color,
  ColorScheme colorScheme,
  bool enableDynamicColoring,
) {
  if (color == null) return null;

  final legacyColor = LegacyColor(color);

  if (colorScheme.brightness == Brightness.light) {
    final backgroundColor = enableDynamicColoring
        ? legacyColor.harmonizeWith(colorScheme.primary)
        : legacyColor;
    return (
      backgroundColor: backgroundColor,
      foregroundColor: backgroundColor.computeLuminance() > 0.7
          ? Colors.black
          : Colors.white,
      borderColor: enableDynamicColoring
          ? legacyColor.harmonizeWith(colorScheme.primary)
          : legacyColor,
    );
  }

  final darkColor = LegacyColor.fromRGBO(
    (legacyColor.red * 0.3).round(),
    (legacyColor.green * 0.3).round(),
    (legacyColor.blue * 0.3).round(),
    1,
  );

  final neutralDarkColor = LegacyColor.fromRGBO(
    (legacyColor.red * 0.5).round(),
    (legacyColor.green * 0.5).round(),
    (legacyColor.blue * 0.5).round(),
    1,
  );

  return (
    foregroundColor: enableDynamicColoring
        ? legacyColor.harmonizeWith(colorScheme.primary)
        : legacyColor,
    backgroundColor: enableDynamicColoring
        ? darkColor.harmonizeWith(colorScheme.primary)
        : darkColor,
    borderColor: enableDynamicColoring
        ? neutralDarkColor.harmonizeWith(colorScheme.primary)
        : neutralDarkColor,
  );
}

extension type LegacyColor(Color color) implements Color {
  LegacyColor.fromRGBO(
    int r,
    int g,
    int b,
    double opacity,
  ) : this(Color.fromRGBO(r, g, b, opacity));

  int get red => (0x00ff0000 & value) >> 16;

  int get green => (0x0000ff00 & value) >> 8;

  int get blue => (0x000000ff & value) >> 0;

  int get value {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }
}

extension ColorX on Color {
  bool get isWhite => computeLuminance() > 0.6;

  String get hex => ColorUtils.colorToHex(this, includeAlpha: true);

  String get hexWithoutAlpha => ColorUtils.colorToHex(this);
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
    final legacyColor = LegacyColor(color);

    final hexValue = legacyColor.value.toRadixString(16).padLeft(8, '0');

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
