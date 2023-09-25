// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/moebooru_autocomplete_provider.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/zerochan/zerochan.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/routes.dart';
import 'core/router.dart';
import 'core/scaffolds/home_page_scaffold.dart';
import 'core/scaffolds/post_details_page_scaffold.dart';
import 'core/scaffolds/search_page_scaffold.dart';
import 'danbooru/feats/posts/posts.dart';

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
  String tags,
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

final booruBuildersProvider = Provider<Map<BooruType, BooruBuilder>>((ref) => {
      BooruType.zerochan: ZerochanBuilder(
        client: ref.watch(zerochanClientProvider),
        settingsRepository: ref.watch(settingsRepoProvider),
      ),
      BooruType.konachan: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.yandere: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.sakugabooru: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.lolibooru: MoebooruBuilder(
        postRepo: ref.watch(moebooruPostRepoProvider),
        autocompleteRepo: ref.watch(moebooruAutocompleteRepoProvider),
      ),
      BooruType.gelbooru: GelbooruBuilder(
        postRepo: ref.watch(gelbooruPostRepoProvider),
        autocompleteRepo: ref.watch(gelbooruAutocompleteRepoProvider),
        client: ref.watch(gelbooruClientProvider),
      ),
      BooruType.rule34xxx: GelbooruBuilder(
        postRepo: ref.watch(gelbooruPostRepoProvider),
        autocompleteRepo: ref.watch(gelbooruAutocompleteRepoProvider),
        client: ref.watch(gelbooruClientProvider),
      ),
      BooruType.e621: E621Builder(
        postRepo: ref.watch(e621PostRepoProvider),
        client: ref.watch(e621ClientProvider),
        favoriteChecker: ref.watch(e621FavoriteCheckerProvider),
      ),
      BooruType.e926: E621Builder(
        postRepo: ref.watch(e621PostRepoProvider),
        client: ref.watch(e621ClientProvider),
        favoriteChecker: ref.watch(e621FavoriteCheckerProvider),
      ),
      BooruType.aibooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
        favoriteRepo: ref.watch(danbooruFavoriteRepoProvider),
        favoriteChecker: ref.watch(danbooruFavoriteCheckerProvider),
        postCountRepo: ref.watch(danbooruPostCountRepoProvider),
      ),
      BooruType.danbooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
        favoriteRepo: ref.watch(danbooruFavoriteRepoProvider),
        favoriteChecker: ref.watch(danbooruFavoriteCheckerProvider),
        postCountRepo: ref.watch(danbooruPostCountRepoProvider),
      ),
      BooruType.safebooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
        favoriteRepo: ref.watch(danbooruFavoriteRepoProvider),
        favoriteChecker: ref.watch(danbooruFavoriteCheckerProvider),
        postCountRepo: ref.watch(danbooruPostCountRepoProvider),
      ),
      BooruType.testbooru: DanbooruBuilder(
        postRepo: ref.watch(danbooruPostRepoProvider),
        autocompleteRepo: ref.watch(danbooruAutocompleteRepoProvider),
        favoriteRepo: ref.watch(danbooruFavoriteRepoProvider),
        favoriteChecker: ref.watch(danbooruFavoriteCheckerProvider),
        postCountRepo: ref.watch(danbooruPostCountRepoProvider),
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
    final booruBuilders = ref.watch(booruBuildersProvider);
    final config = ref.watch(currentBooruConfigProvider);

    return builder(booruBuilders[config.booruType]);
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
              onTagTap: (tag) => goToSearchPage(context),
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
