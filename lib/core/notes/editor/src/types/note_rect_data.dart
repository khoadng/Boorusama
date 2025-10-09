// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../note/types.dart';

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

  //FIXME: handle polygon notes
  Note toNote() => Note(
    coordinate: RectangleNoteCoordinate(
      x: x.toDouble(),
      y: y.toDouble(),
      height: height.toDouble(),
      width: width.toDouble(),
    ),
    content: body,
    origin: origin,
  );

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
