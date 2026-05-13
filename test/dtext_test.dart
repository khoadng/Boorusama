// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/dtext/utils.dart';

void main() {
  group('[dtext renderer]', () {
    test('parses common inline dtext', () {
      const text = '''
[b]foo[/b]
[i]foo[/i]
[u]foo[/u]
[s]foo[/s]
"Foo":[https://foo.com]
''';

      expect(
        renderDText(text, booruUrl: 'https://danbooru.donmai.us'),
        '<p><strong>foo</strong><br><em>foo</em><br><u>foo</u><br><s>foo</s><br><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="https://foo.com">Foo</a></p>',
      );
    });

    test('passes booru URL options into the parser', () {
      expect(
        renderDText(
          'post #1 [[touhou]] https://danbooru.donmai.us/posts/2',
          booruUrl: 'https://danbooru.donmai.us',
        ),
        '<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="https://danbooru.donmai.us/posts/1">post #1</a> <a class="dtext-link dtext-wiki-link" href="https://danbooru.donmai.us/wiki_pages/touhou">touhou</a> <a class="dtext-link dtext-id-link dtext-post-id-link" href="https://danbooru.donmai.us/posts/2">post #2</a></p>',
      );
    });

    test('falls back to escaped plain text when parsing fails', () {
      expect(
        renderDText(
          '<b>unsafe</b>\n[quote]broken',
          booruUrl: 'https://danbooru.donmai.us',
          parser: (_, _) {
            throw StateError('boom');
          },
        ),
        '<p>&lt;b&gt;unsafe&lt;/b&gt;<br>[quote]broken</p>',
      );
    });
  });
}
