// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class NoteCacher implements NoteRepository {
  const NoteCacher({
    required this.cache,
    required this.repo,
  });

  final NoteRepository repo;
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
    await cache.put(postId, fresh);

    return fresh;
  }
}
