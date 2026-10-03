// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';

void main() {
  final cases = [
    (
      name: 'outlines a control focused by keyboard',
      strategy: FocusHighlightStrategy.alwaysTraditional,
      skipTraversal: false,
      drawsRing: true,
    ),
    (
      name: 'stays hidden for touch users',
      strategy: FocusHighlightStrategy.alwaysTouch,
      skipTraversal: false,
      drawsRing: false,
    ),
    (
      name: 'ignores focus that arrow keys cannot reach',
      strategy: FocusHighlightStrategy.alwaysTraditional,
      skipTraversal: true,
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
      await tester.pump();
      await tester.pump();

      final ring = paints..drrect();
      expect(
        find.byType(KurumiFocusRing),
        c.drawsRing ? ring : isNot(ring),
      );
    });
  }
}
