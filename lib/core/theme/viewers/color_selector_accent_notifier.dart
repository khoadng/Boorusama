// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../utils/color_utils.dart';
import '../named_colors.dart';
import '../theme_configs.dart';
import 'theme_previewer_notifier.dart';

class AccentColorSelectorNotifier
    extends AutoDisposeNotifier<AccentColorSelectorState> {
  @override
  AccentColorSelectorState build() {
    final themePreviewerState = ref.watch(themePreviewerProvider);

    return AccentColorSelectorState(
      isDark: themePreviewerState.colors.brightness == Brightness.dark,
      variant: themePreviewerState.colors.dynamicSchemeVariant ??
          DynamicSchemeVariant.tonalSpot,
      viewAllColor: false,
      currentColorCode: themePreviewerState.colors.name,
    );
  }

  void updateColors(ColorSettings colors) {
    ref.read(themePreviewerProvider.notifier).updateColors(colors);
  }

  void updateIsDark(bool value) {
    final color = ColorUtils.hexToColor(state.currentColorCode);

    if (color == null) return;

    final newColors = ColorSettings.fromAccentColor(
      color,
      brightness: value ? Brightness.dark : Brightness.light,
      dynamicSchemeVariant: state.variant,
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
    );

    state = state.copyWith(variant: value);

    updateColors(newColors);
  }

  void toggleViewAllColor() {
    state = state.copyWith(viewAllColor: !state.viewAllColor);
  }

  void updateSelectedColor(Color color) {
    final newColors = ColorSettings.fromAccentColor(
      color,
      brightness: state.isDark ? Brightness.dark : Brightness.light,
      dynamicSchemeVariant: state.variant,
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
    required this.variant,
    required this.viewAllColor,
    required this.currentColorCode,
  });

  final bool isDark;
  final DynamicSchemeVariant variant;
  final bool viewAllColor;
  final String currentColorCode;

  @override
  List<Object?> get props => [
        isDark,
        variant,
        viewAllColor,
        currentColorCode,
      ];

  AccentColorSelectorState copyWith({
    bool? isDark,
    DynamicSchemeVariant? variant,
    bool? viewAllColor,
    String? currentColorCode,
  }) {
    return AccentColorSelectorState(
      isDark: isDark ?? this.isDark,
      variant: variant ?? this.variant,
      viewAllColor: viewAllColor ?? this.viewAllColor,
      currentColorCode: currentColorCode ?? this.currentColorCode,
    );
  }
}

final accentColorSelectorProvider = NotifierProvider.autoDispose<
    AccentColorSelectorNotifier, AccentColorSelectorState>(
  AccentColorSelectorNotifier.new,
  dependencies: [
    themePreviewerProvider,
  ],
);
