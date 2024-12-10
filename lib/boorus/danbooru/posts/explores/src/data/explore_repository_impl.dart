// Package imports:
import 'package:booru_clients/danbooru.dart' as danbooru;
import 'package:collection/collection.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/datetimes/types.dart';
import '../../../../../../core/http/http.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/settings.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';
import '../types/explore_repository.dart';

class ExploreRepositoryApi implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.client,
    required this.postRepository,
    required this.settings,
    this.shouldFilter,
    required this.transformer,
  });

  final PostRepository<DanbooruPost> postRepository;
  final danbooru.DanbooruClient client;
  final ImageListingSettings Function() settings;
  final bool Function(DanbooruPost post)? shouldFilter;
  final PostFetchTransformer transformer;

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
        final dtos = await $(
          tryFetchRemoteData(
            fetcher: () => client.getMostViewedPosts(date: date),
          ),
        );

        final data = dtos.map(postDtoToPostNoMetadata).toList();

        final filtered =
            shouldFilter != null ? data.whereNot(shouldFilter!).toList() : data;

        return transformer(filtered.toResult());
      });

  @override
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final dtos = await $(
          tryFetchRemoteData(
            fetcher: () => client.getPopularPosts(
              date: date,
              scale: switch (scale) {
                TimeScale.day => danbooru.TimeScale.day,
                TimeScale.week => danbooru.TimeScale.week,
                TimeScale.month => danbooru.TimeScale.month,
              },
              page: page,
              limit: limit ?? settings().postsPerPage,
            ),
          ),
        );

        final data = dtos.map(postDtoToPostNoMetadata).toList();

        final filtered =
            shouldFilter != null ? data.whereNot(shouldFilter!).toList() : data;

        return transformer(filtered.toResult());
      });
}
