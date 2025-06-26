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
import '../bulk_downloads/routes.dart';
import '../configs/config/routes.dart';
import '../configs/create/routes.dart';
import '../configs/ref.dart';
import '../donate/routes.dart';
import '../downloads/downloader.dart';
import '../downloads/routes/routes.dart';
import '../posts/details/routes.dart';
import '../posts/details_manager/routes.dart';
import '../posts/favorites/routes.dart';
import '../posts/post/routes.dart';
import '../premiums/routes.dart';
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

class Routes {
  static GoRoute home(Ref ref) => GoRoute(
        path: '/',
        builder: (context, state) => BooruConfigDeepLinkResolver(
          path: state.uri.toString(),
          child: const AppLockWithSettings(
            child: AppRatingScope(
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
          singlePostDetailsRoutes(ref),
          postFavoritesRoutes(ref),
          artists(ref),
          characters(ref),
          settingsRoutes,
          settingsDesktopRoutes,
          bookmarkRoutes,
          globalBlacklistedTagsRoutes,
          downloadManagerRoutes,
          bulkDownloadsRoutes,
          favoriteTags(),
          originalImageRoutes,
          premiumRoutes(ref),
          donationRoutes(ref),
          detailsManagerRoutes,
        ],
      );

  static GoRoute artists(Ref ref) => GoRoute(
        path: 'artists',
        name: '/artists',
        pageBuilder: largeScreenAwarePageBuilder(
          builder: (context, state) {
            return InheritedArtistName(
              artistName: state.uri.queryParameters[kArtistNameKey],
              child: const ArtistPage(),
            );
          },
        ),
      );

  static GoRoute characters(Ref ref) => GoRoute(
        path: 'characters',
        name: '/characters',
        pageBuilder: largeScreenAwarePageBuilder(
          builder: (context, state) {
            return InheritedCharacterName(
              characterName: state.uri.queryParameters[kCharacterNameKey],
              child: const CharacterPage(),
            );
          },
        ),
      );
}

class ArtistPage extends ConsumerWidget {
  const ArtistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final builder = booruBuilder?.artistPageBuilder;
    final artistName = InheritedArtistName.of(context)?.artistName;

    return builder != null
        ? artistName != null
            ? builder(context, artistName)
            : const InvalidPage(message: 'Invalid artist name')
        : const UnimplementedPage();
  }
}

class InheritedArtistName extends InheritedWidget {
  const InheritedArtistName({
    required this.artistName,
    required super.child,
    super.key,
  });

  final String? artistName;

  static InheritedArtistName? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedArtistName>();
  }

  @override
  bool updateShouldNotify(InheritedArtistName oldWidget) {
    return artistName != oldWidget.artistName;
  }
}

class CharacterPage extends ConsumerWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final builder = booruBuilder?.characterPageBuilder;
    final characterName = InheritedCharacterName.of(context)?.characterName;

    return builder != null
        ? characterName != null
            ? builder(context, characterName)
            : const InvalidPage(message: 'Invalid character name')
        : const UnimplementedPage();
  }
}

class InheritedCharacterName extends InheritedWidget {
  const InheritedCharacterName({
    required this.characterName,
    required super.child,
    super.key,
  });

  final String? characterName;

  static InheritedCharacterName? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedCharacterName>();
  }

  @override
  bool updateShouldNotify(InheritedCharacterName oldWidget) {
    return characterName != oldWidget.characterName;
  }
}
