// Project imports:
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/functional.dart';
import 'post.dart';

typedef PostsOrErrorCore<T extends Post> = TaskEither<BooruError, List<T>>;

typedef PostsOrError = PostsOrErrorCore<Post>;

abstract class PostRepository {
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  });
}

Future<List<Post>> getPostsFromTagsOrEmptyFrom(
  PostRepository repository,
  String tags,
  int page, {
  int? limit,
}) =>
    repository
        .getPostsFromTags(
          tags,
          page,
          limit: limit,
        )
        .run()
        .then((value) => value.fold(
              (l) => <Post>[],
              (r) => r,
            ));

extension PostRepositoryX on PostRepository {
  Future<List<Post>> getPostsFromTagsOrEmpty(
    String tags,
    int page, {
    int? limit,
  }) =>
      getPostsFromTagsOrEmptyFrom(this, tags, page, limit: limit);
}

mixin PostRepositoryMixin {
  PostRepository get postRepository;

  Future<List<Post>> getPostsFromTagsOrEmpty(
    String tags,
    int page, {
    int? limit,
  }) =>
      getPostsFromTagsOrEmptyFrom(
        postRepository,
        tags,
        page,
        limit: limit,
      );
}
