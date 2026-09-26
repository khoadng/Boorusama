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
    primary: Color(0xFF1B6EF3),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD3E3FD),
    onPrimaryContainer: Color(0xFF041E49),
    secondary: Color(0xFF00639B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFC2E7FF),
    onSecondaryContainer: Color(0xFF001D35),
    tertiary: Color(0xFF006874),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF97F0FF),
    onTertiaryContainer: Color(0xFF001F24),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    surface: Color(0xFFF8F9FA),
    onSurface: Color(0xFF1F1F1F),
    onSurfaceVariant: Color(0xFF444746),
    outline: Color(0xFF74777F),
    outlineVariant: Color(0xFFC4C7C5),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F4F7),
    surfaceContainer: Color(0xFFECEEF1),
    surfaceContainerHigh: Color(0xFFE6E8EB),
    surfaceContainerHighest: Color(0xFFE0E2E5),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA8C7FA),
    onPrimary: Color(0xFF062E6F),
    primaryContainer: Color(0xFF0842A0),
    onPrimaryContainer: Color(0xFFD3E3FD),
    secondary: Color(0xFF7FCFFF),
    onSecondary: Color(0xFF003355),
    secondaryContainer: Color(0xFF004A77),
    onSecondaryContainer: Color(0xFFC2E7FF),
    tertiary: Color(0xFF4FD8EB),
    onTertiary: Color(0xFF00363D),
    tertiaryContainer: Color(0xFF004F58),
    onTertiaryContainer: Color(0xFF97F0FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Color(0xFF111318),
    onSurface: Color(0xFFE2E2E6),
    onSurfaceVariant: Color(0xFFC4C7C5),
    outline: Color(0xFF8E918F),
    outlineVariant: Color(0xFF444746),
    surfaceContainerLowest: Color(0xFF0C0E13),
    surfaceContainerLow: Color(0xFF191C20),
    surfaceContainer: Color(0xFF1D2024),
    surfaceContainerHigh: Color(0xFF282A2F),
    surfaceContainerHighest: Color(0xFF33353A),
  );

  static const amoledDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA8C7FA),
    onPrimary: Color(0xFF062E6F),
    primaryContainer: Color(0xFF0842A0),
    onPrimaryContainer: Color(0xFFD3E3FD),
    secondary: Color(0xFF7FCFFF),
    onSecondary: Color(0xFF003355),
    secondaryContainer: Color(0xFF004A77),
    onSecondaryContainer: Color(0xFFC2E7FF),
    tertiary: Color(0xFF4FD8EB),
    onTertiary: Color(0xFF00363D),
    tertiaryContainer: Color(0xFF004F58),
    onTertiaryContainer: Color(0xFF97F0FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: Colors.black,
    onSurface: Colors.white,
    onSurfaceVariant: Color(0xFFC4C7C5),
    outline: Color(0xFF8E918F),
    outlineVariant: Color(0xFF444746),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF101216),
    surfaceContainer: Color(0xFF16181D),
    surfaceContainerHigh: Color(0xFF202328),
    surfaceContainerHighest: Color(0xFF2B2E34),
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
