import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_constants.dart';
import 'generated/i18n.dart';
import 'core/app_theme.dart';
import 'boorus/danbooru/application/download/download_service.dart';
import 'boorus/danbooru/application/themes/theme_state_notifier.dart';
import 'boorus/danbooru/infrastructure/repositories/settings/setting.dart';
import 'boorus/danbooru/router.dart';

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
        Duration.zero,
        () => context
            .read(downloadServiceProvider)
            .init(Theme.of(context).platform));

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
        state.when(
          darkMode: () async {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.grey[900],
              statusBarColor: Colors.grey[900],
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
            ));
          },
          lightMode: () async {
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ));
          },
        );
      },
      child: Consumer(
        builder: (context, watch, child) {
          final state = watch(themeStateNotifierProvider.state);
          return MaterialApp(
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
          );
        },
      ),
    );
  }
}
