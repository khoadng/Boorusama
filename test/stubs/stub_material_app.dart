// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/app_constants.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/app_theme.dart';

class StubMaterialApp extends StatelessWidget {
  const StubMaterialApp({
    Key key,
    @required this.child,
  }) : super(key: key);

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
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.router.generator,
      title: AppConstants.appName,
      home: child,
    );
  }
}
