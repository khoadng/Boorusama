// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../posts/post/post.dart';

class Note extends Equatable {
  const Note({
    required this.coordinate,
    required this.content,
  });

  factory Note.empty() => Note(
        coordinate: NoteCoordinate.shrink(),
        content: '',
      );

  final NoteCoordinate coordinate;
  final String content;

  @override
  List<Object?> get props => [coordinate, content];
}

extension NoteX on Note {
  Note copyWith({
    NoteCoordinate? coordinate,
    String? content,
  }) =>
      Note(
        coordinate: coordinate ?? this.coordinate,
        content: content ?? this.content,
      );
}

abstract interface class NoteRepository {
  Future<List<Note>> getNotes(int postId);
}

class NoteRepositoryBuilder implements NoteRepository {
  const NoteRepositoryBuilder({
    required this.fetch,
  });

  final Future<List<Note>> Function(int postId) fetch;

  @override
  Future<List<Note>> getNotes(int postId) => fetch(postId);
}

class EmptyNoteRepository implements NoteRepository {
  const EmptyNoteRepository();

  @override
  Future<List<Note>> getNotes(int postId) async => [];
}

class NoteCoordinate extends Equatable {
  const NoteCoordinate({
    required this.x,
    required this.y,
    required this.height,
    required this.width,
  });

  factory NoteCoordinate.shrink() => const NoteCoordinate(
        x: 0,
        y: 0,
        height: 0,
        width: 0,
      );

  final double x;
  final double y;
  final double height;
  final double width;

  NoteCoordinate withPercent(double widthPercent, double heightPercent) =>
      NoteCoordinate(
        x: x * widthPercent,
        y: y * heightPercent,
        height: height * heightPercent,
        width: width * widthPercent,
      );

  @override
  List<Object?> get props => [x, y, width, height];
}

extension NoteCoordX on Note {
  Note adjustNoteCoordFor(
    Post post, {
    required double widthConstraint,
    required double heightConstraint,
  }) {
    if (post.width == 0 || post.height == 0) {
      return this;
    }

    final widthPercent = widthConstraint / post.width;
    final heightPercent = heightConstraint / post.height;

    return copyWith(
      coordinate: coordinate.withPercent(widthPercent, heightPercent),
    );
  }
}

enum NoteQuadrant {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

extension NoteCoordinateQuadrant on NoteCoordinate {
  NoteQuadrant calculateQuadrant(double screenWidth, double screenHeight) {
    final halfWidth = screenWidth / 2;
    final halfHeight = screenHeight / 2;

    if (x < halfWidth && y < halfHeight) {
      return NoteQuadrant.topLeft;
    } else if (x > halfWidth && y < halfHeight) {
      return NoteQuadrant.topRight;
    } else if (x < halfWidth && y > halfHeight) {
      return NoteQuadrant.bottomLeft;
    } else {
      return NoteQuadrant.bottomRight;
    }
  }
}
