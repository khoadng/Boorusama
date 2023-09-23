// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/danbooru/create_danbooru_config_page.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_category.dart';
import 'package:boorusama/clients/e621/e621_client.dart';
import 'e621_scope.dart';

class E621Builder implements BooruBuilder {
  E621Builder({
    required this.postRepo,
    required this.client,
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
  PostFetcher get postFetcher => (page, tags) => postRepo.getPostsFromTags(
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
}
