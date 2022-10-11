// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'post.dart';
import 'time_scale.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts(
    String tags,
    int page, {
    int limit = 50,
    CancelToken? cancelToken,
    bool skipFavoriteCheck = false,
  });
  Future<List<Post>> getPopularPosts(DateTime date, int page, TimeScale scale);
  Future<List<Post>> getCuratedPosts(DateTime date, int page, TimeScale scale);
  Future<List<Post>> getMostViewedPosts(DateTime date);
  Future<List<Post>> getPostsFromIds(List<int> ids);
}
