// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'color_settings.dart';

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
