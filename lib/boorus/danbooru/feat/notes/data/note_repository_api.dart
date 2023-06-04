// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/feat/notes/notes.dart';
import 'package:boorusama/foundation/http/http.dart';

List<Note> parseNote(HttpResponse<dynamic> value) => parse(
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
    } on DioError catch (e, stackTrace) {
      if (e.type == DioErrorType.cancel) {
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
