// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../colors/types.dart';

extension ThemeX on BuildContext {
  Brightness get onBrightness => Theme.of(this).brightness == Brightness.light
      ? Brightness.dark
      : Brightness.light;

  BoorusamaColors get colors => Theme.of(this).extension<BoorusamaColors>()!;
  ExtendedColorScheme get extendedColorScheme =>
      Theme.of(this).extension<ExtendedColorScheme>()!;
}

extension BrightnessX on Brightness {
  bool get isDark => this == Brightness.dark;
  bool get isLight => !isDark;
}
