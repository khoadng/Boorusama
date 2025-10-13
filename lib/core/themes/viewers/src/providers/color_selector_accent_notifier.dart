// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../colors/types.dart';
import '../../../configs/types.dart';
import 'theme_previewer_notifier.dart';

class AccentColorSelectorNotifier
    extends AutoDisposeNotifier<AccentColorSelectorState> {
  @override
  AccentColorSelectorState build() {
    final themePreviewerState = ref.watch(themePreviewerProvider);

    return AccentColorSelectorState(
      harmonize: themePreviewerState.colors.harmonizeWithPrimary,
      isDark: themePreviewerState.colors.brightness == Brightness.dark,
      variant:
          themePreviewerState.colors.dynamicSchemeVariant ??
          DynamicSchemeVariant.tonalSpot,
      currentColorCode: themePreviewerState.colors.name,
    );
  }

  void updateColors(ColorSettings colors) {
    ref.read(themePreviewerProvider.notifier).updateColors(colors);
  }

  void updateHarmonize(bool value) {
    state = state.copyWith(harmonize: value);

    ref.read(themePreviewerProvider.notifier).updateHarmonize(value);
  }

  void updateIsDark(bool value) {
    final color = ColorUtils.hexToColor(state.currentColorCode);

    if (color == null) return;

    final newColors = ColorSettings.fromAccentColor(
      color,
      brightness: value ? Brightness.dark : Brightness.light,
      dynamicSchemeVariant: state.variant,
      harmonizeWithPrimary: state.harmonize,
    );

    state = state.copyWith(isDark: value);

    updateColors(newColors);
  }

  void updateVariant(DynamicSchemeVariant value) {
    final newColors = ColorSettings.fromAccentColor(
      ColorUtils.hexToColor(state.currentColorCode) ??
          themeAccentColors.values.first,
      brightness: state.isDark ? Brightness.dark : Brightness.light,
      dynamicSchemeVariant: value,
      harmonizeWithPrimary: state.harmonize,
    );

    state = state.copyWith(variant: value);

    updateColors(newColors);
  }

  void updateSelectedColor(Color color) {
    final newColors = ColorSettings.fromAccentColor(
      color,
      brightness: state.isDark ? Brightness.dark : Brightness.light,
      dynamicSchemeVariant: state.variant,
      harmonizeWithPrimary: state.harmonize,
    );

    state = state.copyWith(
      currentColorCode: color.hexWithoutAlpha,
    );

    updateColors(newColors);
  }

  ColorScheme getSchemeFromColor(Color color) {
    return ColorScheme.fromSeed(
      seedColor: color,
      brightness: state.isDark ? Brightness.dark : Brightness.light,
      dynamicSchemeVariant: state.variant,
    );
  }
}

class AccentColorSelectorState extends Equatable {
  const AccentColorSelectorState({
    required this.isDark,
    required this.harmonize,
    required this.variant,
    required this.currentColorCode,
  });

  final bool isDark;
  final bool harmonize;
  final DynamicSchemeVariant variant;
  final String currentColorCode;

  @override
  List<Object?> get props => [
    isDark,
    harmonize,
    variant,
    currentColorCode,
  ];

  AccentColorSelectorState copyWith({
    bool? isDark,
    bool? harmonize,
    DynamicSchemeVariant? variant,
    bool? viewAllColor,
    String? currentColorCode,
  }) {
    return AccentColorSelectorState(
      isDark: isDark ?? this.isDark,
      harmonize: harmonize ?? this.harmonize,
      variant: variant ?? this.variant,
      currentColorCode: currentColorCode ?? this.currentColorCode,
    );
  }
}

final accentColorSelectorProvider =
    NotifierProvider.autoDispose<
      AccentColorSelectorNotifier,
      AccentColorSelectorState
    >(
      AccentColorSelectorNotifier.new,
      dependencies: [
        themePreviewerProvider,
      ],
    );
