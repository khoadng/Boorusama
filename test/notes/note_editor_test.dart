// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import 'package:boorusama/core/haptics/types.dart';
import 'package:boorusama/core/notes/editor/src/constants/editor_keys.dart';
import 'package:boorusama/core/notes/editor/src/pages/raw_note_editor_page.dart';
import 'package:boorusama/core/notes/editor/types.dart';
import 'package:boorusama/core/settings/src/providers/settings_provider.dart';

void main() {
  const testImageWidth = 800.0;
  const testImageHeight = 600.0;

  Widget buildTestWidget({
    List<NoteRectData> initialNotes = const [],
    void Function(NoteChangeset)? onSubmit,
  }) {
    return ProviderScope(
      overrides: [
        hapticFeedbackLevelProvider.overrideWith(
          (ref) => HapticFeedbackLevel.none,
        ),
      ],
      child: BooruLocalization(
        child: MaterialApp(
          home: RawNoteEditorPage(
            image: const NoteImage(
              width: testImageWidth,
              height: testImageHeight,
            ),
            imageBuilder: (constraints) => Container(
              color: Colors.grey,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            onSubmit: onSubmit,
            initialNotes: initialNotes,
          ),
        ),
      ),
    );
  }

  group('Integration Tests', () {
    testWidgets(
      'complete workflow: draw, move, submit',
      (tester) async {
        NoteChangeset? submittedData;

        await tester.pumpWidget(
          buildTestWidget(
            onSubmit: (data) => submittedData = data,
          ),
        );
        await tester.pumpAndSettle();

        // Switch to draw mode
        await tester.tap(find.byKey(kDrawToolButtonKey));
        await tester.pumpAndSettle();

        final gestureArea = find.byType(GestureDetector).first;
        final rect = tester.getRect(gestureArea);
        final center = rect.center;

        // Draw first note at top-left
        var gesture = await tester.startGesture(
          center - const Offset(100, 100),
        );
        await gesture.moveTo(center - const Offset(50, 50));
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(kAddNoteDialogTextFieldKey),
          'First note',
        );
        await tester.tap(find.byKey(kAddNoteDialogOkButtonKey));
        await tester.pumpAndSettle();

        // Draw second note at bottom-right
        gesture = await tester.startGesture(center + const Offset(50, 50));
        await gesture.moveTo(center + const Offset(100, 100));
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(kAddNoteDialogTextFieldKey),
          'Second note',
        );
        await tester.tap(find.byKey(kAddNoteDialogOkButtonKey));
        await tester.pumpAndSettle();

        // Switch to move mode and move first note
        await tester.tap(find.byKey(kMoveToolButtonKey));
        await tester.pumpAndSettle();

        // Select and move first note
        gesture = await tester.startGesture(center - const Offset(75, 75));
        await gesture.moveTo(center + const Offset(25, 25));
        await gesture.up();
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.byKey(kSubmitButtonKey));
        await tester.pumpAndSettle();

        // Verify final submitted data
        expect(submittedData, isNotNull);
        expect(submittedData!.created.length, 2);
        expect(submittedData!.created[0].body, 'First note');
        expect(submittedData!.created[1].body, 'Second note');
        expect(submittedData!.updated, isEmpty);
        expect(submittedData!.deleted, isEmpty);
      },
    );

    testWidgets(
      'undo and redo operations',
      (tester) async {
        NoteChangeset? submittedData;

        await tester.pumpWidget(
          buildTestWidget(
            onSubmit: (data) => submittedData = data,
          ),
        );
        await tester.pumpAndSettle();

        // Switch to draw mode
        await tester.tap(find.byKey(kDrawToolButtonKey));
        await tester.pumpAndSettle();

        final gestureArea = find.byType(GestureDetector).first;
        final rect = tester.getRect(gestureArea);
        final center = rect.center;

        // Draw first note
        var gesture = await tester.startGesture(
          center - const Offset(100, 100),
        );
        await gesture.moveTo(center - const Offset(50, 50));
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(kAddNoteDialogTextFieldKey),
          'First note',
        );
        await tester.tap(find.byKey(kAddNoteDialogOkButtonKey));
        await tester.pumpAndSettle();

        // Draw second note
        gesture = await tester.startGesture(center + const Offset(50, 50));
        await gesture.moveTo(center + const Offset(100, 100));
        await gesture.up();
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(kAddNoteDialogTextFieldKey),
          'Second note',
        );
        await tester.tap(find.byKey(kAddNoteDialogOkButtonKey));
        await tester.pumpAndSettle();

        // Undo the second note
        await tester.tap(find.byKey(kUndoButtonKey));
        await tester.pumpAndSettle();

        // Redo second note back
        await tester.tap(find.byKey(kRedoButtonKey));
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.byKey(kSubmitButtonKey));
        await tester.pumpAndSettle();

        // Verify final submitted data: should have 2 notes
        expect(submittedData, isNotNull);
        expect(submittedData!.created.length, 2);
        expect(submittedData!.created[0].body, 'First note');
        expect(submittedData!.created[1].body, 'Second note');
        expect(submittedData!.updated, isEmpty);
        expect(submittedData!.deleted, isEmpty);
      },
    );
  });
}
