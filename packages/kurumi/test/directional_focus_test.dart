// Flutter imports:
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';

void main() {
  final cases = [
    (
      name: 'a button',
      build: (FocusNode node) =>
          TextButton(focusNode: node, onPressed: () {}, child: const Text('')),
    ),
    (
      name: 'a single-line field',
      build: (FocusNode node) => TextField(focusNode: node),
    ),
    (
      name: 'a search bar being typed in',
      build: (FocusNode node) => KurumiSearchBar(focus: node),
    ),
  ];
  for (final c in cases) {
    testWidgets(
      'reversing an arrow from ${c.name} focused another way moves from it, '
      'not back to where the earlier arrow started',
      (tester) async {
        final nodes = {
          for (final name in ['start', 'above', 'below', 'target'])
            name: FocusNode(debugLabel: name),
        };
        addTearDown(() {
          for (final node in nodes.values) {
            node.dispose();
          }
        });

        Widget button(String name) => TextButton(
          focusNode: nodes[name],
          onPressed: () {},
          child: Text(name),
        );

        await tester.pumpWidget(
          MaterialApp(
            actions: {
              ...WidgetsApp.defaultActions,
              DirectionalFocusIntent: KurumiDirectionalFocusAction(),
              ExtendSelectionVerticallyToAdjacentLineIntent:
                  KurumiLeaveSingleLineFieldAction(),
            },
            home: Scaffold(
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [button('start'), button('above')],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      button('below'),
                      SizedBox(
                        width: 200,
                        child: c.build(nodes['target']!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        nodes['start']!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(nodes['below']!.hasPrimaryFocus, isTrue);

        // As a click or Tab would.
        nodes['target']!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        await tester.pump();

        expect(nodes['above']!.hasPrimaryFocus, isTrue);
      },
    );
  }

  final tabCases = [
    (name: 'Tab', key: LogicalKeyboardKey.tab, shift: false),
    (name: 'Shift+Tab', key: LogicalKeyboardKey.tab, shift: true),
  ];
  for (final c in tabCases) {
    testWidgets(
      '${c.name} wrapping around a long list scrolls to where it lands',
      (
        tester,
      ) async {
        final scroll = ScrollController();
        addTearDown(scroll.dispose);

        await tester.pumpWidget(
          MaterialApp(
            actions: {
              ...WidgetsApp.defaultActions,
              NextFocusIntent: KurumiNextFocusAction(),
              PreviousFocusIntent: KurumiPreviousFocusAction(),
            },
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scroll,
                child: Column(
                  children: [
                    for (var i = 0; i < 40; i++)
                      SizedBox(
                        height: 60,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('$i'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        final (start, end) = c.shift ? ('0', '39') : ('39', '0');
        scroll.jumpTo(c.shift ? 0 : scroll.position.maxScrollExtent);
        await tester.pump();
        Focus.of(tester.element(find.text(start))).requestFocus();
        await tester.pump();

        if (c.shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(c.key);
        if (c.shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();

        final landed = tester.getRect(find.text(end));
        expect(
          Focus.of(tester.element(find.text(end))).hasPrimaryFocus,
          isTrue,
        );
        expect(
          (Offset.zero &
                  tester.view.physicalSize / tester.view.devicePixelRatio)
              .overlaps(landed),
          isTrue,
        );
      },
    );
  }

  testWidgets(
    'a menu opened from a scrolled list counts as visible outside the list',
    (tester) async {
      final controller = AnchorController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 60,
                  child: SingleChildScrollView(
                    child: KurumiAnchor(
                      controller: controller,
                      spacing: 40,
                      overlayBuilder: (context) => TextButton(
                        onPressed: () {},
                        child: const Text('Item'),
                      ),
                      child: TextButton(
                        onPressed: controller.show,
                        child: const Text('Open'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final item = Focus.of(tester.element(find.text('Item')));

      expect(visibleFocusRect(item).isEmpty, isFalse);
    },
  );
}
