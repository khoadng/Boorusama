// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/core/pages/favorite_tags/favorite_tags_page.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/biometrics/app_lock.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'boorus/entry_page.dart';
import 'core/configs/create/add_booru_page.dart';
import 'core/pages/bookmarks/bookmark_details_page.dart';
import 'core/pages/bookmarks/bookmark_page.dart';
import 'core/pages/settings/image_viewer_page.dart';
import 'core/pages/settings/settings.dart';
import 'foundation/rating/rating.dart';
import 'router.dart';

///
/// When navigate to a page, must query the booru builders first to get the correct builder.
/// There is case when you want navigate to a different boorus than the current one.
///
///```
/// final config = ref.read(currentBooruConfigProvider);
/// final booruBuilderFunc =
///     ref.read(booruBuildersProvider)[config.booruType];
/// final booruBuilder =
///     booruBuilderFunc != null ? booruBuilderFunc(config) : null;
///
/// // Or you can use this
/// final booruBuilder = ref.readBooruBuilder(config);
///```
///

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

  static GoRoute addDesktop() => GoRoute(
      path: 'desktop/boorus/add',
      pageBuilder: (context, state) => DialogPage(
            key: state.pageKey,
            name: state.name,
            builder: (context) => const BooruDialog(
              child: AddBooruPage(
                setCurrentBooruOnSubmit: false,
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
              ?.firstWhere((element) => element.id == id);

          if (config == null) {
            return const CupertinoPage(
              child: Scaffold(
                body: Center(
                  child: Text('Booru not found or not loaded yet'),
                ),
              ),
            );
          }

          final booruBuilder = ref.readBooruBuilder(config);

          return CupertinoPage(
            key: state.pageKey,
            child: booruBuilder?.updateConfigPageBuilder(
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
              ?.firstWhere((element) => element.id == id);

          if (config == null) {
            return DialogPage(
              builder: (context) => const BooruDialog(
                child: Scaffold(
                  body: Center(
                    child: Text('Booru not found or not loaded yet'),
                  ),
                ),
              ),
            );
          }

          final booruBuilder = ref.readBooruBuilder(config);

          return DialogPage(
            key: state.pageKey,
            name: state.name,
            builder: (context) => BooruDialog(
              padding: const EdgeInsets.all(16),
              child: booruBuilder?.updateConfigPageBuilder(
                    context,
                    config,
                  ) ??
                  Scaffold(
                    appBar: AppBar(),
                    body: const Center(
                      child: Text('Not implemented'),
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
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const AppearancePage(),
        ),
      );

  static GoRoute download() => GoRoute(
        path: 'download',
        name: '/settings/download',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const DownloadPage(),
        ),
      );

  static GoRoute language() => GoRoute(
        path: 'language',
        name: '/settings/language',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const LanguagePage(),
        ),
      );

  static GoRoute performance() => GoRoute(
        path: 'performance',
        name: '/settings/performance',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const PerformancePage(),
        ),
      );

  static GoRoute dataAndStorage() => GoRoute(
        path: 'data_and_storage',
        name: '/settings/data_and_storage',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const DataAndStoragePage(),
        ),
      );

  static GoRoute backupAndRestore() => GoRoute(
        path: 'backup_and_restore',
        name: '/settings/backup_and_restore',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const BackupAndRestorePage(),
        ),
      );

  static GoRoute privacy() => GoRoute(
        path: 'privacy',
        name: '/settings/privacy',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const PrivacyPage(),
        ),
      );

  static GoRoute accessibility() => GoRoute(
        path: 'accessibility',
        name: '/settings/accessibility',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const AccessibilityPage(),
        ),
      );

  static GoRoute imageViewer() => GoRoute(
        path: 'image_viewer',
        name: '/settings/image_viewer',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const ImageViewerPage(),
        ),
      );

  static GoRoute search() => GoRoute(
        path: 'search',
        name: '/settings/search',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const SearchSettingsPage(),
        ),
      );

  static GoRoute changelog() => GoRoute(
        path: 'changelog',
        name: '/settings/changelog',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const ChangelogPage(),
        ),
      );
}

const kInitialQueryKey = 'query';
const kArtistNameKey = 'name';
const kCharacterNameKey = 'name';

typedef DetailsPayload<T extends Post> = ({
  int initialIndex,
  List<T> posts,
  AutoScrollController? scrollController,
  bool isDesktop,
});

class Routes {
  static GoRoute home(Ref ref) => GoRoute(
        path: '/',
        builder: (context, state) => AppLock(
          enable: ref.read(settingsProvider).appLockEnabled,
          child: ConditionalParentWidget(
            condition: canRate(),
            conditionalBuilder: (child) => createAppRatingWidget(child: child),
            child: const CustomContextMenuOverlay(
              child: Focus(
                autofocus: true,
                child: EntryPage(),
              ),
            ),
          ),
        ),
        routes: [
          BoorusRoutes.update(ref),
          BoorusRoutes.updateDesktop(ref),
          BoorusRoutes.add(ref),
          BoorusRoutes.addDesktop(),
          search(ref),
          postDetails(ref),
          favorites(ref),
          artists(ref),
          characters(ref),
          settings(),
          settingsDesktop(),
          bookmarks(),
          globalBlacklistedTags(),
          bulkDownloads(ref),
          favoriteTags(),
          originalImageViewer(),
        ],
      );

  static GoRoute postDetails(Ref ref) => GoRoute(
        path: 'details',
        name: '/details',
        pageBuilder: (context, state) {
          final config = ref.read(currentBooruConfigProvider);
          final booruBuilder = ref.readBooruBuilder(config);
          final builder = booruBuilder?.postDetailsPageBuilder;

          final payload = state.extra as DetailsPayload;

          if (!payload.isDesktop) {
            return MaterialPage(
              key: state.pageKey,
              name: state.name,
              child: builder != null
                  ? builder(context, config, payload)
                  : const Scaffold(
                      body: Center(child: Text('Not implemented'))),
            );
          } else {
            return builder != null
                ? CustomTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: builder(context, config, payload),
                    transitionsBuilder: fadeTransitionBuilder(),
                  )
                : MaterialPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const Scaffold(
                      body: Center(child: Text('Not implemented')),
                    ),
                  );
          }
        },
      );

  static GoRoute search(Ref ref) => GoRoute(
        path: 'search',
        name: '/search',
        pageBuilder: (context, state) {
          final booruBuilder = ref.readCurrentBooruBuilder();
          final builder = booruBuilder?.searchPageBuilder;
          final query = state.uri.queryParameters[kInitialQueryKey];

          return CustomTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: builder != null
                ? builder(context, query)
                : const Scaffold(body: Center(child: Text('Not implemented'))),
            transitionsBuilder: fadeTransitionBuilder(),
          );
        },
      );

  static GoRoute favorites(Ref ref) => GoRoute(
        path: 'favorites',
        name: '/favorites',
        pageBuilder: (context, state) {
          final config = ref.read(currentBooruConfigProvider);
          final booruBuilder = ref.readBooruBuilder(config);
          final builder = booruBuilder?.favoritesPageBuilder;

          return CupertinoPage(
            key: state.pageKey,
            name: state.name,
            child: builder != null
                ? builder(context, config)
                : const Scaffold(body: Center(child: Text('Not implemented'))),
          );
        },
      );

  static GoRoute artists(Ref ref) => GoRoute(
        path: 'artists',
        name: '/artists',
        pageBuilder: (context, state) {
          final booruBuilder = ref.readCurrentBooruBuilder();
          final builder = booruBuilder?.artistPageBuilder;
          final artistName = state.uri.queryParameters[kArtistNameKey];

          return createPage(
            key: state.pageKey,
            name: state.name,
            child: builder != null
                ? artistName != null
                    ? builder(context, artistName)
                    : const Scaffold(
                        body: Center(child: Text('Invalid artist name')))
                : const Scaffold(body: Center(child: Text('Not implemented'))),
          );
        },
      );

  static GoRoute characters(Ref ref) => GoRoute(
        path: 'characters',
        name: '/characters',
        pageBuilder: (context, state) {
          final booruBuilder = ref.readCurrentBooruBuilder();
          final builder = booruBuilder?.characterPageBuilder;
          final characterName = state.uri.queryParameters[kCharacterNameKey];

          return createPage(
            key: state.pageKey,
            name: state.name,
            child: builder != null
                ? characterName != null
                    ? builder(context, characterName)
                    : const Scaffold(
                        body: Center(child: Text('Invalid character name')))
                : const Scaffold(body: Center(child: Text('Not implemented'))),
          );
        },
      );

  static GoRoute bookmarks() => GoRoute(
        path: 'bookmarks',
        name: '/bookmarks',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const BookmarkPage(),
        ),
        routes: [
          GoRoute(
            path: 'details',
            name: '/bookmarks/details',
            pageBuilder: (context, state) => CupertinoPage(
              key: state.pageKey,
              name: '${state.name}?index=${state.uri.queryParameters['index']}',
              child: BookmarkDetailsPage(
                initialIndex: state.uri.queryParameters['index']?.toInt() ?? 0,
              ),
            ),
          ),
        ],
      );

  static GoRoute originalImageViewer() => GoRoute(
        path: 'original_image_viewer',
        name: '/original_image_viewer',
        pageBuilder: (context, state) {
          final post = state.extra as Post?;

          if (post == null) {
            return const CupertinoPage(
              child: Scaffold(
                body: Center(
                  child: Text('Invalid post'),
                ),
              ),
            );
          }

          return CustomTransitionPage(
            key: state.pageKey,
            name: state.name,
            transitionsBuilder: fadeTransitionBuilder(),
            child: OriginalImagePage(
              initialOrientation: MediaQuery.orientationOf(context),
              post: post,
            ),
          );
        },
      );

  static GoRoute favoriteTags() => GoRoute(
        path: 'favorite_tags',
        name: '/favorite_tags',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const FavoriteTagsPage(),
        ),
      );

  static GoRoute globalBlacklistedTags() => GoRoute(
        path: 'global_blacklisted_tags',
        name: '/global_blacklisted_tags',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name,
          child: const BlacklistedTagPage(),
        ),
      );

  static GoRoute bulkDownloads(Ref ref) => GoRoute(
        path: 'bulk_downloads',
        name: '/bulk_downloads',
        pageBuilder: (context, state) {
          return CupertinoPage(
            key: state.pageKey,
            name: state.name,
            child: ref.read(currentBooruConfigProvider).booruType ==
                    BooruType.zerochan
                ? Scaffold(
                    appBar: AppBar(
                      title: const Text('Bulk Download'),
                    ),
                    body: const Center(
                      child: Text(
                          'Temporarily disabled due to an issue with getting the download link'),
                    ),
                  )
                : const BulkDownloadPage(),
          );
        },
      );

  static GoRoute settings() => GoRoute(
        path: 'settings',
        name: '/settings',
        redirect: (context, state) =>
            !isMobilePlatform() ? '/desktop/settings' : null,
        pageBuilder: (context, state) => CupertinoPage(
            key: state.pageKey,
            name: state.name,
            child: SettingsPage(
              scrollTo: state.uri.queryParameters['scrollTo'],
            )),
        routes: [
          SettingsRoutes.appearance(),
          SettingsRoutes.download(),
          SettingsRoutes.language(),
          SettingsRoutes.performance(),
          SettingsRoutes.dataAndStorage(),
          SettingsRoutes.backupAndRestore(),
          SettingsRoutes.privacy(),
          SettingsRoutes.search(),
          SettingsRoutes.changelog(),
          SettingsRoutes.accessibility(),
          SettingsRoutes.imageViewer(),
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
                    vertical: context.screenWidth < 1100
                        ? 50
                        : context.screenWidth * 0.1,
                    horizontal: context.screenHeight < 900
                        ? 50
                        : context.screenHeight * 0.2,
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

Page<T> createPage<T>({
  required Widget child,
  String? name,
  LocalKey? key,
}) =>
    isMobilePlatform()
        ? CupertinoPage<T>(
            key: key,
            name: name,
            child: child,
          )
        : MaterialPage<T>(
            key: key,
            name: name,
            child: child,
          );
