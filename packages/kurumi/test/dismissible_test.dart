// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late AnchorController menu;

  setUp(() => menu = AnchorController());
  tearDown(() => menu.dispose());

  // Shown as a general dialog, which the barrier alone never closes on
  // Escape.
  Future<void> openDialog(
    WidgetTester tester, {
    bool dismissible = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showGeneralDialog(
                context: context,
                pageBuilder: (context, _, _) => KurumiDialog(
                  dismissible: dismissible,
                  child: KurumiAnchor(
                    controller: menu,
                    overlayBuilder: (context) => TextButton(
                      onPressed: () {},
                      child: const Text('Item'),
                    ),
                    child: TextButton(
                      autofocus: true,
                      onPressed: menu.show,
                      child: const Text('Menu'),
                    ),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> escape(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  }

  final dialogs = [
    (name: 'closes a dialog', dismissible: true, staysOpen: false),
    (
      name: 'leaves open a dialog that only its own buttons may close',
      dismissible: false,
      staysOpen: true,
    ),
  ];
  for (final c in dialogs) {
    testWidgets('Escape ${c.name}', (tester) async {
      await openDialog(tester, dismissible: c.dismissible);

      await escape(tester);

      expect(find.text('Menu'), c.staysOpen ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('each Escape closes one layer, the menu before its dialog', (
    tester,
  ) async {
    await openDialog(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Item'), findsOneWidget);

    await escape(tester);
    expect(find.text('Item'), findsNothing);
    expect(find.text('Menu'), findsOneWidget);

    await escape(tester);
    expect(find.text('Menu'), findsNothing);
  });
}
