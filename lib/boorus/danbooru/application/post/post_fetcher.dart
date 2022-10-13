// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

abstract class PostFetcher {
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  );
}

class PopularPostFetcher implements PostFetcher {
  const PopularPostFetcher({
    required this.date,
    required this.scale,
  });

  final DateTime date;
  final TimeScale scale;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getPopularPosts(date, page, scale);

    return posts;
  }
}

class CuratedPostFetcher implements PostFetcher {
  const CuratedPostFetcher({
    required this.date,
    required this.scale,
  });

  final DateTime date;
  final TimeScale scale;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getCuratedPosts(date, page, scale);

    return posts;
  }
}

class MostViewedPostFetcher implements PostFetcher {
  const MostViewedPostFetcher({
    required this.date,
  });

  final DateTime date;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getMostViewedPosts(date);

    return posts;
  }
}

class HotPostFetcher implements PostFetcher {
  const HotPostFetcher();

  @override
  Future<List<Post>> fetch(PostRepository repo, int page) async {
    final posts = await repo.getPosts('order:rank', page);

    return posts;
  }
}

class ExplorePreviewFetcher implements PostFetcher {
  const ExplorePreviewFetcher({
    required this.category,
    required this.date,
    required this.scale,
    this.limit = 20,
  });

  factory ExplorePreviewFetcher.now({
    required ExploreCategory category,
  }) =>
      ExplorePreviewFetcher(
        category: category,
        date: DateTime.now(),
        scale: TimeScale.day,
      );

  final ExploreCategory category;
  final DateTime date;
  final TimeScale scale;
  final int limit;

  @override
  Future<List<Post>> fetch(PostRepository repo, int page) async {
    var posts = await _categoryToFetcher(date).fetch(repo, page);

    if (posts.isEmpty) {
      posts = await _categoryToFetcher(date.subtract(const Duration(days: 1)))
          .fetch(repo, page);
    }

    return posts.take(limit).toList();
  }

  PostFetcher _categoryToFetcher(DateTime d) {
    if (category == ExploreCategory.popular) {
      return PopularPostFetcher(date: d, scale: scale);
    } else if (category == ExploreCategory.curated) {
      return CuratedPostFetcher(date: d, scale: scale);
    } else if (category == ExploreCategory.hot) {
      return const HotPostFetcher();
    } else {
      return MostViewedPostFetcher(date: d);
    }
  }
}

class LatestPostFetcher implements PostFetcher {
  const LatestPostFetcher();

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getPosts('', page);

    return posts;
  }
}

class SearchedPostFetcher implements PostFetcher {
  const SearchedPostFetcher({
    required this.query,
  });

  factory SearchedPostFetcher.fromTags(
    String tags, {
    PostsOrder? order,
  }) =>
      SearchedPostFetcher(query: '$tags ${_postsOrderToString(order)}');

  final String query;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page,
  ) async {
    final posts = await repo.getPosts(query, page);

    return posts;
  }
}

String _postsOrderToString(PostsOrder? order) {
  switch (order) {
    case PostsOrder.popular:
      return 'order:favcount';
    default:
      return '';
  }
}
