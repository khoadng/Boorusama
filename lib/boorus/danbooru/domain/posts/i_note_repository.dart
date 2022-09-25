// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';

abstract class INoteRepository {
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken? cancelToken,
  });
}
