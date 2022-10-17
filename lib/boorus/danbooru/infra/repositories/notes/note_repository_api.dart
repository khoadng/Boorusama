// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Note> parseNote(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => NoteDto.fromJson(item),
    ).map((e) => e.toEntity()).toList();

class NoteRepositoryApi implements NoteRepository {
  NoteRepositoryApi(this._api);
  final Api _api;

  @override
  Future<List<Note>> getNotesFrom(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _api
          .getNotes(
            postId,
            cancelToken: cancelToken,
          )
          .then(parseNote);
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception('Failed to get notes from $postId');
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
