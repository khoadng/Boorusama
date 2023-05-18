// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/common.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/networks.dart';

class ExploreRepositoryApi
    with SettingsRepositoryMixin, GlobalBlacklistedTagFilterMixin
    implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.api,
    required this.currentBooruConfigRepository,
    required this.postRepository,
    required this.settingsRepository,
    required this.blacklistedTagRepository,
  });

  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final DanbooruPostRepository postRepository;
  final DanbooruApi api;
  @override
  final SettingsRepository settingsRepository;
  @override
  final GlobalBlacklistedTagRepository blacklistedTagRepository;

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
      tryGetBooruConfigFrom(currentBooruConfigRepository)
          .flatMap((booruConfig) => tryParseResponse(
                fetcher: () => api.getMostViewedPosts(
                  booruConfig.login,
                  booruConfig.apiKey,
                  '${date.year}-${date.month}-${date.day}',
                ),
              ))
          .flatMap(tryParseData)
          .flatMap(tryFilterBlacklistedTags);

  @override
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) =>
      tryGetBooruConfigFrom(currentBooruConfigRepository)
          .flatMap((booruConfig) => tryParseResponse(
                fetcher: () =>
                    getPostsPerPage().then((lim) => api.getPopularPosts(
                          booruConfig.login,
                          booruConfig.apiKey,
                          '${date.year}-${date.month}-${date.day}',
                          scale.toString().split('.').last,
                          page,
                          limit ?? lim,
                        )),
              ))
          .flatMap(tryParseData)
          .flatMap(tryFilterBlacklistedTags);
}
