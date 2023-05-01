// Project imports:
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/functional.dart';
import 'danbooru_post.dart';

typedef DanbooruPostsOrError = TaskEither<BooruError, List<DanbooruPost>>;

abstract class DanbooruPostRepository implements PostRepository {
  DanbooruPostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  });
  DanbooruPostsOrError getPostsFromIds(List<int> ids);
}
