// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/biometrics/app_lock.dart';
import 'package:boorusama/foundation/rating/rating.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'routes/configs.dart';
import 'routes/downloads.dart';
import 'routes/settings.dart';
import 'widgets/failsafe_page.dart';

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

const kInitialQueryKey = 'query';
const kArtistNameKey = 'name';
const kCharacterNameKey = 'name';

const kBulkdownload = 'bulk_download';

typedef DetailsPayload<T extends Post> = ({
  int initialIndex,
  List<T> posts,
  AutoScrollController? scrollController,
  bool isDesktop,
});

class Routes {
  static GoRoute home(Ref ref) => GoRoute(
        path: '/',
        builder: (context, state) => const AppLockWithSettings(
          child: RateMyAppScope(
            child: BackgroundDownloaderBuilder(
              child: CustomContextMenuOverlay(
                child: Focus(
                  autofocus: true,
                  child: EntryPage(),
                ),
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
          downloadManager(),
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

          final payload = castOrNull<DetailsPayload>(state.extra);

          if (payload == null) {
            return MaterialPage(
              child: InvalidPage(message: 'Invalid payload: $payload'),
            );
          }

          if (!payload.isDesktop) {
            return MaterialPage(
              key: state.pageKey,
              name: state.name,
              child: builder != null
                  ? builder(context, config, payload)
                  : const UnimplementedPage(),
            );
          } else {
            return builder != null
                ? FastFadePage(
                    key: state.pageKey,
                    name: state.name,
                    child: builder(context, config, payload),
                  )
                : MaterialPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const UnimplementedPage(),
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
                : const UnimplementedPage(),
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
                : const UnimplementedPage(),
          );
        },
      );

  static GoRoute artists(Ref ref) => GoRoute(
        path: 'artists',
        name: '/artists',
        pageBuilder: platformAwarePageBuilder(
          builder: (context, state) {
            final booruBuilder = ref.readCurrentBooruBuilder();
            final builder = booruBuilder?.artistPageBuilder;
            final artistName = state.uri.queryParameters[kArtistNameKey];

            return builder != null
                ? artistName != null
                    ? builder(context, artistName)
                    : const InvalidPage(message: 'Invalid artist name')
                : const UnimplementedPage();
          },
        ),
      );

  static GoRoute characters(Ref ref) => GoRoute(
        path: 'characters',
        name: '/characters',
        pageBuilder: platformAwarePageBuilder(
          builder: (context, state) {
            final booruBuilder = ref.readCurrentBooruBuilder();
            final builder = booruBuilder?.characterPageBuilder;
            final characterName = state.uri.queryParameters[kCharacterNameKey];

            return builder != null
                ? characterName != null
                    ? builder(context, characterName)
                    : const InvalidPage(message: 'Invalid character name')
                : const UnimplementedPage();
          },
        ),
      );

  static GoRoute bookmarks() => GoRoute(
        path: 'bookmarks',
        name: '/bookmarks',
        pageBuilder: genericMobilePageBuilder(
          builder: (context, state) => const BookmarkPage(),
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
              child: InvalidPage(message: 'Invalid post'),
            );
          }

          return CustomTransitionPage(
            key: state.pageKey,
            name: state.name,
            transitionsBuilder: fadeTransitionBuilder(),
            child: OriginalImagePage.post(post),
          );
        },
      );

  static GoRoute favoriteTags() => GoRoute(
        path: 'favorite_tags',
        name: '/favorite_tags',
        pageBuilder: genericMobilePageBuilder(
          builder: (context, state) => const FavoriteTagsPage(),
        ),
      );

  static GoRoute globalBlacklistedTags() => GoRoute(
        path: 'global_blacklisted_tags',
        name: '/global_blacklisted_tags',
        pageBuilder: genericMobilePageBuilder(
          builder: (context, state) => const BlacklistedTagPage(),
        ),
      );
}
