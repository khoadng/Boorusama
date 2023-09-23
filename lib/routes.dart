// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/boorus/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/booru_dialog.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'boorus/core/pages/bookmarks/bookmark_details.dart';
import 'boorus/core/pages/bookmarks/bookmark_page.dart';
import 'boorus/core/pages/boorus/add_booru_page.dart';
import 'boorus/core/pages/settings/appearance_page.dart';
import 'boorus/core/pages/settings/changelog_page.dart';
import 'boorus/core/pages/settings/download_page.dart';
import 'boorus/core/pages/settings/language_page.dart';
import 'boorus/core/pages/settings/performance_page.dart';
import 'boorus/core/pages/settings/privacy_page.dart';
import 'boorus/core/pages/settings/search_settings_page.dart';
import 'boorus/core/pages/settings/settings_page.dart';
import 'boorus/core/pages/settings/settings_page_desktop.dart';
import 'boorus/home_page.dart';
import 'foundation/rating/rating.dart';
import 'router.dart';

class BoorusRoutes {
  BoorusRoutes._();

  static GoRoute add(Ref ref) => GoRoute(
        path: 'boorus/add',
        redirect: (context, state) =>
            isMobilePlatform() ? null : '/desktop/boorus/add',
        builder: (context, state) => AddBooruPage(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          setCurrentBooruOnSubmit:
              state.uri.queryParameters["setAsCurrent"]?.toBool() ?? false,
        ),
      );

  //FIXME: create custom page builder, also can't tap outside to dismiss
  //FIXME: doesn't work on desktop with new implementation
  static GoRoute addDesktop() => GoRoute(
      path: 'desktop/boorus/add',
      pageBuilder: (context, state) => DialogPage(
            key: state.pageKey,
            name: state.name,
            builder: (context) => BooruDialog(
              padding: const EdgeInsets.all(16),
              color: context.theme.canvasColor,
              width: 400,
              child: IntrinsicHeight(
                child: AddBooruPage(
                  backgroundColor: context.theme.canvasColor,
                  setCurrentBooruOnSubmit: false,
                ),
              ),
            ),
          ));

  static GoRoute update(Ref ref) => GoRoute(
        path: 'boorus/:id/update',
        redirect: (context, state) => isMobilePlatform()
            ? null
            : '/desktop/boorus/${state.pathParameters['id']}/update',
        pageBuilder: (context, state) {
          final idParam = state.pathParameters['id'];
          final id = idParam?.toInt();
          final config = ref
              .read(booruConfigProvider)
              .firstWhere((element) => element.id == id);

          return MaterialPage(
            key: state.pageKey,
            child: booruBuilders[config.booruType]?.updateConfigPageBuilder(
                  context,
                  config,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                ) ??
                Scaffold(
                  appBar: AppBar(),
                  body: const Center(
                    child: Text('Not implemented'),
                  ),
                ),
          );
        },
      );

  static GoRoute updateDesktop(Ref ref) => GoRoute(
        path: 'desktop/boorus/:id/update',
        pageBuilder: (context, state) {
          final idParam = state.pathParameters['id'];
          final id = idParam?.toInt();
          final config = ref
              .read(booruConfigProvider)
              .firstWhere((element) => element.id == id);

          return DialogPage(
            key: state.pageKey,
            name: state.name,
            builder: (context) => BooruDialog(
              padding: const EdgeInsets.all(16),
              color: context.theme.canvasColor,
              width: 400,
              child: IntrinsicHeight(
                child: booruBuilders[config.booruType]?.updateConfigPageBuilder(
                      context,
                      config,
                      backgroundColor: context.theme.canvasColor,
                    ) ??
                    Scaffold(
                      appBar: AppBar(),
                      body: const Center(
                        child: Text('Not implemented'),
                      ),
                    ),
              ),
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
          child: const CustomContextMenuOverlay(
            child: Focus(
              autofocus: true,
              child: HomePage(),
            ),
          ),
        ),
        routes: [
          BoorusRoutes.update(ref),
          BoorusRoutes.updateDesktop(ref),
          BoorusRoutes.add(ref),
          BoorusRoutes.addDesktop(),
          settings(),
          settingsDesktop(),
          bookmarks(),
          globalBlacklistedTags(),
          bulkDownloads(ref),
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
              name: '${state.name}?index=${state.uri.queryParameters['index']}',
              child: BookmarkDetailsPage(
                initialIndex: state.uri.queryParameters['index']?.toInt() ?? 0,
              ),
              transitionsBuilder: leftToRightTransitionBuilder(),
            ),
          ),
        ],
      );

  static GoRoute globalBlacklistedTags() => GoRoute(
        path: 'global_blacklisted_tags',
        name: '/global_blacklisted_tags',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const BlacklistedTagPage(),
          transitionsBuilder: leftToRightTransitionBuilder(),
        ),
      );

  static GoRoute bulkDownloads(Ref ref) => GoRoute(
        path: 'bulk_downloads',
        name: '/bulk_downloads',
        pageBuilder: (context, state) {
          final booru = ref.read(currentBooruConfigProvider);

          return CustomTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: Builder(builder: (_) {
              switch (booru.booruType) {
                case BooruType.unknown:
                case BooruType.konachan:
                case BooruType.yandere:
                case BooruType.sakugabooru:
                case BooruType.lolibooru:
                case BooruType.e621:
                case BooruType.e926:
                case BooruType.danbooru:
                case BooruType.safebooru:
                case BooruType.testbooru:
                case BooruType.aibooru:
                case BooruType.gelbooru:
                case BooruType.rule34xxx:
                  return const BulkDownloadPage();
                case BooruType.zerochan:
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Bulk download'),
                    ),
                    body: const Center(
                      child: Text('Sorry, not supported yet :('),
                    ),
                  );
              }
            }),
            transitionsBuilder: leftToRightTransitionBuilder(),
          );
        },
      );

  static GoRoute settings() => GoRoute(
        path: 'settings',
        name: '/settings',
        redirect: (context, state) =>
            !isMobilePlatform() ? '/desktop/settings' : null,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          name: state.name,
          child: const SettingsPage(),
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

  static GoRoute settingsDesktop() => GoRoute(
        path: 'desktop/settings',
        name: '/desktop/settings',
        pageBuilder: (context, state) => DialogPage(
            key: state.pageKey,
            name: state.name,
            builder: (context) => Container(
                  margin: EdgeInsets.symmetric(
                    vertical: context.screenWidth * 0.05,
                    horizontal: context.screenHeight * 0.1,
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
                )),
      );
}
