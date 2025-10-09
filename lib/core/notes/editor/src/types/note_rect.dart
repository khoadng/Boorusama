// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../note/types.dart';
import 'note_rect_data.dart';

class NoteRect extends Equatable {
  const NoteRect(
    this.start,
    this.end, {
    this.body = '',
    this.id,
  });

  final Offset start;
  final Offset end;
  final String body;
  final int? id;

  NoteRect copyWith({
    Offset? start,
    Offset? end,
    String? body,
    int? id,
  }) => NoteRect(
    start ?? this.start,
    end ?? this.end,
    body: body ?? this.body,
    id: id ?? this.id,
  );

  NoteRect translate(Offset delta) {
    return NoteRect(start + delta, end + delta, body: body, id: id);
  }

  Rect toRect() {
    return Rect.fromPoints(start, end);
  }

  bool contains(Offset position) {
    return toRect().contains(position);
  }

  bool isTooSmall({double minSize = 20.0}) {
    final rect = toRect();
    return rect.width.abs() < minSize || rect.height.abs() < minSize;
  }

  NoteRectData toRectData({
    required Size originalImageSize,
    required Size imageSize,
    NoteOrigin origin = NoteOrigin.server,
  }) {
    final scaleX = originalImageSize.width / imageSize.width;
    final scaleY = originalImageSize.height / imageSize.height;

    final startX = start.dx * scaleX;
    final startY = start.dy * scaleY;
    final endX = end.dx * scaleX;
    final endY = end.dy * scaleY;

    // Normalize coordinates to ensure positive width/height
    // Server expects x,y to be top-left corner
    final normalizedX = startX < endX ? startX : endX;
    final normalizedY = startY < endY ? startY : endY;
    final normalizedWidth = (endX - startX).abs();
    final normalizedHeight = (endY - startY).abs();

    return NoteRectData(
      id: id,
      x: normalizedX.toInt(),
      y: normalizedY.toInt(),
      width: normalizedWidth.toInt(),
      height: normalizedHeight.toInt(),
      body: body,
      origin: origin,
    );
  }

  @override
  List<Object?> get props => [start, end, body, id];
}
