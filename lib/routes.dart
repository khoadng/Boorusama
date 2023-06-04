// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/config_booru_page.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/utils/string_utils.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'boorus/core/pages/bookmarks/bookmark_details.dart';
import 'boorus/core/pages/bookmarks/bookmark_page.dart';
import 'boorus/core/pages/boorus/add_booru_page.dart';
import 'boorus/core/pages/boorus/manage_booru_user_page.dart';
import 'boorus/core/pages/settings/appearance_page.dart';
import 'boorus/core/pages/settings/changelog_page.dart';
import 'boorus/core/pages/settings/download_page.dart';
import 'boorus/core/pages/settings/language_page.dart';
import 'boorus/core/pages/settings/performance_page.dart';
import 'boorus/core/pages/settings/privacy_page.dart';
import 'boorus/core/pages/settings/search_settings_page.dart';
import 'boorus/core/pages/settings/settings_page.dart';
import 'boorus/core/pages/settings/settings_page_desktop.dart';
import 'boorus/danbooru/router.dart';
import 'boorus/home_page.dart';
import 'foundation/rating/rating.dart';
import 'router.dart';

class BoorusRoutes {
  BoorusRoutes._();

  static GoRoute add() => GoRoute(
        path: 'add',
        name: '/boorus/add',
        builder: (context, state) => AddBooruPage(
          setCurrentBooruOnSubmit:
              state.queryParameters["setAsCurrent"]?.toBool() ?? false,
        ),
      );

  static GoRoute update(Ref ref) => GoRoute(
        path: ':id/update',
        pageBuilder: (context, state) {
          final idParam = state.pathParameters['id'];
          final id = idParam?.toInt();
          final config = ref
              .read(booruConfigProvider)
              .firstWhere((element) => element.id == id);

          return MaterialPage(
            key: state.pageKey,
            name: '/boorus/$idParam/update',
            child: ConfigBooruPage(
              arg: UpdateConfig(config),
            ),
          );
        },
      );
}

class SettingsRoutes {
  SettingsRoutes._();

  static GoRoute appearance() => GoRoute(
        path: 'appearance',
        name: '/settings/appearance',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const AppearancePage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute download() => GoRoute(
        path: 'download',
        name: '/settings/download',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const DownloadPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute language() => GoRoute(
        path: 'language',
        name: '/settings/language',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const LanguagePage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute performance() => GoRoute(
        path: 'performance',
        name: '/settings/performance',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const PerformancePage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute privacy() => GoRoute(
        path: 'privacy',
        name: '/settings/privacy',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const PrivacyPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute search() => GoRoute(
        path: 'search',
        name: '/settings/search',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const SearchSettingsPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute changelog() => GoRoute(
        path: 'changelog',
        name: '/settings/changelog',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
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
          boorus(ref),
          settings(),
          bookmarks(),
        ],
      );

  static GoRoute boorus(Ref ref) => GoRoute(
        path: 'boorus',
        name: '/boorus',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const ManageBooruPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
        routes: [
          BoorusRoutes.add(),
          BoorusRoutes.update(ref),
        ],
      );

  static GoRoute bookmarks() => GoRoute(
        path: 'bookmarks',
        name: '/bookmarks',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const BookmarkPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
        routes: [
          GoRoute(
            path: 'details',
            name: '/bookmarks/details',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              name: '${state.name}?index=${state.queryParameters['index']}',
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
        name: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
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
