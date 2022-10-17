// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes/notes.dart';

class NoteDto {
  NoteDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isActive,
    required this.postId,
    required this.body,
    required this.version,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) => NoteDto(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        x: json['x'],
        y: json['y'],
        width: json['width'],
        height: json['height'],
        isActive: json['is_active'],
        postId: json['post_id'],
        body: json['body'],
        version: json['version'],
      );

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
