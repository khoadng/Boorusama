// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/search/selected_tags/tag_search_item.dart';
import 'package:boorusama/core/tags/metatag/types.dart';

final _defaultMetatags = DefaultMetatagExtractor(
  metatags: {
    const Metatag.simple(
      name: 'foo',
    ),
    const Metatag.simple(
      name: 'bar',
    ),
  },
);

void main() {
  group('[parse tests]', () {
    test('valid tag', () {
      final item = TagSearchItem.fromString(
        'tag',
        extractor: _defaultMetatags,
      );

      expect(
        item.toString(),
        'tag',
      );
    });

    test('empty tag', () {
      final item = TagSearchItem.fromString(
        '',
        extractor: _defaultMetatags,
      );

      expect(
        item.toString(),
        '',
      );
    });

    test('tag with colon', () {
      final item = TagSearchItem.fromString(
        ':p',
        extractor: _defaultMetatags,
      );

      expect(
        item.toString(),
        ':p',
      );
    });

    test('tag with operator', () {
      final item = TagSearchItem.fromString(
        '-tag',
        extractor: _defaultMetatags,
      );

      expect(
        item.toString(),
        '-tag',
      );
    });

    test('tag with metatag', () {
      final item = TagSearchItem.fromString(
        'foo:tag',
        extractor: _defaultMetatags,
      );

      expect(
        item.toString(),
        'foo:tag',
      );
    });

    test('tag with metatag and its value', () {
      final item = TagSearchItem.fromString(
        'foo:>10',
        extractor: _defaultMetatags,
      );

      expect(
        item.toString(),
        'foo:>10',
      );
    });

    test('tag with wrong metatag', () {
      final item = TagSearchItem.fromString(
        'wrong:tag',
        extractor: _defaultMetatags,
      );

      expect(
        item.toString(),
        'wrong:tag',
      );
    });
  });
}
