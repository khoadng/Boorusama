// Project imports:
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../widgets/dialog_page.dart';

GoRoute settings() => GoRoute(
      path: 'settings',
      name: '/settings',
      redirect: (context, state) =>
          !kPreferredLayout.isMobile ? '/desktop/settings' : null,
      pageBuilder: genericMobilePageBuilder(
        builder: (context, state) => SettingsPage(
          scrollTo: state.uri.queryParameters['scrollTo'],
        ),
      ),
    );

GoRoute settingsDesktop() => GoRoute(
      path: 'desktop/settings',
      name: '/desktop/settings',
      pageBuilder: (context, state) => DialogPage(
        key: state.pageKey,
        name: state.name,
        builder: (context) => const BooruDialog(
          width: 800,
          height: 600,
          child: SettingsPage(),
        ),
      ),
    );
