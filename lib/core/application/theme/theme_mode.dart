// Flutter imports:
import 'package:flutter/material.dart' as m;

// Copy from Flutter ThemeMode enum
enum ThemeMode {
  system,
  light,
  dark,
  amoledDark,
}

m.ThemeMode mapAppThemeModeToSystemThemeMode(ThemeMode theme) =>
    switch (theme) {
      ThemeMode.system => m.ThemeMode.system,
      ThemeMode.dark => m.ThemeMode.dark,
      ThemeMode.light => m.ThemeMode.light,
      ThemeMode.amoledDark => m.ThemeMode.dark
    };
