// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [start, end, body, id];
}
