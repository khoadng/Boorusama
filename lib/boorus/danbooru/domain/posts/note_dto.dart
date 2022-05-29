// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/note_coordinate.dart';
import 'note.dart';

class NoteDto {
  NoteDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.x,
    this.y,
    this.width,
    this.height,
    this.isActive,
    this.postId,
    this.body,
    this.version,
  });

  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int x;
  final int y;
  final int width;
  final int height;
  final bool isActive;
  final int postId;
  final String body;
  final int version;

  factory NoteDto.fromJson(Map<String, dynamic> json) => NoteDto(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        x: json["x"],
        y: json["y"],
        width: json["width"],
        height: json["height"],
        isActive: json["is_active"],
        postId: json["post_id"],
        body: json["body"],
        version: json["version"],
      );
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
