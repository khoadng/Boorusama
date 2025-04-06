// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/caching.dart';
import '../../../../search/queries/query.dart';
import '../../../../search/selected_tags/tag.dart';
import '../types/post.dart';
import '../types/post_repository.dart';

class EmptyPostRepository extends PostRepository {
  EmptyPostRepository();

  @override
  PostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) =>
      TaskEither.right(PostResult.empty());

  @override
  PostsOrError getPostsFromController(
    SearchTagSet controller,
    int page, {
    int? limit,
    PostFetchOptions? options,
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
    PostFetchOptions? options,
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
    SearchTagSet controller,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) =>
      repository.getPostsFromController(controller, page, limit: limit);
}
