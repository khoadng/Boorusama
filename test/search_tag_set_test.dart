// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/search/selected_tags/search_tag_set.dart';
import 'package:boorusama/core/search/selected_tags/tag_search_item.dart';

void main() {
  group('SearchTagSet', () {
    test('add single tag', () {
      final set = SearchTagSet()..addTag(TagSearchItem.fromString('test_tag'));
      expect(set.toString(), equals('["test_tag"]'));
    });

    test('add multiple tags', () {
      final set = SearchTagSet()
        ..addTags([
          TagSearchItem.fromString('tag1'),
          TagSearchItem.fromString('tag2'),
        ]);
      expect(set.toString(), equals('["tag1","tag2"]'));
    });

    test('remove tag', () {
      final set = SearchTagSet()
        ..addTag(TagSearchItem.fromString('tag1'))
        ..addTag(TagSearchItem.fromString('tag2'))
        ..removeTag(
          TagSearchItem.fromString('tag1'),
        );
      expect(set.toString(), equals('["tag2"]'));
    });

    test('clear tags', () {
      final set = SearchTagSet()
        ..addTags([
          TagSearchItem.fromString('tag1'),
          TagSearchItem.fromString('tag2'),
        ])
        ..clear();
      expect(set.toString(), equals(''));
    });

    test('add tag with operator', () {
      final set = SearchTagSet()..addTag(TagSearchItem.fromString('-test_tag'));
      expect(set.toString(), equals('["-test_tag"]'));
    });

    test('update tag', () {
      final set = SearchTagSet();

      final tag = TagSearchItem.fromString('old_tag');
      set.addTag(tag);
      set.updateTag(tag, const TagSearchItem.raw(tag: 'new_tag'));
      expect(set.toString(), equals('["new_tag"]'));
    });

    test('handle duplicate tags', () {
      final tag1 = TagSearchItem.fromString('tag1');
      final tag2 = TagSearchItem.fromString('tag2');
      final set = SearchTagSet()
        ..addTag(tag1)
        ..addTag(tag1)
        ..addTag(tag2)
        ..addTag(tag2);
      expect(set.toString(), equals('["tag1","tag2"]'));
    });

    test('handle mixed operators', () {
      final set = SearchTagSet()
        ..addTag(TagSearchItem.fromString('-tag1'))
        ..addTag(TagSearchItem.fromString('tag2'))
        ..addTag(TagSearchItem.fromString('-tag3'));
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
        ..addTag(TagSearchItem.fromString('tag1'))
        ..addTag(TagSearchItem.fromString('-tag2'))
        ..addTag(TagSearchItem.fromString('~tag3'));

      final cloned = original.clone();

      // Verify initial state matches
      expect(cloned, equals(original));

      // Modify cloned set
      cloned.addTag(TagSearchItem.fromString('tag4'));

      // Verify changes don't affect original
      expect(original.list, equals(['tag1', '-tag2', '~tag3']));
      expect(cloned.list, equals(['tag1', '-tag2', '~tag3', 'tag4']));
    });

    test('list getter should return tags', () {
      final set = SearchTagSet()
        ..addTag(TagSearchItem.fromString('tag1'))
        ..addTag(TagSearchItem.fromString('-tag2'))
        ..addTag(TagSearchItem.fromString('~tag3'));

      expect(set.list, equals(['tag1', '-tag2', '~tag3']));
    });

    test('list getter should return empty list for empty set', () {
      final set = SearchTagSet();
      expect(set.list, isEmpty);
    });

    test('originalTag preserves spaces after round-trip serialization', () {
      final original = SearchTagSet()
        ..addTag(const TagSearchItem.raw(tag: '{1girl ~ blue_hair}'));

      final serialized = original.toString();
      final restored = SearchTagSet.fromString(serialized);

      expect(
        restored.spaceDelimitedOriginalTags,
        equals('{1girl ~ blue_hair}'),
      );
    });
  });

  group('queryAsList', () {
    test('handle null input', () {
      expect(queryAsList(null), equals([]));
    });

    test('parse simple space-delimited tags', () {
      expect(
        queryAsList('tag1 tag2 tag3'),
        equals(['tag1', 'tag2', 'tag3']),
      );
    });

    test('parse JSON array format', () {
      expect(
        queryAsList('["tag1","tag2","tag3"]'),
        equals(['tag1', 'tag2', 'tag3']),
      );
    });

    test('handle whitespace properly', () {
      expect(
        queryAsList('  tag1    tag2  tag3  '),
        equals(['tag1', 'tag2', 'tag3']),
      );
    });

    test('handle malformed JSON input', () {
      expect(
        queryAsList('[not valid json}'),
        equals(['[not', 'valid', 'json}']),
      );
    });

    test('handle empty string', () {
      expect(queryAsList(''), equals([]));
    });

    test('handle JSON array with non-string values', () {
      expect(
        queryAsList('["tag1", 123, "tag2", true]'),
        equals(['tag1', 'tag2']),
      );
    });

    test('handle JSON array with empty strings', () {
      expect(
        queryAsList('["tag1", "", "tag2", "  "]'),
        equals(['tag1', 'tag2']),
      );
    });

    test('handle special characters', () {
      expect(
        queryAsList('tag#1 tag@2 tag%3'),
        equals(['tag#1', 'tag@2', 'tag%3']),
      );
    });

    test('handle nested JSON arrays', () {
      expect(
        queryAsList('["tag1",["tag2","tag3"],"tag4"]'),
        equals(['tag1', 'tag4']), // nested arrays are ignored
      );
    });

    test('handle unicode characters', () {
      expect(
        queryAsList('タグ1 タグ2 タグ3'),
        equals(['タグ1', 'タグ2', 'タグ3']),
      );
    });
  });
}
