// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/posts/details_parts/widgets.dart';

import '../support/boorusama_test_runtime.dart';
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
      addTearDown(harness.dispose);

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
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
    },
  );
}
