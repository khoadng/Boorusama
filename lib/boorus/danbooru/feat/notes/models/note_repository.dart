// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feat/notes/notes.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken? cancelToken,
  });
}
