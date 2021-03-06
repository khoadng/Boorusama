// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/note_dto.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';

final noteProvider =
    Provider<INoteRepository>((ref) => NoteRepository(ref.watch(apiProvider)));

class NoteRepository implements INoteRepository {
  final IApi _api;

  NoteRepository(this._api);

  @override
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken cancelToken,
  }) async {
    try {
      final value = await _api.getNotes(postId, cancelToken: cancelToken);
      return List<Note>.from(value.response.data
          .map((note) => NoteDto.fromJson(note).toEntity())
          .toList());
    } on DioError catch (e) {
      if (e.type == DioErrorType.CANCEL) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception("Failed to get notes from $postId");
      }
    }
  }
}
