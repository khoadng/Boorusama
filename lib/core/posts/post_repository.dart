// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/functional.dart';
import 'filter.dart';
import 'post.dart';

class PostResult<T extends Post> extends Equatable {
  const PostResult({
    required this.posts,
    required this.total,
  });

  PostResult.empty()
      : posts = <T>[],
        total = 0;

  PostResult<T> copyWith({
    List<T>? posts,
    int? Function()? total,
  }) =>
      PostResult(
        posts: posts ?? this.posts,
        total: total != null ? total() : this.total,
      );

  final List<T> posts;
  final int? total;

  @override
  List<Object?> get props => [posts, total];
}

extension PostResultX<T extends Post> on List<T> {
  PostResult<T> toResult({
    int? total,
  }) =>
      PostResult(
        posts: this,
        total: total,
      );
}

typedef PostsOrErrorCore<T extends Post>
    = TaskEither<BooruError, PostResult<T>>;

typedef PostsOrError<T extends Post> = PostsOrErrorCore<T>;

typedef PostFutureFetcher<T extends Post> = Future<PostResult<T>> Function(
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
  final Future<ImageListingSettings> Function() getSettings;

  @override
  PostsOrError<T> getPosts(String tags, int page, {int? limit}) =>
      TaskEither.Do(($) async {
        var lim = limit;

        lim ??= await getSettings().then((value) => value.postsPerPage);

        final newTags = tags.isEmpty ? <String>[] : tags.split(' ');

        return $(tryFetchRemoteData(
          fetcher: () => fetch(newTags, page, limit: lim),
        ));
      });
}

extension PostRepositoryX<T extends Post> on PostRepository<T> {
  Future<PostResult<T>> getPostsFromTagsOrEmpty(
    String tags, {
    int? limit,
    int page = 1,
  }) =>
      getPosts(
        tags,
        page,
        limit: limit,
      ).run().then((value) => value.fold(
            (l) => PostResult.empty(),
            (r) => r,
          ));

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
        softLimit == null ? posts.posts : posts.posts.take(softLimit).toList();

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

class EmptyPostRepository extends PostRepository {
  EmptyPostRepository();

  @override
  PostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.right(PostResult.empty());
}
