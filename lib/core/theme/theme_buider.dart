// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/current.dart';
import '../configs/ref.dart';
import '../settings/providers.dart';
import 'app_theme.dart';
import 'colors.dart';
import 'theme_configs.dart';
import 'theme_mode.dart';

//FIXME: remove this when premium is implemented
const kHasPremium = true;

final hasCustomThemeSettingsProvider = Provider<bool>((ref) {
  final themeConfigs =
      ref.watch(currentBooruConfigProvider.select((value) => value.theme));

  return themeConfigs != null && themeConfigs.enable;
});

class ThemeBuilder extends ConsumerWidget {
  const ThemeBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(ThemeData theme, ThemeMode themeMode) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme =
        ref.watch(settingsProvider.select((value) => value.themeMode));
    final enableDynamicColor = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

    final colors = ref.watch(settingsProvider.select((value) => value.colors));

    final systemDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return DynamicColorBuilder(
      builder: (lightOrigin, darkOrigin) {
        final (light, dark) = enableDynamicColor
            ? lightOrigin != null && darkOrigin != null
                ? _generateDynamicColourSchemes(lightOrigin, darkOrigin)
                : (null, null)
            : (null, null);

        final customColorScheme = kHasPremium
            ? ref.watchThemeConfigs?.enable == true
                ? getSchemeFromColorSettings(
                    ref.watchConfig.theme?.colors,
                    dynamicDarkScheme: dark,
                    dynamicLightScheme: light,
                    systemDarkMode: systemDarkMode,
                  )
                : getSchemeFromColorSettings(
                    colors,
                    dynamicDarkScheme: dark,
                    dynamicLightScheme: light,
                    systemDarkMode: systemDarkMode,
                  )
            : null;

        final scheme = customColorScheme ??
            AppTheme.generateScheme(
              theme,
              dynamicDarkScheme: dark,
              dynamicLightScheme: light,
              systemDarkMode: systemDarkMode,
            );

        return Builder(
          builder: (context) => ProviderScope(
            overrides: [
              dynamicColorSupportProvider
                  .overrideWithValue(lightOrigin != null && darkOrigin != null),
              colorSchemeProvider.overrideWithValue(scheme),
            ],
            child: builder(
              AppTheme.themeFrom(
                customColorScheme != null ? null : theme,
                colorScheme: scheme,
                systemDarkMode: systemDarkMode,
              ),
              mapAppThemeModeToSystemThemeMode(theme),
            ),
          ),
        );
      },
    );
  }
}

//TODO: temp solution
// https://github.com/material-foundation/flutter-packages/issues/582
(ColorScheme light, ColorScheme dark) _generateDynamicColourSchemes(
  ColorScheme lightDynamic,
  ColorScheme darkDynamic,
) {
  final lightBase = ColorScheme.fromSeed(seedColor: lightDynamic.primary);
  final darkBase = ColorScheme.fromSeed(
    seedColor: darkDynamic.primary,
    brightness: Brightness.dark,
  );

  final lightAdditionalColours = _extractAdditionalColours(lightBase);
  final darkAdditionalColours = _extractAdditionalColours(darkBase);

  final lightScheme = _insertAdditionalColours(
    lightBase,
    lightAdditionalColours,
  );
  final darkScheme = _insertAdditionalColours(
    darkBase,
    darkAdditionalColours,
  );

  return (
    lightScheme.harmonized(),
    darkScheme.harmonized(),
  );
}

List<Color> _extractAdditionalColours(ColorScheme scheme) => [
      scheme.surface,
      scheme.surfaceDim,
      scheme.surfaceBright,
      scheme.surfaceContainerLowest,
      scheme.surfaceContainerLow,
      scheme.surfaceContainer,
      scheme.surfaceContainerHigh,
      scheme.surfaceContainerHighest,
    ];

ColorScheme _insertAdditionalColours(
  ColorScheme scheme,
  List<Color> additionalColours,
) =>
    scheme.copyWith(
      surface: additionalColours[0],
      surfaceDim: additionalColours[1],
      surfaceBright: additionalColours[2],
      surfaceContainerLowest: additionalColours[3],
      surfaceContainerLow: additionalColours[4],
      surfaceContainer: additionalColours[5],
      surfaceContainerHigh: additionalColours[6],
      surfaceContainerHighest: additionalColours[7],
    );
