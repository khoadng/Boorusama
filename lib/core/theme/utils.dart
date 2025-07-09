// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../foundation/utils/color_utils.dart';

class BooruChipColors {
  factory BooruChipColors.colorScheme(
    ColorScheme colorScheme, {
    bool? harmonizeWithPrimary,
  }) {
    return BooruChipColors._(
      brightness: colorScheme.brightness,
      harmonizer: harmonizeWithPrimary != null && harmonizeWithPrimary
          ? ColorHarmonizer(
              primaryColor: colorScheme.primary,
              harmonizeWithPrimary: harmonizeWithPrimary,
            )
          : null,
    );
  }

  const BooruChipColors._({
    this.brightness,
    this.harmonizer,
  });

  final Brightness? brightness;
  final ColorHarmonizer? harmonizer;

  ChipColors? fromColor(Color? color) {
    if (color == null) return null;

    final legacyColor = LegacyColor(color);

    if (brightness == Brightness.light) {
      final backgroundColor = harmonizer?.harmonize(legacyColor) ?? legacyColor;

      return ChipColors(
        backgroundColor: backgroundColor,
        foregroundColor: backgroundColor.computeLuminance() > 0.7
            ? Colors.black
            : Colors.white,
        borderColor: backgroundColor,
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

    return ChipColors(
      foregroundColor: harmonizer?.harmonize(legacyColor) ?? legacyColor,
      backgroundColor: harmonizer?.harmonize(darkColor) ?? darkColor,
      borderColor: harmonizer?.harmonize(neutralDarkColor) ?? neutralDarkColor,
    );
  }
}

class ChipColors extends Equatable {
  const ChipColors({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  List<Object?> get props => [foregroundColor, backgroundColor, borderColor];
}

class ColorHarmonizer extends Equatable {
  const ColorHarmonizer({
    required this.primaryColor,
    required this.harmonizeWithPrimary,
  });

  final Color primaryColor;
  final bool harmonizeWithPrimary;

  Color harmonize(Color color) {
    return harmonizeWithPrimary
        ? color.harmonizeWith(primaryColor)
        : primaryColor;
  }

  @override
  List<Object?> get props => [primaryColor, harmonizeWithPrimary];
}
