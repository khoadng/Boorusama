// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/search/filter_operator.dart';
import 'package:boorusama/core/search/tag_search_item.dart';
import 'package:boorusama/core/tags/tags.dart';

final _defaultMetatags = [
  const Metatag(
    name: 'foo',
    description: '',
    example: '',
  ),
  const Metatag(
    name: 'bar',
    description: '',
    example: '',
  ),
];

void main() {
  group('[parse tests]', () {
    test('valid tag', () {
      final item = TagSearchItem.fromString(
        'tag',
        TagInfo(
          metatags: _defaultMetatags,
          defaultBlacklistedTags: [],
          r18Tags: [],
        ),
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'tag',
          operator: FilterOperator.none,
        ),
      );
    });

    test('empty tag', () {
      final item = TagSearchItem.fromString(
        '',
        TagInfo(
          metatags: _defaultMetatags,
          defaultBlacklistedTags: [],
          r18Tags: [],
        ),
      );

      expect(
        item,
        const TagSearchItem(
          tag: '',
          operator: FilterOperator.none,
        ),
      );
    });

    test('tag with operator', () {
      final item = TagSearchItem.fromString(
        '-tag',
        TagInfo(
          metatags: _defaultMetatags,
          defaultBlacklistedTags: [],
          r18Tags: [],
        ),
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'tag',
          operator: FilterOperator.not,
        ),
      );
    });

    test('tag with metatag', () {
      final item = TagSearchItem.fromString(
        'foo:tag',
        TagInfo(
          metatags: _defaultMetatags,
          defaultBlacklistedTags: [],
          r18Tags: [],
        ),
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'tag',
          metatag: 'foo',
          operator: FilterOperator.none,
        ),
      );
    });

    test('tag with wrong metatag', () {
      final item = TagSearchItem.fromString(
        'wrong:tag',
        TagInfo(
          metatags: _defaultMetatags,
          defaultBlacklistedTags: [],
          r18Tags: [],
        ),
      );

      expect(
        item,
        const TagSearchItem(
          tag: 'wrong:tag',
          operator: FilterOperator.none,
        ),
      );
    });

    group('convert to string tests', () {
      test('tag with operator', () {
        const item = TagSearchItem(
          tag: 'tag',
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
