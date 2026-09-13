// ignore_for_file: prefer_initializing_formals

import 'package:material_ui/material_ui.dart';

import 'package:equatable/equatable.dart';

class KurumiExtendedColorScheme
    extends ThemeExtension<KurumiExtendedColorScheme>
    with Equatable {
  const KurumiExtendedColorScheme({
    Color? surfaceContainerOverlay,
    Color? onSurfaceContainerOverlay,
    Color? surfaceContainerOverlayDim,
    Color? onSurfaceContainerOverlayDim,
  }) : _surfaceContainerOverlay = surfaceContainerOverlay,
       _onSurfaceContainerOverlay = onSurfaceContainerOverlay,
       _surfaceContainerOverlayDim = surfaceContainerOverlayDim,
       _onSurfaceContainerOverlayDim = onSurfaceContainerOverlayDim;

  final Color? _surfaceContainerOverlay;
  final Color? _onSurfaceContainerOverlay;
  final Color? _surfaceContainerOverlayDim;
  final Color? _onSurfaceContainerOverlayDim;

  Color get surfaceContainerOverlay =>
      _surfaceContainerOverlay ?? Colors.black.withAlpha(127);

  Color get onSurfaceContainerOverlay =>
      _onSurfaceContainerOverlay ?? Colors.white;

  Color get surfaceContainerOverlayDim =>
      _surfaceContainerOverlayDim ?? Colors.black.withAlpha(127);

  Color get onSurfaceContainerOverlayDim =>
      _onSurfaceContainerOverlayDim ?? Colors.white70;

  @override
  ThemeExtension<KurumiExtendedColorScheme> copyWith() => this;

  @override
  ThemeExtension<KurumiExtendedColorScheme> lerp(
    covariant ThemeExtension<KurumiExtendedColorScheme>? other,
    double t,
  ) => this;

  @override
  List<Object?> get props => [
    _surfaceContainerOverlay,
    _onSurfaceContainerOverlay,
    _surfaceContainerOverlayDim,
    _onSurfaceContainerOverlayDim,
  ];
}
