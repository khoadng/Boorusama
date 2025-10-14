// Project imports:
import '../../../filter/types.dart';
import '../types/post.dart';
import '../types/post_repository.dart';

extension PostRepositoryX<T extends Post> on PostRepository<T> {
  Future<PostResult<T>> getPostsFromTagsOrEmpty(
    String tags, {
    int? limit,
    int page = 1,
    PostFetchOptions? options,
  }) =>
      getPosts(
        tags,
        page,
        limit: limit,
        options: options,
      ).run().then(
        (value) => value.fold(
          (l) => PostResult.empty(),
          (r) => r,
        ),
      );

  Future<List<T>> getPostsFromTagsWithBlacklist({
    required String tags,
    required Future<Set<String>> blacklist,
    int page = 1,
    int? hardLimit,
    int? softLimit,
    PostFetchOptions? options,
  }) async {
    final posts = await getPostsFromTagsOrEmpty(
      tags,
      page: page,
      limit: hardLimit,
      options: options,
    );

    final bl = await blacklist;

    final postsWithLimit = softLimit == null
        ? posts.posts
        : posts.posts.take(softLimit).toList();

    return filterTags(
      postsWithLimit.where((e) => !e.isFlash).toList(),
      bl,
    );
  }

  Future<List<T>> getPostsFromTagWithBlacklist({
    required String? tag,
    required Future<Set<String>> blacklist,
    int page = 1,
    int? hardLimit,
    int? softLimit = 30,
    PostFetchOptions? options,
  }) async {
    if (tag == null) return [];

    return getPostsFromTagsWithBlacklist(
      tags: tag,
      page: page,
      blacklist: blacklist,
      hardLimit: hardLimit,
      softLimit: softLimit,
      options: options,
    );
  }
}
