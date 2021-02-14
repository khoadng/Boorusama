// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/all.dart';

// Project imports:
import 'app_constants.dart';
import 'boorus/danbooru/application/themes/theme_state_notifier.dart';
import 'boorus/danbooru/infrastructure/repositories/settings/setting.dart';
import 'boorus/danbooru/infrastructure/services/download_service.dart';
import 'boorus/danbooru/router.dart';
import 'core/app_theme.dart';
import 'generated/i18n.dart';

class App extends StatefulWidget {
  App({this.settings});

  final Setting settings;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final i18n = I18n.delegate;

  @override
  void initState() {
    super.initState();

    AppRouter().setupRoutes();

    Future.delayed(
        Duration.zero, () => context.read(downloadServiceProvider).init());

    Future.delayed(
        Duration.zero,
        () => context
            .read(themeStateNotifierProvider)
            .changeTheme(widget.settings.themeMode));

    I18n.onLocaleChanged = onLocaleChange;
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderListener<ThemeState>(
      provider: themeStateNotifierProvider.state,
      onChange: (context, state) {
        // state.when(
        //   darkMode: () async {
        //     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        //       systemNavigationBarColor: Colors.grey[900],
        //       statusBarColor: Colors.grey[900],
        //       statusBarIconBrightness: Brightness.light,
        //       statusBarBrightness: Brightness.light,
        //     ));
        //   },
        //   lightMode: () async {
        //     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        //       systemNavigationBarColor: Colors.white,
        //       statusBarColor: Colors.white,
        //       statusBarIconBrightness: Brightness.dark,
        //       statusBarBrightness: Brightness.dark,
        //     ));
        //   },
        // );
      },
      child: Consumer(
        builder: (context, watch, child) {
          final state = watch(themeStateNotifierProvider.state);
          return Portal(
            child: MaterialApp(
              builder: (context, child) => ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: child,
              ),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.when(
                darkMode: () => ThemeMode.dark,
                lightMode: () => ThemeMode.light,
              ),
              localizationsDelegates: [
                i18n,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              locale: Locale(widget.settings.language),
              supportedLocales: i18n.supportedLocales,
              localeResolutionCallback:
                  i18n.resolution(fallback: Locale("en", "US")),
              debugShowCheckedModeBanner: false,
              onGenerateRoute: AppRouter.router.generator,
              title: AppConstants.appName,
            ),
          );
        },
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
