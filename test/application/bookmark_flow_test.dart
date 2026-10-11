// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/posts/details_parts/widgets.dart';

import '../support/boorusama_test_runtime.dart';
import 'support/app_flow_driver.dart';
import 'support/app_flow_finders.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets(
    'bookmarks and unbookmarks a post through the details UI',
    (tester) async {
      final backend = FakeBooruBackend();
      final repository = MemoryBookmarkRepository();
      final harness = HeadlessAppHarness(
        booruBackend: backend,
        runtime: backend.createRuntime(bookmarkRepository: repository),
      );

      try {
        await harness.pump(tester);
        await harness.openFirstPost(tester);

        final bookmarkButton = find.descendant(
          of: find.byType(BookmarkPostButton),
          matching: find.byIcon(Symbols.bookmark),
        );
        await tester.tap(bookmarkButton);
        await harness.settle(tester);

        expect(repository.bookmarks, hasLength(1));
        expect(find.byIcon(Symbols.bookmark), findsOneWidget);

        await tester.tap(bookmarkButton);
        await harness.settle(tester);

        expect(repository.bookmarks, isEmpty);
      } finally {
        await harness.teardown(tester);
      }
    },
  );

  for (final via in PostMenuOpener.values) {
    testWidgets(
      'bookmarks and unbookmarks a post from its grid menu by ${via.label}',
      (tester) async {
        final backend = FakeBooruBackend();
        final repository = MemoryBookmarkRepository();
        final harness = HeadlessAppHarness(
          booruBackend: backend,
          runtime: backend.createRuntime(bookmarkRepository: repository),
        );
        final driver = AppFlowDriver(tester: tester, harness: harness);

        try {
          await harness.pump(tester);
          await harness.pumpUntilFound(tester, postTile(101));
          await harness.settle(tester);
          final strings = appStrings(tester).post.detail;

          await driver.openPostMenu(101, via: via);
          await driver.choosePostMenuAction(strings.add_to_bookmark);

          expect(repository.bookmarks, hasLength(1));

          await driver.openPostMenu(101, via: via);
          await driver.choosePostMenuAction(strings.remove_from_bookmark);

          expect(repository.bookmarks, isEmpty);
        } finally {
          await harness.teardown(tester);
        }
      },
    );
  }
}
