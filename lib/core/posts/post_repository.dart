// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';
import 'filter.dart';
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
    String tags,
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
  PostsOrError<T> getPosts(String tags, int page, {int? limit}) =>
      TaskEither.Do(($) async {
        var lim = limit;

        lim ??= await getSettings().then((value) => value.listing.postsPerPage);

        final newTags = tags.isEmpty ? <String>[] : tags.split(' ');

        return $(tryFetchRemoteData(
          fetcher: () => fetch(newTags, page, limit: lim),
        ));
      });
}

Future<List<T>> getPostsFromTagsOrEmptyFrom<T extends Post>(
  PostRepository<T> repository,
  String tags,
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
              (l) => <T>[],
              (r) => r,
            ));

extension PostRepositoryX<T extends Post> on PostRepository<T> {
  Future<List<T>> getPostsFromTagsOrEmpty(
    String tags, {
    int? limit,
    int page = 1,
  }) =>
      getPostsFromTagsOrEmptyFrom(this, tags, page, limit: limit);

  Future<List<T>> getPostsFromTagsWithBlacklist({
    required String tags,
    int page = 1,
    required Future<Set<String>> blacklist,
    int? hardLimit,
    int? softLimit,
  }) async {
    final posts = await getPostsFromTagsOrEmpty(
      tags,
      page: page,
      limit: hardLimit,
    );

    final bl = await blacklist;

    final postsWithLimit =
        softLimit == null ? posts : posts.take(softLimit).toList();

    return filterTags(
      postsWithLimit.where((e) => !e.isFlash).toList(),
      bl,
    );
  }

  Future<List<T>> getPostsFromTagWithBlacklist({
    required String? tag,
    int page = 1,
    required Future<Set<String>> blacklist,
    int? hardLimit,
    int? softLimit = 30,
  }) async {
    if (tag == null) return [];

    return getPostsFromTagsWithBlacklist(
      tags: tag,
      page: page,
      blacklist: blacklist,
      hardLimit: hardLimit,
      softLimit: softLimit,
    );
  }
}

mixin PostRepositoryMixin<T extends Post> {
  PostRepository<T> get postRepository;

  Future<List<T>> getPostsFromTagsOrEmpty(
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
  PostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.right([]);
}
