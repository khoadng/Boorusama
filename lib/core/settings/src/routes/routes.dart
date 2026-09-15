// Package imports:
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../router.dart';
import '../pages/settings_page.dart';
import 'settings_adaptive_page.dart';

final settingsRoutes = GoRoute(
  path: 'settings',
  name: '/settings',
  redirect: (context, state) => !kPreferredLayout.isMobile
      ? Uri(
          path: '/desktop/settings',
          query: state.uri.query,
        ).toString()
      : null,
  pageBuilder: (context, state) {
    final reduceAnimations =
        MediaQuery.disableAnimationsOf(context) ||
        (KurumiTheme.maybeBehaviorOf(context)?.reduceMotion ?? false);
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final animate = !wide && !reduceAnimations;

    return SettingsAdaptivePage<void>(
      key: state.pageKey,
      name: state.name,
      animate: animate,
      child: SettingsPage(
        scrollTo: state.uri.queryParameters['scrollTo'],
        initial: state.uri.queryParameters['initial'],
      ),
    );
  },
);

final settingsDesktopRoutes = GoRoute(
  path: 'desktop/settings',
  name: '/desktop/settings',
  pageBuilder: (context, state) => DialogPage(
    key: state.pageKey,
    name: state.name,
    animationStyle: AnimationStyle.noAnimation,
    builder: (context) => KurumiDialog(
      width: 800,
      height: 600,
      child: SettingsPage(
        initial: state.uri.queryParameters['initial'],
        scrollTo: state.uri.queryParameters['scrollTo'],
      ),
    ),
  ),
);
