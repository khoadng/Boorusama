// Project imports:
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/functional.dart';
import 'post.dart';

typedef PostsOrError = TaskEither<BooruError, List<Post>>;

//FIXME: limit should be implemented in the repository
abstract class PostRepository {
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  });
}

List<Post> filterTags(List<Post> posts, Set<String> tags) => posts
    .where((post) => !tags.intersection(post.tags.toSet()).isNotEmpty)
    .toList();
