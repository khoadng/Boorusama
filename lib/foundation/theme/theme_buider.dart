// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
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
    final enableDynamicColor = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

    final systemDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return DynamicColorBuilder(
      builder: (light, dark) {
        final darkScheme = AppTheme.generateFromThemeMode(
          theme,
          seed: enableDynamicColor ? dark : null,
          systemDarkMode: systemDarkMode,
        );
        final lightScheme = AppTheme.generateFromThemeMode(
          theme,
          seed: enableDynamicColor ? light : null,
          systemDarkMode: systemDarkMode,
        );
        final darkAmoledScheme = AppTheme.generateFromThemeMode(
          AppThemeMode.amoledDark,
          seed: enableDynamicColor ? dark : null,
          systemDarkMode: systemDarkMode,
        );

        final colorScheme = switch (theme) {
          AppThemeMode.light => lightScheme,
          AppThemeMode.dark => darkScheme,
          AppThemeMode.amoledDark => darkAmoledScheme,
          AppThemeMode.system => systemDarkMode ? darkScheme : lightScheme,
        };

        return Builder(
          builder: (context) => ProviderScope(
            overrides: [
              dynamicColorSupportProvider
                  .overrideWithValue(light != null && dark != null),
            ],
            child: builder(
              AppTheme.themeFrom(
                theme,
                colorScheme: colorScheme,
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
