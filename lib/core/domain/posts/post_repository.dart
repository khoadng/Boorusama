// Project imports:
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/functional.dart';
import 'post.dart';

typedef PostsOrError = TaskEither<BooruError, List<Post>>;

abstract class PostRepository {
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  });
}
