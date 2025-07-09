// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

class ExtendedColorScheme extends ThemeExtension<ExtendedColorScheme>
    with EquatableMixin {
  const ExtendedColorScheme({
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
  ThemeExtension<ExtendedColorScheme> copyWith() {
    return this;
  }

  @override
  ThemeExtension<ExtendedColorScheme> lerp(
    covariant ThemeExtension<ExtendedColorScheme>? other,
    double t,
  ) {
    return this;
  }

  @override
  List<Object?> get props => [
    _surfaceContainerOverlay,
    _onSurfaceContainerOverlay,
    _surfaceContainerOverlayDim,
    _onSurfaceContainerOverlayDim,
  ];
}
