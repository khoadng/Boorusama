// Project imports:
import 'package:boorusama/core/domain/posts/post_repository.dart' as core;
import 'post.dart';

abstract class PostRepository implements core.PostRepository {
  Future<List<Post>> getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  });
  Future<List<Post>> getPostsFromIds(List<int> ids);
  Future<bool> putTag(int postId, String tagString);
}
