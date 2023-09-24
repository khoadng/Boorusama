// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/moebooru/feats/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/moebooru_post_repository_api.dart';
import 'package:boorusama/boorus/moebooru/moebooru_scope.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/boorus/moebooru/pages/posts/moebooru_post_details_desktop_page.dart';
import 'package:boorusama/boorus/moebooru/pages/search/moebooru_search_page.dart';
import 'create_moebooru_config_page.dart';

class MoebooruBuilder
    with FavoriteNotSupportedMixin, PostCountNotSupportedMixin
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
  PostFetcher get postFetcher => (page, tags) => postRepo.getPostsFromTags(
        tags,
        page,
      );

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => MoebooruSearchPage(
            initialQuery: initialQuery,
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
