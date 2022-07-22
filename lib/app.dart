// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/widgets/conditional_parent_widget.dart';
import 'app_constants.dart';
import 'boorus/danbooru/router.dart';

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
            onGenerateRoute: AppRouter.router.generator,
            title: AppConstants.appName,
          );
        },
      ),
    );
  }
}

class AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) =>
      child;
}

final buttonColors = WindowButtonColors(
  iconNormal: const Color.fromARGB(255, 114, 137, 217),
  mouseOver: const Color(0xFFF6A00C),
  mouseDown: const Color(0xFF805306),
  iconMouseOver: const Color(0xFF805306),
  iconMouseDown: const Color(0xFFFFD500),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: const Color.fromARGB(255, 114, 137, 217),
  iconMouseOver: Colors.white,
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
