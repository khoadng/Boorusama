// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/app_theme.dart';
import 'package:boorusama/core/application/app_rating.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/platforms/windows/windows.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'package:boorusama/home_page.dart';
import 'boorus/danbooru/router.dart';

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
    final theme = ref.watch(themeProvider);

    return Portal(
      child: OKToast(
        child: MaterialApp(
          builder: (context, child) => ConditionalParentWidget(
            condition: isDesktopPlatform(),
            conditionalBuilder: (child) => Column(
              children: [
                WindowTitleBarBox(
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow()),
                      const WindowButtons(),
                    ],
                  ),
                ),
                Expanded(
                  child: child,
                ),
              ],
            ),
            child: ScrollConfiguration(
              behavior: AppScrollBehavior(),
              child: child!,
            ),
          ),
          theme: AppTheme.lightTheme,
          darkTheme: theme == ThemeMode.amoledDark
              ? AppTheme.darkAmoledTheme
              : AppTheme.darkTheme,
          themeMode: mapAppThemeModeToSystemThemeMode(theme),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: ref.watch(appInfoProvider).appName,
          navigatorKey: navigatorKey,
          navigatorObservers: isAnalyticsEnabled(widget.settings)
              ? [
                  getAnalyticsObserver(),
                ]
              : [],
          home: ConditionalParentWidget(
            condition: canRate(),
            conditionalBuilder: (child) => createAppRatingWidget(child: child),
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(
                  LogicalKeyboardKey.keyF,
                  control: true,
                ): () => goToSearchPage(context),
              },
              child: const CustomContextMenuOverlay(
                child: Focus(
                  autofocus: true,
                  child: HomePage(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
