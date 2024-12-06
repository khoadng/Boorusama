// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/core/datetimes/datetimes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/http/http_utils.dart';
import 'package:boorusama/functional.dart';

enum ExploreCategory {
  popular,
  mostViewed,
  hot,
}

abstract class ExploreRepository {
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  });

  DanbooruPostsOrError getMostViewedPosts(DateTime date);

  DanbooruPostsOrError getHotPosts(
    int page, {
    int? limit,
  });
}

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

class ExploreRepositoryCacher implements ExploreRepository {
  ExploreRepositoryCacher({
    required this.repository,
    required this.popularStaleDuration,
    required this.mostViewedStaleDuration,
    required this.hotStaleDuration,
  });

  final ExploreRepository repository;
  final Duration popularStaleDuration;
  final Duration mostViewedStaleDuration;
  final Duration hotStaleDuration;

  final Map<String, (DateTime, List<DanbooruPost>)> _cache = {};

  DateTime _truncateToDate(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  bool _isCached(String key, Duration staleDuration) {
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (DateTime.now().difference(entry.$1) <= staleDuration) {
        return true;
      }
    }
    return false;
  }

  @override
  DanbooruPostsOrError getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) {
    final truncatedDate = _truncateToDate(date);
    final name = 'popular-$truncatedDate-$page-$scale-$limit';

    if (_isCached(name, popularStaleDuration)) {
      return TaskEither.of(_cache[name]!.$2.toResult());
    }

    return repository
        .getPopularPosts(date, page, scale, limit: limit)
        .flatMap((r) => TaskEither(() async {
              _cache[name] = (DateTime.now(), r.posts);
              return Either.of(r);
            }));
  }

  @override
  DanbooruPostsOrError getMostViewedPosts(DateTime date) {
    final truncatedDate = _truncateToDate(date);
    final name = 'mostViewed-$truncatedDate';

    if (_isCached(name, mostViewedStaleDuration)) {
      return TaskEither.of(_cache[name]!.$2.toResult());
    }

    return repository
        .getMostViewedPosts(date)
        .flatMap((r) => TaskEither(() async {
              _cache[name] = (DateTime.now(), r.posts);
              return Either.of(r);
            }));
  }

  @override
  DanbooruPostsOrError getHotPosts(
    int page, {
    int? limit,
  }) {
    final name = 'hot-$page-$limit';

    if (_isCached(name, hotStaleDuration)) {
      return TaskEither.of(_cache[name]!.$2.toResult());
    }

    return repository
        .getHotPosts(page, limit: limit)
        .flatMap((r) => TaskEither(() async {
              _cache[name] = (DateTime.now(), r.posts);
              return Either.of(r);
            }));
  }
}
