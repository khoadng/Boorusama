// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';

const _notesLimit = 200;

class NoteRepositoryApi implements NoteRepository {
  NoteRepositoryApi(this.client);
  final DanbooruClient client;

  @override
  Future<List<Note>> getNotes(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    try {
      return client
          .getNotes(
            postId: postId,
            limit: _notesLimit,
          )
          .then((value) => value.map((e) => e.toEntity()).toList());
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
