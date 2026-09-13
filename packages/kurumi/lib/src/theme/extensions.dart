import 'package:material_ui/material_ui.dart';

import 'extended_color_scheme.dart';

extension KurumiThemeBuildContext on BuildContext {
  Brightness get onBrightness => Theme.of(this).brightness == Brightness.light
      ? Brightness.dark
      : Brightness.light;

  KurumiExtendedColorScheme get extendedColorScheme =>
      Theme.of(this).extension<KurumiExtendedColorScheme>()!;
}

extension KurumiBrightness on Brightness {
  bool get isDark => this == Brightness.dark;
  bool get isLight => !isDark;
}

extension KurumiColorSchemeX on ColorScheme {
  Color get hintColor => outline;
}
