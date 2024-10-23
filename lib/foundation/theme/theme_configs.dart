// Dart imports:
import 'dart:convert';

// Flutter imports:
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
    staticLightScheme,
    nickname: 'Light',
  ),
  ColorSettings.fromPredefinedScheme(
    'boorusama_dark',
    staticDarkScheme,
    nickname: 'Dark',
  ),
  ColorSettings.fromPredefinedScheme(
    'boorusama_black',
    staticBlackScheme,
    nickname: 'Midnight',
  ),
  ColorSettings.fromPredefinedScheme(
    'danbooru_dark',
    staticDanbooruDarkScheme,
    nickname: 'Dark Blue',
  ),
  ColorSettings.fromPredefinedScheme(
    'danbooru_light',
    staticDanbooruLightScheme,
    nickname: 'Light Blue',
  ),
  ColorSettings.fromPredefinedScheme(
    'green',
    staticGreenScheme,
    nickname: 'Light Green',
  ),
  ColorSettings.fromPredefinedScheme(
    'coral_pink',
    staticCoralPinkScheme,
    nickname: 'Coral Pink',
  ),
  ColorSettings.fromPredefinedScheme(
    'hacker',
    staticHackerScheme,
    nickname: 'Hacker',
  ),
  ColorSettings.fromPredefinedScheme(
    'cyberpunk',
    staticCyberpunkScheme,
    nickname: 'Cyberpunk',
  ),
].whereNotNull().toList();

ColorScheme? getSchemeFromColorSettings(ColorSettings? colorSettings) {
  // if is predefined, use the predefined color scheme instead
  if (colorSettings?.isPredefined == true) {
    final scheme = preDefinedColorSettings
        .firstWhereOrNull(
          (e) => e.name == colorSettings!.name,
        )
        ?.colorScheme;

    return scheme;
  } else {
    return colorSettings?.colorScheme;
  }
}

const staticDanbooruDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  secondaryContainer: Color(0xff2c2c3e),
  onSecondaryContainer: Colors.white,
  onTertiaryContainer: Colors.white,
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

// hacker theme, green text on black background
const staticHackerScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kHackerPrimaryColor,
  onPrimary: Colors.black,
  secondary: kHackerPrimaryColor,
  onSecondary: Colors.black,
  secondaryContainer: Color(0xff000000),
  onSecondaryContainer: kHackerPrimaryColor,
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
  surfaceContainerHighest: kCyberpunkSecondaryContainerColor,
  outline: kCyberpunkOutlineColor,
  outlineVariant: kCyberpunkOutlineColor,
  error: kCyberpunkErrorColor,
  onError: kOnErrorDarkColor,
  surface: kCyberpunkSurfaceColor,
  onSurface: kCyberpunkOnSurfaceColor,
);

class ColorSettings extends Equatable {
  final String name;
  final String? nickname;
  final bool isPredefined;

  final ColorScheme? colorScheme;
  final ExtendedColorScheme? extendedColorScheme;

  const ColorSettings({
    required this.name,
    this.nickname,
    required this.isPredefined,
    required this.colorScheme,
    required this.extendedColorScheme,
  });

  static ColorSettings? fromPredefinedScheme(
    String name,
    ColorScheme colorScheme, {
    String? nickname,
    ExtendedColorScheme? extendedColorScheme,
  }) {
    return ColorSettings(
      name: name,
      nickname: nickname,
      isPredefined: true,
      colorScheme: colorScheme,
      extendedColorScheme: extendedColorScheme,
    );
  }

  static ColorSettings? fromCustomScheme(
    String name,
    ColorScheme? colorScheme, {
    String? nickname,
    ExtendedColorScheme? extendedColorScheme,
  }) {
    if (colorScheme == null) return null;

    return ColorSettings(
      name: name,
      nickname: nickname,
      isPredefined: false,
      colorScheme: colorScheme,
      extendedColorScheme: extendedColorScheme,
    );
  }

  static ColorSettings? fromJson(Map<String, dynamic> json) {
    try {
      return ColorSettings(
        name: json['name'],
        nickname: json['nickname'],
        isPredefined: json['isPredefined'],
        colorScheme: colorSchemeFromJson(json['scheme']),
        extendedColorScheme: extendedColorSchemeFromJson(json['extended']),
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nickname': nickname,
      'isPredefined': isPredefined,
      if (colorScheme != null) 'scheme': colorScheme!.toJson(),
      if (extendedColorScheme != null)
        'extended': extendedColorScheme!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        name,
        nickname,
        isPredefined,
        colorScheme,
        extendedColorScheme,
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
