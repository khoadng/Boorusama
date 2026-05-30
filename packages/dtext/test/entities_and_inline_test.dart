import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group('html entities', () {
    test('sanitizes raw html characters', () {
      expectDTextCases({
        '<3': '<p>&lt;3</p>',
        '<': '<p>&lt;</p>',
        '>': '<p>&gt;</p>',
        '&': '<p>&amp;</p>',
        '"': '<p>&quot;</p>',
      });
    });

    test('decodes supported escaped dtext entities', () {
      expectDTextCases({
        '&amp;': '<p>&amp;</p>',
        '&lt;': '<p>&lt;</p>',
        '&gt;': '<p>&gt;</p>',
        '&quot;': '<p>&quot;</p>',
        '&#39;': '<p>\'</p>',
        '&apos;': '<p>\'</p>',
        '&lpar;': '<p>(</p>',
        '&rpar;': '<p>)</p>',
        '&lbrack;b]foo&lbrack;/b]': '<p>[b]foo[/b]</p>',
        '&lbrace;&lbrace;foo}}': '<p>{{foo}}</p>',
        'http&colon;//google.com': '<p>http://google.com</p>',
        '&commat;user': '<p>@user</p>',
        'post &num;1': '<p>post #1</p>',
        'h4&period; See also': '<p>h4. See also</p>',
        '&grave;&grave;&grave;\ncode\n&grave;&grave;&grave;':
            '<p>```<br>code<br>```</p>',
        '&ast; list': '<p>* list</p>',
      });
    });

    test('keeps escaped dtext inert after entity decoding', () {
      expectDTextCases({
        '&quot;title&quot;:/posts': '<p>&quot;title&quot;:/posts</p>',
        'post &num;1': '<p>post #1</p>',
        '[nodtext]&lt;[/nodtext]': '<p>&amp;lt;</p>',
      });
    });
  });

  group('inline elements', () {
    test('handles common inline tags', () {
      expectDTextCases({
        '[b]foo[/b]': '<p><strong>foo</strong></p>',
        '<b>foo</b>': '<p><strong>foo</strong></p>',
        '<strong>foo</strong>': '<p><strong>foo</strong></p>',
        '[i]foo[/i]': '<p><em>foo</em></p>',
        '<i>foo</i>': '<p><em>foo</em></p>',
        '<em>foo</em>': '<p><em>foo</em></p>',
        '[s]foo[/s]': '<p><s>foo</s></p>',
        '[u]foo[/u]': '<p><u>foo</u></p>',
        'foo [tn]bar[/tn] baz': '<p>foo <span class="tn">bar</span> baz</p>',
        'foo <tn>bar</tn> baz': '<p>foo <span class="tn">bar</span> baz</p>',
        '[expand]blah[/expand]':
            '<details><summary>Show</summary><div><p>blah</p></div></details>',
        '[expand=title]blah[/expand]':
            '<details><summary>title</summary><div><p>blah</p></div></details>',
      });
    });

    test('handles inline code', () {
      expectDTextCases({
        'foo [code][b]lol[/b][/code].': '<p>foo <code>[b]lol[/b]</code>.</p>',
        'foo [code][code][/code].': '<p>foo <code>[code]</code>.</p>',
        'foo [i][code]post #123[/code][/i].':
            '<p>foo <em><code>post #123</code></em>.</p>',
        'inline [code=ruby]x[/code]':
            '<p>inline <code class="language-ruby">x</code></p>',
        'inline [code = ruby]x[/code]':
            '<p>inline <code class="language-ruby">x</code></p>',
        "inline [code=ruby'>]x[/code]":
            '<p>inline [code=ruby\'&gt;]x[/code]</p>',
      });
    });

    test('handles raw nodtext spans', () {
      expectDTextCases({
        '[nodtext][b]foo[/b][/nodtext]': '<p>[b]foo[/b]</p>',
        '[nodtext](http://example.com)[/nodtext]':
            '<p>(http://example.com)</p>',
        '[nodtext](http://example.com)': '<p>(http://example.com)</p>',
      });
    });
  });

  group('tn elements', () {
    test('handles block tn at the start of a block', () {
      expectDTextCases({
        '[tn]bar[/tn]': '<p class="tn">bar</p>',
        '<tn>bar</tn>': '<p class="tn">bar</p>',
        'foo [b]bar\n\n[tn]bar[/tn]':
            '<p>foo <strong>bar</strong></p><p class="tn">bar</p>',
      });
    });
  });
}
