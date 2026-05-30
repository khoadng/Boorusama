import 'package:dtext/dtext.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

String external(String url, {String? text}) =>
    '<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="$url">${text ?? url}</a>';

String namedExternal(String url, String text) =>
    '<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="$url">$text</a>';

String internal(String url, {String? text}) =>
    '<a class="dtext-link" href="$url">${text ?? url}</a>';

String idLink(String type, String url, String text) =>
    '<a class="dtext-link dtext-id-link dtext-$type-id-link" href="$url">$text</a>';

String wikiLink(String page, String text) =>
    '<a class="dtext-link dtext-wiki-link" href="/wiki_pages/$page">$text</a>';

String inline(String input, {DTextOptions options = const DTextOptions()}) =>
    parse(input, options: copyOptionsForInline(options));

DTextOptions copyOptionsForInline(DTextOptions options) => DTextOptions(
  inline: true,
  enableMentions: options.enableMentions,
  enableMediaEmbeds: options.enableMediaEmbeds,
  baseUrl: options.baseUrl,
  domain: options.domain,
  internalDomains: options.internalDomains,
  isAllowedEmoji: options.isAllowedEmoji,
);

void expectInlineCases(Map<String, String> cases) {
  for (final entry in cases.entries) {
    expect(inline(entry.key), entry.value, reason: entry.key);
  }
}

void main() {
  group('raw url detection', () {
    test('links ordinary http urls and trims sentence punctuation', () {
      expectDTextCases({
        'a http://test.com b': '<p>a ${external('http://test.com')} b</p>',
        'a Http://test.com b': '<p>a ${external('Http://test.com')} b</p>',
        'http://test.com\nb': '<p>${external('http://test.com')}<br>b</p>',
        'a http://test.com. b': '<p>a ${external('http://test.com')}. b</p>',
        '(http://test.com)': '<p>(${external('http://test.com')})</p>',
        '[http://test.com]': '<p>[${external('http://test.com')}]</p>',
        '{http://test.com}': '<p>{${external('http://test.com')}}</p>',
        '(at http://test.com/1234?page=42). blah':
            '<p>(at ${external('http://test.com/1234?page=42')}). blah</p>',
        'http://test.com/~bob/image.jpg':
            '<p>${external('http://test.com/~bob/image.jpg')}</p>',
        'http://test.com/home.html#toc':
            '<p>${external('http://test.com/home.html#toc')}</p>',
      });
    });

    test('respects URL start boundaries', () {
      expectDTextCases({
        'a_http://test.com': '<p>a_${external('http://test.com')}</p>',
        'a-http://test.com': '<p>a-${external('http://test.com')}</p>',
        'a*http://test.com': '<p>a*${external('http://test.com')}</p>',
        'a.http://test.com': '<p>a.${external('http://test.com')}</p>',
        'a,http://test.com': '<p>a,${external('http://test.com')}</p>',
        'a/http://test.com': '<p>a/${external('http://test.com')}</p>',
        'a"http://test.com': '<p>a&quot;${external('http://test.com')}</p>',
        "a'http://test.com": "<p>a'${external('http://test.com')}</p>",
        'a;http://test.com': '<p>a;${external('http://test.com')}</p>',
        'hhttp://example.com': '<p>hhttp://example.com</p>',
        'blahhttp://example.com': '<p>blahhttp://example.com</p>',
      });
    });

    test('handles delimiters and malformed URLs conservatively', () {
      expectDTextCases({
        '<https://danbooru.donmai.us>':
            '<p>${external('https://danbooru.donmai.us')}</p>',
        'https://example.com@gmail.com':
            '<p>${external('https://example.com')}@gmail.com</p>',
        'https://username@gmail.com': '<p>https://username@gmail.com</p>',
        'http://tegaki/pipa.jp/248411/': '<p>http://tegaki/pipa.jp/248411/</p>',
        'source:http://*.pixiv.net/img/una_k/':
            '<p>source:http://*.pixiv.net/img/una_k/</p>',
        'hxxp://www.age.jp/~kw': '<p>hxxp://www.age.jp/~kw</p>',
        'file://9dcd08b05cdc11e79eb675210c777bab.jpg':
            '<p>file://9dcd08b05cdc11e79eb675210c777bab.jpg</p>',
      });
    });
  });

  group('internal and short links', () {
    test('uses normal internal links for the configured domain', () {
      const options = DTextOptions(domain: 'danbooru.donmai.us');
      expect(
        parse('https://danbooru.donmai.us/login', options: options),
        '<p>${internal('https://danbooru.donmai.us/login')}</p>',
      );
      expect(
        parse('https://testbooru.donmai.us/login', options: options),
        '<p>${external('https://testbooru.donmai.us/login')}</p>',
      );
      expect(
        parse('"login":https://danbooru.donmai.us/login', options: options),
        '<p>${internal('https://danbooru.donmai.us/login', text: 'login')}</p>',
      );
    });

    test('converts trusted internal urls to id and wiki links', () {
      const options = DTextOptions(
        internalDomains: {'danbooru.donmai.us', 'betabooru.donmai.us'},
      );
      final cases = {
        'https://danbooru.donmai.us/posts/1234': idLink(
          'post',
          '/posts/1234',
          'post #1234',
        ),
        '<https://danbooru.donmai.us/posts/1234>': idLink(
          'post',
          '/posts/1234',
          'post #1234',
        ),
        'https://betabooru.donmai.us/posts/1234': idLink(
          'post',
          '/posts/1234',
          'post #1234',
        ),
        'https://danbooru.donmai.us/posts/1234?q=touhou': idLink(
          'post',
          '/posts/1234',
          'post #1234',
        ),
        'https://danbooru.donmai.us/pools/1234': idLink(
          'pool',
          '/pools/1234',
          'pool #1234',
        ),
        'https://danbooru.donmai.us/comments/1234': idLink(
          'comment',
          '/comments/1234',
          'comment #1234',
        ),
        'https://danbooru.donmai.us/forum_posts/1234': idLink(
          'forum-post',
          '/forum_posts/1234',
          'forum #1234',
        ),
        'https://danbooru.donmai.us/forum_topics/1234': idLink(
          'forum-topic',
          '/forum_topics/1234',
          'topic #1234',
        ),
        'https://danbooru.donmai.us/users/1234': idLink(
          'user',
          '/users/1234',
          'user #1234',
        ),
        'https://danbooru.donmai.us/artists/1234': idLink(
          'artist',
          '/artists/1234',
          'artist #1234',
        ),
        'https://danbooru.donmai.us/notes/1234': idLink(
          'note',
          '/notes/1234',
          'note #1234',
        ),
        'https://danbooru.donmai.us/favorite_groups/1234': idLink(
          'favorite-group',
          '/favorite_groups/1234',
          'favgroup #1234',
        ),
        'https://danbooru.donmai.us/wiki_pages/1234': idLink(
          'wiki-page',
          '/wiki_pages/1234',
          'wiki #1234',
        ),
        'https://danbooru.donmai.us/wiki_pages/touhou': wikiLink(
          'touhou',
          'touhou',
        ),
      };

      for (final entry in cases.entries) {
        expect(parse(entry.key, options: options), '<p>${entry.value}</p>');
      }
    });

    test('does not shortlink urls with fragments or non-post queries', () {
      const options = DTextOptions(
        domain: 'danbooru.donmai.us',
        internalDomains: {'danbooru.donmai.us'},
      );
      expect(
        parse(
          'https://danbooru.donmai.us/posts/1234#comment-5678',
          options: options,
        ),
        '<p>${internal('https://danbooru.donmai.us/posts/1234#comment-5678')}</p>',
      );
      expect(
        parse('https://danbooru.donmai.us/pools/1234?page=2', options: options),
        '<p>${internal('https://danbooru.donmai.us/pools/1234?page=2')}</p>',
      );
    });
  });

  group('named links', () {
    test('parses textile links', () {
      expectDTextCases({
        '"test":http://test.com':
            '<p>${namedExternal('http://test.com', 'test')}</p>',
        '"test":[http://test.com/(parentheses)]':
            '<p>${namedExternal('http://test.com/(parentheses)', 'test')}</p>',
        '"[i]test[/i]":http://test.com':
            '<p>${namedExternal('http://test.com', '<em>test</em>')}</p>',
        '"1" "2 & 3":http://three.com':
            '<p>&quot;1&quot; ${namedExternal('http://three.com', '2 &amp; 3')}</p>',
        '"http://test.com":http://test.com':
            '<p>${external('http://test.com')}</p>',
        '"test":#': '<p>${internal('#', text: 'test')}</p>',
        '"test":/x': '<p>${internal('/x', text: 'test')}</p>',
        '"test"://example.com':
            '<p>${namedExternal('http://example.com', 'test')}</p>',
      });
    });

    test('parses markdown and backwards markdown links', () {
      expectInlineCases({
        '[test](http://example.com)': namedExternal(
          'http://example.com',
          'test',
        ),
        '[http://example.com](test)': namedExternal(
          'http://example.com',
          'test',
        ),
        '[http://foo.com](http://bar.com)': namedExternal(
          'http://foo.com',
          'http://bar.com',
        ),
        '[/foo](/bar)': '[/foo](/bar)',
        '[test](/posts/1)': internal('/posts/1', text: 'test'),
        '[test](#foo)': internal('#foo', text: 'test'),
        '[blah](test)': '[blah](test)',
        '[test](/posts/1 2)': '[test](/posts/1 2)',
      });
    });
  });

  group('html and bbcode links', () {
    test('parses html anchor links', () {
      expectInlineCases({
        '<a href="http://example.com">test</a>': namedExternal(
          'http://example.com',
          'test',
        ),
        '<a href="Http://example.com">test</a>': namedExternal(
          'Http://example.com',
          'test',
        ),
        '<a href="/x">a [i]b[/i] c</a>': internal('/x', text: 'a <em>b</em> c'),
        '<a href="//example.com">test</a>': namedExternal(
          'http://example.com',
          'test',
        ),
        '<a href="">test</a>': '&lt;a href=&quot;&quot;&gt;test&lt;/a&gt;',
      });
    });

    test('parses bbcode url links', () {
      expectDTextCases({
        '[url]http://example.com[/url]':
            '<p>${external('http://example.com')}</p>',
        '[URL] http://example.com [/URL]':
            '<p>${external('http://example.com')}</p>',
        '[url]/posts[/url]': '<p>${internal('/posts')}</p>',
        '[url=/posts]posts[/url]':
            '<p>${internal('/posts', text: 'posts')}</p>',
        '[url=http://example.com]example[/url]':
            '<p>${namedExternal('http://example.com', 'example')}</p>',
        '[url="http://example.com"]example[/url]':
            '<p>${namedExternal('http://example.com', 'example')}</p>',
        "[url='http://example.com'] example [/url]":
            '<p>${namedExternal('http://example.com', 'example')}</p>',
        '[url=http://example.com][i]example[/i][/url]':
            '<p>${namedExternal('http://example.com', '<em>example</em>')}</p>',
        '[url]nonurl[/url]': '<p>[url]nonurl[/url]</p>',
        '[url=nonurl]blah[/url]': '<p>[url=nonurl]blah[/url]</p>',
        '[url=http://google.com][/url]':
            '<p>[url=${external('http://google.com')}][/url]</p>',
      });
    });
  });

  group('mailto links', () {
    test('requires an explicit mailto scheme', () {
      expectInlineCases({
        'user@gmail.com': 'user@gmail.com',
        'mailto:user@gmail.com': namedExternal(
          'mailto:user@gmail.com',
          'user@gmail.com',
        ),
        '<mailto:user@gmail.com>': namedExternal(
          'mailto:user@gmail.com',
          'user@gmail.com',
        ),
        '[url]mailto:user@gmail.com[/url]': namedExternal(
          'mailto:user@gmail.com',
          'user@gmail.com',
        ),
        '"user":mailto:user@gmail.com': namedExternal(
          'mailto:user@gmail.com',
          'user',
        ),
        '[user](mailto:user@gmail.com)': namedExternal(
          'mailto:user@gmail.com',
          'user',
        ),
        '[mailto:user@gmail.com](user)': namedExternal(
          'mailto:user@gmail.com',
          'user',
        ),
        '[url=mailto:user@gmail.com]user[/url]': namedExternal(
          'mailto:user@gmail.com',
          'user',
        ),
        '<a href="mailto:user@gmail.com">user</a>': namedExternal(
          'mailto:user@gmail.com',
          'user',
        ),
        'mailto:user@gmail.com.':
            '${namedExternal('mailto:user@gmail.com', 'user@gmail.com')}.',
        '(mailto:user@gmail.com)':
            '(${namedExternal('mailto:user@gmail.com', 'user@gmail.com')})',
      });
    });
  });
}
