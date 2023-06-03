// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/utils/string_utils.dart';
import 'boorus/danbooru/router.dart';
import 'core/application/app_rating.dart';
import 'core/platform.dart';
import 'core/ui/bookmarks/bookmark_details.dart';
import 'core/ui/bookmarks/bookmark_page.dart';
import 'core/ui/custom_context_menu_overlay.dart';
import 'core/ui/route_transition_builder.dart';
import 'core/ui/settings/appearance_page.dart';
import 'core/ui/settings/changelog_page.dart';
import 'core/ui/settings/download_page.dart';
import 'core/ui/settings/language_page.dart';
import 'core/ui/settings/performance_page.dart';
import 'core/ui/settings/privacy_page.dart';
import 'core/ui/settings/search_settings_page.dart';
import 'core/ui/settings/settings_page.dart';
import 'core/ui/settings/settings_page_desktop.dart';
import 'core/ui/widgets/conditional_parent_widget.dart';
import 'home_page.dart';
import 'router.dart';

class SettingsRoutes {
  static GoRoute appearance() => GoRoute(
        path: 'appearance',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AppearancePage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute download() => GoRoute(
        path: 'download',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DownloadPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute language() => GoRoute(
        path: 'language',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LanguagePage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute performance() => GoRoute(
        path: 'performance',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PerformancePage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute privacy() => GoRoute(
        path: 'privacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PrivacyPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute search() => GoRoute(
        path: 'search',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SearchSettingsPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute changelog() => GoRoute(
        path: 'changelog',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChangelogPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );
}

class Routes {
  static GoRoute home(Ref ref) => GoRoute(
        path: '/',
        builder: (context, state) => ConditionalParentWidget(
          condition: canRate(),
          conditionalBuilder: (child) => createAppRatingWidget(child: child),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(
                LogicalKeyboardKey.keyF,
                control: true,
              ): () => goToSearchPage(context),
            },
            child: const CustomContextMenuOverlay(
              child: Focus(
                autofocus: true,
                child: HomePage(),
              ),
            ),
          ),
        ),
        routes: [
          settings(),
          bookmarks(),
        ],
      );

  static GoRoute bookmarks() => GoRoute(
        path: 'bookmarks',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const BookmarkPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
        routes: [
          GoRoute(
            path: 'details',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: BookmarkDetailsPage(
                initialIndex: state.queryParameters['index']?.toInt() ?? 0,
              ),
              transitionsBuilder: leftToRightTransitionBuilder(),
            ),
          ),
        ],
      );

  static GoRoute settings() => GoRoute(
        path: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: isMobilePlatform()
              ? const SettingsPage()
              : const SettingsPageDesktop(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
        routes: [
          SettingsRoutes.appearance(),
          SettingsRoutes.download(),
          SettingsRoutes.language(),
          SettingsRoutes.performance(),
          SettingsRoutes.privacy(),
          SettingsRoutes.search(),
          SettingsRoutes.changelog(),
        ],
      );
}
