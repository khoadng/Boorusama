// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/notes/editor/src/types/note_rect.dart';
import 'package:boorusama/core/notes/editor/src/types/note_rect_converter.dart';
import 'package:boorusama/core/notes/editor/src/types/note_rect_data.dart';

void main() {
  group('NoteRectData', () {
    test('preserves ID through conversions and operations', () {
      const originalData = NoteRectData(
        id: 999,
        x: 100,
        y: 100,
        width: 50,
        height: 50,
        body: 'test',
      );

      const imageSize = Size(800, 600);

      final noteRect = NoteRectConverter.toNoteRect(
        originalData,
        originalImageSize: imageSize,
        imageSize: imageSize,
      );

      // Move the rect
      final movedRect = noteRect.translate(const Offset(10, 20));

      // Convert back
      final resultData = NoteRectConverter.toRectData(
        movedRect,
        originalImageSize: imageSize,
        imageSize: imageSize,
      );

      // ID must be preserved after all operations
      expect(resultData.id, 999);
    });

    test('normalizes coordinates for reversed drawing directions', () {
      const imageSize = Size(800, 600);

      // Drawing from bottom-right to top-left
      const noteRect = NoteRect(
        Offset(200, 200), // start (bottom-right)
        Offset(100, 100), // end (top-left)
        body: 'reversed',
      );

      final data = NoteRectConverter.toRectData(
        noteRect,
        originalImageSize: imageSize,
        imageSize: imageSize,
      );

      // Should normalize to top-left corner with positive dimensions
      expect(data.x, 100);
      expect(data.y, 100);
      expect(data.width, 100);
      expect(data.height, 100);
    });
  });
}
