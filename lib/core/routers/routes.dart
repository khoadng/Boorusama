// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../boorus/entry_page.dart';
import '../app_rating/app_rating.dart';
import '../applock/applock.dart';
import '../blacklists/blacklisted_tag_page.dart';
import '../bookmarks/routes.dart';
import '../boorus/engine/providers.dart';
import '../configs/redirect.dart';
import '../downloads/downloader.dart';
import '../images/original_image_page.dart';
import '../posts/details/details.dart';
import '../posts/post/post.dart';
import '../router.dart';
import '../tags/favorites/routes.dart';
import '../widgets/widgets.dart';

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

class Routes {
  static GoRoute home(Ref ref) => GoRoute(
        path: '/',
        builder: (context, state) => BooruConfigDeepLinkResolver(
          path: state.uri.toString(),
          child: const AppLockWithSettings(
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
        ),
        routes: [
          BoorusRoutes.update(ref),
          BoorusRoutes.add(ref),
          search(ref),
          postDetails(ref),
          favorites(ref),
          artists(ref),
          characters(ref),
          settings(),
          settingsDesktop(),
          bookmarkRoutes,
          globalBlacklistedTags(),
          downloadManager(),
          bulkDownloads(ref),
          favoriteTags(),
          originalImageViewer(),
        ],
      );

  static GoRoute postDetails(Ref ref) => GoRoute(
        path: 'details',
        pageBuilder: (context, state) {
          final booruBuilder = ref.read(currentBooruBuilderProvider);
          final builder = booruBuilder?.postDetailsPageBuilder;

          final payload = castOrNull<DetailsPayload>(state.extra);

          if (payload == null) {
            return MaterialPage(
              child: InvalidPage(message: 'Invalid payload: $payload'),
            );
          }

          // must use the value from the payload for orientation
          // Using MediaQuery.orientationOf(context) will cause the page to be rebuilt
          final page = !payload.isDesktop
              ? MaterialPage(
                  key: state.pageKey,
                  name: state.name,
                  child: builder != null
                      ? builder(context, payload)
                      : const UnimplementedPage(),
                )
              : builder != null
                  ? FastFadePage(
                      key: state.pageKey,
                      name: state.name,
                      child: builder(context, payload),
                    )
                  : MaterialPage(
                      key: state.pageKey,
                      name: state.name,
                      child: const UnimplementedPage(),
                    );

          return page;
        },
      );

  static GoRoute search(Ref ref) => GoRoute(
        path: 'search',
        name: '/search',
        pageBuilder: (context, state) {
          final booruBuilder = ref.read(currentBooruBuilderProvider);
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
          final booruBuilder = ref.read(currentBooruBuilderProvider);
          final builder = booruBuilder?.favoritesPageBuilder;

          return CupertinoPage(
            key: state.pageKey,
            name: state.name,
            child:
                builder != null ? builder(context) : const UnimplementedPage(),
          );
        },
      );

  static GoRoute artists(Ref ref) => GoRoute(
        path: 'artists',
        name: '/artists',
        pageBuilder: largeScreenAwarePageBuilder(
          builder: (context, state) {
            final booruBuilder = ref.read(currentBooruBuilderProvider);
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
        pageBuilder: largeScreenAwarePageBuilder(
          builder: (context, state) {
            final booruBuilder = ref.read(currentBooruBuilderProvider);
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

  static GoRoute globalBlacklistedTags() => GoRoute(
        path: 'global_blacklisted_tags',
        name: '/global_blacklisted_tags',
        pageBuilder: genericMobilePageBuilder(
          builder: (context, state) => const BlacklistedTagPage(),
        ),
      );
}
