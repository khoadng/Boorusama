// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken? cancelToken,
  });
}
