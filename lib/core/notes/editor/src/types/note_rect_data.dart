// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../note/types.dart';
import 'note_rect.dart';

class NoteRectData extends Equatable {
  const NoteRectData({
    this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.body,
    this.origin = NoteOrigin.server,
  });

  Note toNote() => Note(
    coordinate: NoteCoordinate(
      x: x.toDouble(),
      y: y.toDouble(),
      height: height.toDouble(),
      width: width.toDouble(),
    ),
    content: body,
    origin: origin,
  );

  NoteRect toNoteRect({
    required Size originalImageSize,
    required Size imageSize,
  }) {
    final scaleX = imageSize.width / originalImageSize.width;
    final scaleY = imageSize.height / originalImageSize.height;

    final startX = x * scaleX;
    final startY = y * scaleY;
    final endX = (x + width) * scaleX;
    final endY = (y + height) * scaleY;

    return NoteRect(
      Offset(startX, startY),
      Offset(endX, endY),
      body: body,
      id: id,
    );
  }

  final int? id;
  final int x;
  final int y;
  final int width;
  final int height;
  final String body;
  final NoteOrigin origin;

  @override
  List<Object?> get props => [id, x, y, width, height, body, origin];
}
