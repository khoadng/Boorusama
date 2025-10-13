// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../colors/types.dart';
import 'color_scheme_converter.dart';

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
  }) : _schemeType = schemeType,
       _dynamicSchemeVariant = dynamicSchemeVariant;

  factory ColorSettings.fromAccentColor(
    Color color, {
    required Brightness brightness,
    required DynamicSchemeVariant dynamicSchemeVariant,
    required bool harmonizeWithPrimary,
  }) {
    final name = color.hexWithoutAlpha;
    final nickname =
        namedColors.entries
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
      harmonizeWithPrimary: false,
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
        brightness: json['brightness'] == 'dark'
            ? Brightness.dark
            : Brightness.light,
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
) => switch (dynamicSchemeVariant) {
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
