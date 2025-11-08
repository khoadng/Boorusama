// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/providers/create_download_options_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_options.dart';
import 'package:boorusama/core/search/histories/types.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';

void main() {
  late ProviderContainer container;
  late DownloadOptions initial;

  setUp(() {
    container = ProviderContainer();
    initial = DownloadOptions.initial(
      quality: 'original',
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('tag operations should work correctly', () {
    final notifier = container.read(
      createDownloadOptionsProvider(initial).notifier,
    )..addTag(TagSearchItem.fromString('tag1'));

    expect(
      listEquals(
        container.read(createDownloadOptionsProvider(initial)).tags.list,
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
        container.read(createDownloadOptionsProvider(initial)).tags.list,
        ['tag1', 'tag2'],
      ),
      isTrue,
    );

    // Remove tag
    notifier.removeTag(const TagSearchItem.raw(tag: 'tag2'));
    expect(
      listEquals(
        container.read(createDownloadOptionsProvider(initial)).tags.list,
        ['tag1'],
      ),
      isTrue,
    );
  });

  test('validation should work correctly', () {
    final notifier = container.read(
      createDownloadOptionsProvider(initial).notifier,
    );

    expect(notifier.state.valid(), isFalse); // Initially invalid

    notifier
      ..setPath('/storage/emulated/0/Download')
      ..addTag(TagSearchItem.fromString('test_tag'));

    expect(notifier.state.valid(), isTrue); // Valid
  });
}
