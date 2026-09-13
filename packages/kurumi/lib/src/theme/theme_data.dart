import 'package:material_ui/material_ui.dart';

import 'extended_color_scheme.dart';
import 'semantic_tokens.dart';

@immutable
class KurumiThemeData {
  const KurumiThemeData({
    required this.materialTheme,
    this.surfaceContainerOverlay = const Color(0x7F000000),
    this.onSurfaceContainerOverlay = Colors.white,
    this.surfaceContainerOverlayDim = const Color(0x7F000000),
    this.onSurfaceContainerOverlayDim = Colors.white70,
  });

  factory KurumiThemeData.fromMaterial(
    ThemeData theme, {
    KurumiExtendedColorScheme? extendedColorScheme,
    Color? surfaceContainerOverlay,
    Color? onSurfaceContainerOverlay,
    Color? surfaceContainerOverlayDim,
    Color? onSurfaceContainerOverlayDim,
  }) {
    final extension =
        extendedColorScheme ?? theme.extension<KurumiExtendedColorScheme>();

    return KurumiThemeData(
      materialTheme: theme,
      surfaceContainerOverlay:
          surfaceContainerOverlay ??
          extension?.surfaceContainerOverlay ??
          const Color(0x7F000000),
      onSurfaceContainerOverlay:
          onSurfaceContainerOverlay ??
          extension?.onSurfaceContainerOverlay ??
          Colors.white,
      surfaceContainerOverlayDim:
          surfaceContainerOverlayDim ??
          extension?.surfaceContainerOverlayDim ??
          const Color(0x7F000000),
      onSurfaceContainerOverlayDim:
          onSurfaceContainerOverlayDim ??
          extension?.onSurfaceContainerOverlayDim ??
          Colors.white70,
    );
  }

  final ThemeData materialTheme;
  final Color surfaceContainerOverlay;
  final Color onSurfaceContainerOverlay;
  final Color surfaceContainerOverlayDim;
  final Color onSurfaceContainerOverlayDim;

  /// Semantic roles backed by this theme's existing values.
  KurumiSemanticColors get semanticColors => KurumiSemanticColors.fromMaterial(
    materialTheme,
    surfaceContainerOverlay: surfaceContainerOverlay,
    onSurfaceContainerOverlay: onSurfaceContainerOverlay,
    surfaceContainerOverlayDim: surfaceContainerOverlayDim,
    onSurfaceContainerOverlayDim: onSurfaceContainerOverlayDim,
  );

  ThemeData toMaterialTheme() => materialTheme;
}
