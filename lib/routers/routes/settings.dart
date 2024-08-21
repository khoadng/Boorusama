// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/router.dart';
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
        builder: (context) => Container(
          margin: EdgeInsets.symmetric(
            vertical:
                context.screenWidth < 1100 ? 50 : context.screenWidth * 0.1,
            horizontal:
                context.screenHeight < 900 ? 50 : context.screenHeight * 0.2,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Dialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Material(
                color: Colors.transparent,
                child: SettingsPageDesktop(),
              ),
            ),
          ),
        ),
      ),
    );
