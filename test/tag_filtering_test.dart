// Package imports:
import 'package:quiver/iterables.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/search/filter_operator.dart';
import 'package:boorusama/core/domain/posts/rating.dart';

Post _createPost(int id, List<String> tags) => Post(
      id: id,
      thumbnailImageUrl: '',
      sampleImageUrl: '',
      originalImageUrl: '',
      copyrightTags: const [],
      characterTags: const [],
      artistTags: const [],
      generalTags: const [],
      metaTags: const [],
      tags: tags,
      width: 1,
      height: 1,
      format: '',
      md5: '',
      lastCommentAt: null,
      source: null,
      createdAt: DateTime.now(),
      score: 1,
      upScore: 1,
      downScore: 1,
      favCount: 1,
      uploaderId: 1,
      rating: Rating.explicit,
      fileSize: 1,
      pixivId: null,
      isBanned: false,
      hasChildren: false,
      parentId: null,
      hasLarge: false,
      comments: const [],
      totalComments: 0,
    );

void main() {
  test('Single group', () {
    const tagString = 'a';
    final filterGroup = stringToFilterGroup(tagString);

    expect(filterGroup, isNot(null));
    expect(filterGroup!.groupType, FilterGroupType.single);
    expect(filterGroup.filterItems, [
      const FilterItem(
        tag: 'a',
        operator: FilterOperator.none,
      ),
    ]);
  });

  test('Single group with operator NOT', () {
    const tagString = '-a';
    final filterGroup = stringToFilterGroup(tagString);

    expect(filterGroup, isNot(null));
    expect(filterGroup!.groupType, FilterGroupType.single);
    expect(filterGroup.filterItems, [
      const FilterItem(
        tag: 'a',
        operator: FilterOperator.none,
      ),
    ]);
  });

  test('Single group with operator OR', () {
    const tagString = '~a';
    final filterGroup = stringToFilterGroup(tagString);

    expect(filterGroup, isNot(null));
    expect(filterGroup!.groupType, FilterGroupType.single);
    expect(filterGroup.filterItems, [
      const FilterItem(
        tag: 'a',
        operator: FilterOperator.none,
      ),
    ]);
  });

  test('Single group with unknown operator', () {
    const tagString = '+a';
    final filterGroup = stringToFilterGroup(tagString);

    expect(filterGroup, isNot(null));
    expect(filterGroup!.groupType, FilterGroupType.single);
    expect(filterGroup.filterItems, [
      const FilterItem(
        tag: '+a',
        operator: FilterOperator.none,
      ),
    ]);
  });

  test('Multiple group', () {
    const tagString = 'a b';
    final filterGroup = stringToFilterGroup(tagString);

    expect(filterGroup, isNot(null));
    expect(filterGroup!.groupType, FilterGroupType.multiple);
    expect(filterGroup.filterItems, [
      const FilterItem(
        tag: 'a',
        operator: FilterOperator.none,
      ),
      const FilterItem(
        tag: 'b',
        operator: FilterOperator.none,
      ),
    ]);
  });

  test('Multiple group with operators', () {
    const tagString = 'a -b ~c';
    final filterGroup = stringToFilterGroup(tagString);

    expect(filterGroup, isNot(null));
    expect(filterGroup!.groupType, FilterGroupType.multiple);
    expect(filterGroup.filterItems, [
      const FilterItem(
        tag: 'a',
        operator: FilterOperator.none,
      ),
      const FilterItem(
        tag: 'b',
        operator: FilterOperator.not,
      ),
      const FilterItem(
        tag: 'c',
        operator: FilterOperator.or,
      ),
    ]);
  });

  test('Empty tag list should return null', () {
    final filterGroup = stringToFilterGroup('');

    expect(filterGroup, null);
  });

  test('Filter blacklisted tags with single tag only should work', () {
    final tags = [
      ['a', 'b', 'c', 'd'],
      ['a'],
      ['c', 'd'],
      ['b', 'e'],
    ];
    final originals = range(tags.length)
        .map((e) => e.toInt())
        .map((e) => _createPost(e, tags[e]))
        .toList();

    final blacklisted = ['b', 'c'];

    final expected =
        filterRawPost(originals, blacklisted).map((e) => e.id).toList();
    expect(expected, [1]);
  });

  test('Filter blacklisted tags with multiple tags should work', () {
    final tags = [
      ['a', 'b', 'c', 'd'],
      ['a'],
      ['c', 'd'],
      ['b', 'e'],
    ];
    final originals = range(tags.length)
        .map((e) => e.toInt())
        .map((e) => _createPost(e, tags[e]))
        .toList();

    final blacklisted = ['b c', 'b e'];

    final expected =
        filterRawPost(originals, blacklisted).map((e) => e.id).toList();
    expect(expected, [1, 2]);
  });

  test('Filter blacklisted tags: NOT operator', () {
    final tags = [
      ['a', 'b', 'c', 'd'],
      ['a', 'b', 'd'],
      ['a', 'b', 'c'],
      ['a', 'b', 'foo', 'bar'],
      ['a', 'b'],
    ];
    final originals = range(tags.length)
        .map((e) => e.toInt())
        .map((e) => _createPost(e, tags[e]))
        .toList();

    final blacklisted = ['a b -c -d'];

    final expected =
        filterRawPost(originals, blacklisted).map((e) => e.id).toList();
    expect(expected, [0, 1, 2]);
  });

  test('Filter blacklisted tags: OR operator', () {
    final tags = [
      ['a'],
      ['b'],
      ['b', 'a'],
      ['c'],
      ['c', 'a'],
      ['c', 'b'],
      ['c', 'b', 'a'],
    ];
    final originals = range(tags.length)
        .map((e) => e.toInt())
        .map((e) => _createPost(e, tags[e]))
        .toList();

    final blacklisted = ['~a ~b -c'];

    final expected =
        filterRawPost(originals, blacklisted).map((e) => e.id).toList();
    expect(expected, [3, 4, 5, 6]);
  });

  test('Filter blacklisted tags: all operators', () {
    final tags = [
      ['a'],
      ['b'],
      ['b', 'a'], //remove
      ['c'], //remove
      ['c', 'a'], //remove
      ['c', 'b'], //remove
      ['c', 'b', 'a'], //remove
      ['d'],
      ['d', 'a'],
      ['d', 'b'],
      ['d', 'b', 'a'],
      ['d', 'c'],
      ['d', 'c', 'a'],
      ['d', 'c', 'b'],
      ['d', 'c', 'b', 'a'],
    ];
    final originals = range(tags.length)
        .map((e) => e.toInt())
        .map((e) => _createPost(e, tags[e]))
        .toList();

    final blacklisted = ['a b ~c -d'];

    final expected =
        filterRawPost(originals, blacklisted).map((e) => e.id).toList();
    expect(expected, [0, 1, 7, 8, 9, 10, 11, 12, 13, 14]);
  });

  test('Filter blacklisted tags with non-existed tag should be ignored', () {
    final tags = [
      ['a'],
      ['b'],
      ['b', 'a'],
      ['c'],
      ['c', 'a'],
      ['c', 'b'],
      ['c', 'b', 'a'],
    ];
    final originals = range(tags.length)
        .map((e) => e.toInt())
        .map((e) => _createPost(e, tags[e]))
        .toList();

    final blacklisted = ['~a ~b foobar'];

    final expected =
        filterRawPost(originals, blacklisted).map((e) => e.id).toList();
    expect(expected, [3]);
  });

  test(
    'Filter blacklisted tags with non-existed operator should be ignored',
    () {
      final tags = [
        ['a'],
        ['b'],
        ['b', 'a'],
        ['c'],
        ['c', 'a'],
        ['c', 'b'],
        ['c', 'b', 'a'],
      ];
      final originals = range(tags.length)
          .map((e) => e.toInt())
          .map((e) => _createPost(e, tags[e]))
          .toList();

      final blacklisted = ['~c %b'];

      final expected =
          filterRawPost(originals, blacklisted).map((e) => e.id).toList();
      expect(expected, [0, 1, 2]);
    },
  );
}
