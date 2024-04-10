// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'colors.dart';
import 'theme_mode.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  IconThemeData get iconTheme => theme.iconTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  BoorusamaColors get colors => Theme.of(this).extension<BoorusamaColors>()!;
  AppThemeMode get themeMode => colors.themeMode;
}
