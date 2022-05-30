// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';
import 'post.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts(
    String tagString,
    int page, {
    int limit = 100,
    CancelToken? cancelToken,
    bool skipFavoriteCheck = false,
  });
  Future<List<Post>> getPopularPosts(DateTime date, int page, TimeScale scale);
  Future<List<Post>> getCuratedPosts(DateTime date, int page, TimeScale scale);
  Future<List<Post>> getMostViewedPosts(DateTime date);
}
