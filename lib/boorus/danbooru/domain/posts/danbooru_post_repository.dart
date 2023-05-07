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
  });
  DanbooruPostsOrError getPostsFromIds(List<int> ids);
}

mixin DanbooruPostRepositoryMixin {
  DanbooruPostRepository get postRepository;

  Future<List<DanbooruPost>> getPostsOrEmpty(String tags, int page) =>
      postRepository.getPosts(tags, page).run().then((value) => value.fold(
            (l) => <DanbooruPost>[],
            (r) => r,
          ));
}
