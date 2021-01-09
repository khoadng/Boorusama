import 'package:boorusama/domain/posts/time_scale.dart';

import 'post_dto.dart';

abstract class IPostRepository {
  Future<List<PostDto>> getPosts(String tagString, int page);
  Future<List<PostDto>> getPopularPosts(
      DateTime date, int page, TimeScale scale);
  Future<List<PostDto>> getCuratedPosts(
      DateTime date, int page, TimeScale scale);
  Future<List<PostDto>> getMostViewedPosts(DateTime date);
}
