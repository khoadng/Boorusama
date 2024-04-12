// Flutter imports:
import 'package:flutter/material.dart';

// Copy from Flutter ThemeMode enum
enum AppThemeMode {
  system,
  light,
  dark,
  amoledDark,
}

ThemeMode mapAppThemeModeToSystemThemeMode(AppThemeMode theme) =>
    switch (theme) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.amoledDark => ThemeMode.dark
    };

extension ThemeModeX on AppThemeMode {
  bool get isDark => switch (this) {
        AppThemeMode.light => false,
        _ => true,
      };

  bool get isLight => !isDark;
}
