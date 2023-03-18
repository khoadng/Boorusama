// Project imports:
import 'post.dart';

abstract class PostRepository {
  Future<List<Post>> getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  });
}
