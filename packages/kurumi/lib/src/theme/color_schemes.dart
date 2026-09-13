import 'package:material_ui/material_ui.dart';

import 'color_tokens.dart';
import 'extended_color_scheme.dart';
import 'grayscale_shades.dart';

/// The built-in palettes used by Boorusama's existing theme modes.
///
/// These values are compatibility tokens. Keep changes to them in a
/// deliberate visual-design pass rather than during migration.
abstract final class KurumiColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    secondaryContainer: KurumiGreyscaleShades.gray220,
    onSecondaryContainer: KurumiColorTokens.onSurfaceLight,
    tertiaryContainer: KurumiGreyscaleShades.gray220,
    onTertiaryContainer: KurumiColorTokens.onSurfaceLight,
    surfaceContainerLowest: KurumiGreyscaleShades.gray226,
    surfaceContainerLow: KurumiGreyscaleShades.gray224,
    surfaceContainer: KurumiGreyscaleShades.gray220,
    surfaceContainerHigh: KurumiGreyscaleShades.gray216,
    surfaceContainerHighest: KurumiGreyscaleShades.gray214,
    primary: KurumiColorTokens.primaryLight,
    onPrimary: KurumiColorTokens.onPrimaryLight,
    secondary: KurumiColorTokens.primaryLight,
    onSecondary: KurumiColorTokens.onPrimaryLight,
    error: KurumiColorTokens.errorLight,
    onError: KurumiColorTokens.onErrorLight,
    surface: KurumiGreyscaleShades.gray242,
    onSurface: KurumiColorTokens.onSurfaceLight,
    outline: KurumiGreyscaleShades.gray110,
    outlineVariant: KurumiGreyscaleShades.gray60,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    secondaryContainer: KurumiGreyscaleShades.gray52,
    onSecondaryContainer: Colors.white,
    tertiaryContainer: KurumiGreyscaleShades.gray48,
    onTertiaryContainer: Colors.white,
    surfaceContainerLowest: KurumiGreyscaleShades.gray16,
    surfaceContainerLow: KurumiGreyscaleShades.gray30,
    surfaceContainer: KurumiGreyscaleShades.gray38,
    surfaceContainerHigh: KurumiGreyscaleShades.gray48,
    surfaceContainerHighest: KurumiGreyscaleShades.gray56,
    primary: KurumiColorTokens.primaryDark,
    onPrimary: KurumiColorTokens.onPrimaryDark,
    secondary: KurumiColorTokens.primaryDark,
    onSecondary: KurumiColorTokens.onPrimaryDark,
    error: KurumiColorTokens.errorDark,
    onError: KurumiColorTokens.onErrorDark,
    surface: KurumiGreyscaleShades.gray24,
    onSurface: Colors.white,
    outline: KurumiGreyscaleShades.gray160,
    outlineVariant: KurumiGreyscaleShades.gray60,
  );

  static const amoledDark = ColorScheme(
    brightness: Brightness.dark,
    secondaryContainer: KurumiGreyscaleShades.gray32,
    onSecondaryContainer: Colors.white,
    tertiaryContainer: KurumiGreyscaleShades.gray28,
    onTertiaryContainer: Colors.white,
    surfaceContainerLowest: KurumiGreyscaleShades.gray8,
    surfaceContainerLow: KurumiGreyscaleShades.gray20,
    surfaceContainer: KurumiGreyscaleShades.gray32,
    surfaceContainerHigh: KurumiGreyscaleShades.gray36,
    surfaceContainerHighest: KurumiGreyscaleShades.gray40,
    primary: KurumiColorTokens.primaryAmoledDark,
    onPrimary: KurumiColorTokens.onPrimaryAmoledDark,
    secondary: KurumiColorTokens.primaryAmoledDark,
    onSecondary: KurumiColorTokens.onPrimaryAmoledDark,
    error: KurumiColorTokens.errorAmoledDark,
    onError: KurumiColorTokens.onErrorAmoledDark,
    surface: Colors.black,
    onSurface: Colors.white,
    outline: KurumiGreyscaleShades.gray120,
    outlineVariant: KurumiGreyscaleShades.gray48,
  );

  static const lightExtended = KurumiExtendedColorScheme(
    surfaceContainerOverlay: Colors.black54,
    onSurfaceContainerOverlay: Colors.white,
    surfaceContainerOverlayDim: Color(0xb3000000),
    onSurfaceContainerOverlayDim: Colors.white70,
  );

  static const darkExtended = KurumiExtendedColorScheme(
    surfaceContainerOverlay: Colors.black54,
    onSurfaceContainerOverlay: Colors.white,
    surfaceContainerOverlayDim: Color(0xb3000000),
    onSurfaceContainerOverlayDim: Colors.white70,
  );

  static const amoledDarkExtended = KurumiExtendedColorScheme(
    surfaceContainerOverlay: Colors.black54,
    onSurfaceContainerOverlay: Colors.white,
    surfaceContainerOverlayDim: Color(0xb3000000),
    onSurfaceContainerOverlayDim: Colors.white70,
  );
}
