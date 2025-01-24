// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/current.dart';
import '../configs/ref.dart';
import '../premiums/providers.dart';
import '../settings/providers.dart';
import 'app_theme.dart';
import 'colors.dart';
import 'dynamic_color.dart';
import 'providers.dart';
import 'theme_configs.dart';
import 'theme_mode.dart';

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
    final enableDynamicColor = ref.watch(enableDynamicColoringProvider);

    final colors = ref.watch(settingsProvider.select((value) => value.colors));

    final hasPremium = ref.watch(hasPremiumProvider);

    final systemDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return AppDynamicColorBuilder(
      builder: (lightOrigin, darkOrigin) {
        final (light, dark) =
            enableDynamicColor ? (lightOrigin, darkOrigin) : (null, null);

        final customColorScheme = hasPremium
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
