// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/gelbooru/feats/tags/utils.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';

import 'gelbooru_post_parser.dart';

class GelbooruPostRepositoryApi
    with GlobalBlacklistedTagFilterMixin, SettingsRepositoryMixin
    implements PostRepository {
  const GelbooruPostRepositoryApi({
    required this.api,
    required this.booruConfig,
    required this.blacklistedTagRepository,
    required this.settingsRepository,
  });

  final GelbooruApi api;
  final BooruConfig booruConfig;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;
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
        final response = await $(tryParseResponse(
          fetcher: () => api.getPosts(
            booruConfig.apiKey,
            booruConfig.login,
            'dapi',
            'post',
            'index',
            getTags(booruConfig, tags).join(' '),
            '1',
            (page - 1).toString(),
          ),
        ));

        final data = await $(tryParseJsonFromResponse(
          response,
          parseGelbooruResponse,
        ));

        final filtered = await $(tryFilterBlacklistedTags(data));

        return filtered;
      });
}
