// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/kurumi.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/tags/favorites/src/pages/edit_favorite_tag_sheet.dart';
import 'package:boorusama/core/tags/favorites/widgets.dart';
import '../support/boorusama_test_runtime.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets(
    'creates and removes a favorite tag through the UI',
    (tester) async {
      final backend = FakeBooruBackend();
      final repository = MemoryFavoriteTagRepository();
      final harness = HeadlessAppHarness(
        booruBackend: backend,
        runtime: backend.createRuntime(
          favoriteTagRepository: repository,
        ),
      );
      addTearDown(() => harness.teardown(tester));

      await harness.pump(tester);
      await tester.tap(find.byIcon(Symbols.menu).first);
      await tester.pump();
      await harness.settle(tester);
      await tester.tap(find.byIcon(Symbols.tag).last);
      await tester.pump();
      await harness.pumpUntilFound(tester, find.byType(FavoriteTagsPage));
      await harness.settle(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(FavoriteTagsPage),
          matching: find.byIcon(Symbols.add),
        ),
      );
      await tester.pump();
      await harness.settle(tester);

      final valueField = find.descendant(
        of: find.byType(EditFavoriteTagSheet),
        matching: find.byType(EditableText),
      );
      expect(valueField, findsOneWidget);
      await tester.enterText(valueField, 'cat');
      expect(tester.widget<EditableText>(valueField).controller.text, 'cat');
      await tester.pump();
      final saveButton = find.descendant(
        of: find.byType(EditFavoriteTagSheet),
        matching: find.byTooltip('Save'),
      );
      expect(saveButton, findsOneWidget);
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await harness.pumpUntil(
        tester,
        () => repository.tags.isNotEmpty,
      );
      await harness.settle(tester);

      expect(repository.tags.single.name, 'cat');
      expect(find.text('cat'), findsOneWidget);
      final row = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_ListTile',
      );
      expect(row, findsOneWidget);
      await tester.tap(
        find.descendant(
          of: row,
          matching: find.byType(KurumiPopupMenuButton),
        ),
      );
      await harness.settle(tester);
      expect(find.byType(KurumiPopupMenuItem), findsNWidgets(3));
      await tester.tap(find.byType(KurumiPopupMenuItem).last);
      await harness.pumpUntil(
        tester,
        () => repository.tags.isEmpty,
      );
      await harness.settle(tester);

      expect(find.text('cat'), findsNothing);
    },
  );
}
