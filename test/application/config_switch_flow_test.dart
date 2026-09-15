// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/home/types.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/settings/types.dart';

import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets(
    'switches the active booru and reloads posts from the new config',
    (tester) async {
      final backend = FakeBooruBackend();
      final harness = HeadlessAppHarness(
        booruBackend: backend,
        runtime: backend.createRuntime(
          configs: [backend.config, backend.configB],
          settings: Settings.defaultSettings.copyWith(
            booruConfigSelectorPosition: BooruConfigSelectorPosition.bottom,
          ),
        ),
      );
      addTearDown(() => harness.teardown(tester));

      await harness.pump(tester);
      await harness.pumpUntilFound(
        tester,
        find.byType(SliverPostGridImageGridItem),
      );
      expect(find.byType(SliverPostGridImageGridItem), findsNWidgets(2));
      expect(
        backend.requests.whereType<FakeBooruPostRequest>().last.siteUrl,
        backend.config.url,
      );

      final configBSelector = find.byKey(ValueKey(backend.configB.id));
      expect(configBSelector, findsOneWidget);
      await tester.tap(configBSelector);
      await harness.pumpUntil(
        tester,
        () => backend.requests.whereType<FakeBooruPostRequest>().any(
          (request) => request.siteUrl == backend.configB.url,
        ),
      );
      await harness.settle(tester);

      expect(find.byType(SliverPostGridImageGridItem), findsNWidgets(2));
      expect(
        backend.requests.whereType<FakeBooruPostRequest>().last.siteUrl,
        backend.configB.url,
      );
      expect(
        backend.requests.whereType<FakeBooruPostRequest>().last.resultIds,
        [201, 202],
      );
    },
  );
}
