// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'colors.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  IconThemeData get iconTheme => theme.iconTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  Brightness get brightness => theme.brightness;
  Brightness get onBrightness =>
      brightness == Brightness.light ? Brightness.dark : Brightness.light;

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => !isDark;

  BoorusamaColors get colors => Theme.of(this).extension<BoorusamaColors>()!;
}

extension BrightnessX on Brightness {
  bool get isDark => this == Brightness.dark;
  bool get isLight => !isDark;
}
