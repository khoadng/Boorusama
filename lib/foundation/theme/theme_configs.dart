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
  ColorSettings.fromScheme(
    'boorusama_light',
    staticLightScheme,
    nickname: 'Light',
  ),
  ColorSettings.fromScheme(
    'boorusama_dark',
    staticDarkScheme,
    nickname: 'Dark',
  ),
  ColorSettings.fromScheme(
    'boorusama_black',
    staticBlackScheme,
    nickname: 'Midnight',
  ),
  ColorSettings.fromScheme(
    'danbooru_dark',
    staticDanbooruDarkScheme,
    nickname: 'Dark Blue',
  ),
  ColorSettings.fromScheme(
    'danbooru_light',
    staticDanbooruLightScheme,
    nickname: 'Light Blue',
  ),
  ColorSettings.fromScheme(
    'green',
    staticGreenScheme,
    nickname: 'Light Green',
  ),
].whereNotNull().toList();

const staticDanbooruDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  secondaryContainer: Color(0xff2c2c3e),
  onSecondaryContainer: Colors.white,
  onTertiaryContainer: Colors.white,
  surfaceContainerHighest: Color(0xff3e4059),
  primary: Color(0xff019ae6),
  onPrimary: kOnPrimaryDarkColor,
  secondary: kOnPrimaryDarkColor,
  onSecondary: kOnPrimaryDarkColor,
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
  onPrimary: kOnPrimaryLightColor,
  secondary: kOnPrimaryLightColor,
  onSecondary: kOnPrimaryLightColor,
  error: Color(0xfffec3c3),
  onError: kOnErrorDarkColor,
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
  onPrimary: kOnPrimaryLightColor,
  secondary: kOnPrimaryLightColor,
  onSecondary: kOnPrimaryLightColor,
  error: Color(0xffff0101),
  onError: kOnErrorDarkColor,
  surface: Color(0xffa9e4a4),
  onSurface: Colors.black,
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
  });

  static ColorSettings? fromScheme(
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
