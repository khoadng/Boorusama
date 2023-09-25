// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/create_danbooru_config_page.dart';
import 'package:boorusama/boorus/e621/e621_post_details_desktop_page.dart';
import 'package:boorusama/boorus/e621/e621_post_details_page.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_category.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'e621_artist_page.dart';
import 'e621_favorites_page.dart';
import 'e621_scope.dart';
import 'e621_search_page.dart';

final e621ClientProvider = Provider<E621Client>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return E621Client(
    baseUrl: booruConfig.url,
    dio: dio,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
  );
});

class E621Builder with PostCountNotSupportedMixin implements BooruBuilder {
  E621Builder({
    required this.postRepo,
    required this.client,
    required this.favoriteChecker,
  });

  final E621PostRepository postRepo;
  final E621Client client;

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
      (context, config) => E621Scope(config: config);

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
      (query) => client.getAutocomplete(query: query).then((value) => value
          .map((dto) => AutocompleteData(
                type: AutocompleteData.tag,
                label: dto.name?.replaceAll('_', ' ') ?? '',
                value: dto.name ?? '',
                category: intToE621TagCategory(dto.category).name,
                postCount: dto.postCount,
                antecedent: dto.antecedentName,
              ))
          .toList());

  @override
  FavoriteAdder? get favoriteAdder => (postId) => client
      .addToFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  FavoriteRemover? get favoriteRemover => (postId) => client
      .removeFromFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  final FavoriteChecker? favoriteChecker;

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => E621SearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => payload.isDesktop
          ? E621PostDetailsDesktopPage(
              initialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as E621Post).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            )
          : E621PostDetailsPage(
              intitialIndex: payload.initialIndex,
              posts: payload.posts.map((e) => e as E621Post).toList(),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
            );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => const E621FavoritesPage();

  @override
  ArtistPageBuilder? get artistPageBuilder =>
      (context, artistName) => E621ArtistPage(artistName: artistName);
}
