// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/common.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post_image_source_composer.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/networks.dart';

class ExploreRepositoryApi
    with SettingsRepositoryMixin
    implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.api,
    required this.currentBooruConfigRepository,
    required this.postRepository,
    required this.urlComposer,
    required this.settingsRepository,
  });

  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final DanbooruPostRepository postRepository;
  final DanbooruApi api;
  final ImageSourceComposer<PostDto> urlComposer;
  @override
  final SettingsRepository settingsRepository;

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
          .flatMap((response) => tryParseData(response, urlComposer));

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
          .flatMap((response) => tryParseData(response, urlComposer));
}
