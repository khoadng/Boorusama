// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'note_coordinate.dart';
import 'note_display_mode.dart';
import 'note_font_size.dart';
import 'note_origin.dart';

class Note extends Equatable {
  Note({
    required this.coordinate,
    required this.content,
    this.fontSize,
    this.origin,
  }) : strippedContent = content.replaceAll(RegExp('<[^>]*>'), '').trim();

  const Note.empty()
    : coordinate = const RectangleNoteCoordinate.shrink(),
      content = '',
      strippedContent = '',
      origin = null,
      fontSize = null;

  final NoteCoordinate coordinate;
  final String content;
  final NoteFontSize? fontSize;
  final String strippedContent;
  final NoteOrigin? origin;

  Note copyWith({
    NoteCoordinate? coordinate,
    NoteFontSize? fontSize,
    NoteOrigin? origin,
  }) => Note(
    coordinate: coordinate ?? this.coordinate,
    content: content,
    fontSize: fontSize ?? this.fontSize,
    origin: origin ?? this.origin,
  );

  Note adjust({
    required double width,
    required double height,
    required double widthConstraint,
    required double heightConstraint,
    NoteDisplayMode? displayMode,
  }) {
    if (width == 0 || height == 0) return this;

    final widthPercent = widthConstraint / width;
    final heightPercent = heightConstraint / height;
    final newCoordinate = coordinate.withPercent(widthPercent, heightPercent);

    return copyWith(
      coordinate: newCoordinate,
      fontSize: switch (displayMode) {
        NoteDisplayMode.box || null => fontSize,
        NoteDisplayMode.inlineHorizontal ||
        NoteDisplayMode.inlineVertical => NoteFontSize.calculate(
          text: strippedContent,
          coordinate: newCoordinate,
        ),
      },
    );
  }

  @override
  List<Object?> get props => [coordinate, content, fontSize, origin];
}

abstract interface class NoteRepository {
  Future<List<Note>> getNotes(int postId);
}
