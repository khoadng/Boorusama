// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';
import 'post.dart';

typedef PostsOrErrorCore<T extends Post> = TaskEither<BooruError, List<T>>;

typedef PostsOrError<T extends Post> = PostsOrErrorCore<T>;

typedef PostFutureFetcher<T extends Post> = Future<List<T>> Function(
  List<String> tags,
  int page, {
  int? limit,
});

abstract class PostRepository<T extends Post> {
  PostsOrError<T> getPosts(
    List<String> tags,
    int page, {
    int? limit,
  });
}

class PostRepositoryBuilder<T extends Post> implements PostRepository<T> {
  PostRepositoryBuilder({
    required this.fetch,
    required this.getSettings,
  });

  final PostFutureFetcher<T> fetch;
  final Future<Settings> Function() getSettings;

  @override
  PostsOrError<T> getPosts(List<String> tags, int page, {int? limit}) =>
      TaskEither.Do(($) async {
        var lim = limit;

        lim ??= await getSettings().then((value) => value.postsPerPage);

        return $(tryFetchRemoteData(
          fetcher: () => fetch(tags, page, limit: lim),
        ));
      });
}

Future<List<Post>> getPostsFromTagsOrEmptyFrom(
  PostRepository repository,
  List<String> tags,
  int page, {
  int? limit,
}) =>
    repository
        .getPosts(
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
    List<String> tags,
    int page, {
    int? limit,
  }) =>
      getPostsFromTagsOrEmptyFrom(this, tags, page, limit: limit);
}

mixin PostRepositoryMixin {
  PostRepository get postRepository;

  Future<List<Post>> getPostsFromTagsOrEmpty(
    List<String> tags,
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

class EmptyPostRepository extends PostRepository {
  EmptyPostRepository();

  @override
  PostsOrError getPosts(
    List<String> tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.right([]);
}
