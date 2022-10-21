// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';

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
  group('[tag search item test]', () {
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
  });
}
