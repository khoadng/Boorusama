// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';
import 'gelbooru_post_parser.dart';

class GelbooruPostRepositoryApi
    with SettingsRepositoryMixin
    implements PostRepository {
  const GelbooruPostRepositoryApi({
    required this.client,
    required this.booruConfig,
    required this.settingsRepository,
  });

  final GelbooruClient client;
  final BooruConfig booruConfig;
  @override
  final SettingsRepository settingsRepository;

  List<String> getTags(BooruConfig config, String tags) {
    final tag = booruFilterConfigToGelbooruTag(config.ratingFilter);

    return [
      ...tags.split(' '),
      if (tag != null) tag,
    ];
  }

  @override
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final lim = await getPostsPerPage();
        final response = await $(tryFetchRemoteData(
          fetcher: () => client.getPosts(
            tags: getTags(booruConfig, tags),
            page: page,
            limit: limit ?? lim,
          ),
        ));

        final data = response.map(gelbooruPostDtoToGelbooruPost).toList();

        return data;
      });
}

String? booruFilterConfigToGelbooruTag(BooruConfigRatingFilter? filter) =>
    switch (filter) {
      BooruConfigRatingFilter.none || null => null,
      BooruConfigRatingFilter.hideExplicit => '-rating:explicit',
      BooruConfigRatingFilter.hideNSFW => 'rating:general',
    };
