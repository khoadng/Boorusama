// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import '../models/danbooru_post.dart';
import '../models/danbooru_post_repository.dart';
import '../models/explore_repository.dart';
import 'common.dart';

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
      tryParseResponse(
        fetcher: () => api.getMostViewedPosts(
          '${date.year}-${date.month}-${date.day}',
        ),
      )
          .flatMap(tryParseData)
          .flatMap(tryFilterBlacklistedTags)
          // filter when filerFn is provided
          .map((posts) => shouldFilter != null
              ? posts.whereNot(shouldFilter!).toList()
              : posts.toList());

  @override
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) =>
      tryParseResponse(
        fetcher: () => getPostsPerPage().then((lim) => api.getPopularPosts(
              '${date.year}-${date.month}-${date.day}',
              scale.toString().split('.').last,
              page,
              limit ?? lim,
            )),
      ).flatMap(tryParseData).flatMap(tryFilterBlacklistedTags).map((posts) =>
          shouldFilter != null
              ? posts.whereNot(shouldFilter!).toList()
              : posts.toList());
}
