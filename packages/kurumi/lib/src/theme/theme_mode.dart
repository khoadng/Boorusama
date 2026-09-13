import 'package:material_ui/material_ui.dart';

/// Theme modes supported by the Kurumi design language.
enum KurumiThemeMode {
  system,
  light,
  dark,
  amoledDark;

  factory KurumiThemeMode.parse(dynamic value) => switch (value) {
    'system' || '0' || 0 => system,
    'light' || '1' || 1 => light,
    'dark' || '2' || 2 => dark,
    'amoledDark' || '3' || 3 => amoledDark,
    _ => defaultValue,
  };

  static const KurumiThemeMode defaultValue = amoledDark;

  ThemeMode toSystem() => switch (this) {
    system => ThemeMode.system,
    dark => ThemeMode.dark,
    light => ThemeMode.light,
    amoledDark => ThemeMode.dark,
  };

  bool get isDark => this != light;
  bool get isLight => !isDark;
}
