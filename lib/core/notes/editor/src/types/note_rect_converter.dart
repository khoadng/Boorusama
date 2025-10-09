// Dart imports:
import 'dart:ui';

// Project imports:
import '../../../note/types.dart';
import 'note_rect.dart';
import 'note_rect_data.dart';

class NoteRectConverter {
  static NoteRect toNoteRect(
    NoteRectData data, {
    required Size originalImageSize,
    required Size imageSize,
  }) {
    final scaleX = imageSize.width / originalImageSize.width;
    final scaleY = imageSize.height / originalImageSize.height;

    final startX = data.x * scaleX;
    final startY = data.y * scaleY;
    final endX = (data.x + data.width) * scaleX;
    final endY = (data.y + data.height) * scaleY;

    return NoteRect(
      Offset(startX, startY),
      Offset(endX, endY),
      body: data.body,
      id: data.id,
    );
  }

  static NoteRectData toRectData(
    NoteRect rect, {
    required Size originalImageSize,
    required Size imageSize,
    NoteOrigin origin = NoteOrigin.server,
  }) {
    final scaleX = originalImageSize.width / imageSize.width;
    final scaleY = originalImageSize.height / imageSize.height;

    final startX = rect.start.dx * scaleX;
    final startY = rect.start.dy * scaleY;
    final endX = rect.end.dx * scaleX;
    final endY = rect.end.dy * scaleY;

    // Normalize coordinates to ensure positive width/height
    // Server expects x,y to be top-left corner
    final normalizedX = startX < endX ? startX : endX;
    final normalizedY = startY < endY ? startY : endY;
    final normalizedWidth = (endX - startX).abs();
    final normalizedHeight = (endY - startY).abs();

    return NoteRectData(
      id: rect.id,
      x: normalizedX.toInt(),
      y: normalizedY.toInt(),
      width: normalizedWidth.toInt(),
      height: normalizedHeight.toInt(),
      body: rect.body,
      origin: origin,
    );
  }
}
