// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../utils/color_utils.dart';
import 'app_theme.dart';
import 'color_scheme_converter.dart';
import 'colors.dart';
import 'extended_color_scheme.dart';
import 'grayscale_shades.dart';
import 'named_colors.dart';
import 'theme_mode.dart';

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
    'coral_pink' => staticCoralPinkScheme,
    'hacker' => staticHackerScheme,
    'cyberpunk' => staticCyberpunkScheme,
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

const staticCoralPinkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffef8987),
  onPrimary: Colors.white,
  secondary: Color(0xffef8987),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xff2c1f1e),
  onSecondaryContainer: Colors.white,
  surfaceContainerLowest: Color.fromARGB(255, 35, 25, 24),
  surfaceContainerLow: Color.fromARGB(255, 41, 30, 29),
  surfaceContainer: Color.fromARGB(255, 51, 38, 37),
  surfaceContainerHigh: Color.fromARGB(255, 60, 43, 41),
  surfaceContainerHighest: Color.fromARGB(255, 70, 51, 49),
  onTertiaryContainer: Colors.white,
  error: Color(0xffc10105),
  onError: kOnErrorDarkColor,
  surface: Color(0xff1f1615),
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

enum SchemeType {
  basic,
  builtIn,
  accent,
  custom,
}

SchemeType? _parseSchemeType(String? schemeType) => switch (schemeType) {
      'basic' => SchemeType.basic,
      'builtIn' => SchemeType.builtIn,
      'accent' => SchemeType.accent,
      'custom' => SchemeType.custom,
      _ => null,
    };

extension SchemeTypeX on SchemeType {
  String get value => switch (this) {
        SchemeType.basic => 'basic',
        SchemeType.builtIn => 'builtIn',
        SchemeType.accent => 'accent',
        SchemeType.custom => 'custom',
      };
}

DynamicSchemeVariant? _parseDynamicSchemeVariant(
  String? dynamicSchemeVariant,
) =>
    switch (dynamicSchemeVariant) {
      'tonalSpot' => DynamicSchemeVariant.tonalSpot,
      'fidelity' => DynamicSchemeVariant.fidelity,
      'monochrome' => DynamicSchemeVariant.monochrome,
      'neutral' => DynamicSchemeVariant.neutral,
      'vibrant' => DynamicSchemeVariant.vibrant,
      'expressive' => DynamicSchemeVariant.expressive,
      'content' => DynamicSchemeVariant.content,
      'rainbow' => DynamicSchemeVariant.rainbow,
      'fruitSalad' => DynamicSchemeVariant.fruitSalad,
      _ => null,
    };

extension DynamicSchemeVariantX on DynamicSchemeVariant {
  String get value => switch (this) {
        DynamicSchemeVariant.tonalSpot => 'tonalSpot',
        DynamicSchemeVariant.fidelity => 'fidelity',
        DynamicSchemeVariant.monochrome => 'monochrome',
        DynamicSchemeVariant.neutral => 'neutral',
        DynamicSchemeVariant.vibrant => 'vibrant',
        DynamicSchemeVariant.expressive => 'expressive',
        DynamicSchemeVariant.content => 'content',
        DynamicSchemeVariant.rainbow => 'rainbow',
        DynamicSchemeVariant.fruitSalad => 'fruitSalad',
      };
}

class ColorSettings extends Equatable {
  const ColorSettings({
    required this.name,
    required this.brightness,
    required this.colorScheme,
    required this.extendedColorScheme,
    required String schemeType,
    required String? dynamicSchemeVariant,
    required this.enableDynamicColoring,
    required this.followSystemDarkMode,
    required this.harmonizeWithPrimary,
    this.nickname,
  })  : _schemeType = schemeType,
        _dynamicSchemeVariant = dynamicSchemeVariant;

  factory ColorSettings.fromAccentColor(
    Color color, {
    required Brightness brightness,
    required DynamicSchemeVariant dynamicSchemeVariant,
    required bool harmonizeWithPrimary,
  }) {
    final name = color.hexWithoutAlpha;
    final nickname = namedColors.entries
            .firstWhereOrNull((e) => e.value.hexWithoutAlpha == name)
            ?.key ??
        name;

    return ColorSettings(
      name: name,
      nickname: nickname,
      schemeType: SchemeType.accent.value,
      colorScheme: null,
      extendedColorScheme: null,
      brightness: brightness,
      dynamicSchemeVariant: dynamicSchemeVariant.value,
      enableDynamicColoring: false,
      harmonizeWithPrimary: harmonizeWithPrimary,
      followSystemDarkMode: null,
    );
  }

  factory ColorSettings.fromCustomScheme(
    String name,
    ColorScheme colorScheme, {
    String? nickname,
    ExtendedColorScheme? extendedColorScheme,
  }) {
    return ColorSettings(
      name: name,
      nickname: nickname,
      schemeType: SchemeType.custom.value,
      colorScheme: colorScheme,
      extendedColorScheme: extendedColorScheme,
      brightness: colorScheme.brightness,
      dynamicSchemeVariant: null,
      enableDynamicColoring: false,
      harmonizeWithPrimary: false,
      followSystemDarkMode: null,
    );
  }

  factory ColorSettings.fromBasicScheme(
    String name, {
    String? nickname,
    bool? followSystemDarkMode,
  }) {
    return ColorSettings(
      name: name,
      nickname: nickname,
      colorScheme: null,
      extendedColorScheme: null,
      brightness: null,
      schemeType: SchemeType.basic.value,
      dynamicSchemeVariant: null,
      enableDynamicColoring: false,
      harmonizeWithPrimary: false,
      followSystemDarkMode: followSystemDarkMode,
    );
  }

  final String name;
  final String? nickname;
  final Brightness? brightness;
  final bool enableDynamicColoring;
  final bool harmonizeWithPrimary;
  final bool? followSystemDarkMode;

  final ColorScheme? colorScheme;
  final ExtendedColorScheme? extendedColorScheme;

  final String _schemeType;
  final String? _dynamicSchemeVariant;

  SchemeType? get schemeType => _parseSchemeType(_schemeType);
  DynamicSchemeVariant? get dynamicSchemeVariant =>
      _parseDynamicSchemeVariant(_dynamicSchemeVariant);

  static ColorSettings? fromPredefinedScheme(
    String name, {
    String? nickname,
  }) {
    return ColorSettings(
      name: name,
      nickname: nickname,
      colorScheme: null,
      extendedColorScheme: null,
      brightness: null,
      schemeType: SchemeType.builtIn.value,
      dynamicSchemeVariant: null,
      enableDynamicColoring: false,
      harmonizeWithPrimary: true,
      followSystemDarkMode: null,
    );
  }

  ColorSettings copyWith({
    Brightness? brightness,
    ColorScheme? colorScheme,
    bool? enableDynamicColoring,
    bool? harmonizeWithPrimary,
  }) {
    return ColorSettings(
      brightness: brightness ?? this.brightness,
      name: name,
      nickname: nickname,
      colorScheme: colorScheme ?? this.colorScheme,
      extendedColorScheme: extendedColorScheme,
      schemeType: _schemeType,
      dynamicSchemeVariant: _dynamicSchemeVariant,
      enableDynamicColoring:
          enableDynamicColoring ?? this.enableDynamicColoring,
      harmonizeWithPrimary: harmonizeWithPrimary ?? this.harmonizeWithPrimary,
      followSystemDarkMode: followSystemDarkMode,
    );
  }

  static ColorSettings? fromJson(Map<String, dynamic> json) {
    try {
      return ColorSettings(
        name: json['name'],
        nickname: json['nickname'],
        schemeType: json['schemeType'],
        colorScheme: colorSchemeFromJson(json['scheme']),
        extendedColorScheme: extendedColorSchemeFromJson(json['extended']),
        brightness:
            json['brightness'] == 'dark' ? Brightness.dark : Brightness.light,
        dynamicSchemeVariant: json['dynamicSchemeVariant'],
        enableDynamicColoring: json['enableDynamicColoring'],
        harmonizeWithPrimary: json['harmonizeWithPrimary'],
        followSystemDarkMode: json['followSystemDarkMode'],
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nickname': nickname,
      'schemeType': _schemeType,
      if (colorScheme != null) 'scheme': colorScheme!.toJson(),
      if (extendedColorScheme != null)
        'extended': extendedColorScheme!.toJson(),
      'brightness': brightness == Brightness.dark ? 'dark' : 'light',
      'dynamicSchemeVariant': _dynamicSchemeVariant,
      'enableDynamicColoring': enableDynamicColoring,
      'harmonizeWithPrimary': harmonizeWithPrimary,
      'followSystemDarkMode': followSystemDarkMode,
    };
  }

  @override
  List<Object?> get props => [
        name,
        nickname,
        _schemeType,
        colorScheme,
        extendedColorScheme,
        brightness,
        _dynamicSchemeVariant,
        enableDynamicColoring,
        harmonizeWithPrimary,
        followSystemDarkMode,
      ];
}

class ThemeConfigs extends Equatable {
  const ThemeConfigs({
    required this.colors,
    required this.enable,
  });

  const ThemeConfigs.undefined()
      : colors = null,
        enable = false;

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
