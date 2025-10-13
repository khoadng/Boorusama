// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:booru_clients/szurubooru.dart';

// Project imports:
import '../../../core/notes/note/types.dart';

Note szurubooruNoteToNote(
  NoteDto note, {
  required double imageWidth,
  required double imageHeight,
}) {
  // Convert normalized coordinates (0-1) to pixel coordinates
  final points = note.polygon
      .where((point) => point.length >= 2)
      .map(
        (point) => Offset(
          point[0] * imageWidth,
          point[1] * imageHeight,
        ),
      )
      .toList();

  return Note(
    coordinate: PolygonNoteCoordinate(points: points),
    content: note.text ?? '',
  );
}
