// Package imports:
import 'package:booru_clients/szurubooru.dart';

// Project imports:
import '../../../core/notes/note/types.dart';

Note szurubooruNoteToNote(
  NoteDto note, {
  required double imageWidth,
  required double imageHeight,
}) {
  final bounds = _calculateBoundingBox(note.polygon);

  return Note(
    coordinate: NoteCoordinate(
      x: bounds.x * imageWidth,
      y: bounds.y * imageHeight,
      width: bounds.width * imageWidth,
      height: bounds.height * imageHeight,
    ),
    content: note.text ?? '',
  );
}

({double x, double y, double width, double height}) _calculateBoundingBox(
  List<List<double>> polygon,
) {
  if (polygon.isEmpty) {
    return (x: 0.0, y: 0.0, width: 0.0, height: 0.0);
  }

  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = double.negativeInfinity;
  var maxY = double.negativeInfinity;

  for (final point in polygon) {
    if (point.length < 2) continue;

    final x = point[0];
    final y = point[1];

    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  }

  return (
    x: minX,
    y: minY,
    width: maxX - minX,
    height: maxY - minY,
  );
}
