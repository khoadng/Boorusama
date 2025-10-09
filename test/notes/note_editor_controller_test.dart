// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/notes/editor/src/controllers/note_editor_controller.dart';
import 'package:boorusama/core/notes/editor/src/types/note_image.dart';
import 'package:boorusama/core/notes/editor/src/types/note_rect.dart';
import 'package:boorusama/core/notes/editor/src/types/note_rect_data.dart';
import 'package:boorusama/core/notes/editor/src/types/note_state.dart';

void main() {
  group('NoteEditorController', () {
    late NoteEditorController controller;

    setUp(() {
      controller = NoteEditorController(
        image: const NoteImage(
          width: 800,
          height: 600,
        ),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('loads initial notes with unchanged state', () {
      final initialNotes = [
        const NoteRectData(
          id: 1,
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          body: 'Note 1',
        ),
        const NoteRectData(
          id: 2,
          x: 300,
          y: 300,
          width: 100,
          height: 100,
          body: 'Note 2',
        ),
      ];

      controller.loadInitialNotes(initialNotes);

      expect(controller.notes.length, 2);
      expect(controller.notes[0].state, NoteState.unchanged);
      expect(controller.notes[0].serverId, 1);
      expect(controller.notes[1].state, NoteState.unchanged);
      expect(controller.notes[1].serverId, 2);
    });

    test('state transitions work correctly', () {
      controller.loadInitialNotes([
        const NoteRectData(
          id: 123,
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          body: 'Original',
        ),
      ]);
      controller.initializeHistory();

      // Modify unchanged → modified
      controller.updateNote(
        0,
        const NoteRect(
          Offset(200, 200),
          Offset(300, 300),
          body: 'Original',
          id: 123,
        ),
      );
      expect(controller.notes[0].state, NoteState.modified);
      expect(controller.notes[0].serverId, 123);

      // Add new note → added
      controller.addNote(
        const NoteRect(Offset(400, 400), Offset(500, 500), body: 'New'),
        'New',
      );
      expect(controller.notes[1].state, NoteState.added);
      expect(controller.notes[1].serverId, isNull);

      // Modify added → stays added
      controller.updateNote(
        1,
        const NoteRect(Offset(450, 450), Offset(550, 550), body: 'New'),
      );
      expect(controller.notes[1].state, NoteState.added);
    });

    test('delete behavior: server notes marked, new notes removed', () {
      controller.loadInitialNotes([
        const NoteRectData(
          id: 123,
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          body: 'Server note',
        ),
      ]);
      controller.initializeHistory();

      controller.addNote(
        const NoteRect(Offset(200, 200), Offset(300, 300), body: 'New'),
        'New',
      );

      // Delete server note → marked deleted
      controller.deleteNote(0);
      expect(controller.notes.length, 2);
      expect(controller.notes[0].state, NoteState.deleted);
      expect(controller.notes[0].serverId, 123);

      // Delete new note → removed entirely
      controller.deleteNote(1);
      expect(controller.notes.length, 1);
    });

    test('undo/redo restores correct states', () {
      controller.loadInitialNotes([
        const NoteRectData(
          id: 123,
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          body: 'Note',
        ),
      ]);
      controller.initializeHistory();

      // Modify → Undo → should restore unchanged
      controller.updateNote(
        0,
        const NoteRect(
          Offset(200, 200),
          Offset(300, 300),
          body: 'Note',
          id: 123,
        ),
      );
      expect(controller.notes[0].state, NoteState.modified);

      controller.undo();
      expect(controller.notes[0].state, NoteState.unchanged);

      // Redo → should restore modified
      controller.redo();
      expect(controller.notes[0].state, NoteState.modified);
    });

    test('changeset generation categorizes changes correctly', () {
      controller.loadInitialNotes([
        const NoteRectData(
          id: 1,
          x: 100,
          y: 100,
          width: 100,
          height: 100,
          body: 'Note 1',
        ),
        const NoteRectData(
          id: 2,
          x: 300,
          y: 300,
          width: 100,
          height: 100,
          body: 'Note 2',
        ),
      ]);
      controller.initializeHistory();

      // Add new note
      controller.addNote(
        const NoteRect(Offset(500, 500), Offset(600, 600), body: 'New'),
        'New',
      );

      // Modify note 1
      controller.updateNote(
        0,
        const NoteRect(
          Offset(150, 150),
          Offset(250, 250),
          body: 'Note 1',
          id: 1,
        ),
      );

      // Delete note 2
      controller.deleteNote(1);

      final changeset = controller.getChangeset();

      expect(changeset.created.length, 1);
      expect(changeset.updated.length, 1);
      expect(changeset.updated[0].id, 1);
      expect(changeset.deleted.length, 1);
      expect(changeset.deleted[0], 2);
    });

    test('critical: undo delete of new note restores added state', () {
      controller.initializeHistory();

      // Add new note
      controller.addNote(
        const NoteRect(Offset(100, 100), Offset(200, 200), body: 'New'),
        'New',
      );

      // Delete it (removes from list)
      controller.deleteNote(0);
      expect(controller.notes, isEmpty);

      // Undo delete (should restore with added state)
      controller.undo();
      expect(controller.notes.length, 1);
      expect(controller.notes[0].state, NoteState.added);

      // Changeset should show it as created
      final changeset = controller.getChangeset();
      expect(changeset.created.length, 1);
      expect(changeset.deleted, isEmpty);
    });
  });
}
