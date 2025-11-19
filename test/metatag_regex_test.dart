// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/tags/types.dart';

void main() {
  final metatags = ['id', 'score', 'rating', 'user', 'height', 'width', 'sort'];
  final sortableTypes = [
    'id',
    'score',
    'rating',
    'user',
    'height',
    'width',
    'parent',
    'source',
    'updated',
  ];

  group('Regular metatags', () {
    test('extracts metatag with colon', () {
      expect(extractMetatagMatch('id:', metatags, sortableTypes), 'id:');
    });

    test('handles value after colon', () {
      expect(extractMetatagMatch('id:123', metatags, sortableTypes), 'id:');
    });

    final invalidCases = [
      'id',
      'invalid:',
      'xyz:',
    ];
    for (final input in invalidCases) {
      test('returns null for "$input"', () {
        expect(extractMetatagMatch(input, metatags, sortableTypes), null);
      });
    }
  });

  group('Sort metatags', () {
    final validCases = [
      (input: 'sort:', expected: 'sort:'),
      (input: 'sort:id', expected: 'sort:id'),
      (input: 'sort:id:', expected: 'sort:id:'),
      (input: 'sort:id:asc', expected: 'sort:id:asc'),
      (input: 'sort:id:desc', expected: 'sort:id:desc'),
    ];
    for (final c in validCases) {
      test('extracts "${c.expected}" from "${c.input}"', () {
        expect(
          extractMetatagMatch(c.input, metatags, sortableTypes),
          c.expected,
        );
      });
    }

    test('extracts only "sort:" when type is invalid', () {
      expect(
        extractMetatagMatch('sort:invalid', metatags, sortableTypes),
        'sort:',
      );
    });

    test('extracts only "sort:" when type is incomplete', () {
      expect(extractMetatagMatch('sort:sc', metatags, sortableTypes), 'sort:');
    });

    test('extracts up to valid part when order is invalid', () {
      expect(
        extractMetatagMatch('sort:id:invalid', metatags, sortableTypes),
        'sort:id:',
      );
    });

    test('excludes sort from regular metatags pattern', () {
      final regularMetatags = metatags.where((e) => e != 'sort').toList();
      expect(
        extractMetatagMatch('sort:', regularMetatags, sortableTypes),
        'sort:',
      );
    });
  });

  group('Pattern building', () {
    test(
      'generates valid pattern with sort syntax',
      () {
        final pattern = buildMetatagRegexPattern(
          metatags: ['id', 'score', 'sort'],
          sortableTypes: ['id', 'score'],
        );

        expect(pattern.contains('id'), true);
        expect(pattern.contains('score'), true);
        expect(pattern.contains('asc'), true);
        expect(pattern.contains('desc'), true);
      },
    );

    test('produces valid regex with empty lists', () {
      final pattern = buildMetatagRegexPattern(
        metatags: [],
        sortableTypes: [],
      );

      expect(() => RegExp(pattern), returnsNormally);
    });
  });
}
