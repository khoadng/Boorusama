// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';

void main() {
  final cases = [
    (
      name: 'outlines a control focused by keyboard',
      strategy: FocusHighlightStrategy.alwaysTraditional,
      skipTraversal: false,
      pressesKey: true,
      drawsRing: true,
    ),
    (
      name: 'waits for a key press before outlining an autofocused control',
      strategy: FocusHighlightStrategy.alwaysTraditional,
      skipTraversal: false,
      pressesKey: false,
      drawsRing: false,
    ),
    (
      name: 'stays hidden for touch users',
      strategy: FocusHighlightStrategy.alwaysTouch,
      skipTraversal: false,
      pressesKey: true,
      drawsRing: false,
    ),
    (
      name: 'ignores focus that arrow keys cannot reach',
      strategy: FocusHighlightStrategy.alwaysTraditional,
      skipTraversal: true,
      pressesKey: true,
      drawsRing: false,
    ),
  ];
  for (final c in cases) {
    testWidgets('focus ring ${c.name}', (tester) async {
      final previous = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy = c.strategy;
      addTearDown(() => FocusManager.instance.highlightStrategy = previous);

      final node = FocusNode(skipTraversal: c.skipTraversal);
      addTearDown(node.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: KurumiFocusRing(
            child: Center(
              child: TextButton(
                focusNode: node,
                onPressed: () {},
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      node.requestFocus();
      if (c.pressesKey) {
        await tester.sendKeyEvent(LogicalKeyboardKey.shift);
      }
      await tester.pump();
      await tester.pump();

      final ring = paints..drrect();
      expect(
        find.byType(KurumiFocusRing),
        c.drawsRing ? ring : isNot(ring),
      );
    });
  }

  testWidgets(
    'focus ring hides after a mouse click and returns on the next key press',
    (tester) async {
      final previous = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = previous);

      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: KurumiFocusRing(
            child: Center(
              child: TextButton(
                focusNode: node,
                onPressed: () {},
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      node.requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      await tester.pump();
      final ring = paints..drrect();
      expect(find.byType(KurumiFocusRing), ring);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.down(const Offset(5, 5));
      await mouse.up();
      await tester.pump();
      await tester.pump();
      expect(node.hasFocus, isTrue);
      expect(find.byType(KurumiFocusRing), isNot(ring));

      await tester.sendKeyEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      await tester.pump();
      expect(find.byType(KurumiFocusRing), ring);
    },
  );

  final presses = [
    (kind: PointerDeviceKind.mouse, focusesButton: true),
    // Moving focus off the field would close the soft keyboard.
    (kind: PointerDeviceKind.touch, focusesButton: false),
  ];
  for (final c in presses) {
    testWidgets(
      'pressing a button with ${c.kind.name} '
      '${c.focusesButton ? 'moves focus to it' : 'keeps focus in the field'}',
      (tester) async {
        final field = FocusNode();
        final button = FocusNode();
        addTearDown(field.dispose);
        addTearDown(button.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: KurumiFocusRing(
              child: Material(
                child: Column(
                  children: [
                    TextField(focusNode: field),
                    TextButton(
                      focusNode: button,
                      onPressed: () {},
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        field.requestFocus();
        await tester.pump();

        await tester.tap(find.text('Send'), kind: c.kind);
        await tester.pump();

        expect(button.hasPrimaryFocus, c.focusesButton);
        expect(field.hasPrimaryFocus, !c.focusesButton);
      },
    );
  }
}
