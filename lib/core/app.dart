// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../foundation/info/app_info.dart';
import '../foundation/networking.dart';
import '../foundation/platform.dart';
import '../foundation/scrolling.dart';
import 'analytics/widgets.dart';
import 'backups/auto/trigger.dart';
import 'router.dart';
import 'settings/providers.dart';
import 'themes/theme/types.dart';
import 'themes/theme/widgets.dart';
import 'widgets/widgets.dart';
import 'window/widgets.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const OKToast(
      child: AnalyticsScope(
        child: AutoBackupAppLifecycle(
          child: NetworkListener(
            child: _App(),
          ),
        ),
      ),
    );
  }
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appInfo = ref.watch(appInfoProvider);
    final reduceAnimations = ref.watch(
      settingsProvider.select((value) => value.reduceAnimations),
    );

    return ThemeBuilder(
      builder: (theme, themeMode) => MaterialApp.router(
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
              weight: isWindows() ? 200 : 400,
            ),
          ),
          child: AnnotatedRegion(
            // Needed to make the bottom navigation bar transparent
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              statusBarBrightness: theme.brightness,
              statusBarIconBrightness: context.onBrightness,
            ),
            child: AppTitleBar(
              child: Column(
                children: [
                  const NetworkUnavailableIndicatorWithState(),
                  Expanded(
                    child: NetworkUnavailableRemovePadding(
                      child: child!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        scrollBehavior: reduceAnimations ? const NoOverscrollBehavior() : null,
        theme: theme,
        themeMode: themeMode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        title: appInfo.appName,
        routerConfig: router,
      ),
    );
  }
}
