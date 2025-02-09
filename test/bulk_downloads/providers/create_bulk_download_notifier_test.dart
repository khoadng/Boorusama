// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/downloads/bulks/providers/create_bulk_download_notifier.dart';
import 'package:boorusama/core/downloads/bulks/types/download_options.dart';
import 'package:boorusama/core/search/histories/history.dart';
import 'package:boorusama/core/settings/settings.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        bulkDownloadQualityProvider.overrideWithValue(
          DownloadQuality.original,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('tag operations should work correctly', () {
    final notifier = container.read(createBulkDownload2Provider.notifier)
      ..addTag('tag1');

    expect(
      listEquals(
        container.read(createBulkDownload2Provider).tags,
        ['tag1'],
      ),
      isTrue,
    );

    // Add multiple tags from search history
    notifier.addFromSearchHistory(
      SearchHistory(
        query: 'tag2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        searchCount: 1,
        queryType: QueryType.simple,
        booruTypeName: 'test',
        siteUrl: 'test',
      ),
    );

    expect(
      listEquals(
        container.read(createBulkDownload2Provider).tags,
        ['tag1', 'tag2'],
      ),
      isTrue,
    );

    // Remove tag
    notifier.removeTag('tag2');
    expect(
      listEquals(
        container.read(createBulkDownload2Provider).tags,
        ['tag1'],
      ),
      isTrue,
    );
  });

  test('validation should work correctly', () {
    final notifier = container.read(createBulkDownload2Provider.notifier);

    expect(notifier.state.valid(android: false), isFalse); // Initially invalid

    notifier
      ..setPath('/test/path')
      ..addTag('test_tag');

    expect(notifier.state.valid(android: false), isTrue); // Valid
  });
}
