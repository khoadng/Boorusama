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
      routes: [
        GoRoute(
          path: 'appearance',
          name: '/settings/appearance',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const AppearancePage(),
          ),
        ),
        GoRoute(
          path: 'download',
          name: '/settings/download',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const DownloadPage(),
          ),
        ),
        GoRoute(
          path: 'language',
          name: '/settings/language',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const LanguagePage(),
          ),
        ),
        GoRoute(
          path: 'performance',
          name: '/settings/performance',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const PerformancePage(),
          ),
        ),
        GoRoute(
          path: 'data_and_storage',
          name: '/settings/data_and_storage',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const DataAndStoragePage(),
          ),
        ),
        GoRoute(
          path: 'backup_and_restore',
          name: '/settings/backup_and_restore',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const BackupAndRestorePage(),
          ),
        ),
        GoRoute(
          path: 'privacy',
          name: '/settings/privacy',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const PrivacyPage(),
          ),
        ),
        GoRoute(
          path: 'accessibility',
          name: '/settings/accessibility',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const AccessibilityPage(),
          ),
        ),
        GoRoute(
          path: 'image_viewer',
          name: '/settings/image_viewer',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const ImageViewerPage(),
          ),
        ),
        GoRoute(
          path: 'search',
          name: '/settings/search',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const SearchSettingsPage(),
          ),
        ),
        GoRoute(
          path: 'changelog',
          name: '/settings/changelog',
          pageBuilder: genericMobilePageBuilder(
            builder: (context, state) => const ChangelogPage(),
          ),
        ),
      ],
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
          child: SettingsPageDesktop(),
        ),
      ),
    );
