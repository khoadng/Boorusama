import 'package:material_ui/material_ui.dart';

import 'color_tokens.dart';
import 'grayscale_shades.dart';

/// Additional palettes shipped with the app.
///
/// These are compatibility palettes: moving them into Kurumi centralizes the
/// actual visual values while the application remains responsible for how
/// users select and persist them.
abstract final class KurumiPresetColorSchemes {
  static const danbooruDark = ColorScheme(
    brightness: Brightness.dark,
    secondaryContainer: Color(0xff2c2c3e),
    onSecondaryContainer: Colors.white,
    onTertiaryContainer: Colors.white,
    surfaceContainerLowest: Color.fromARGB(255, 19, 19, 27),
    surfaceContainerLow: Color.fromARGB(255, 34, 36, 51),
    surfaceContainer: Color.fromARGB(255, 46, 47, 66),
    surfaceContainerHigh: Color.fromARGB(255, 53, 54, 73),
    surfaceContainerHighest: Color.fromARGB(255, 61, 62, 82),
    primary: Color(0xff019ae6),
    onPrimary: Colors.white,
    secondary: Color(0xff019ae6),
    onSecondary: Colors.white,
    error: Color(0xffc10105),
    onError: KurumiColorTokens.onErrorDark,
    surface: Color(0xff1f1e2d),
    onSurface: Colors.white,
    outline: KurumiGreyscaleShades.gray160,
    outlineVariant: KurumiGreyscaleShades.gray60,
  );

  static const danbooruLight = ColorScheme(
    brightness: Brightness.light,
    secondaryContainer: Color(0xfff2f6fe),
    onSecondaryContainer: Colors.black,
    onTertiaryContainer: Colors.black,
    surfaceContainerLowest: Color(0xfffafbfe),
    surfaceContainerLow: Color(0xfff6f8fd),
    surfaceContainer: Color(0xfff2f6fe),
    surfaceContainerHigh: Color(0xffe4ebf6),
    surfaceContainerHighest: Color(0xffd5dfee),
    primary: Color(0xff0174f9),
    onPrimary: Colors.white,
    secondary: Color(0xff0174f9),
    onSecondary: Colors.white,
    error: Color(0xffec2525),
    onError: Colors.black,
    surface: Color(0xfffefeff),
    onSurface: Colors.black,
    outline: KurumiGreyscaleShades.gray110,
    outlineVariant: KurumiGreyscaleShades.gray60,
  );

  static const green = ColorScheme(
    brightness: Brightness.light,
    secondaryContainer: Color(0xff93c292),
    onSecondaryContainer: Colors.black,
    onTertiaryContainer: Colors.black,
    surfaceContainerLowest: Color.fromARGB(255, 185, 245, 184),
    surfaceContainerLow: Color.fromARGB(255, 181, 235, 181),
    surfaceContainer: Color.fromARGB(255, 165, 219, 164),
    surfaceContainerHigh: Color.fromARGB(255, 158, 207, 157),
    surfaceContainerHighest: Color.fromARGB(255, 151, 200, 150),
    primary: Color(0xff000198),
    onPrimary: Colors.white,
    secondary: Color(0xff000198),
    onSecondary: Colors.white,
    error: Color(0xffff0101),
    onError: KurumiColorTokens.onErrorDark,
    surface: Color(0xffa9e4a4),
    onSurface: Colors.black,
    outline: KurumiGreyscaleShades.gray110,
    outlineVariant: KurumiGreyscaleShades.gray60,
  );

  static const darkGreen = ColorScheme(
    brightness: Brightness.dark,
    secondaryContainer: Color(0xff505b51),
    onSecondaryContainer: Color(0xffc0c1c1),
    onTertiaryContainer: Color(0xff93b393),
    surfaceContainerLowest: Color.fromARGB(255, 44, 51, 42),
    surfaceContainerLow: Color.fromARGB(255, 50, 57, 49),
    surfaceContainer: Color.fromARGB(255, 56, 66, 55),
    surfaceContainerHigh: Color.fromARGB(255, 62, 71, 58),
    surfaceContainerHighest: Color.fromARGB(255, 68, 79, 66),
    primary: Color(0xffa9d6a9),
    onPrimary: Color(0xff313b30),
    secondary: Color(0xffa9d6a9),
    onSecondary: Color(0xff313b30),
    error: Color(0xffe36d5e),
    onError: KurumiColorTokens.onErrorDark,
    surface: Color.fromARGB(255, 38, 44, 37),
    onSurface: Color(0xffc0c1c1),
    outline: Color(0xffb1e0b1),
    outlineVariant: Color.fromARGB(255, 91, 104, 92),
  );

  static const coralPink = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xffef8987),
    onPrimary: Colors.white,
    secondary: Color(0xffef8987),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xff2c1f1e),
    onSecondaryContainer: Colors.white,
    surfaceContainerLowest: KurumiGreyscaleShades.gray12,
    surfaceContainerLow: KurumiGreyscaleShades.gray32,
    surfaceContainer: KurumiGreyscaleShades.gray46,
    surfaceContainerHigh: KurumiGreyscaleShades.gray50,
    surfaceContainerHighest: KurumiGreyscaleShades.gray54,
    onTertiaryContainer: Colors.white,
    error: Color(0xffc10105),
    onError: KurumiColorTokens.onErrorDark,
    surface: Color(0xff232322),
    onSurface: Colors.white,
    outline: KurumiGreyscaleShades.gray160,
    outlineVariant: KurumiGreyscaleShades.gray60,
  );

  static const _hackerPrimary = Color(0xff00ff00);
  static const _hackerPrimaryVariant = Color(0xff388e3c);

  static const hacker = ColorScheme(
    brightness: Brightness.dark,
    primary: _hackerPrimary,
    onPrimary: Colors.black,
    secondary: _hackerPrimary,
    onSecondary: Colors.black,
    secondaryContainer: Color(0xff000000),
    onSecondaryContainer: _hackerPrimary,
    surfaceContainerLowest: Color(0xff000000),
    surfaceContainerLow: Color(0xff000000),
    surfaceContainer: Color(0xff000000),
    surfaceContainerHigh: Color(0xff000000),
    surfaceContainerHighest: Color(0xff000000),
    outline: _hackerPrimaryVariant,
    outlineVariant: _hackerPrimaryVariant,
    onTertiaryContainer: _hackerPrimaryVariant,
    error: Color(0xffff0000),
    onError: KurumiColorTokens.onErrorDark,
    surface: Color(0xff000000),
    onSurface: _hackerPrimary,
  );

  static const _cyberpunkPrimary = Color(0xfffcec0c);
  static const _cyberpunkSurface = Color(0xff120c15);
  static const _cyberpunkOnSurface = Color(0xff02d6f1);
  static const _cyberpunkOutline = Color(0xff34736a);
  static const _cyberpunkError = Color(0xffff6159);

  static const cyberpunk = ColorScheme(
    brightness: Brightness.dark,
    primary: _cyberpunkPrimary,
    onPrimary: Colors.black,
    secondary: _cyberpunkPrimary,
    onSecondary: Colors.black,
    secondaryContainer: Color(0xff141824),
    onSecondaryContainer: _cyberpunkOnSurface,
    surfaceContainerLowest: Color(0xff151a27),
    surfaceContainerLow: Color(0xff161b29),
    surfaceContainer: Color(0xff141824),
    surfaceContainerHigh: Color(0xff121623),
    surfaceContainerHighest: Color(0xff0f1320),
    outline: _cyberpunkOutline,
    outlineVariant: _cyberpunkOutline,
    error: _cyberpunkError,
    onError: KurumiColorTokens.onErrorDark,
    surface: _cyberpunkSurface,
    onSurface: _cyberpunkOnSurface,
  );
}
