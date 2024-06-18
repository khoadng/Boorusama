// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'app_theme.dart';
import 'colors.dart';
import 'theme_mode.dart';

class ThemeBuilder extends ConsumerWidget {
  const ThemeBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(ThemeData theme, ThemeMode themeMode) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme =
        ref.watch(settingsProvider.select((value) => value.themeMode));
    final enableDynamicColor = ref.watch(enableDynamicColoringSettingsProvider);

    final systemDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return DynamicColorBuilder(
      builder: (lightOrigin, darkOrigin) {
        final (light, dark) = enableDynamicColor
            ? lightOrigin != null && darkOrigin != null
                ? _generateDynamicColourSchemes(lightOrigin, darkOrigin)
                : (null, null)
            : (null, null);

        final scheme = AppTheme.generateScheme(
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
            ],
            child: builder(
              AppTheme.themeFrom(
                theme,
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
    ColorScheme lightDynamic, ColorScheme darkDynamic) {
  var lightBase = ColorScheme.fromSeed(seedColor: lightDynamic.primary);
  var darkBase = ColorScheme.fromSeed(
      seedColor: darkDynamic.primary, brightness: Brightness.dark);

  var lightAdditionalColours = _extractAdditionalColours(lightBase);
  var darkAdditionalColours = _extractAdditionalColours(darkBase);

  var lightScheme = _insertAdditionalColours(lightBase, lightAdditionalColours);
  var darkScheme = _insertAdditionalColours(darkBase, darkAdditionalColours);

  return (lightScheme.harmonized(), darkScheme.harmonized());
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
        ColorScheme scheme, List<Color> additionalColours) =>
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
