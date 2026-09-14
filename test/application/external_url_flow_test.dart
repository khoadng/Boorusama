// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/config_widgets/website_logo.dart';
import 'package:boorusama/core/posts/details_parts/src/source_section.dart';
import 'package:boorusama/core/posts/sources/types.dart';
import '../support/boorusama_test_runtime.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets('launches a source through the injected URL service', (
    tester,
  ) async {
    final launcher = RecordingExternalUrlLauncher();
    await tester.pumpWidget(
      BoorusamaAppScope(
        runtime: createTestBoorusamaRuntime(
          externalUrlLauncher: launcher,
        ),
        child: MaterialApp(
          home: SourceSection(
            source: RawWebSource(
              faviconUrl: null,
              url: 'https://source.booru.test/101',
              uri: Uri.parse('https://source.booru.test/101'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Symbols.arrow_outward));

    expect(
      launcher.launched.single.$1.toString(),
      'https://source.booru.test/101',
    );
  });

  testWidgets('launches a post source from the real details flow', (
    tester,
  ) async {
    final launcher = RecordingExternalUrlLauncher();
    final backend = FakeBooruBackend();
    final harness = HeadlessAppHarness(
      booruBackend: backend,
      runtime: backend.createRuntime(
        externalUrlLauncher: launcher,
      ),
    );
    addTearDown(() => harness.teardown(tester));

    await harness.pump(tester);
    await harness.openFirstPost(tester);

    await tester.tap(find.byType(KurumiInfoCircleIcon).first);
    await harness.settle(tester);

    final sourceLogo = find.byType(ConfigAwareWebsiteLogo);
    expect(sourceLogo, findsOneWidget);
    await tester.tap(sourceLogo);

    expect(
      launcher.launched.single.$1.toString(),
      'https://source.booru.test/101',
    );
  });
}
