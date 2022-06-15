// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';

// Project imports:
import 'app_constants.dart';
import 'boorus/danbooru/application/theme/theme_bloc.dart';
import 'boorus/danbooru/router.dart';
import 'core/app_theme.dart';

class App extends StatefulWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  State<App> createState() => _AppState();
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
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            builder: (context, child) => ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: child!,
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
            onGenerateRoute: AppRouter.router.generator,
            title: AppConstants.appName,
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
