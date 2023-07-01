// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';

class ExploreRepositoryApi
    with SettingsRepositoryMixin, GlobalBlacklistedTagFilterMixin
    implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.api,
    required this.postRepository,
    required this.settingsRepository,
    required this.blacklistedTagRepository,
    this.shouldFilter,
  });

  final DanbooruPostRepository postRepository;
  final DanbooruApi api;
  @override
  final SettingsRepository settingsRepository;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;
  final bool Function(DanbooruPost post)? shouldFilter;

  @override
  DanbooruPostsOrError getHotPosts(
    int page, {
    int? limit,
  }) =>
      postRepository.getPosts(
        'order:rank',
        page,
        limit: limit,
      );

  @override
  DanbooruPostsOrError getMostViewedPosts(
    DateTime date,
  ) =>
      TaskEither.Do(($) async {
        final response = await $(tryParseResponse(
          fetcher: () => api.getMostViewedPosts(
            '${date.year}-${date.month}-${date.day}',
          ),
        ));

        final data = await $(tryParseJsonFromResponse(response, parsePost));
        final filtered = await $(tryFilterBlacklistedTags(data));

        return shouldFilter != null
            ? filtered.whereNot(shouldFilter!).toList()
            : filtered.toList();
      });

  @override
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final response = await $(tryParseResponse(
          fetcher: () => getPostsPerPage().then((lim) => api.getPopularPosts(
                '${date.year}-${date.month}-${date.day}',
                scale.toString().split('.').last,
                page,
                limit ?? lim,
              )),
        ));

        final data = await $(tryParseJsonFromResponse(response, parsePost));
        final filtered = await $(tryFilterBlacklistedTags(data));

        return shouldFilter != null
            ? filtered.whereNot(shouldFilter!).toList()
            : filtered.toList();
      });
}