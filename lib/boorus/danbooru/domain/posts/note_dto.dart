// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/note_coordinate.dart';
import 'note.dart';

part 'note_dto.freezed.dart';
part 'note_dto.g.dart';

@freezed
abstract class NoteDto with _$NoteDto {
  const factory NoteDto({
    @required int id,
    @required String created_at,
    @required String updated_at,
    @required int x,
    @required int y,
    @required int width,
    @required int height,
    @required bool is_active,
    @required int post_id,
    @required String body,
    @required int version,
  }) = _NoteDto;

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);
}

extension NoteDtoX on NoteDto {
  Note toEntity() {
    final coord = NoteCoordinate(
        x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    return Note(
      coordinate: coord,
      content: body,
    );
  }
}
