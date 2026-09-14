import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/posts/details_parts/src/source_section.dart';
import 'package:boorusama/core/posts/sources/types.dart';

import '../support/boorusama_test_runtime.dart';

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
}
