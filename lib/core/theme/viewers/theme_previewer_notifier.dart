// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../configs/appearance/types.dart';
import '../../settings/providers.dart';
import '../app_theme.dart';
import '../named_colors.dart';
import '../theme_configs.dart' as configs show getSchemeFromColorSettings;
import '../theme_configs.dart';
import 'theme_widgets.dart';

class ThemePreviewerNotifier extends AutoDisposeNotifier<ThemePreviewerState> {
  ThemePreviewerNotifier({
    required this.initialColors,
    required this.updateMethod,
    required this.onThemeUpdated,
    required this.onExit,
    required this.light,
    required this.dark,
    required this.systemDarkMode,
  });

  final ColorSettings? initialColors;
  final ThemeUpdateMethod updateMethod;
  final void Function(ColorSettings? colors) onThemeUpdated;
  final void Function() onExit;
  final ColorScheme? light;
  final ColorScheme? dark;
  final bool systemDarkMode;

  @override
  ThemePreviewerState build() {
    final settingsColors = ref.watch(settingsProvider.select((v) => v.colors));
    final effectiveColors = initialColors ??
        settingsColors ??
        ColorSettings.fromBasicScheme(
          'boorusama_black',
          nickname: 'Midnight',
        );

    final colorScheme = configs.getSchemeFromColorSettings(
          effectiveColors,
          dynamicLightScheme: light,
          dynamicDarkScheme: dark,
          systemDarkMode: systemDarkMode,
        ) ??
        staticBlackScheme;

    return ThemePreviewerState(
      colors: effectiveColors,
      category: switch (initialColors?.schemeType) {
        SchemeType.basic => ThemeCategory.basic,
        SchemeType.builtIn => ThemeCategory.builtIn,
        SchemeType.accent => ThemeCategory.accent,
        SchemeType.custom => throw UnimplementedError(),
        null => ThemeCategory.basic,
      },
      colorScheme: colorScheme,
      basicColors: basicColorSettings,
      builtinColors: preDefinedColorSettings,
      accentColors: themeAccentColors,
    );
  }

  ColorScheme? getSchemeFromColorSettings(ColorSettings settings) {
    return configs.getSchemeFromColorSettings(
      settings,
      dynamicLightScheme: light,
      dynamicDarkScheme: dark,
      systemDarkMode: systemDarkMode,
    );
  }

  void updateColors(ColorSettings? colors) {
    state = state.copyWith(
      colors: colors,
      colorScheme: configs.getSchemeFromColorSettings(
        colors,
        dynamicLightScheme: light,
        dynamicDarkScheme: dark,
        systemDarkMode: systemDarkMode,
      ),
    );
  }

  void updateHarmonize(bool value) {
    final newColors = state.colors.copyWith(
      harmonizeWithPrimary: value,
    );

    state = state.copyWith(colors: newColors);
  }

  void updateCategory(ThemeCategory category) {
    final newColors = switch (category) {
      ThemeCategory.basic => state.basicColors.first,
      ThemeCategory.builtIn => state.builtinColors.first,
      ThemeCategory.accent => ColorSettings.fromAccentColor(
          themeAccentColors.values.first,
          brightness: state.colors.brightness ?? Brightness.dark,
          dynamicSchemeVariant: state.colors.dynamicSchemeVariant ??
              DynamicSchemeVariant.tonalSpot,
          harmonizeWithPrimary: state.colors.harmonizeWithPrimary,
        ),
    };

    state = state.copyWith(
      category: category,
      colors: newColors,
      colorScheme: configs.getSchemeFromColorSettings(
        newColors,
        dynamicLightScheme: light,
        dynamicDarkScheme: dark,
        systemDarkMode: systemDarkMode,
      ),
    );
  }

  void updateScheme() {
    onThemeUpdated(state.colors);
  }

  void exit() {
    onExit();
  }
}

class ThemePreviewerState extends Equatable {
  const ThemePreviewerState({
    required this.colors,
    required this.category,
    required this.colorScheme,
    required this.basicColors,
    required this.builtinColors,
    required this.accentColors,
  });

  final ColorSettings colors;
  final ColorScheme colorScheme;
  final ThemeCategory category;

  final List<ColorSettings> basicColors;
  final List<ColorSettings> builtinColors;
  final Map<String, Color> accentColors;

  ThemePreviewerState copyWith({
    ColorSettings? colors,
    ColorScheme? colorScheme,
    ThemeCategory? category,
  }) {
    return ThemePreviewerState(
      colors: colors ?? this.colors,
      colorScheme: colorScheme ?? this.colorScheme,
      category: category ?? this.category,
      basicColors: basicColors,
      builtinColors: builtinColors,
      accentColors: accentColors,
    );
  }

  @override
  List<Object?> get props => [
        colors,
        category,
        colorScheme,
        basicColors,
        builtinColors,
        accentColors,
      ];
}

final themePreviewerProvider =
    NotifierProvider.autoDispose<ThemePreviewerNotifier, ThemePreviewerState>(
  () => throw UnimplementedError(),
);

final themePreviewerSchemeProvider = Provider.autoDispose<ColorScheme>(
  (ref) =>
      ref.watch(themePreviewerProvider.select((value) => value.colorScheme)),
  dependencies: [themePreviewerProvider],
);

final themePreviewerColorsProvider = Provider.autoDispose<ColorSettings>(
  (ref) => ref.watch(themePreviewerProvider.select((value) => value.colors)),
  dependencies: [themePreviewerProvider],
);
