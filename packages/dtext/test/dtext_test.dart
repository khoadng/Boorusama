import 'package:dtext/dtext.dart';
import 'package:test/test.dart';

void main() {
  group('DText.parse', () {
    test('parses paragraphs and line breaks', () {
      expect(DText.parse('hello world'), '<p>hello world</p>');
      expect(DText.parse('a\nb'), '<p>a<br>b</p>');
      expect(DText.parse('a\n\nb'), '<p>a</p><p>b</p>');
    });

    test('escapes html', () {
      expect(DText.parse('<3 & "x"'), '<p>&lt;3 &amp; &quot;x&quot;</p>');
    });

    test('parses common inline tags', () {
      expect(
        DText.parse('[b]bold[/b] [i]it[/i] [u]u[/u] [s]s[/s]'),
        '<p><strong>bold</strong> <em>it</em> <u>u</u> <s>s</s></p>',
      );
    });

    test('parses inline spoiler and code', () {
      expect(
        DText.parse('a [spoiler]b[/spoiler] [code]<x>[/code]'),
        '<p>a <span class="spoiler">b</span> <code>&lt;x&gt;</code></p>',
      );
    });

    test('parses wiki links and records wiki pages', () {
      final result = DText.parseWithResult('a [[Touhou Project|Touhou]] b');

      expect(
        result.html,
        '<p>a <a class="dtext-link dtext-wiki-link" href="/wiki_pages/touhou_project">Touhou</a> b</p>',
      );
      expect(result.wikiPages, {'Touhou Project'});
      expect(result.document.wikiPages, {'Touhou Project'});
    });

    test('separates document parsing from html rendering', () {
      final document = DText.parseDocument('[b]bold[/b]');

      expect(document.children, hasLength(1));
      expect(document.children.single, isA<DTextElementNode>());
      final paragraph = document.children.single as DTextElementNode;
      expect(paragraph.element, DTextElement.paragraph);
      expect(paragraph.children.single, isA<DTextElementNode>());
      expect(DText.renderHtml(document), '<p><strong>bold</strong></p>');
    });

    test('parses post search links', () {
      expect(
        DText.parse('{{cat dog|Search}}'),
        '<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=cat%20dog">Search</a></p>',
      );
    });

    test('parses named links and raw urls', () {
      expect(
        DText.parse('"home":/posts https://example.com'),
        '<p><a class="dtext-link" href="/posts">home</a> <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="https://example.com">https://example.com</a></p>',
      );
    });

    test('parses id links', () {
      expect(
        DText.parse('post #123 topic #456/p7 pixiv #42/p3'),
        '<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/123">post #123</a> <a class="dtext-link dtext-id-link dtext-forum-topic-id-link" href="/forum_topics/456?page=7">topic #456/p7</a> <a rel="external nofollow noreferrer" class="dtext-link dtext-id-link dtext-pixiv-id-link" href="https://www.pixiv.net/artworks/42#3">pixiv #42/p3</a></p>',
      );
    });

    test('parses mentions', () {
      expect(
        DText.parse('hi @evazion'),
        '<p>hi <a class="dtext-link dtext-user-mention-link" data-user-name="evazion" href="/users?name=evazion">@evazion</a></p>',
      );
    });

    test('can disable mentions', () {
      expect(
        DText.parse(
          'hi @evazion',
          options: const DTextOptions(enableMentions: false),
        ),
        '<p>hi @evazion</p>',
      );
    });

    test('parses block quote, spoiler, and expand', () {
      expect(
        DText.parse(
          '[quote]\nhello\n[/quote]\n[spoiler]\nsecret\n[/spoiler]\n[expand=More]\nbody\n[/expand]',
        ),
        '<blockquote><p>hello</p></blockquote><div class="spoiler"><p>secret</p></div><details><summary>More</summary><div><p>body</p></div></details>',
      );
    });

    test('parses nested quotes', () {
      expect(
        DText.parse(
          '[quote]\nouter\n[quote]\nmiddle\n[quote]\ninner\n[/quote]\n[/quote]\n[/quote]',
        ),
        '<blockquote><p>outer</p><blockquote><p>middle</p><blockquote><p>inner</p></blockquote></blockquote></blockquote>',
      );
    });

    test('parses headings, hr, lists, and code fences', () {
      expect(
        DText.parse(
          'h2#See-Also. See Also\n* one\n** two\n[hr]\n```dart\n<x>\n```',
        ),
        '<h2 id="dtext-see-also">See Also</h2><ul><li>one</li><ul><li>two</li></ul></ul><hr><pre class="language-dart">&lt;x&gt;</pre>',
      );
    });

    test('parses simple tables', () {
      expect(
        DText.parse(
          '[table][tr][th]A[/th][/tr][tr][td]post #1[/td][/tr][/table]',
        ),
        '<table class="striped"><tr><th>A</th></tr><tr><td><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1">post #1</a></td></tr></table>',
      );
    });

    test('parses html table head and body sections', () {
      expect(
        DText.parse(
          '<table>\n'
          '<thead>\n'
          '<tr>\n'
          '<th>Post#</th>\n'
          '<th>Date</th>\n'
          '</tr>\n'
          '</thead>\n'
          '<tbody>\n'
          '<tr>\n'
          '<td>post #1</td>\n'
          '<td>24-may-2005</td>\n'
          '</tr>\n'
          '</tbody>\n'
          '</table>',
        ),
        '<table class="striped"><tr><th>Post#</th><th>Date</th></tr><tr><td><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1">post #1</a></td><td>24-may-2005</td></tr></table>',
      );
    });

    test('wraps table sections without an explicit table tag', () {
      expect(
        DText.parse(
          '<thead><tr><th>A</th></tr></thead>'
          '<tbody><tr><td>post #1</td></tr></tbody>',
        ),
        '<table class="striped"><tr><th>A</th></tr><tr><td><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1">post #1</a></td></tr></table>',
      );
    });

    test('uses base url for relative links', () {
      expect(
        DText.parse(
          'post #1 [[touhou]] "home":/posts',
          options: const DTextOptions(baseUrl: 'https://danbooru.donmai.us'),
        ),
        '<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="https://danbooru.donmai.us/posts/1">post #1</a> <a class="dtext-link dtext-wiki-link" href="https://danbooru.donmai.us/wiki_pages/touhou">touhou</a> <a class="dtext-link" href="https://danbooru.donmai.us/posts">home</a></p>',
      );
    });
  });
}
