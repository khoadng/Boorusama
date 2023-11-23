// Flutter imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends ConsumerStatefulWidget {
  const App({
    super.key,
    required this.settings,
  });

  final Settings settings;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final theme =
        ref.watch(settingsProvider.select((value) => value.themeMode));
    final router = ref.watch(routerProvider(widget.settings));
    final enableDynamicColor = ref
        .watch(settingsProvider.select((value) => value.enableDynamicColoring));

    ref.listen(
      currentBooruConfigProvider,
      (p, c) {
        if (p != c) {
          if (isAnalyticsEnabled(widget.settings)) {
            changeCurrentAnalyticConfig(c);
          }
        }
      },
    );

    return Portal(
      child: OKToast(
        child: DynamicColorBuilder(
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
              ThemeMode.amoledDark,
              seed: enableDynamicColor ? dark : null,
            );

            final colorScheme = theme == ThemeMode.light
                ? lightScheme
                : theme == ThemeMode.dark
                    ? darkScheme
                    : darkAmoledScheme;

            return Builder(
              builder: (context) => ProviderScope(
                overrides: [
                  colorSchemeProvider.overrideWithValue(colorScheme),
                  dynamicColorSupportProvider
                      .overrideWithValue(light != null && dark != null),
                ],
                child: MaterialApp.router(
                  builder: (context, child) => ConditionalParentWidget(
                    condition: isDesktopPlatform(),
                    conditionalBuilder: (child) => child,
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior()
                          .copyWith(overscroll: false),
                      child: child!,
                    ),
                  ),
                  theme: AppTheme.themeFrom(theme, colorScheme: colorScheme),
                  themeMode: mapAppThemeModeToSystemThemeMode(theme),
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  debugShowCheckedModeBanner: false,
                  title: ref.watch(appInfoProvider).appName,
                  routerConfig: router,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
