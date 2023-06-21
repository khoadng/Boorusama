// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';
import 'package:boorusama/foundation/http/http.dart';

List<Note> parseNote(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => NoteDto.fromJson(item),
    ).map((e) => e.toEntity()).toList();

const _notesLimit = 200;

class NoteRepositoryApi implements NoteRepository {
  NoteRepositoryApi(this._api);
  final DanbooruApi _api;

  @override
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _api
          .getNotes(
            postId,
            _notesLimit,
            cancelToken: cancelToken,
          )
          .then(parseNote);
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get notes from $postId'),
          stackTrace,
        );
      }
    }
  }
}

extension NoteDtoX on NoteDto {
  Note toEntity() {
    final coord = NoteCoordinate(
      x: x.toDouble(),
      y: y.toDouble(),
      width: width.toDouble(),
      height: height.toDouble(),
    );

    return Note(
      coordinate: coord,
      content: body,
    );
  }
}
