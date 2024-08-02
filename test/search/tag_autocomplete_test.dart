// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'common.dart';

final _defaultExtractor = MetatagExtractor(
  metatags: {
    const Metatag.simple(name: 'meta'),
  },
);

void main() {
  group('HTML test', () {
    // normal tag
    test('normal tag', () {
      expect(
        autocompleteData('tag').toDisplayHtml('ta'),
        '<p><b>ta</b>g</p>',
      );
    });

    // alias tag
    test('alias tag', () {
      expect(
        autocompleteData('tag', 'alias').toDisplayHtml('ta'),
        '<p>alias ➞ <b>ta</b>g</p>',
      );
    });

    // negate tag
    test('negate tag', () {
      expect(
        autocompleteData('tag').toDisplayHtml('-ta'),
        '<p><b>ta</b>g</p>',
      );
    });

    // or tag
    test('or tag', () {
      expect(
        autocompleteData('tag').toDisplayHtml('~ta'),
        '<p><b>ta</b>g</p>',
      );
    });

    // metatag
    group('metatag', () {
      test('normal', () {
        expect(
          autocompleteData('tag').toDisplayHtml('meta:ta', _defaultExtractor),
          '<p><b>ta</b>g</p>',
        );
      });

      // case
      test('case', () {
        expect(
          const AutocompleteData(
            value: 'meta:Sentence_Case',
            label: 'Sentence Case',
          ).toDisplayHtml('meta:sent', _defaultExtractor),
          '<p><b>Sent</b>ence Case</p>',
        );
      });

      // unknown metatag
      test('unknown metatag', () {
        expect(
          const AutocompleteData(
            value: 'foo:Unknown',
            label: 'Unknown',
          ).toDisplayHtml('foo:unk', _defaultExtractor),
          '<p>Unknown</p>',
        );
      });
    });

    group('complex queries', () {
      // normal
      test('parenthesis', () {
        expect(
          autocompleteData('tag').toDisplayHtml('(ta', _defaultExtractor),
          '<p>tag</p>',
        );
      });
    });
  });
}
