// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:boorusama/dart.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'color_scheme_converter.dart';

final preDefinedColorSettings = [
  ColorSettings.fromPredefinedScheme(
    'boorusama_light',
    nickname: 'Light',
  ),
  ColorSettings.fromPredefinedScheme(
    'boorusama_dark',
    nickname: 'Dark',
  ),
  ColorSettings.fromPredefinedScheme(
    'boorusama_black',
    nickname: 'Midnight',
  ),
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
].whereNotNull().toList();

ColorScheme? getSchemeFromPredefined(String? name) {
  return switch (name) {
    'boorusama_light' => staticLightScheme,
    'boorusama_dark' => staticDarkScheme,
    'boorusama_black' => staticBlackScheme,
    'danbooru_dark' => staticDanbooruDarkScheme,
    'danbooru_light' => staticDanbooruLightScheme,
    'green' => staticGreenScheme,
    'coral_pink' => staticCoralPinkScheme,
    'hacker' => staticHackerScheme,
    'cyberpunk' => staticCyberpunkScheme,
    _ => null,
  };
}

ColorScheme? getSchemeFromColorSettings(ColorSettings? colorSettings) {
  final settings = colorSettings;
  if (settings == null) return null;

  return switch (settings.schemeType) {
    SchemeType.builtIn => getSchemeFromPredefined(settings.name),
    SchemeType.accent => () {
        final accentColor = settings.name;
        final color = ColorUtils.hexToColor(accentColor);

        if (color == null) return null;

        return ColorScheme.fromSeed(
          seedColor: color,
          brightness: settings.brightness ?? Brightness.dark,
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
  surfaceContainerLowest: Color(0xff3e4059),
  surfaceContainerLow: Color(0xff3e4059),
  surfaceContainer: Color(0xff3e4059),
  surfaceContainerHigh: Color(0xff3e4059),
  surfaceContainerHighest: Color(0xff3e4059),
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
  surfaceContainerLowest: Color(0xfff2f6fe),
  surfaceContainerLow: Color(0xfff2f6fe),
  surfaceContainer: Color(0xfff2f6fe),
  surfaceContainerHigh: Color(0xfff2f6fe),
  surfaceContainerHighest: Color(0xfff2f6fe),
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
  surfaceContainerLowest: Color(0xff93c292),
  surfaceContainerLow: Color(0xff93c292),
  surfaceContainer: Color(0xff93c292),
  surfaceContainerHigh: Color(0xff93c292),
  surfaceContainerHighest: Color(0xff93c292),
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
  surfaceContainerLowest: Color(0xff3e2d2b),
  surfaceContainerLow: Color(0xff3e2d2b),
  surfaceContainer: Color(0xff3e2d2b),
  surfaceContainerHigh: Color(0xff3e2d2b),
  surfaceContainerHighest: Color(0xff3e2d2b),
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
const kCyberpunkSecondaryContainerColor = Color(0xff141824);
const kCyberpunkOnSurfaceColor = Color(0xff02d6f1);
const kCyberpunkOutlineColor = Color(0xff34736a);
const kCyberpunkErrorColor = Color(0xffff6159);

const staticCyberpunkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kCyberpunkPrimaryColor,
  onPrimary: Colors.black,
  secondary: kCyberpunkPrimaryColor,
  onSecondary: Colors.black,
  secondaryContainer: kCyberpunkSecondaryContainerColor,
  onSecondaryContainer: kCyberpunkOnSurfaceColor,
  surfaceContainerLowest: kCyberpunkSecondaryContainerColor,
  surfaceContainerLow: kCyberpunkSecondaryContainerColor,
  surfaceContainer: kCyberpunkSecondaryContainerColor,
  surfaceContainerHigh: kCyberpunkSecondaryContainerColor,
  surfaceContainerHighest: kCyberpunkSecondaryContainerColor,
  outline: kCyberpunkOutlineColor,
  outlineVariant: kCyberpunkOutlineColor,
  error: kCyberpunkErrorColor,
  onError: kOnErrorDarkColor,
  surface: kCyberpunkSurfaceColor,
  onSurface: kCyberpunkOnSurfaceColor,
);

enum SchemeType {
  builtIn,
  accent,
  image,
  custom,
}

SchemeType? _parseSchemeType(String? schemeType) => switch (schemeType) {
      'builtIn' => SchemeType.builtIn,
      'accent' => SchemeType.accent,
      'image' => SchemeType.image,
      'custom' => SchemeType.custom,
      _ => null,
    };

extension SchemeTypeX on SchemeType {
  String get value => switch (this) {
        SchemeType.builtIn => 'builtIn',
        SchemeType.accent => 'accent',
        SchemeType.image => 'image',
        SchemeType.custom => 'custom',
      };
}

class ColorSettings extends Equatable {
  const ColorSettings({
    required this.name,
    this.nickname,
    required this.brightness,
    required this.colorScheme,
    required this.extendedColorScheme,
    required String schemeType,
  }) : _schemeType = schemeType;

  final String name;
  final String? nickname;
  final Brightness? brightness;

  final ColorScheme? colorScheme;
  final ExtendedColorScheme? extendedColorScheme;

  final String _schemeType;

  SchemeType? get schemeType => _parseSchemeType(_schemeType);

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
    );
  }

  ColorSettings copyWith({
    Brightness? brightness,
  }) {
    return ColorSettings(
      brightness: brightness ?? this.brightness,
      name: name,
      nickname: nickname,
      colorScheme: colorScheme,
      extendedColorScheme: extendedColorScheme,
      schemeType: _schemeType,
    );
  }

  static ColorSettings fromAccentColor(
    Color color, {
    required Brightness brightness,
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
    );
  }

  static ColorSettings fromImage(
    ColorScheme colorScheme, {
    required Brightness brightness,
  }) {
    return ColorSettings(
      name: 'image',
      nickname: 'image',
      schemeType: SchemeType.image.value,
      colorScheme: colorScheme,
      extendedColorScheme: null,
      brightness: brightness,
    );
  }

  static ColorSettings fromCustomScheme(
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
      ];
}

class ThemeConfigs extends Equatable {
  final ColorSettings? colors;
  final bool enable;

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
        String s => tryDecodeJson(s).fold(
            (_) => const ThemeConfigs.undefined(),
            (json) => ThemeConfigs.fromJson(json),
          ),
      };

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

  factory ThemeConfigs.fromJson(Map<String, dynamic> json) {
    return ThemeConfigs(
      colors: json['colors'] == null
          ? null
          : ColorSettings.fromJson(json['colors']),
      enable: json['enable'],
    );
  }
}
