// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'danbooru_post.dart';

abstract class DanbooruPostRepository implements PostRepository {
  Future<List<DanbooruPost>> getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  });
  Future<List<DanbooruPost>> getPostsFromIds(List<int> ids);
  Future<bool> putTag(int postId, String tagString);
}
