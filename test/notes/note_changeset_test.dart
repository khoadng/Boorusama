// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/notes/editor/src/types/note_changeset.dart';
import 'package:boorusama/core/notes/editor/src/types/note_rect.dart';
import 'package:boorusama/core/notes/editor/src/types/tracked_note.dart';

void main() {
  group('NoteChangeset', () {
    const imageSize = Size(800, 600);

    test('fromTrackedNotes correctly categorizes all changes', () {
      final notes = [
        // Unchanged - should be ignored
        TrackedNote.fromServer(
          serverId: 1,
          rect: const NoteRect(
            Offset(10, 10),
            Offset(50, 50),
            body: 'unchanged',
            id: 1,
          ),
        ),
        // New notes - should be created
        TrackedNote.newNote(
          rect: const NoteRect(
            Offset(100, 100),
            Offset(200, 200),
            body: 'new',
          ),
        ),
        TrackedNote.newNote(
          rect: const NoteRect(
            Offset(700, 700),
            Offset(750, 750),
            body: 'another new',
          ),
        ),
        // Modified note - should be updated
        TrackedNote.fromServer(
          serverId: 2,
          rect: const NoteRect(
            Offset(300, 300),
            Offset(400, 400),
            body: 'modified',
            id: 2,
          ),
        ).markModified(),
        // Deleted note - should be in deleted list
        TrackedNote.fromServer(
          serverId: 3,
          rect: const NoteRect(
            Offset(500, 500),
            Offset(600, 600),
            body: 'deleted',
            id: 3,
          ),
        ).markDeleted(),
      ];

      final changeset = NoteChangeset.fromTrackedNotes(
        notes: notes,
        originalImageSize: imageSize,
        imageSize: imageSize,
      );

      expect(changeset.created.length, 2);
      expect(changeset.created[0].body, 'new');
      expect(changeset.created[0].id, isNull);

      expect(changeset.updated.length, 1);
      expect(changeset.updated[0].id, 2);
      expect(changeset.updated[0].body, 'modified');

      expect(changeset.deleted.length, 1);
      expect(changeset.deleted[0], 3);

      expect(changeset.hasChanges, isTrue);
      expect(changeset.isEmpty, isFalse);
    });

    test('deleted new notes are NOT sent to server', () {
      // Critical: if user creates then deletes a note,
      // we should NOT send a delete request to the server
      final newThenDeleted = TrackedNote.newNote(
        rect: const NoteRect(
          Offset(100, 100),
          Offset(200, 200),
          body: 'created then deleted',
        ),
      ).markDeleted();

      final changeset = NoteChangeset.fromTrackedNotes(
        notes: [newThenDeleted],
        originalImageSize: imageSize,
        imageSize: imageSize,
      );

      // Should not be in any list
      expect(changeset.isEmpty, isTrue);
    });

    test('only notes with server IDs appear in updated/deleted lists', () {
      final notes = [
        // Modified note WITH server ID
        TrackedNote.fromServer(
          serverId: 123,
          rect: const NoteRect(
            Offset(100, 100),
            Offset(200, 200),
            body: 'has server id',
            id: 123,
          ),
        ).markModified(),
        // Deleted note WITH server ID
        TrackedNote.fromServer(
          serverId: 456,
          rect: const NoteRect(
            Offset(300, 300),
            Offset(400, 400),
            body: 'to delete',
            id: 456,
          ),
        ).markDeleted(),
      ];

      final changeset = NoteChangeset.fromTrackedNotes(
        notes: notes,
        originalImageSize: imageSize,
        imageSize: imageSize,
      );

      expect(changeset.updated.length, 1);
      expect(changeset.updated[0].id, 123);
      expect(changeset.deleted.length, 1);
      expect(changeset.deleted[0], 456);
    });

    test('preserves rect data correctly', () {
      final newNote = TrackedNote.newNote(
        rect: const NoteRect(
          Offset(100, 150),
          Offset(250, 300),
          body: 'test content',
        ),
      );

      final changeset = NoteChangeset.fromTrackedNotes(
        notes: [newNote],
        originalImageSize: imageSize,
        imageSize: imageSize,
      );

      final created = changeset.created[0];
      expect(created.x, 100);
      expect(created.y, 150);
      expect(created.width, 150); // 250 - 100
      expect(created.height, 150); // 300 - 150
      expect(created.body, 'test content');
    });
  });
}
