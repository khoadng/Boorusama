// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/gelbooru_v1/gelbooru_v1.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/routes.dart';
import 'danbooru/feats/posts/posts.dart';
import 'philomena/philomena.dart';
import 'philomena/providers.dart';

typedef CreateConfigPageBuilder = Widget Function(
  BuildContext context,
  String url,
  BooruType booruType, {
  Color? backgroundColor,
});

typedef UpdateConfigPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config, {
  Color? backgroundColor,
});

typedef HomePageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

typedef SearchPageBuilder = Widget Function(
  BuildContext context,
  String? initialQuery,
);

typedef PostDetailsPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
  DetailsPayload payload,
);

typedef FavoritesPageBuilder = Widget Function(
  BuildContext context,
  BooruConfig config,
);

typedef ArtistPageBuilder = Widget Function(
  BuildContext context,
  String artistName,
);

typedef PostFetcher = PostsOrError Function(
  int page,
  List<String> tags,
);

typedef AutocompleteFetcher = Future<List<AutocompleteData>> Function(
  String query,
);

typedef FavoriteAdder = Future<bool> Function(int postId);
typedef FavoriteRemover = Future<bool> Function(int postId);
typedef FavoriteChecker = bool Function(int postId);

typedef PostCountFetcher = Future<int?> Function(List<String> tags);

abstract class BooruBuilder {
  // UI Builders
  HomePageBuilder get homePageBuilder;
  CreateConfigPageBuilder get createConfigPageBuilder;
  UpdateConfigPageBuilder get updateConfigPageBuilder;
  SearchPageBuilder get searchPageBuilder;
  PostDetailsPageBuilder get postDetailsPageBuilder;
  FavoritesPageBuilder? get favoritesPageBuilder;
  ArtistPageBuilder? get artistPageBuilder;

  // Data Builders
  PostFetcher get postFetcher;
  AutocompleteFetcher get autocompleteFetcher;

  // Action Builders
  FavoriteAdder? get favoriteAdder;
  FavoriteRemover? get favoriteRemover;
  FavoriteChecker? get favoriteChecker;

  PostCountFetcher? get postCountFetcher;
}

mixin FavoriteNotSupportedMixin implements BooruBuilder {
  @override
  FavoriteAdder? get favoriteAdder => null;
  @override
  FavoriteRemover? get favoriteRemover => null;
  @override
  FavoriteChecker? get favoriteChecker => null;
  @override
  FavoritesPageBuilder? get favoritesPageBuilder => null;
}

mixin ArtistNotSupportedMixin implements BooruBuilder {
  @override
  ArtistPageBuilder? get artistPageBuilder => null;
}

mixin PostCountNotSupportedMixin implements BooruBuilder {
  @override
  PostCountFetcher? get postCountFetcher => null;
}

final booruBuilderProvider = Provider<BooruBuilder?>((ref) {
  final config = ref.watchConfig;
  final booruBuilders = ref.watch(booruBuildersProvider);
  final booruBuilderFunc = booruBuilders[config.booruType];

  return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
});

/// A provider that provides a map of [BooruType] to [BooruBuilder] functions
/// that can be used to build a Booru instances with the given [BooruConfig].
///
/// The [BooruType] enum represents different types of boorus that can be built.
/// The [BooruConfig] class represents the configuration for a booru instance.
///
/// Example usage:
/// ```
/// final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder Function(BooruConfig config)>>((ref) =>
///   {
///     BooruType.zerochan: (config) => ZerochanBuilder(
///       postRepo: ref.watch(zerochanPostRepoProvider(config)),
///       autocompleteRepo: ref.watch(zerochanAutoCompleteRepoProvider(config)),
///     ),
///     // ...
///   }
/// );
/// ```
/// Note that the [BooruBuilder] functions are not called until they are used and they won't be called again
/// Each local instance of [BooruBuilder] will be cached and reused until the app is restarted.
final booruBuildersProvider =
    Provider<Map<BooruType, BooruBuilder Function(BooruConfig config)>>((ref) =>
        {
          BooruType.zerochan: (config) => ZerochanBuilder(
                postRepo: ref.watch(zerochanPostRepoProvider(config)),
                autocompleteRepo:
                    ref.watch(zerochanAutoCompleteRepoProvider(config)),
              ),
          BooruType.moebooru: (config) => MoebooruBuilder(
                postRepo: ref.watch(moebooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.watch(moebooruAutocompleteRepoProvider(config)),
              ),
          BooruType.gelbooru: (config) => GelbooruBuilder(
                postRepo: ref.watch(gelbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.watch(gelbooruAutocompleteRepoProvider(config)),
                client: ref.watch(gelbooruClientProvider(config)),
              ),
          BooruType.gelbooruV2: (config) => GelbooruBuilder(
                postRepo: ref.watch(gelbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.watch(gelbooruAutocompleteRepoProvider(config)),
                client: ref.watch(gelbooruClientProvider(config)),
              ),
          BooruType.e621: (config) => E621Builder(
                autocompleteRepo:
                    ref.watch(e621AutocompleteRepoProvider(config)),
                postRepo: ref.watch(e621PostRepoProvider(config)),
                client: ref.watch(e621ClientProvider(config)),
                favoriteChecker: ref.watch(e621FavoriteCheckerProvider(config)),
              ),
          BooruType.danbooru: (config) => DanbooruBuilder(
                postRepo: ref.watch(danbooruPostRepoProvider(config)),
                autocompleteRepo:
                    ref.watch(danbooruAutocompleteRepoProvider(config)),
                favoriteRepo: ref.watch(danbooruFavoriteRepoProvider(config)),
                favoriteChecker:
                    ref.watch(danbooruFavoriteCheckerProvider(config)),
                postCountRepo: ref.watch(danbooruPostCountRepoProvider(config)),
              ),
          BooruType.gelbooruV1: (config) => GelbooruV1Builder(
                postRepo: ref.watch(gelbooruV1PostRepoProvider(config)),
                client: GelbooruClient.gelbooru(),
              ),
          BooruType.sankaku: (config) => SankakuBuilder(
                postRepository: ref.watch(sankakuPostRepoProvider(config)),
                client: ref.watch(sankakuClientProvider(config)),
              ),
          BooruType.philomena: (config) => PhilomenaBuilder(
                postRepo: ref.watch(philomenaPostRepoProvider(config)),
                autocompleteRepo:
                    ref.watch(philomenaAutoCompleteRepoProvider(config)),
              ),
        });

extension BooruBuilderFeatureCheck on BooruBuilder {
  bool get isArtistSupported => artistPageBuilder != null;
}

class BooruProvider extends ConsumerWidget {
  const BooruProvider({
    super.key,
    required this.builder,
  });

  final Widget Function(BooruBuilder? booruBuilder) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);

    return builder(booruBuilder);
  }
}

mixin DefaultBooruUIMixin implements BooruBuilder {
  @override
  HomePageBuilder get homePageBuilder => (context, config) => HomePageScaffold(
        onPostTap:
            (context, posts, post, scrollController, settings, initialIndex) =>
                goToPostDetailsPage(
          context: context,
          posts: posts,
          initialIndex: initialIndex,
        ),
        onSearchTap: () => goToSearchPage(context),
      );

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => BooruProvider(
            builder: (booruBuilder) => SearchPageScaffold(
              initialQuery: initialQuery,
              fetcher: (page, tags) =>
                  booruBuilder?.postFetcher.call(page, tags) ??
                  TaskEither.of(<Post>[]),
            ),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
            ),
          );

  //FIXME: this is a hack, we should have a proper update page
  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          createConfigPageBuilder(
            context,
            config.url,
            config.booruType,
            backgroundColor: backgroundColor,
          );
}

extension BooruRef on Ref {
  BooruBuilder? readBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }

  BooruBuilder? readCurrentBooruBuilder() {
    final config = read(currentBooruConfigProvider);
    return readBooruBuilder(config);
  }
}

extension BooruWidgetRef on WidgetRef {
  BooruBuilder? readBooruBuilder(BooruConfig? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc(config) : null;
  }
}
