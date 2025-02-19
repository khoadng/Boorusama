// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/search/queries/filter_operator.dart';
import 'package:boorusama/core/search/selected_tags/search_tag_set.dart';
import 'package:boorusama/core/search/selected_tags/tag_search_item.dart';

void main() {
  group('SearchTagSet', () {
    test('create from string - simple tags', () {
      final set = SearchTagSet.fromString('tag1 tag2 tag3');
      expect(set.toString(), equals('["tag1","tag2","tag3"]'));
    });

    test('create from string - json format', () {
      final set = SearchTagSet.fromString('["tag1","tag2","tag3"]');
      expect(set.toString(), equals('["tag1","tag2","tag3"]'));
    });

    test('add single tag', () {
      final set = SearchTagSet()..addTag('test_tag');
      expect(set.toString(), equals('["test_tag"]'));
    });

    test('add multiple tags', () {
      final set = SearchTagSet()..addTags(['tag1', 'tag2']);
      expect(set.toString(), equals('["tag1","tag2"]'));
    });

    test('remove tag', () {
      final set = SearchTagSet()
        ..addTag('tag1')
        ..addTag('tag2')
        ..removeTag(
          const TagSearchItem(
            tag: 'tag1',
            operator: FilterOperator.none,
            originalTag: 'tag1',
          ),
        );
      expect(set.toString(), equals('["tag2"]'));
    });

    test('clear tags', () {
      final set = SearchTagSet()
        ..addTags(['tag1', 'tag2'])
        ..clear();
      expect(set.toString(), equals(''));
    });

    test('add tag with operator', () {
      final set = SearchTagSet()
        ..addTag('test_tag', operator: FilterOperator.not);
      expect(set.toString(), equals('["-test_tag"]'));
    });

    test('negate tag', () {
      final set = SearchTagSet()..negateTag('test_tag');
      expect(set.toString(), equals('["-test_tag"]'));
    });

    test('update tag', () {
      final set = SearchTagSet();

      final tag = set.addTag('old_tag');
      set.updateTag(tag!, 'new_tag');
      expect(set.toString(), equals('["new_tag"]'));
    });

    test('ignore empty tags', () {
      final set = SearchTagSet()..addTag('');
      expect(set.toString(), equals(''));
    });

    test('handle whitespace properly', () {
      final set = SearchTagSet.fromString('  tag1    tag2  tag3  ');
      expect(set.toString(), equals('["tag1","tag2","tag3"]'));
    });

    test('handle duplicate tags', () {
      final set = SearchTagSet()
        ..addTag('tag1')
        ..addTag('tag1')
        ..addTag('tag2')
        ..addTag('tag2');
      expect(set.toString(), equals('["tag1","tag2"]'));
    });

    test('handle malformed JSON input', () {
      final set = SearchTagSet.fromString('[not valid json}');
      expect(set.toString(), equals('["[not","valid","json}"]'));
    });

    test('handle mixed operators', () {
      final set = SearchTagSet()
        ..addTag('tag1', operator: FilterOperator.not)
        ..addTag('tag2')
        ..addTag('tag3', operator: FilterOperator.not);
      expect(set.toString(), equals('["-tag1","tag2","-tag3"]'));
    });

    test('empty set should return empty string', () {
      final set = SearchTagSet();
      expect(set.toString(), equals(''));

      set.clear();
      expect(set.toString(), equals(''));
    });

    test('clone should create independent copy', () {
      final original = SearchTagSet()
        ..addTag('tag1')
        ..addTag('tag2', operator: FilterOperator.not)
        ..addTag('tag3', operator: FilterOperator.or);

      final cloned = original.clone();

      // Verify initial state matches
      expect(cloned, equals(original));

      // Modify cloned set
      cloned.addTag('tag4');

      // Verify changes don't affect original
      expect(original.list, equals(['tag1', '-tag2', '~tag3']));
      expect(cloned.list, equals(['tag1', '-tag2', '~tag3', 'tag4']));
    });

    test('list getter should return tags', () {
      final set = SearchTagSet()
        ..addTag('tag1')
        ..addTag('tag2', operator: FilterOperator.not)
        ..addTag('tag3', operator: FilterOperator.or);

      expect(set.list, equals(['tag1', '-tag2', '~tag3']));
    });

    test('list getter should return empty list for empty set', () {
      final set = SearchTagSet();
      expect(set.list, isEmpty);
    });
  });
}
