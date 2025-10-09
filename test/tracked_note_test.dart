// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/notes/editor/src/types/note_rect.dart';
import 'package:boorusama/core/notes/editor/src/types/note_state.dart';
import 'package:boorusama/core/notes/editor/src/types/tracked_note.dart';

void main() {
  const testRect = NoteRect(
    Offset(100, 100),
    Offset(200, 200),
    body: 'test note',
    id: 123,
  );

  group('TrackedNote', () {
    test('factory constructors create correct states', () {
      final fromServer = TrackedNote.fromServer(serverId: 456, rect: testRect);
      final newNote = TrackedNote.newNote(rect: testRect);

      expect(fromServer.state, NoteState.unchanged);
      expect(fromServer.serverId, 456);
      expect(newNote.state, NoteState.added);
      expect(newNote.serverId, isNull);
    });

    test('state transitions work correctly', () {
      final unchanged = TrackedNote.fromServer(serverId: 123, rect: testRect);
      final added = TrackedNote.newNote(rect: testRect);

      // Modifying unchanged → modified
      expect(unchanged.markModified().state, NoteState.modified);

      // Modifying added → stays added
      expect(added.markModified().state, NoteState.added);

      // Deleting → deleted
      expect(unchanged.markDeleted().state, NoteState.deleted);

      // Resetting → unchanged
      expect(
        unchanged.markModified().markUnchanged().state,
        NoteState.unchanged,
      );
    });

    test('updateRect triggers correct state transitions', () {
      final unchanged = TrackedNote.fromServer(serverId: 123, rect: testRect);
      final added = TrackedNote.newNote(rect: testRect);
      final newRect = testRect.translate(const Offset(50, 50));

      // Updating unchanged → modified
      expect(unchanged.updateRect(newRect).state, NoteState.modified);

      // Updating added → stays added
      expect(added.updateRect(newRect).state, NoteState.added);

      // IDs preserved
      expect(unchanged.updateRect(newRect).serverId, 123);
    });

    test('change detection helpers work correctly', () {
      final unchanged = TrackedNote.fromServer(serverId: 1, rect: testRect);
      final added = TrackedNote.newNote(rect: testRect);
      final modified = unchanged.markModified();
      final deleted = unchanged.markDeleted();

      expect(unchanged.hasChanges, isFalse);
      expect(added.hasChanges, isTrue);
      expect(modified.hasChanges, isTrue);
      expect(deleted.hasChanges, isTrue);
    });

    test('equality based on localId (identity)', () {
      final note1 = TrackedNote.newNote(rect: testRect);
      final note2 = TrackedNote.newNote(rect: testRect);
      final note1Modified = note1.markModified();

      // Different localIds → not equal
      expect(note1, isNot(equals(note2)));

      // Same localId → equal (even with different state)
      expect(note1, equals(note1Modified));
    });

    test('undo scenarios restore correct states', () {
      // Move server note → undo
      final original = TrackedNote.fromServer(serverId: 123, rect: testRect);
      final moved = original.updateRect(
        testRect.translate(const Offset(50, 50)),
      );
      final undone = moved.copyWith(rect: testRect, state: NoteState.unchanged);

      expect(moved.state, NoteState.modified);
      expect(undone.state, NoteState.unchanged);
      expect(undone.hasChanges, isFalse);

      // Delete server note → undo
      final deleted = original.markDeleted();
      final undeleted = deleted.markUnchanged();

      expect(deleted.state, NoteState.deleted);
      expect(undeleted.state, NoteState.unchanged);
      expect(undeleted.hasChanges, isFalse);
    });
  });
}
