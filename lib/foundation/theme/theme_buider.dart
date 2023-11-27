// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'app_theme.dart';
import 'colors.dart';
import 'theme_mode.dart' as tm;

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

    return DynamicColorBuilder(
      builder: (light, dark) {
        final darkScheme = AppTheme.generateFromThemeMode(
          theme,
          seed: enableDynamicColor ? dark : null,
        );
        final lightScheme = AppTheme.generateFromThemeMode(
          theme,
          seed: enableDynamicColor ? light : null,
        );
        final darkAmoledScheme = AppTheme.generateFromThemeMode(
          tm.ThemeMode.amoledDark,
          seed: enableDynamicColor ? dark : null,
        );

        final colorScheme = theme == tm.ThemeMode.light
            ? lightScheme
            : theme == tm.ThemeMode.dark
                ? darkScheme
                : darkAmoledScheme;

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
              ),
              tm.mapAppThemeModeToSystemThemeMode(theme),
            ),
          ),
        );
      },
    );
  }
}
