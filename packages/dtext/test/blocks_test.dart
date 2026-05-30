import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group('paragraphs', () {
    test('handles paragraph and line break boundaries', () {
      expectDTextCases({
        'abc': '<p>abc</p>',
        'a\nb\nc': '<p>a<br>b<br>c</p>',
        'a\n\nb': '<p>a</p><p>b</p>',
        'a\r\n\r\nb': '<p>a</p><p>b</p>',
        'a \n\nb': '<p>a </p><p>b</p>',
        'a\n\n b': '<p>a</p><p> b</p>',
        'a\n ': '<p>a</p>',
        'a \n': '<p>a </p>',
        'a\n\n ': '<p>a</p>',
      });
    });
  });

  group('headers', () {
    test('handles header levels and ids', () {
      expectDTextCases({
        'h1. header': '<h1>header</h1>',
        'h4. See also': '<h4>See also</h4>',
        'h1#blah. header': '<h1 id="dtext-blah">header</h1>',
        'h1#See_Also. header': '<h1 id="dtext-see-also">header</h1>',
        'blah h1. blah': '<p>blah h1. blah</p>',
        '* a\n\nh1. header\n* list':
            '<ul><li>a</li></ul><h1>header</h1><ul><li>list</li></ul>',
        'h1. header\nh2. header': '<h1>header</h1><h2>header</h2>',
        'h1. [i]header\nblah': '<h1><em>header</em></h1><p>blah</p>',
      });
    });
  });

  group('spoilers', () {
    test('handles inline and block spoilers', () {
      expectDTextCases({
        'this is [spoiler]an inline spoiler[/spoiler].':
            '<p>this is <span class="spoiler">an inline spoiler</span>.</p>',
        'this is [SPOILERS]an inline spoiler[/SPOILERS].':
            '<p>this is <span class="spoiler">an inline spoiler</span>.</p>',
        'this is\n\n[spoiler]\na block spoiler\n[/spoiler].':
            '<p>this is</p><div class="spoiler"><p>a block spoiler</p></div><p>.</p>',
        '[spoiler]this is a spoiler with no closing tag\n\nnew text':
            '<div class="spoiler"><p>this is a spoiler with no closing tag</p><p>new text</p></div>',
        '[spoiler]this is a spoiler with no closing tag\nnew text':
            '<div class="spoiler"><p>this is a spoiler with no closing tag<br>new text</p></div>',
        '[spoiler]\nthis is a block spoiler with no closing tag':
            '<div class="spoiler"><p>this is a block spoiler with no closing tag</p></div>',
        '[spoiler]this is [spoiler]a nested[/spoiler] spoiler[/spoiler]':
            '<div class="spoiler"><p>this is <span class="spoiler">a nested</span> spoiler</p></div>',
        '[spoiler]\nh4. Blah\n[/spoiler]':
            '<div class="spoiler"><h4>Blah</h4></div>',
        '* one\n[spoiler]\n* two\n[/spoiler]\n* three':
            '<ul><li>one</li></ul><div class="spoiler"><ul><li>two</li></ul></div><ul><li>three</li></ul>',
      });
    });
  });

  group('quote blocks', () {
    test('handles quote block forms and continuations', () {
      expectDTextCases({
        '[quote]\ntest\n[/quote]': '<blockquote><p>test</p></blockquote>',
        '<quote>\ntest\n</quote>': '<blockquote><p>test</p></blockquote>',
        '<blockquote>\ntest\n</blockquote>':
            '<blockquote><p>test</p></blockquote>',
        '[quote]\ntest\n[/quote] blah':
            '<blockquote><p>test</p></blockquote><p> blah</p>',
        '[quote]\ntest\n[/quote]\nblah':
            '<blockquote><p>test</p></blockquote><p>blah</p>',
        'test\n[/quote] blah': '<p>test<br>[/quote] blah</p>',
        '[quote]\ntest\n[/quote]\nh4. See also':
            '<blockquote><p>test</p></blockquote><h4>See also</h4>',
        '[quote]\ntest\n[/quote]\n[spoiler]blah[/spoiler]':
            '<blockquote><p>test</p></blockquote><div class="spoiler"><p>blah</p></div>',
        '[quote]\n* hello\n* there\n[/quote]\nabc':
            '<blockquote><ul><li>hello</li><li>there</li></ul></blockquote><p>abc</p>',
      });
    });

    test('handles nested quote blocks', () {
      expect(
        parse('[quote]\na\n[quote]\nb\n[/quote]\nc\n[/quote]'),
        '<blockquote><p>a</p><blockquote><p>b</p></blockquote><p>c</p></blockquote>',
      );
    });

    test('recovers from unclosed tags inside quote blocks', () {
      expectDTextCases({
        '[quote][b]foo[/quote]':
            '<blockquote><p><strong>foo</strong></p></blockquote>',
        '[quote][quote]foo[/quote]':
            '<blockquote><blockquote><p>foo</p></blockquote></blockquote>',
        '[quote][spoiler]foo[/quote]':
            '<blockquote><div class="spoiler"><p>foo</p></div></blockquote>',
        '[quote][code]foo[/quote]':
            '<blockquote><pre>foo[/quote]</pre></blockquote>',
        '[quote][expand]foo[/quote]':
            '<blockquote><details><summary>Show</summary><div><p>foo</p></div></details></blockquote>',
        '[quote][nodtext]foo[/quote]':
            '<blockquote><p>foo[/quote]</p></blockquote>',
        '[quote]* foo[/quote]':
            '<blockquote><ul><li>foo</li></ul></blockquote>',
        '[quote]h1. foo[/quote]': '<blockquote><h1>foo</h1></blockquote>',
      });
    });

    test('handles nested spoiler and expand blocks', () {
      expectDTextCases({
        '[quote]\na\n[spoiler]blah[/spoiler]\nc[/quote]':
            '<blockquote><p>a<br><span class="spoiler">blah</span><br>c</p></blockquote>',
        '[quote]\na\n\n[spoiler]blah[/spoiler]\n\nc[/quote]':
            '<blockquote><p>a</p><div class="spoiler"><p>blah</p></div><p>c</p></blockquote>',
        '[quote]\na\n[expand]\nb\n[/expand]\nc\n[/quote]':
            '<blockquote><p>a</p><details><summary>Show</summary><div><p>b</p></div></details><p>c</p></blockquote>',
      });
    });
  });

  group('code blocks', () {
    test('escapes code block contents', () {
      expectDTextCases({
        '[code]\n<br>\n[/code]': '<pre>&lt;br&gt;\n</pre>',
        '```\n&lt;\n```': '<pre>&amp;lt;</pre>',
        '[code][b]lol[/b][/code]': '<pre>[b]lol[/b]</pre>',
        '[code]post #123[/code]': '<pre>post #123</pre>',
        '[code]x': '<pre>x</pre>',
        '[code=ruby]\nx\n[/code]': '<pre class="language-ruby">x\n</pre>',
        '[code]\n[hr]\n[/code]': '<pre>[hr]\n</pre>',
      });
    });
  });

  group('expand blocks', () {
    test('handles default and aliased expand blocks', () {
      expectDTextCases({
        '[expand]hello world[/expand]':
            '<details><summary>Show</summary><div><p>hello world</p></div></details>',
        '<expand>hello world</expand>':
            '<details><summary>Show</summary><div><p>hello world</p></div></details>',
        '[expand=hello]blah blah[/expand]':
            '<details><summary>hello</summary><div><p>blah blah</p></div></details>',
        '[expand hello]blah blah[/expand]':
            '<details><summary>hello</summary><div><p>blah blah</p></div></details>',
        'inline [expand]blah blah[/expand]':
            '<p>inline [expand]blah blah[/expand]</p>',
        '[expand]\n[code]\nhello\n[/code]\n[/expand]':
            '<details><summary>Show</summary><div><pre>hello\n</pre></div></details>',
        '[expand]\n* a\n* b\n[/expand]\nc':
            '<details><summary>Show</summary><div><ul><li>a</li><li>b</li></ul></div></details><p>c</p>',
      });
    });
  });

  group('hr and br', () {
    test('handles horizontal rules at block boundaries', () {
      expectDTextCases({
        '[hr]': '<hr>',
        '[HR]': '<hr>',
        '<hr>': '<hr>',
        ' [hr] ': '<hr>',
        '[hr]\n\n[hr]\n\n[hr]': '<hr><hr><hr>',
        'foo\n\n[hr]': '<p>foo</p><hr>',
        '[hr]\n\nfoo': '<hr><p>foo</p>',
        'x[hr]': '<p>x[hr]</p>',
        '[hr]x': '<p>[hr]x</p>',
        'foo [hr] bar': '<p>foo [hr] bar</p>',
        '[quote]\n[hr]\n[/quote]': '<blockquote><hr></blockquote>',
        '[spoiler]\n[hr]\n[/spoiler]': '<div class="spoiler"><hr></div>',
        '[expand]\n[hr]\n[/expand]':
            '<details><summary>Show</summary><div><hr></div></details>',
      });
    });

    test('handles explicit line breaks', () {
      expectDTextCases({
        'foo[br]bar': '<p>foo<br>bar</p>',
        'foo[BR]bar': '<p>foo<br>bar</p>',
        'foo<br>bar': '<p>foo<br>bar</p>',
        'foo<BR>bar': '<p>foo<br>bar</p>',
        '* foo<br>bar': '<ul><li>foo<br>bar</li></ul>',
        'foo [br]\n\nbar': '<p>foo <br></p><p>bar</p>',
        'foo\n[br][br]\n\nbar': '<p>foo<br><br><br></p><p>bar</p>',
      });
    });
  });

  group('lists', () {
    test('handles flat and nested lists', () {
      expectDTextCases({
        '* a': '<ul><li>a</li></ul>',
        '* a\n* b': '<ul><li>a</li><li>b</li></ul>',
        '* a\r\n* b': '<ul><li>a</li><li>b</li></ul>',
        '* a\n\n* b': '<ul><li>a</li></ul><ul><li>b</li></ul>',
        '* a\n** b': '<ul><li>a</li><ul><li>b</li></ul></ul>',
        '* a\n** b\n*** c':
            '<ul><li>a</li><ul><li>b</li><ul><li>c</li></ul></ul></ul>',
        '*** a\n** b\n* c':
            '<ul><ul><ul><li>a</li></ul><li>b</li></ul><li>c</li></ul>',
        '* a\nb\n* c': '<ul><li>a</li></ul><p>b</p><ul><li>c</li></ul>',
        'a\nb\n* c\n* d': '<p>a<br>b</p><ul><li>c</li><li>d</li></ul>',
        '* post #1':
            '<ul><li><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1">post #1</a></li></ul>',
        '* [i]a[/i]\n* b': '<ul><li><em>a</em></li><li>b</li></ul>',
        '[quote]\n* b\n* c\n[/quote]':
            '<blockquote><ul><li>b</li><li>c</li></ul></blockquote>',
        '[expand]\n* b\n* c\n[/expand]':
            '<details><summary>Show</summary><div><ul><li>b</li><li>c</li></ul></div></details>',
        '*': '<p>*</p>',
        '*a': '<p>*a</p>',
        '***': '<p>***</p>',
      });
    });
  });
}
