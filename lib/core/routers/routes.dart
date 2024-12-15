// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/entry_page.dart';
import '../app_rating/app_rating.dart';
import '../applock/applock.dart';
import '../blacklists/routes.dart';
import '../bookmarks/routes.dart';
import '../boorus/engine/providers.dart';
import '../configs/redirect.dart';
import '../configs/routes.dart';
import '../downloads/downloader.dart';
import '../downloads/routes/routes.dart';
import '../posts/details/routes.dart';
import '../posts/favorites/routes.dart';
import '../posts/post/routes.dart';
import '../router.dart';
import '../search/search/routes.dart';
import '../settings/routes.dart';
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
          addBooruConfigRoutes(ref),
          updateBooruConfigRoutes(ref),
          searchRoutes(ref),
          postDetailsRoutes(ref),
          postFavoritesRoutes(ref),
          artists(ref),
          characters(ref),
          settingsRoutes,
          settingsDesktopRoutes,
          bookmarkRoutes,
          globalBlacklistedTagsRoutes,
          downloadManagerRoutes,
          bulkDownloadsRoutes(ref),
          favoriteTags(),
          originalImageRoutes,
        ],
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
}
