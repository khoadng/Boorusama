// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/kurumi.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

// Project imports:
import 'package:boorusama/core/downloads/urls/providers.dart';
import 'package:boorusama/core/downloads/urls/types.dart';
import 'package:boorusama/core/posts/details_parts/widgets.dart';
import 'package:boorusama/core/posts/post/types.dart';

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

  testWidgets(
    'routes quality menu choices through the extractor and preserves direct URLs',
    (tester) async {
      final backend = FakeBooruBackend();
      final service = MemoryDownloadService();
      final extractor = _RecordingDownloadExtractor();
      final sources = [
        const DownloadSource.quality(
          quality: 'sample',
          name: 'Sample',
        ),
        const DownloadSource.quality(
          quality: 'original',
          name: 'Original',
        ),
        const DownloadSource(
          url: 'https://listing.invalid/guessed.jpg',
          name: 'Direct',
        ),
      ];
      final harness = HeadlessAppHarness(
        booruBackend: backend,
        runtime: backend.createRuntime(downloadService: service),
        additionalOverrides: [
          downloadSourceProvider.overrideWith(
            (ref, config) => _TestDownloadSourceProvider(sources),
          ),
          downloadFileUrlExtractorProvider.overrideWith(
            (ref, config) => extractor,
          ),
        ],
      );

      try {
        await harness.pump(tester);
        await harness.openFirstPost(tester);

        final infoButtons = find.byType(KurumiInfoCircleIcon);
        await tester.tap(infoButtons.first);
        await harness.settle(tester);
        await tester.pump(const Duration(milliseconds: 500));
        final downloadControl = find
            .byWidgetPredicate(
              (widget) =>
                  widget is material_ui.IconButton &&
                  widget.onLongPress != null,
            )
            .first;

        Future<void> selectSource(int index) async {
          final expectedRequestCount = service.requests.length + 1;
          await tester.ensureVisible(downloadControl);
          tester
              .widget<material_ui.IconButton>(downloadControl)
              .onLongPress!
              .call();
          await tester.pump();
          await harness.settle(tester);
          final items = find.byType(KurumiPopupMenuItem);
          expect(items, findsNWidgets(3));
          await tester.tap(items.at(index));
          await harness.pumpUntil(
            tester,
            () => service.requests.length >= expectedRequestCount,
          );
        }

        await selectSource(1);
        await selectSource(0);
        await selectSource(2);

        expect(extractor.qualities, ['original', 'sample']);
        expect(
          service.requests.map((request) => request.url),
          [
            'https://authoritative.test/posts/101/original.jpg',
            'https://authoritative.test/posts/101/sample.jpg',
            'https://listing.invalid/guessed.jpg',
          ],
        );
      } finally {
        await harness.teardown(tester);
      }
    },
  );
}

final class _TestDownloadSourceProvider implements DownloadSourceProvider {
  const _TestDownloadSourceProvider(this.sources);

  final List<DownloadSource> sources;

  @override
  List<DownloadSource> getDownloadSources(BuildContext context, Post post) =>
      sources;
}

final class _RecordingDownloadExtractor implements DownloadFileUrlExtractor {
  final qualities = <String>[];

  @override
  Future<DownloadUrlData> getDownloadFileUrl({
    required Post post,
    required String quality,
  }) async {
    qualities.add(quality);
    return DownloadUrlData.urlOnly(
      'https://authoritative.test/posts/${post.id}/$quality.jpg',
    );
  }
}
