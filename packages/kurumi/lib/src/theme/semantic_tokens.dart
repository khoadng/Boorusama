import 'package:material_ui/material_ui.dart';

/// Semantic color roles for Kurumi components.
///
/// The roles are aliases over the existing Material color scheme and Kurumi
/// overlay values. They provide a stable vocabulary for consumers without
/// changing the current palette.
@immutable
class KurumiSemanticColors {
  const KurumiSemanticColors({
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.content,
    required this.contentSecondary,
    required this.contentMuted,
    required this.outline,
    required this.outlineVariant,
    required this.danger,
    required this.onDanger,
    required this.overlay,
    required this.onOverlay,
    required this.overlayDim,
    required this.onOverlayDim,
  });

  /// Creates semantic roles from the application's existing Material theme.
  factory KurumiSemanticColors.fromMaterial(
    ThemeData theme, {
    Color surfaceContainerOverlay = const Color(0x7F000000),
    Color onSurfaceContainerOverlay = Colors.white,
    Color surfaceContainerOverlayDim = const Color(0x7F000000),
    Color onSurfaceContainerOverlayDim = Colors.white70,
  }) {
    final colorScheme = theme.colorScheme;

    return KurumiSemanticColors(
      accent: colorScheme.primary,
      onAccent: colorScheme.onPrimary,
      accentContainer: colorScheme.primaryContainer,
      onAccentContainer: colorScheme.onPrimaryContainer,
      surface: colorScheme.surface,
      surfaceContainer: colorScheme.surfaceContainer,
      surfaceContainerLow: colorScheme.surfaceContainerLow,
      surfaceContainerHigh: colorScheme.surfaceContainerHigh,
      surfaceContainerHighest: colorScheme.surfaceContainerHighest,
      content: colorScheme.onSurface,
      contentSecondary: colorScheme.onSurfaceVariant,
      contentMuted: colorScheme.outline,
      outline: colorScheme.outline,
      outlineVariant: colorScheme.outlineVariant,
      danger: colorScheme.error,
      onDanger: colorScheme.onError,
      overlay: surfaceContainerOverlay,
      onOverlay: onSurfaceContainerOverlay,
      overlayDim: surfaceContainerOverlayDim,
      onOverlayDim: onSurfaceContainerOverlayDim,
    );
  }

  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color content;
  final Color contentSecondary;
  final Color contentMuted;
  final Color outline;
  final Color outlineVariant;
  final Color danger;
  final Color onDanger;
  final Color overlay;
  final Color onOverlay;
  final Color overlayDim;
  final Color onOverlayDim;
}
