// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../../premiums/providers.dart';
import '../../../settings/providers.dart';
import '../../colors/providers.dart';
import '../../colors/types.dart';
import '../../configs/types.dart';

class ThemeBuilder extends ConsumerWidget {
  const ThemeBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(ThemeData theme, ThemeMode themeMode) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(
      settingsProvider.select((value) => value.themeMode),
    );
    final enableDynamicColor = ref.watch(enableDynamicColoringProvider);

    final colors = ref.watch(settingsProvider.select((value) => value.colors));

    final hasPremium = ref.watch(hasPremiumProvider);

    final systemDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    final dynamicColors = ref.watch(dynamicColorSchemesProvider);
    final (light, dark) = enableDynamicColor
        ? (dynamicColors.light, dynamicColors.dark)
        : (null, null);

    final customColorScheme = hasPremium
        ? (ref.watchThemeConfigs?.enable ?? false)
              ? getSchemeFromColorSettings(
                  ref.watchThemeConfigs?.colors,
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

    final scheme =
        customColorScheme ??
        Kurumi.generateColorScheme(
          theme,
          dynamicLightScheme: light,
          dynamicDarkScheme: dark,
          systemDarkMode: systemDarkMode,
        );

    return ProviderScope(
      overrides: [
        dynamicColorSupportProvider.overrideWithValue(
          dynamicColors.light != null && dynamicColors.dark != null,
        ),
        colorSchemeProvider.overrideWithValue(scheme),
      ],
      child: builder(
        Kurumi.themeFrom(
          customColorScheme != null ? null : theme,
          colorScheme: scheme,
          systemDarkMode: systemDarkMode,
        ).withBoorusamaColors(),
        theme.toSystem(),
      ),
    );
  }
}
