// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'pages/create_danbooru_config_page.dart';
import 'pages/danbooru_artist_page.dart';
import 'pages/danbooru_home_page.dart';
import 'pages/danbooru_post_details_desktop_page.dart';
import 'pages/danbooru_post_details_page.dart';
import 'pages/danbooru_search_page.dart';
import 'pages/favorites_page.dart';

const kDanbooruSafeUrl = 'https://safebooru.donmai.us/';

class DanbooruBuilder implements BooruBuilder {
  const DanbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.favoriteRepo,
    required this.favoriteChecker,
    required this.postCountRepo,
  });

  final PostRepository<DanbooruPost> postRepo;
  final AutocompleteRepository autocompleteRepo;
  final FavoritePostRepository favoriteRepo;
  final PostCountRepository postCountRepo;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateDanbooruConfigPage(
            config: BooruConfig.defaultConfig(booruType: booruType, url: url),
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => DanbooruHomePage(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateDanbooruConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(
        tags,
        page,
      );

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  FavoriteAdder? get favoriteAdder =>
      (postId) => favoriteRepo.addToFavorites(postId);

  @override
  FavoriteRemover? get favoriteRemover =>
      (postId) => favoriteRepo.removeFromFavorites(postId);

  @override
  final FavoriteChecker? favoriteChecker;

  @override
  PostCountFetcher? get postCountFetcher => (tags) => postCountRepo.count(tags);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => CustomContextMenuOverlay(
            child: DanbooruSearchPage(initialQuery: initialQuery),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => payload.isDesktop
          ? DanbooruPostDetailsDesktopPage(
              initialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as DanbooruPost).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            )
          : DanbooruPostDetailsPage(
              intitialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as DanbooruPost).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => config.login != null
          ? DanbooruFavoritesPage(username: config.login!)
          : Scaffold(
              appBar: AppBar(
                title: const Text('Favorites'),
              ),
              body: const Center(
                child: Text('You must be logged in to view your favorites'),
              ),
            );

  @override
  ArtistPageBuilder? get artistPageBuilder => (context, artistName) =>
      DanbooruArtistPage(artistName: artistName, backgroundImageUrl: '');

  @override
  GridThumbnailUrlBuilder get gridThumbnailUrlBuilder => (settings, post) =>
      (post as DanbooruPost).thumbnailFromSettings(settings);
}
