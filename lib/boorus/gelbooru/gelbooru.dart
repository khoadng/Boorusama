// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/gelbooru/create_gelbooru_config_page.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_scope.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts/gelbooru_post_details_desktop_page.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts/gelbooru_post_details_page.dart';
import 'package:boorusama/boorus/gelbooru/pages/search/gelbooru_search_page.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';

class GelbooruBuilder with FavoriteNotSupportedMixin implements BooruBuilder {
  GelbooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.client,
  });

  final GelbooruPostRepositoryApi postRepo;
  final AutocompleteRepository autocompleteRepo;
  final GelbooruClient client;

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateGelbooruConfigPage(
            config: BooruConfig.defaultConfig(booruType: booruType, url: url),
            backgroundColor: backgroundColor,
          );

  @override
  HomePageBuilder get homePageBuilder =>
      (context, config) => GelbooruScope(config: config);

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateGelbooruConfigPage(
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
  PostCountFetcher? get postCountFetcher =>
      (tags) => client.countPosts(tags: tags);

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, initialQuery) => GelbooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, booruConfig, payload) => payload.isDesktop
          ? GelbooruPostDetailsDesktopPage(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              hasDetailsTagList: booruConfig.booruType.supportTagDetails,
            )
          : GelbooruPostDetailsPage(
              posts: payload.posts.map((e) => e as GelbooruPost).toList(),
              initialIndex: payload.initialIndex,
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              hasDetailsTagList: booruConfig.booruType.supportTagDetails,
            );
}
