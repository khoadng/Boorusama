// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/explores/explores.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/core/datetimes/datetimes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';

class ExploreRepositoryApi implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.client,
    required this.postRepository,
    required this.settings,
    this.shouldFilter,
    required this.transformer,
  });

  final PostRepository<DanbooruPost> postRepository;
  final DanbooruClient client;
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
        final dtos = await $(tryFetchRemoteData(
          fetcher: () => client.getMostViewedPosts(date: date),
        ));

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
        final dtos = await $(tryFetchRemoteData(
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
        ));

        final data = dtos.map(postDtoToPostNoMetadata).toList();

        final filtered =
            shouldFilter != null ? data.whereNot(shouldFilter!).toList() : data;

        return transformer(filtered.toResult());
      });
}
