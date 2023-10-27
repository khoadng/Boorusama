// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/moebooru/moebooru_client.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'feats/autocomplete/autocomplete.dart';
import 'feats/posts/posts.dart';
import 'pages/create_moebooru_config_page.dart';
import 'pages/moebooru_home_page.dart';
import 'pages/moebooru_post_details_desktop_page.dart';
import 'pages/moebooru_post_details_page.dart';

final moebooruClientProvider =
    Provider.family<MoebooruClient, BooruConfig>((ref, booruConfig) {
  final dio = newDio(ref.watch(dioArgsProvider(booruConfig)));

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
        CommentNotSupportedMixin,
        NoteNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        DefaultTagColorMixin,
        ArtistNotSupportedMixin
    implements BooruBuilder {
  MoebooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final PostRepository<MoebooruPost> postRepo;
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
      (context, config) => MoebooruHomePage(config: config);

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
  PostFetcher get postFetcher => (page, tags) => postRepo.getPosts(tags, page);

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => SearchPageScaffold(
            initialQuery: initialQuery,
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
