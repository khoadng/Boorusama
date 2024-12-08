// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/search/filter.dart';
import 'package:boorusama/core/search/tag_edit.dart';
import 'package:boorusama/core/tags/metatag/extractor.dart';
import 'package:boorusama/core/tags/metatag/metatag.dart';

final _defaultMetatags = MetatagExtractor(
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
        _defaultMetatags,
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'tag',
          originalTag: 'tag',
          operator: FilterOperator.none,
        ),
      );
    });

    test('empty tag', () {
      final item = TagSearchItem.fromString(
        '',
        _defaultMetatags,
      );

      expect(
        item,
        const TagSearchItem(
          tag: '',
          originalTag: '',
          operator: FilterOperator.none,
        ),
      );
    });

    test('tag with colon', () {
      final item = TagSearchItem.fromString(
        ':p',
        _defaultMetatags,
      );

      expect(
        item,
        const TagSearchItem(
          tag: ':p',
          originalTag: ':p',
          operator: FilterOperator.none,
        ),
      );
    });

    test('tag with operator', () {
      final item = TagSearchItem.fromString(
        '-tag',
        _defaultMetatags,
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'tag',
          originalTag: '-tag',
          operator: FilterOperator.not,
        ),
      );
    });

    test('tag with metatag', () {
      final item = TagSearchItem.fromString(
        'foo:tag',
        _defaultMetatags,
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'tag',
          originalTag: 'foo:tag',
          metatag: 'foo',
          operator: FilterOperator.none,
        ),
      );
    });

    test('tag with metatag and its value', () {
      final item = TagSearchItem.fromString(
        'foo:>10',
        _defaultMetatags,
      );

      expect(
        item,
        const TagSearchItem(
          tag: '>10',
          originalTag: 'foo:>10',
          metatag: 'foo',
          operator: FilterOperator.none,
        ),
      );
    });

    test('tag with wrong metatag', () {
      final item = TagSearchItem.fromString(
        'wrong:tag',
        _defaultMetatags,
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'wrong:tag',
          originalTag: 'wrong:tag',
          operator: FilterOperator.none,
        ),
      );
    });

    group('convert to string tests', () {
      test('tag with operator', () {
        const item = TagSearchItem(
          tag: 'tag',
          originalTag: 'tag',
          operator: FilterOperator.not,
        );

        expect(
          item.toString(),
          '-tag',
        );
      });

      test('tag with metatag', () {
        const item = TagSearchItem(
          tag: 'tag',
          originalTag: 'tag',
          operator: FilterOperator.none,
          metatag: 'foo',
        );

        expect(
          item.toString(),
          'foo:tag',
        );
      });

      test('tag with metatag and operator', () {
        const item = TagSearchItem(
          tag: 'tag',
          originalTag: 'tag',
          operator: FilterOperator.not,
          metatag: 'foo',
        );

        expect(
          item.toString(),
          '-foo:tag',
        );
      });
    });
  });
}
