// Project imports:
import '../../../../foundation/display.dart';
import '../../../router.dart';
import '../../../widgets/widgets.dart';
import '../pages/settings_page.dart';

final settingsRoutes = GoRoute(
  path: 'settings',
  name: '/settings',
  redirect: (context, state) => !kPreferredLayout.isMobile
      ? Uri(
          path: '/desktop/settings',
          query: state.uri.query,
        ).toString()
      : null,
  pageBuilder: largeScreenAwarePageBuilder(
    builder: (context, state) => SettingsPage(
      scrollTo: state.uri.queryParameters['scrollTo'],
      initial: state.uri.queryParameters['initial'],
    ),
  ),
);

final settingsDesktopRoutes = GoRoute(
  path: 'desktop/settings',
  name: '/desktop/settings',
  pageBuilder: (context, state) => DialogPage(
    key: state.pageKey,
    name: state.name,
    builder: (context) => BooruDialog(
      width: 800,
      height: 600,
      child: SettingsPage(
        initial: state.uri.queryParameters['initial'],
      ),
    ),
  ),
);
