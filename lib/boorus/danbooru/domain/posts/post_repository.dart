// Project imports:
import 'post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  });
  Future<List<Post>> getPostsFromIds(List<int> ids);
  Future<bool> putTag(int postId, String tagString);
}
