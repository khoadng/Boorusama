import 'package:boorusama/app.dart';
import 'package:boorusama/app_constants.dart';
import 'package:boorusama/core/app_theme.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class StubMaterialApp extends StatelessWidget {
  const StubMaterialApp({
    Key key,
    @required this.child,
  }) : super(key: key);

  final i18n = I18n.delegate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: child,
      ),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      localizationsDelegates: [
        i18n,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: i18n.supportedLocales,
      localeResolutionCallback: i18n.resolution(fallback: Locale("en", "US")),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.router.generator,
      title: AppConstants.appName,
      home: child,
    );
  }
}
