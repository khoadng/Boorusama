// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../foundation/utils/color_utils.dart';
import '../theme.dart';

Color? _parse(dynamic value) => switch (value) {
      final String hex => ColorUtils.hexToColor(hex),
      _ => null,
    };

ColorScheme? colorSchemeFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;

  final primary = _parse(json['primary']);
  final onPrimary = _parse(json['onPrimary']);
  final secondary = _parse(json['secondary']);
  final onSecondary = _parse(json['onSecondary']);
  final error = _parse(json['error']);
  final onError = _parse(json['onError']);
  final surface = _parse(json['surface']);
  final onSurface = _parse(json['onSurface']);

  if (primary == null ||
      onPrimary == null ||
      secondary == null ||
      onSecondary == null ||
      error == null ||
      onError == null ||
      surface == null ||
      onSurface == null) {
    return null;
  }

  return ColorScheme(
    brightness:
        json['brightness'] == 'dark' ? Brightness.dark : Brightness.light,
    primary: primary,
    surfaceTint: _parse(json['surfaceTint']),
    onPrimary: onPrimary,
    primaryContainer: _parse(json['primaryContainer']),
    onPrimaryContainer: _parse(json['onPrimaryContainer']),
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: _parse(json['secondaryContainer']),
    onSecondaryContainer: _parse(json['onSecondaryContainer']),
    tertiary: _parse(json['tertiary']),
    onTertiary: _parse(json['onTertiary']),
    tertiaryContainer: _parse(json['tertiaryContainer']),
    onTertiaryContainer: _parse(json['onTertiaryContainer']),
    error: error,
    onError: onError,
    errorContainer: _parse(json['errorContainer']),
    onErrorContainer: _parse(json['onErrorContainer']),
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: _parse(json['onSurfaceVariant']),
    outline: _parse(json['outline']),
    outlineVariant: _parse(json['outlineVariant']),
    shadow: _parse(json['shadow']),
    scrim: _parse(json['scrim']),
    inverseSurface: _parse(json['inverseSurface']),
    onInverseSurface: _parse(json['onInverseSurface']),
    inversePrimary: _parse(json['inversePrimary']),
    primaryFixed: _parse(json['primaryFixed']),
    onPrimaryFixed: _parse(json['onPrimaryFixed']),
    primaryFixedDim: _parse(json['primaryFixedDim']),
    onPrimaryFixedVariant: _parse(json['onPrimaryFixedVariant']),
    secondaryFixed: _parse(json['secondaryFixed']),
    onSecondaryFixed: _parse(json['onSecondaryFixed']),
    secondaryFixedDim: _parse(json['secondaryFixedDim']),
    onSecondaryFixedVariant: _parse(json['onSecondaryFixedVariant']),
    tertiaryFixed: _parse(json['tertiaryFixed']),
    onTertiaryFixed: _parse(json['onTertiaryFixed']),
    tertiaryFixedDim: _parse(json['tertiaryFixedDim']),
    onTertiaryFixedVariant: _parse(json['onTertiaryFixedVariant']),
    surfaceDim: _parse(json['surfaceDim']),
    surfaceBright: _parse(json['surfaceBright']),
    surfaceContainerLowest: _parse(json['surfaceContainerLowest']),
    surfaceContainerLow: _parse(json['surfaceContainerLow']),
    surfaceContainer: _parse(json['surfaceContainer']),
    surfaceContainerHigh: _parse(json['surfaceContainerHigh']),
    surfaceContainerHighest: _parse(json['surfaceContainerHighest']),
  );
}

extension ColorSchemeConverter on ColorScheme {
  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness == Brightness.dark ? 'dark' : 'light',
      'primary': primary.hex,
      'surfaceTint': surfaceTint.hex,
      'onPrimary': onPrimary.hex,
      'primaryContainer': primaryContainer.hex,
      'onPrimaryContainer': onPrimaryContainer.hex,
      'secondary': secondary.hex,
      'onSecondary': onSecondary.hex,
      'secondaryContainer': secondaryContainer.hex,
      'onSecondaryContainer': onSecondaryContainer.hex,
      'tertiary': tertiary.hex,
      'onTertiary': onTertiary.hex,
      'tertiaryContainer': tertiaryContainer.hex,
      'onTertiaryContainer': onTertiaryContainer.hex,
      'error': error.hex,
      'onError': onError.hex,
      'errorContainer': errorContainer.hex,
      'onErrorContainer': onErrorContainer.hex,
      'surface': surface.hex,
      'onSurface': onSurface.hex,
      'onSurfaceVariant': onSurfaceVariant.hex,
      'outline': outline.hex,
      'outlineVariant': outlineVariant.hex,
      'shadow': shadow.hex,
      'scrim': scrim.hex,
      'inverseSurface': inverseSurface.hex,
      'onInverseSurface': onInverseSurface.hex,
      'inversePrimary': inversePrimary.hex,
      'primaryFixed': primaryFixed.hex,
      'onPrimaryFixed': onPrimaryFixed.hex,
      'primaryFixedDim': primaryFixedDim.hex,
      'onPrimaryFixedVariant': onPrimaryFixedVariant.hex,
      'secondaryFixed': secondaryFixed.hex,
      'onSecondaryFixed': onSecondaryFixed.hex,
      'secondaryFixedDim': secondaryFixedDim.hex,
      'onSecondaryFixedVariant': onSecondaryFixedVariant.hex,
      'tertiaryFixed': tertiaryFixed.hex,
      'onTertiaryFixed': onTertiaryFixed.hex,
      'tertiaryFixedDim': tertiaryFixedDim.hex,
      'onTertiaryFixedVariant': onTertiaryFixedVariant.hex,
      'surfaceDim': surfaceDim.hex,
      'surfaceBright': surfaceBright.hex,
      'surfaceContainerLowest': surfaceContainerLowest.hex,
      'surfaceContainerLow': surfaceContainerLow.hex,
      'surfaceContainer': surfaceContainer.hex,
      'surfaceContainerHigh': surfaceContainerHigh.hex,
      'surfaceContainerHighest': surfaceContainerHighest.hex,
    };
  }
}

ExtendedColorScheme? extendedColorSchemeFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;

  final surfaceContainerOverlay = _parse(json['surfaceContainerOverlay']);
  final onSurfaceContainerOverlay = _parse(json['onSurfaceContainerOverlay']);
  final surfaceContainerOverlayDim = _parse(json['surfaceContainerOverlayDim']);
  final onSurfaceContainerOverlayDim =
      _parse(json['onSurfaceContainerOverlayDim']);

  return ExtendedColorScheme(
    surfaceContainerOverlay: surfaceContainerOverlay,
    onSurfaceContainerOverlay: onSurfaceContainerOverlay,
    surfaceContainerOverlayDim: surfaceContainerOverlayDim,
    onSurfaceContainerOverlayDim: onSurfaceContainerOverlayDim,
  );
}

extension ExtendedColorSchemeConverter on ExtendedColorScheme {
  Map<String, dynamic> toJson() {
    return {
      'surfaceContainerOverlay': surfaceContainerOverlay.hex,
      'onSurfaceContainerOverlay': onSurfaceContainerOverlay.hex,
      'surfaceContainerOverlayDim': surfaceContainerOverlayDim.hex,
      'onSurfaceContainerOverlayDim': onSurfaceContainerOverlayDim.hex,
    };
  }
}
