// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/caching.dart';
import 'package:boorusama/foundation/http.dart';
import 'package:boorusama/functional.dart';
import 'filter.dart';
import 'post.dart';

class PostRepositoryBuilder<T extends Post> implements PostRepository<T> {
  PostRepositoryBuilder({
    required this.fetch,
    required this.getSettings,
    this.fetchFromController,
    required this.getComposer,
  });

  final TagQueryComposer Function() getComposer;

  final PostFutureFetcher<T> fetch;
  final PostFutureControllerFetcher<T>? fetchFromController;
  final Future<ImageListingSettings> Function() getSettings;
  @override
  TagQueryComposer get tagComposer => getComposer();

  @override
  PostsOrError<T> getPosts(String tags, int page, {int? limit}) =>
      TaskEither.Do(($) async {
        var lim = limit;

        lim ??= await getSettings().then((value) => value.postsPerPage);

        final newTags = tags.isEmpty ? <String>[] : tags.split(' ');

        final tags2 = tagComposer.compose(newTags);

        return $(tryFetchRemoteData(
          fetcher: () => fetch(tags2, page, limit: lim),
        ));
      });

  @override
  PostsOrError<T> getPostsFromController(
    SelectedTagController controller,
    int page, {
    int? limit,
  }) =>
      fetchFromController != null
          ? TaskEither.Do(($) async {
              var lim = limit;

              lim ??= await getSettings().then((value) => value.postsPerPage);

              return $(tryFetchRemoteData(
                fetcher: () =>
                    fetchFromController!(controller, page, limit: lim),
              ));
            })
          : getPosts(
              controller.rawTagsString,
              page,
              limit: limit,
            );
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

  @override
  PostsOrError getPostsFromController(
    SelectedTagController controller,
    int page, {
    int? limit,
  }) =>
      TaskEither.right(PostResult.empty());

  @override
  final TagQueryComposer tagComposer = EmptyTagQueryComposer();
}

class PostRepositoryCacher<T extends Post> implements PostRepository<T> {
  PostRepositoryCacher({
    required this.repository,
    required this.cache,
    this.keyBuilder,
  });

  final PostRepository<T> repository;
  final Cacher<String, List<T>> cache;
  final String Function(String tags, int page, {int? limit})? keyBuilder;
  @override
  TagQueryComposer get tagComposer => repository.tagComposer;

  @override
  PostsOrError<T> getPosts(
    String tags,
    int page, {
    int? limit,
  }) =>
      TaskEither.Do(($) async {
        final tagString = tags;
        final defaultKey = '$tagString-$page-$limit';
        final name = keyBuilder != null
            ? keyBuilder!(tags, page, limit: limit)
            : defaultKey;

        // Check if the data exists in the cache
        if (cache.exist(name)) {
          return cache.get(name)!.toResult();
        }

        // If data is not in the cache, retrieve it from the repository and update the cache
        final data = await $(repository.getPosts(tags, page, limit: limit));

        await cache.put(name, data.posts);

        return data;
      });

  @override
  PostsOrError<T> getPostsFromController(
          SelectedTagController controller, int page,
          {int? limit}) =>
      repository.getPostsFromController(controller, page, limit: limit);
}
