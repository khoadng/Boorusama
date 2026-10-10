// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late KurumiListboxController listbox;
  late FocusNode field;
  late TextEditingController text;
  late List<String> picked;
  late ValueNotifier<bool> showList;

  setUp(() {
    listbox = KurumiListboxController();
    field = FocusNode();
    text = TextEditingController();
    picked = [];
    showList = ValueNotifier(true);
  });

  tearDown(() {
    listbox.dispose();
    field.dispose();
    text.dispose();
    showList.dispose();
  });

  const rows = ['cat', 'cat_ears', 'cat_tail'];

  Future<void> mount(WidgetTester tester, {bool reversed = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              KurumiSearchBar(
                focus: field,
                controller: text,
                listbox: listbox,
              ),
              ValueListenableBuilder(
                valueListenable: showList,
                builder: (context, show, _) => show
                    ? KurumiListbox(
                        controller: listbox,
                        count: rows.length,
                        reversed: reversed,
                        onPick: (index) => picked.add(rows[index]),
                        child: Column(
                          children: [
                            for (final (index, row) in rows.indexed)
                              ListenableBuilder(
                                listenable: listbox,
                                builder: (context, _) => KurumiListboxItem(
                                  active: listbox.active == index,
                                  child: Text(row),
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
    field.requestFocus();
    await tester.pump();
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  String? highlighted() => switch (listbox.active) {
    final index? => rows[index],
    null => null,
  };

  final moves = [
    (
      name: 'down from the field highlights the first row',
      reversed: false,
      keys: [LogicalKeyboardKey.arrowDown],
      highlighted: 'cat',
    ),
    (
      name: 'down past the last row stays on it',
      reversed: false,
      keys: List.filled(5, LogicalKeyboardKey.arrowDown),
      highlighted: 'cat_tail',
    ),
    (
      name: 'up from the first row drops the highlight',
      reversed: false,
      keys: [LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowUp],
      highlighted: null,
    ),
    (
      name: 'up moves into a list above the field',
      reversed: true,
      keys: [LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowUp],
      highlighted: 'cat_ears',
    ),
  ];
  for (final c in moves) {
    testWidgets('${c.name} while focus stays in the field', (tester) async {
      await mount(tester, reversed: c.reversed);

      for (final key in c.keys) {
        await press(tester, key);
      }

      expect(highlighted(), c.highlighted);
      expect(field.hasFocus, isTrue);
    });
  }

  testWidgets('Enter picks the highlighted row and clears the highlight', (
    tester,
  ) async {
    await mount(tester);
    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.arrowDown);

    await press(tester, LogicalKeyboardKey.enter);

    expect(picked, ['cat_ears']);
    expect(highlighted(), isNull);
  });

  final drops = [
    (
      name: 'Escape',
      drop: (WidgetTester tester) => press(tester, LogicalKeyboardKey.escape),
    ),
    (
      name: 'typing',
      drop: (WidgetTester tester) =>
          tester.enterText(find.byType(TextField), 'd'),
    ),
  ];
  for (final c in drops) {
    testWidgets('${c.name} drops the highlight', (tester) async {
      await mount(tester);
      await press(tester, LogicalKeyboardKey.arrowDown);

      await c.drop(tester);
      await tester.pump();

      expect(highlighted(), isNull);
      expect(field.hasFocus, isTrue);
    });
  }

  testWidgets('once the list closes, keys no longer pick its rows', (
    tester,
  ) async {
    await mount(tester);
    await press(tester, LogicalKeyboardKey.arrowDown);
    showList.value = false;
    await tester.pump();

    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.enter);

    expect(picked, isEmpty);
  });
}
