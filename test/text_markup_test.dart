// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/text_markup/types.dart';

void main() {
  group('text emoji shortcodes', () {
    test('extracts normalized shortcode names', () {
      expect(
        extractTextEmojiShortcodes(':Smile: :party_hat: :123: :http: :ab:'),
        {'smile', 'party_hat'},
      );
    });
  });

  group('text media embeds', () {
    test('extracts post and asset refs', () {
      expect(
        extractTextMediaEmbedRefs(
          'before\n!post #123\n* !asset #456: custom caption\nafter',
        ),
        {
          const TextMediaEmbedRef(type: TextMediaEmbedType.post, id: 123),
          const TextMediaEmbedRef(type: TextMediaEmbedType.asset, id: 456),
        },
      );
    });

    test('matches only Danbooru embed syntax', () {
      expect(
        extractTextMediaEmbedRefs(
          [
            'text !asset #456',
            ' !asset #456',
            '!Asset #456',
            '!asset  #456',
            '!asset #456 trailing',
          ].join('\n'),
        ),
        isEmpty,
      );
    });
  });
}
