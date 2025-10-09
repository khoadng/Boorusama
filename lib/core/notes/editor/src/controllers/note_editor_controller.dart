// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../types/editor_tool.dart';
import '../types/note_changeset.dart';
import '../types/note_image.dart';
import '../types/note_rect.dart';
import '../types/note_rect_converter.dart';
import '../types/note_rect_data.dart';
import '../types/tracked_note.dart';

enum GestureMode {
  none,
  drawing,
  moving,
}

class NoteEditorController extends ChangeNotifier {
  NoteEditorController({
    required this.image,
  });

  final NoteImage image;

  List<TrackedNote> _notes = [];

  // Undo/redo state
  final List<List<TrackedNote>> _history = [];
  var _historyIndex = -1;

  final ValueNotifier<EditorTool> currentTool = ValueNotifier(
    EditorTool.interact,
  );

  // Gesture state
  GestureMode mode = GestureMode.none;
  int? movingRectIndex;
  int? selectedRectIndex;
  Offset? dragStartPosition;
  NoteRect? drawingRect;
  NoteRect? originalMovingRect;

  List<TrackedNote> get notes => List.unmodifiable(_notes);

  void loadInitialNotes(List<NoteRectData> initialNotes) {
    final imageSize = image.size;

    _notes = initialNotes.map((data) {
      final rect = NoteRectConverter.toNoteRect(
        data,
        originalImageSize: imageSize,
        imageSize: imageSize,
      );
      return TrackedNote.fromServer(
        serverId: data.id!,
        rect: rect,
      );
    }).toList();

    notifyListeners();
  }

  List<NoteRect> get savedRects {
    return _notes
        .where((note) => !note.isDeleted)
        .map((note) => note.rect)
        .toList();
  }

  List<TrackedNote> get savedTrackedNotes {
    return _notes.where((note) => !note.isDeleted).toList();
  }

  bool get hasNoChanges {
    return _notes.every((note) => note.isUnchanged);
  }

  void addNote(NoteRect rect, String body) {
    final newNote = TrackedNote.newNote(rect: rect.copyWith(body: body));
    _notes.add(newNote);
    _saveState();
    notifyListeners();
  }

  void updateNote(int index, NoteRect newRect) {
    if (index >= 0 && index < _notes.length) {
      _notes[index] = _notes[index].updateRect(newRect);
      _saveState();
      notifyListeners();
    }
  }

  void deleteNote(int index) {
    if (index >= 0 && index < _notes.length) {
      final note = _notes[index];

      if (note.isAdded) {
        // New notes: remove completely
        _notes.removeAt(index);
      } else {
        // Server notes: mark as deleted
        _notes[index] = note.markDeleted();
      }

      _saveState();
      notifyListeners();
    }
  }

  NoteChangeset getChangeset() {
    final imageSize = image.size;
    return NoteChangeset.fromTrackedNotes(
      notes: _notes,
      originalImageSize: imageSize,
      imageSize: imageSize,
    );
  }

  void setTool(EditorTool tool) {
    currentTool.value = tool;
    selectedRectIndex = null;
    notifyListeners();
  }

  void selectRect(int index) {
    selectedRectIndex = index;
    notifyListeners();
  }

  void deleteSelectedRect() {
    final selected = selectedRectIndex;
    if (selected != null && selected < savedRects.length) {
      final nonDeletedNotes = _notes
          .asMap()
          .entries
          .where((e) => !e.value.isDeleted)
          .toList();

      if (selected < nonDeletedNotes.length) {
        final actualIndex = nonDeletedNotes[selected].key;
        deleteNote(actualIndex);
        selectedRectIndex = null;
      }
    }
  }

  void initializeHistory() {
    _history.clear();
    _history.add(List.from(_notes));
    _historyIndex = 0;
  }

  void _saveState() {
    // Remove any redo branch
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(List.from(_notes));
    _historyIndex++;
    notifyListeners();
  }

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  void undo() {
    if (canUndo) {
      _historyIndex--;
      _notes = List.from(_history[_historyIndex]);
      selectedRectIndex = null;
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _historyIndex++;
      _notes = List.from(_history[_historyIndex]);
      selectedRectIndex = null;
      notifyListeners();
    }
  }

  void startGesture(Offset imagePosition, Offset displayPosition) {
    switch (currentTool.value) {
      case EditorTool.interact:
      // No gesture handling in view mode
      case EditorTool.draw:
        mode = GestureMode.drawing;
        dragStartPosition = imagePosition;
        drawingRect = NoteRect(imagePosition, imagePosition);
        notifyListeners();
      case EditorTool.move:
        // Check if starting on an existing square
        final rects = savedRects;
        for (var i = 0; i < rects.length; i++) {
          final square = rects[i];
          if (square.contains(imagePosition)) {
            mode = GestureMode.moving;
            movingRectIndex = i;
            selectedRectIndex = i;
            dragStartPosition = imagePosition;
            originalMovingRect = square;
            notifyListeners();
            return;
          }
        }
        // Tap on empty space clears selection
        selectedRectIndex = null;
        notifyListeners();
    }
  }

  void updateGesture(Offset imagePosition, Offset displayPosition) {
    final movingIndex = movingRectIndex;
    final dragStart = dragStartPosition;

    if (mode == GestureMode.moving &&
        movingIndex != null &&
        dragStart != null) {
      final delta = imagePosition - dragStart;

      final nonDeletedNotes = _notes
          .asMap()
          .entries
          .where((e) => !e.value.isDeleted)
          .toList();

      if (movingIndex < nonDeletedNotes.length) {
        final actualIndex = nonDeletedNotes[movingIndex].key;
        final note = _notes[actualIndex];
        final newRect = note.rect.translate(delta);
        _notes[actualIndex] = note.updateRect(newRect);
      }

      dragStartPosition = imagePosition;
      notifyListeners();
    } else if (mode == GestureMode.drawing &&
        drawingRect != null &&
        dragStart != null) {
      drawingRect = NoteRect(dragStart, imagePosition);
      notifyListeners();
    }
  }

  void finishMoving() {
    _saveState();
    mode = GestureMode.none;
    movingRectIndex = null;
    dragStartPosition = null;
    originalMovingRect = null;
    notifyListeners();
  }

  void finishDrawing(String? text) {
    final currentDrawingRect = drawingRect;
    if (text != null && currentDrawingRect != null) {
      final newRect = currentDrawingRect.copyWith(body: text);
      addNote(newRect, text);
    }

    mode = GestureMode.none;
    drawingRect = null;
    dragStartPosition = null;
    notifyListeners();
  }

  void cancelDrag() {
    if (mode == GestureMode.moving) {
      // Restore original position
      final movingIndex = movingRectIndex;
      final originalRect = originalMovingRect;
      if (movingIndex != null && originalRect != null) {
        final nonDeletedNotes = _notes
            .asMap()
            .entries
            .where((e) => !e.value.isDeleted)
            .toList();

        if (movingIndex < nonDeletedNotes.length) {
          final actualIndex = nonDeletedNotes[movingIndex].key;
          final note = _notes[actualIndex];
          _notes[actualIndex] = note.updateRect(originalRect);
        }
      }
    } else if (mode == GestureMode.drawing) {
      drawingRect = null;
    }

    mode = GestureMode.none;
    movingRectIndex = null;
    dragStartPosition = null;
    originalMovingRect = null;
    notifyListeners();
  }

  List<NoteRectData> calcRectData(
    List<NoteRect> squares,
    Size? size,
  ) {
    if (size == null) return [];

    final imageSize = image.size;

    return squares
        .map(
          (square) => NoteRectConverter.toRectData(
            square,
            originalImageSize: imageSize,
            imageSize: size,
          ),
        )
        .toList();
  }
}
