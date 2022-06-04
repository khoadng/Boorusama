// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'note.dart';

abstract class INoteRepository {
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken? cancelToken,
  });
}
