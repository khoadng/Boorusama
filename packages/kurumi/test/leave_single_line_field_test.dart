// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';

void main() {
  final cases = [
    (
      name: 'right at the end of the text leaves for the next control',
      caret: 4,
      key: LogicalKeyboardKey.arrowRight,
      focused: 'after',
      caretAfter: 4,
    ),
    (
      name: 'left at the start of the text leaves for the previous control',
      caret: 0,
      key: LogicalKeyboardKey.arrowLeft,
      focused: 'before',
      caretAfter: 0,
    ),
    (
      name: 'right inside the text moves the caret',
      caret: 2,
      key: LogicalKeyboardKey.arrowRight,
      focused: 'field',
      caretAfter: 3,
    ),
    (
      name: 'left at the end of the text moves the caret',
      caret: 4,
      key: LogicalKeyboardKey.arrowLeft,
      focused: 'field',
      caretAfter: 3,
    ),
  ];
  for (final c in cases) {
    testWidgets('in a single-line field, ${c.name}', (tester) async {
      final nodes = {
        for (final name in ['before', 'field', 'after']) name: FocusNode(),
      };
      final controller = TextEditingController(text: 'cats');
      addTearDown(() {
        for (final node in nodes.values) {
          node.dispose();
        }
        controller.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          actions: {
            ...WidgetsApp.defaultActions,
            DirectionalFocusIntent: KurumiDirectionalFocusAction(),
            ExtendSelectionByCharacterIntent:
                KurumiLeaveSingleLineFieldAction(),
          },
          home: Scaffold(
            body: Row(
              children: [
                TextButton(
                  focusNode: nodes['before'],
                  onPressed: () {},
                  child: const Text('Before'),
                ),
                Expanded(
                  child: TextField(
                    focusNode: nodes['field'],
                    controller: controller,
                  ),
                ),
                TextButton(
                  focusNode: nodes['after'],
                  onPressed: () {},
                  child: const Text('After'),
                ),
              ],
            ),
          ),
        ),
      );
      nodes['field']!.requestFocus();
      await tester.pump();
      controller.selection = TextSelection.collapsed(offset: c.caret);
      await tester.pump();

      await tester.sendKeyEvent(c.key);
      await tester.pump();

      expect(nodes[c.focused]!.hasPrimaryFocus, isTrue);
      expect(controller.selection.baseOffset, c.caretAfter);
    });
  }
}
