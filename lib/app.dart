// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';

// Project imports:
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/application/app_rating.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/platforms/windows/windows.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'package:boorusama/home_page.dart';
import 'boorus/danbooru/router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({
    super.key,
    required this.settings,
  });

  final Settings settings;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return Portal(
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
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
            darkTheme: state.theme == ThemeMode.amoledDark
                ? AppTheme.darkAmoledTheme
                : AppTheme.darkTheme,
            themeMode: mapAppThemeModeToSystemThemeMode(state.theme),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            title: context.read<AppInfoProvider>().appInfo.appName,
            navigatorKey: navigatorKey,
            navigatorObservers: isAnalyticsEnabled(widget.settings)
                ? [
                    getAnalyticsObserver(),
                  ]
                : [],
            home: ConditionalParentWidget(
              condition: canRate(),
              conditionalBuilder: (child) =>
                  createAppRatingWidget(child: child),
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
          );
        },
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
