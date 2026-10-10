// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'Escape closes an anchored menu and returns focus to its button',
    (
      tester,
    ) async {
      final controller = AnchorController();
      addTearDown(controller.dispose);
      final button = FocusNode();
      addTearDown(button.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: KurumiAnchor(
                controller: controller,
                overlayBuilder: (context) => TextButton(
                  onPressed: () {},
                  child: const Text('Item'),
                ),
                child: TextButton(
                  focusNode: button,
                  onPressed: controller.show,
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      button.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);
      expect(button.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Item'), findsNothing);
      expect(button.hasFocus, isTrue);
    },
  );
}
