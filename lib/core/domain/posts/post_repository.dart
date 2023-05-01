// Project imports:
import 'post.dart';

//FIXME: limit should be implemented in the repository
abstract class PostRepository {
  Future<List<Post>> getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  });
}
