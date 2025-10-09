// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../note/types.dart';
import 'note_rect.dart';
import 'note_rect_converter.dart';
import 'note_rect_data.dart';
import 'note_state.dart';

class TrackedNote extends Equatable {
  const TrackedNote({
    required this.localId,
    required this.serverId,
    required this.rect,
    required this.state,
  });

  factory TrackedNote.fromServer({
    required int serverId,
    required NoteRect rect,
  }) {
    return TrackedNote(
      localId: const Uuid().v4(),
      serverId: serverId,
      rect: rect,
      state: NoteState.unchanged,
    );
  }

  factory TrackedNote.newNote({
    required NoteRect rect,
  }) {
    return TrackedNote(
      localId: const Uuid().v4(),
      serverId: null,
      rect: rect,
      state: NoteState.added,
    );
  }

  /// Unique local identifier for tracking (UUID)
  final String localId;

  /// Server-assigned ID (null for new notes)
  final int? serverId;

  /// The note rectangle data
  final NoteRect rect;

  final NoteState state;

  TrackedNote markModified() {
    // If already added, keep it as added
    if (state == NoteState.added) {
      return this;
    }
    return copyWith(state: NoteState.modified);
  }

  TrackedNote markDeleted() {
    return copyWith(state: NoteState.deleted);
  }

  /// Mark this note as unchanged (e.g., after successful save or undo)
  TrackedNote markUnchanged() {
    return copyWith(state: NoteState.unchanged);
  }

  TrackedNote updateRect(NoteRect newRect) {
    final newState = state == NoteState.added || state == NoteState.modified
        ? state
        : NoteState.modified;

    return copyWith(
      rect: newRect,
      state: newState,
    );
  }

  bool get isUnchanged => state == NoteState.unchanged;
  bool get isAdded => state == NoteState.added;
  bool get isModified => state == NoteState.modified;
  bool get isDeleted => state == NoteState.deleted;
  bool get hasChanges => !isUnchanged;

  NoteRectData toRectData({
    required Size originalImageSize,
    required Size imageSize,
  }) => NoteRectConverter.toRectData(
    rect,
    originalImageSize: originalImageSize,
    imageSize: imageSize,
    origin: serverId == null ? NoteOrigin.local : NoteOrigin.server,
  );

  TrackedNote copyWith({
    String? localId,
    int? serverId,
    NoteRect? rect,
    NoteState? state,
  }) {
    return TrackedNote(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      rect: rect ?? this.rect,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [localId];
}
