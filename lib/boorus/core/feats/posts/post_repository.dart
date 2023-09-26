// Project imports:
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';
import 'post.dart';

typedef PostsOrErrorCore<T extends Post> = TaskEither<BooruError, List<T>>;

typedef PostsOrError = PostsOrErrorCore<Post>;

typedef PostFutureFetcher = Future<List<Post>> Function(
  String tags,
  int page, {
  int? limit,
});

abstract class PostRepository {
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  });
}

class PostRepositoryBuilder
    with SettingsRepositoryMixin, DebounceMixin
    implements PostRepository {
  PostRepositoryBuilder({
    required this.settingsRepository,
    required this.getPosts,
  });

  final PostFutureFetcher getPosts;

  @override
  final SettingsRepository settingsRepository;

  @override
  PostsOrError getPostsFromTags(String tags, int page, {int? limit}) =>
      TaskEither.Do(($) async {
        var lim = limit;

        lim ??= await getPostsPerPage();

        return $(tryFetchRemoteData(
          fetcher: () => getPosts(tags, page, limit: lim),
        ));
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

class EmptyPostRepository extends PostRepository {
  EmptyPostRepository();

  @override
  PostsOrError getPostsFromTags(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.right([]);
}
