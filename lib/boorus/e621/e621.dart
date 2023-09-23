// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/danbooru/create_danbooru_config_page.dart';
import 'package:boorusama/boorus/e621/feats/autocomplete/e621_autocomplete_repository.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'e621_scope.dart';

class E621Builder implements BooruBuilder {
  E621Builder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final E621PostRepository postRepo;
  final E621AutocompleteRepository autocompleteRepo;

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
  PostFetcher get postFetcher => (page, tags) => postRepo.getPostsFromTags(
        tags,
        page,
      );

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);
}
