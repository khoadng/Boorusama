// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../foundation/utils/color_utils.dart';
import '../tags/tag/colors.dart';
import 'app_theme.dart';
import 'color_settings.dart';
import 'colors.dart';
import 'grayscale_shades.dart';
import 'theme_mode.dart';

export 'color_settings.dart';

final preDefinedColorSettings = [
  ColorSettings.fromPredefinedScheme(
    'danbooru_dark',
    nickname: 'Dark Blue',
  ),
  ColorSettings.fromPredefinedScheme(
    'danbooru_light',
    nickname: 'Light Blue',
  ),
  ColorSettings.fromPredefinedScheme(
    'green',
    nickname: 'Light Green',
  ),
  ColorSettings.fromPredefinedScheme(
    'dark_green',
    nickname: 'Dark Green',
  ),
  ColorSettings.fromPredefinedScheme(
    'coral_pink',
    nickname: 'Coral Pink',
  ),
  ColorSettings.fromPredefinedScheme(
    'hacker',
    nickname: 'Hacker',
  ),
  ColorSettings.fromPredefinedScheme(
    'cyberpunk',
    nickname: 'Cyberpunk',
  ),
].nonNulls.toList();

final basicColorSettings = [
  ColorSettings.fromBasicScheme(
    'boorusama_light',
    nickname: 'Light',
  ),
  ColorSettings.fromBasicScheme(
    'boorusama_dark',
    nickname: 'Dark',
  ),
  ColorSettings.fromBasicScheme(
    'boorusama_black',
    nickname: 'Midnight',
  ),
  ColorSettings.fromBasicScheme(
    'boorusama_system',
    nickname: 'System',
    followSystemDarkMode: true,
  ),
].nonNulls.toList();

ColorScheme getSchemeFromBasic(
  String? name, {
  required bool systemDarkMode,
  required ColorScheme? dynamicLightScheme,
  required ColorScheme? dynamicDarkScheme,
  required bool enableDynamicColoring,
  required bool? followSystemDarkMode,
}) {
  final mode = followSystemDarkMode == true
      ? AppThemeMode.system
      : switch (name) {
          'boorusama_light' => AppThemeMode.light,
          'boorusama_dark' => AppThemeMode.dark,
          'boorusama_black' => AppThemeMode.amoledDark,
          _ => AppThemeMode.amoledDark,
        };

  final (dark, light) = enableDynamicColoring
      ? dynamicLightScheme != null && dynamicDarkScheme != null
            ? (dynamicDarkScheme, dynamicLightScheme)
            : (null, null)
      : (null, null);

  return AppTheme.generateScheme(
    mode,
    systemDarkMode: systemDarkMode,
    dynamicLightScheme: light,
    dynamicDarkScheme: dark,
  );
}

ColorScheme? getSchemeFromPredefined(String? name) {
  return switch (name) {
    'danbooru_dark' => staticDanbooruDarkScheme,
    'danbooru_light' => staticDanbooruLightScheme,
    'green' => staticGreenScheme,
    'dark_green' => staticDarkGreenScheme,
    'coral_pink' => staticCoralPinkScheme,
    'hacker' => staticHackerScheme,
    'cyberpunk' => staticCyberpunkScheme,
    _ => null,
  };
}

TagColors? getTagColorsFromPredefined(String name, Brightness? brightness) {
  return switch (name) {
    'green' => const TagColors(
      general: Color(0xff000198),
      artist: Color(0xffaa0101),
      character: Color(0xff01aa01),
      copyright: Color(0xffab00ab),
      meta: Color(0xfffe8900),
    ),
    'dark_green' => const TagColors(
      general: Color(0xffb0e0b0),
      artist: Color(0xffeea0a1),
      character: Color(0xfff1f1a0),
      copyright: Color(0xffeea0ee),
      meta: Color(0xff8ed8ec),
    ),
    'coral_pink' => const TagColors(
      general: Color(0xffe36d5e),
      artist: Color(0xffcaca05),
      character: Color(0xff2b9122),
      copyright: Color(0xffdc00dc),
      meta: Color(0xfffe1e1e),
    ),
    _ => null,
  };
}

TagColors? getTagColorsFromColorSettings(ColorSettings? colorSettings) {
  final settings = colorSettings;
  if (settings == null) return null;

  return switch (settings.schemeType) {
    SchemeType.builtIn => getTagColorsFromPredefined(
      settings.name,
      settings.colorScheme?.brightness,
    ),
    _ => null,
  };
}

ColorScheme? getSchemeFromColorSettings(
  ColorSettings? colorSettings, {
  required ColorScheme? dynamicLightScheme,
  required ColorScheme? dynamicDarkScheme,
  required bool systemDarkMode,
}) {
  final settings = colorSettings;
  if (settings == null) return null;

  return switch (settings.schemeType) {
    SchemeType.basic => getSchemeFromBasic(
      settings.name,
      systemDarkMode: systemDarkMode,
      dynamicLightScheme: dynamicLightScheme,
      dynamicDarkScheme: dynamicDarkScheme,
      enableDynamicColoring: settings.enableDynamicColoring,
      followSystemDarkMode: settings.followSystemDarkMode,
    ),
    SchemeType.builtIn => getSchemeFromPredefined(settings.name),
    SchemeType.accent => () {
      final accentColor = settings.name;
      final color = ColorUtils.hexToColor(accentColor);

      if (color == null) return null;

      return ColorScheme.fromSeed(
        seedColor: color,
        brightness: settings.brightness ?? Brightness.dark,
        dynamicSchemeVariant:
            settings.dynamicSchemeVariant ?? DynamicSchemeVariant.tonalSpot,
      );
    }(),
    _ => colorSettings?.colorScheme,
  };
}

const staticDanbooruDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  secondaryContainer: Color(0xff2c2c3e),
  onSecondaryContainer: Colors.white,
  onTertiaryContainer: Colors.white,
  surfaceContainerLowest: Color.fromARGB(255, 19, 19, 27),
  surfaceContainerLow: Color.fromARGB(255, 34, 36, 51),
  surfaceContainer: Color.fromARGB(255, 46, 47, 66),
  surfaceContainerHigh: Color.fromARGB(255, 53, 54, 73),
  surfaceContainerHighest: Color.fromARGB(255, 61, 62, 82),
  primary: Color(0xff019ae6),
  onPrimary: Colors.white,
  secondary: Color(0xff019ae6),
  onSecondary: Colors.white,
  error: Color(0xffc10105),
  onError: kOnErrorDarkColor,
  surface: Color(0xff1f1e2d),
  onSurface: Colors.white,
  outline: GreyscaleShades.gray160,
  outlineVariant: GreyscaleShades.gray60,
);

const staticDanbooruLightScheme = ColorScheme(
  brightness: Brightness.light,
  secondaryContainer: Color(0xfff2f6fe),
  onSecondaryContainer: Colors.black,
  onTertiaryContainer: Colors.black,
  surfaceContainerLowest: Color(0xfffafbfe),
  surfaceContainerLow: Color(0xfff6f8fd),
  surfaceContainer: Color(0xfff2f6fe),
  surfaceContainerHigh: Color(0xffe4ebf6),
  surfaceContainerHighest: Color(0xffd5dfee),
  primary: Color(0xff0174f9),
  onPrimary: Colors.white,
  secondary: Color(0xff0174f9),
  onSecondary: Colors.white,
  error: Color(0xffec2525),
  onError: Colors.black,
  surface: Color(0xfffefeff),
  onSurface: Colors.black,
  outline: GreyscaleShades.gray110,
  outlineVariant: GreyscaleShades.gray60,
);

const staticGreenScheme = ColorScheme(
  brightness: Brightness.light,
  secondaryContainer: Color(0xff93c292),
  onSecondaryContainer: Colors.black,
  onTertiaryContainer: Colors.black,
  surfaceContainerLowest: Color.fromARGB(255, 185, 245, 184),
  surfaceContainerLow: Color.fromARGB(255, 181, 235, 181),
  surfaceContainer: Color.fromARGB(255, 165, 219, 164),
  surfaceContainerHigh: Color.fromARGB(255, 158, 207, 157),
  surfaceContainerHighest: Color.fromARGB(255, 151, 200, 150),
  primary: Color(0xff000198),
  onPrimary: Colors.white,
  secondary: Color(0xff000198),
  onSecondary: Colors.white,
  error: Color(0xffff0101),
  onError: kOnErrorDarkColor,
  surface: Color(0xffa9e4a4),
  onSurface: Colors.black,
  outline: GreyscaleShades.gray110,
  outlineVariant: GreyscaleShades.gray60,
);

const staticDarkGreenScheme = ColorScheme(
  brightness: Brightness.dark,
  secondaryContainer: Color(0xff505b51),
  onSecondaryContainer: Color(0xffc0c1c1),
  onTertiaryContainer: Color(0xff93b393),
  surfaceContainerLowest: Color.fromARGB(255, 44, 51, 42),
  surfaceContainerLow: Color.fromARGB(255, 50, 57, 49),
  surfaceContainer: Color.fromARGB(255, 56, 66, 55),
  surfaceContainerHigh: Color.fromARGB(255, 62, 71, 58),
  surfaceContainerHighest: Color.fromARGB(255, 68, 79, 66),
  primary: Color(0xffa9d6a9),
  onPrimary: Color(0xff313b30),
  secondary: Color(0xffa9d6a9),
  onSecondary: Color(0xff313b30),
  error: Color(0xffe36d5e),
  onError: kOnErrorDarkColor,
  surface: Color.fromARGB(255, 38, 44, 37),
  onSurface: Color(0xffc0c1c1),
  outline: Color(0xffb1e0b1),
  outlineVariant: Color.fromARGB(255, 91, 104, 92),
);

const staticCoralPinkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffef8987),
  onPrimary: Colors.white,
  secondary: Color(0xffef8987),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xff2c1f1e),
  onSecondaryContainer: Colors.white,
  surfaceContainerLowest: GreyscaleShades.gray12,
  surfaceContainerLow: GreyscaleShades.gray32,
  surfaceContainer: GreyscaleShades.gray46,
  surfaceContainerHigh: GreyscaleShades.gray50,
  surfaceContainerHighest: GreyscaleShades.gray54,
  onTertiaryContainer: Colors.white,
  error: Color(0xffc10105),
  onError: kOnErrorDarkColor,
  surface: Color(0xff232322),
  onSurface: Colors.white,
  outline: GreyscaleShades.gray160,
  outlineVariant: GreyscaleShades.gray60,
);

const kHackerPrimaryColor = Color(0xff00ff00);
const kHackerPrimaryVariantColor = Color(0xff388e3c);

const staticHackerScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kHackerPrimaryColor,
  onPrimary: Colors.black,
  secondary: kHackerPrimaryColor,
  onSecondary: Colors.black,
  secondaryContainer: Color(0xff000000),
  onSecondaryContainer: kHackerPrimaryColor,
  surfaceContainerLowest: Color(0xff000000),
  surfaceContainerLow: Color(0xff000000),
  surfaceContainer: Color(0xff000000),
  surfaceContainerHigh: Color(0xff000000),
  surfaceContainerHighest: Color(0xff000000),
  outline: kHackerPrimaryVariantColor,
  outlineVariant: kHackerPrimaryVariantColor,
  onTertiaryContainer: kHackerPrimaryVariantColor,
  error: Color(0xffff0000),
  onError: kOnErrorDarkColor,
  surface: Color(0xff000000),
  onSurface: kHackerPrimaryColor,
);

const kCyberpunkPrimaryColor = Color(0xfffcec0c);
const kCyberpunkSurfaceColor = Color(0xff120c15);
const kCyberpunkOnSurfaceColor = Color(0xff02d6f1);
const kCyberpunkOutlineColor = Color(0xff34736a);
const kCyberpunkErrorColor = Color(0xffff6159);

const staticCyberpunkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kCyberpunkPrimaryColor,
  onPrimary: Colors.black,
  secondary: kCyberpunkPrimaryColor,
  onSecondary: Colors.black,
  secondaryContainer: Color(0xff141824),
  onSecondaryContainer: kCyberpunkOnSurfaceColor,
  surfaceContainerLowest: Color(0xff151a27), // Darkest
  surfaceContainerLow: Color(0xff161b29), // Slightly darker
  surfaceContainer: Color(0xff141824), // Middle
  surfaceContainerHigh: Color(0xff121623), // Slightly lighter
  surfaceContainerHighest: Color(0xff0f1320), // Lightest
  outline: kCyberpunkOutlineColor,
  outlineVariant: kCyberpunkOutlineColor,
  error: kCyberpunkErrorColor,
  onError: kOnErrorDarkColor,
  surface: kCyberpunkSurfaceColor,
  onSurface: kCyberpunkOnSurfaceColor,
);

class ThemeConfigs extends Equatable {
  const ThemeConfigs({
    required this.colors,
    required this.enable,
  });

  const ThemeConfigs.undefined() : colors = null, enable = false;

  factory ThemeConfigs.fromJsonString(String? jsonString) =>
      switch (jsonString) {
        null => const ThemeConfigs.undefined(),
        final String s => tryDecodeJson(s).fold(
          (_) => const ThemeConfigs.undefined(),
          (json) => ThemeConfigs.fromJson(json),
        ),
      };

  factory ThemeConfigs.fromJson(Map<String, dynamic> json) {
    return ThemeConfigs(
      colors: json['colors'] == null
          ? null
          : ColorSettings.fromJson(json['colors']),
      enable: json['enable'],
    );
  }

  final ColorSettings? colors;
  final bool enable;

  ThemeConfigs copyWith({
    ColorSettings? Function()? colors,
    bool? enable,
  }) {
    return ThemeConfigs(
      colors: colors != null ? colors() : this.colors,
      enable: enable ?? this.enable,
    );
  }

  @override
  List<Object?> get props => [colors, enable];

  Map<String, dynamic> toJson() => {
    'colors': colors?.toJson(),
    'enable': enable,
  };

  String toJsonString() => jsonEncode(toJson());
}
