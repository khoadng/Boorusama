// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';

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
].whereNotNull().toList();

ColorScheme? getSchemeFromColorSettings(ColorSettings? colorSettings) {
  // if is predefined, use the predefined color scheme instead
  if (colorSettings?.isPredefined == true) {
    final scheme = preDefinedColorSettings
        .firstWhereOrNull(
          (e) => e.name == colorSettings!.name,
        )
        ?.toColorScheme();

    return scheme;
  } else {
    return colorSettings?.toColorScheme();
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
);

// hacker theme, green text on black background
const staticHackerScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xff00ff00),
  onPrimary: Colors.black,
  secondary: Color(0xff00ff00),
  onSecondary: Colors.black,
  secondaryContainer: Color(0xff000000),
  onSecondaryContainer: Colors.green,
  surfaceContainerHighest: Color(0xff000000),
  onTertiaryContainer: Colors.green,
  error: Color(0xffff0000),
  onError: kOnErrorDarkColor,
  surface: Color(0xff000000),
  onSurface: Colors.green,
);

Color? _parseColor(dynamic color) => switch (color) {
      String s => ColorUtils.hexToColor(s),
      _ => null,
    };

class ColorSettings extends Equatable {
  final String name;
  final String? nickname;
  final Brightness brightness;
  final Color? secondaryContainer;
  final Color? onSecondaryContainer;
  final Color? onTertiaryContainer;
  final Color? surfaceContainerHighest;
  final Color? primary;
  final Color? onPrimary;
  final Color? secondary;
  final Color? onSecondary;
  final Color? error;
  final Color? onError;
  final Color? surface;
  final Color? onSurface;

  final bool isPredefined;

  const ColorSettings({
    required this.name,
    required this.brightness,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.onTertiaryContainer,
    required this.surfaceContainerHighest,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.error,
    required this.onError,
    required this.surface,
    required this.onSurface,
    this.nickname,
    required this.isPredefined,
  });

  static ColorSettings? fromPredefinedScheme(
    String name,
    ColorScheme colorScheme, {
    String? nickname,
  }) {
    return ColorSettings(
      name: name,
      brightness: colorScheme.brightness,
      secondaryContainer: colorScheme.secondaryContainer,
      onSecondaryContainer: colorScheme.onSecondaryContainer,
      onTertiaryContainer: colorScheme.onTertiaryContainer,
      surfaceContainerHighest: colorScheme.surfaceContainerHighest,
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      secondary: colorScheme.secondary,
      onSecondary: colorScheme.onSecondary,
      error: colorScheme.error,
      onError: colorScheme.onError,
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      nickname: nickname,
      isPredefined: true,
    );
  }

  static ColorSettings? fromCustomScheme(
    String name,
    ColorScheme? colorScheme, {
    String? nickname,
  }) {
    if (colorScheme == null) return null;

    return ColorSettings(
      name: name,
      brightness: colorScheme.brightness,
      secondaryContainer: colorScheme.secondaryContainer,
      onSecondaryContainer: colorScheme.onSecondaryContainer,
      onTertiaryContainer: colorScheme.onTertiaryContainer,
      surfaceContainerHighest: colorScheme.surfaceContainerHighest,
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      secondary: colorScheme.secondary,
      onSecondary: colorScheme.onSecondary,
      error: colorScheme.error,
      onError: colorScheme.onError,
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      nickname: nickname,
      isPredefined: false,
    );
  }

  ColorScheme? toColorScheme() {
    if (primary == null ||
        onPrimary == null ||
        secondary == null ||
        onSecondary == null ||
        error == null ||
        onError == null ||
        surface == null ||
        onSurface == null) {
      return null;
    }

    return ColorScheme(
      brightness: brightness,
      primary: primary!,
      onPrimary: onPrimary!,
      secondary: secondary!,
      onSecondary: onSecondary!,
      error: error!,
      onError: onError!,
      surface: surface!,
      onSurface: onSurface!,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      surfaceContainerHighest: surfaceContainerHighest,
      onTertiaryContainer: onTertiaryContainer,
      tertiaryContainer: onTertiaryContainer,
    );
  }

  static ColorSettings? fromJson(Map<String, dynamic> json) {
    try {
      return ColorSettings(
        name: json['name'],
        brightness: switch (json['brightness']) {
          'light' => Brightness.light,
          'dark' => Brightness.dark,
          _ => Brightness.dark,
        },
        secondaryContainer: _parseColor(json['secondaryContainer']),
        onSecondaryContainer: _parseColor(json['onSecondaryContainer']),
        onTertiaryContainer: _parseColor(json['onTertiaryContainer']),
        surfaceContainerHighest: _parseColor(json['surfaceContainerHighest']),
        primary: _parseColor(json['primary']),
        onPrimary: _parseColor(json['onPrimary']),
        secondary: _parseColor(json['secondary']),
        onSecondary: _parseColor(json['onSecondary']),
        error: _parseColor(json['error']),
        onError: _parseColor(json['onError']),
        surface: _parseColor(json['surface']),
        onSurface: _parseColor(json['onSurface']),
        nickname: json['nickname'],
        isPredefined: json['isPredefined'],
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brightness': brightness.name,
      'secondaryContainer': secondaryContainer?.hex,
      'onSecondaryContainer': onSecondaryContainer?.hex,
      'onTertiaryContainer': onTertiaryContainer?.hex,
      'surfaceContainerHighest': surfaceContainerHighest?.hex,
      'primary': primary?.hex,
      'onPrimary': onPrimary?.hex,
      'secondary': secondary?.hex,
      'onSecondary': onSecondary?.hex,
      'error': error?.hex,
      'onError': onError?.hex,
      'surface': surface?.hex,
      'onSurface': onSurface?.hex,
      'nickname': nickname,
      'isPredefined': isPredefined,
    };
  }

  @override
  List<Object?> get props => [
        name,
        brightness,
        secondaryContainer,
        onSecondaryContainer,
        onTertiaryContainer,
        surfaceContainerHighest,
        primary,
        onPrimary,
        secondary,
        onSecondary,
        error,
        onError,
        surface,
        onSurface,
        nickname,
        isPredefined,
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
