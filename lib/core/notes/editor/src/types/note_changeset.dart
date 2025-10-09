// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'note_rect_data.dart';
import 'note_state.dart';
import 'tracked_note.dart';

/// Represents the changes to be submitted to the server
class NoteChangeset extends Equatable {
  const NoteChangeset({
    required this.created,
    required this.updated,
    required this.deleted,
  });

  factory NoteChangeset.fromTrackedNotes({
    required List<TrackedNote> notes,
    required Size originalImageSize,
    required Size imageSize,
  }) {
    final created = <NoteRectData>[];
    final updated = <NoteRectData>[];
    final deleted = <int>[];

    for (final note in notes) {
      switch (note.state) {
        case NoteState.unchanged:
          // No action needed
          break;

        case NoteState.added:
          // Convert rect to data and add to created list
          final data = note.toRectData(
            originalImageSize: originalImageSize,
            imageSize: imageSize,
          );
          created.add(data);

        case NoteState.modified:
          // Only include if note has server ID
          if (note.serverId != null) {
            final data = note.toRectData(
              originalImageSize: originalImageSize,
              imageSize: imageSize,
            );
            updated.add(data);
          }

        case NoteState.deleted:
          // Only include server ID for deletion
          // New notes that are deleted should be ignored
          if (note.serverId != null) {
            deleted.add(note.serverId!);
          }
      }
    }

    return NoteChangeset(
      created: created,
      updated: updated,
      deleted: deleted,
    );
  }

  /// Notes to be created on the server (no IDs)
  final List<NoteRectData> created;

  /// Notes to be updated on the server (with IDs)
  final List<NoteRectData> updated;

  /// Note IDs to be deleted on the server
  final List<int> deleted;

  /// Check if there are any changes
  bool get hasChanges =>
      created.isNotEmpty || updated.isNotEmpty || deleted.isNotEmpty;

  /// Check if changeset is empty
  bool get isEmpty => !hasChanges;

  @override
  List<Object?> get props => [created, updated, deleted];
}
