import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/time_scale.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts(String tagString, int page);
  Future<List<Post>> getPopularPosts(DateTime date, int page, TimeScale scale);
  Future<List<Post>> getCuratedPosts(DateTime date, int page, TimeScale scale);
}
