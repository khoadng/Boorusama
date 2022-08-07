// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/infrastructure/caching/cacher.dart';

class RecommendedPostCacher implements IPostRepository {
  const RecommendedPostCacher({
    required this.cache,
    required this.postRepository,
  });

  final Cacher cache;
  final IPostRepository postRepository;

  @override
  Future<List<Post>> getCuratedPosts(
          DateTime date, int page, TimeScale scale) =>
      postRepository.getCuratedPosts(date, page, scale);

  @override
  Future<List<Post>> getMostViewedPosts(DateTime date) =>
      postRepository.getMostViewedPosts(date);

  @override
  Future<List<Post>> getPopularPosts(
          DateTime date, int page, TimeScale scale) =>
      postRepository.getPopularPosts(date, page, scale);

  @override
  Future<List<Post>> getPosts(String tags, int page,
      {int limit = 50,
      CancelToken? cancelToken,
      bool skipFavoriteCheck = false}) async {
    final key = '$tags$page$limit';
    final posts = cache.get(key);

    if (posts != null) return posts;

    final fresh = await postRepository.getPosts(
      tags,
      page,
      limit: limit,
      cancelToken: cancelToken,
      skipFavoriteCheck: skipFavoriteCheck,
    );
    await cache.put(key, fresh);

    return fresh;
  }

  @override
  Future<List<Post>> getPostsFromIds(List<int> ids) =>
      postRepository.getPostsFromIds(ids);
}
