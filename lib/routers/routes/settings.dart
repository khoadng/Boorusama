// Project imports:
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../widgets/dialog_page.dart';

GoRoute settings() => GoRoute(
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

GoRoute settingsDesktop() => GoRoute(
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
