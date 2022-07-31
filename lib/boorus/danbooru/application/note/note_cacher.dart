// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/infrastructure/caching/cacher.dart';

class NoteCacher implements INoteRepository {
  const NoteCacher({
    required this.cache,
    required this.repo,
  });

  final INoteRepository repo;
  final Cacher<int, List<Note>> cache;

  @override
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    final items = cache.get(postId);

    if (items != null) return items;

    final fresh = await repo.getNotesFrom(
      postId,
      cancelToken: cancelToken,
    );
    cache.put(postId, fresh);

    return fresh;
  }
}
