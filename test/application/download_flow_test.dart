// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/kurumi.dart';

// Project imports:
import 'package:boorusama/core/posts/details_parts/widgets.dart';

import '../support/boorusama_test_runtime.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets(
    'sends a post download request to the injected service',
    (tester) async {
      final backend = FakeBooruBackend();
      final service = MemoryDownloadService();
      final harness = HeadlessAppHarness(
        booruBackend: backend,
        runtime: backend.createRuntime(downloadService: service),
      );

      try {
        await harness.pump(tester);
        await harness.openFirstPost(tester);

        final infoButtons = find.byType(KurumiInfoCircleIcon);
        await tester.tap(infoButtons.first);
        await harness.settle(tester);
        await tester.pump(const Duration(milliseconds: 500));
        final downloadButtons = find.byType(DownloadPostButton);
        final downloadButton = downloadButtons.last;
        await tester.ensureVisible(downloadButton);
        await tester.tap(downloadButton);
        await harness.pumpUntil(
          tester,
          () => service.requests.isNotEmpty,
        );

        expect(service.requests, hasLength(1));
        expect(
          service.requests.single.url,
          'https://headless.booru.test/posts/101.jpg',
        );
        expect(service.requests.single.filename, endsWith('.jpg'));
      } finally {
        await harness.teardown(tester);
      }
    },
  );
}
