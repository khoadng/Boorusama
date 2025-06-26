// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../configs/appearance/types.dart';
import '../app_theme.dart';
import '../dynamic_color.dart';
import '../theme_configs.dart';
import 'theme_preview_page.dart';
import 'theme_previewer_notifier.dart';

class ThemePreviewer extends ConsumerWidget {
  const ThemePreviewer({
    required this.onThemeUpdated,
    required this.colorSettings,
    required this.updateMethod,
    super.key,
  });

  final void Function(ColorSettings? colors) onThemeUpdated;
  final ColorSettings? colorSettings;
  final ThemeUpdateMethod updateMethod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = Navigator.of(context);
    final systemDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return AppDynamicColorBuilder(
      builder: (light, dark) => ProviderScope(
        key: ValueKey((light, dark, systemDarkMode)),
        overrides: [
          themePreviewerProvider.overrideWith(
            () => ThemePreviewerNotifier(
              initialColors: colorSettings,
              updateMethod: updateMethod,
              onThemeUpdated: onThemeUpdated,
              onExit: () => navigator.pop(),
              light: light,
              dark: dark,
              systemDarkMode: systemDarkMode,
            ),
          ),
        ],
        child: const ThemePreviewApp(
          home: ThemePreviewPage(),
        ),
      ),
    );
  }
}

class ThemePreviewApp extends ConsumerWidget {
  const ThemePreviewApp({
    required this.home,
    super.key,
  });

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(
      themePreviewerProvider.select((v) => v.colorScheme),
    );

    final notifier = ref.watch(themePreviewerProvider.notifier);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness: colorScheme.brightness,
        statusBarIconBrightness: colorScheme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeFrom(
          null,
          colorScheme: colorScheme,
          systemDarkMode: notifier.systemDarkMode,
        ),
        home: home,
      ),
    );
  }
}
