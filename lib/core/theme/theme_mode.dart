// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Copy from Flutter ThemeMode enum
enum AppThemeMode {
  system,
  light,
  dark,
  amoledDark;

  factory AppThemeMode.parse(dynamic value) => switch (value) {
    'system' || '0' || 0 => system,
    'light' || '1' || 1 => light,
    'dark' || '2' || 2 => dark,
    'amoledDark' || '3' || 3 => amoledDark,
    _ => defaultValue,
  };

  static const AppThemeMode defaultValue = amoledDark;

  ThemeMode toSystem() => switch (this) {
    system => ThemeMode.system,
    dark => ThemeMode.dark,
    light => ThemeMode.light,
    amoledDark => ThemeMode.dark,
  };

  bool get isDark => switch (this) {
    light => false,
    _ => true,
  };

  bool get isLight => !isDark;

  String localize(BuildContext context) => switch (this) {
    dark => context.t.settings.theme.dark,
    system => context.t.settings.theme.system,
    amoledDark => context.t.settings.theme.amoled_dark,
    light => context.t.settings.theme.light,
  };

  dynamic toData() => index;
}
