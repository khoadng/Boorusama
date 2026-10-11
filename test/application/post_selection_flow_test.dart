// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';

import '../support/boorusama_test_runtime.dart';
import 'support/app_flow_driver.dart';
import 'support/app_flow_finders.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  for (final via in PostMenuOpener.values) {
    testWidgets(
      'selects posts from the grid menu by ${via.label} and downloads them together',
      (tester) async {
        final backend = FakeBooruBackend();
        final service = MemoryDownloadService();
        final harness = HeadlessAppHarness(
          booruBackend: backend,
          runtime: backend.createRuntime(downloadService: service),
        );
        final driver = AppFlowDriver(tester: tester, harness: harness);

        try {
          await harness.pump(tester);
          await harness.pumpUntilFound(tester, postTile(102));
          await harness.settle(tester);
          final strings = appStrings(tester);

          await driver.openPostMenu(101, via: via);
          await driver.choosePostMenuAction(strings.generic.action.select);
          await tester.tap(postTile(102));
          await tester.pump();

          await tester.tap(
            find.widgetWithText(MultiSelectButton, strings.download.download),
          );
          await harness.pumpUntil(
            tester,
            () => service.requests.length == 2,
            description: 'both selected posts to download',
          );

          expect(
            service.requests.map((request) => request.url),
            unorderedEquals([
              'https://headless.booru.test/posts/101.jpg',
              'https://headless.booru.test/posts/102.jpg',
            ]),
          );
          expect(find.byType(MultiSelectionActionBar), findsNothing);
        } finally {
          await harness.teardown(tester);
        }
      },
    );
  }
}
