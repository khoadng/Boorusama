// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_portal/flutter_portal.dart';

// Project imports:
import 'app_constants.dart';
import 'boorus/danbooru/router.dart';
import 'core/app_theme.dart';

class App extends StatefulWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    AppRouter().setupRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: MaterialApp(
        builder: (context, child) => ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: child!,
        ),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.router.generator,
        title: AppConstants.appName,
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
