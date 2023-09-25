// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/scaffolds/search_page_scaffold.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/moebooru_post_repository_api.dart';
import 'package:boorusama/boorus/moebooru/moebooru_scope.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'create_moebooru_config_page.dart';
import 'moebooru_post_details_desktop_page.dart';
import 'moebooru_post_details_page.dart';

final moebooruClientProvider = Provider<MoebooruClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return MoebooruClient.custom(
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
    dio: dio,
  );
});

class MoebooruBuilder
    with
        FavoriteNotSupportedMixin,
        PostCountNotSupportedMixin,
        ArtistNotSupportedMixin
    implements BooruBuilder {
  MoebooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final MoebooruPostRepositoryApi postRepo;
  final MoebooruAutocompleteRepository autocompleteRepo;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateMoebooruConfigPage(
            config: BooruConfig.defaultConfig(booruType: booruType, url: url),
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => MoebooruScope(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateMoebooruConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher =>
      (page, tags) => postRepo.getPostsFromTags(tags, page);

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => SearchPageScaffold(
            fetcher: (page, tags) => postFetcher(page, tags),
          );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => payload.isDesktop
          ? MoebooruPostDetailsDesktopPage(
              posts: payload.posts,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              initialIndex: payload.initialIndex,
            )
          : MoebooruPostDetailsPage(
              posts: payload.posts,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              initialPage: payload.initialIndex,
            );
}
