// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/utils.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/handle_error.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts/post_image_source_composer.dart';
import 'post_repository_api.dart';

class ExploreRepositoryApi implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.api,
    required this.currentBooruConfigRepository,
    required this.postRepository,
    required this.urlComposer,
  });

  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final DanbooruPostRepository postRepository;
  final DanbooruApi api;
  final ImageSourceComposer<PostDto> urlComposer;

  static const int _limit = 60;

  @override
  Future<List<DanbooruPost>> getHotPosts(
    int page, {
    int? limit,
  }) async {
    final booruConfig = await currentBooruConfigRepository.get();
    final tag = booruFilterConfigToDanbooruTag(booruConfig?.ratingFilter);
    final tags = [
      'order:rank',
      if (tag != null) tag,
    ];

    return postRepository.getPosts(
      tags.join(' '),
      page,
      limit: limit,
    );
  }

  @override
  Future<List<DanbooruPost>> getMostViewedPosts(
    DateTime date,
  ) =>
      currentBooruConfigRepository
          .get()
          .then(
            (booruConfig) => api.getMostViewedPosts(
              booruConfig?.login,
              booruConfig?.apiKey,
              '${date.year}-${date.month}-${date.day}',
            ),
          )
          .then((e) => parsePost(e, urlComposer))
          .catchError((e) {
        handleError(e);

        return <DanbooruPost>[];
      });

  @override
  Future<List<DanbooruPost>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) =>
      currentBooruConfigRepository
          .get()
          .then(
            (booruConfig) => api.getPopularPosts(
              booruConfig?.login,
              booruConfig?.apiKey,
              '${date.year}-${date.month}-${date.day}',
              scale.toString().split('.').last,
              page,
              limit ?? _limit,
            ),
          )
          .then((e) => parsePost(e, urlComposer))
          .catchError((e) {
        handleError(e);

        return <DanbooruPost>[];
      });
}
