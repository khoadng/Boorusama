// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class CommentCacher implements CommentRepository {
  CommentCacher({
    required this.cache,
    required this.repo,
  });

  final Cacher cache;
  final CommentRepository repo;

  @override
  Future<List<Comment>> getCommentsFromPostId(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    final key = postId.toString();
    final items = cache.get(key);

    if (items != null) return items;

    final fresh = await repo.getCommentsFromPostId(
      postId,
      cancelToken: cancelToken,
    );
    await cache.put(key, fresh);

    return fresh;
  }

  @override
  Future<bool> postComment(int postId, String content) {
    return repo.postComment(postId, content);
  }

  @override
  Future<bool> updateComment(int commentId, String content) {
    return repo.updateComment(commentId, content);
  }

  @override
  Future<bool> deleteComment(int commentId) {
    return repo.deleteComment(commentId);
  }
}
