// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/dtext_parser.dart';

void main() {
  group('[dtext parser test]', () {
    test('bold', () => expect(bold('[b]foo[/b]'), '<strong>foo</strong>'));
    test('italic', () => expect(italic('[i]foo[/i]'), '<em>foo</em>'));
    test('underline', () => expect(underline('[u]foo[/u]'), '<u>foo</u>'));
    test(
        'strikethrough',
        () => expect(
              strikethrough('[s]foo[/s]'),
              '<s>foo</s>',
            ));
    test(
        'link with custom text',
        () => expect(
              linkCustomText('"Foo":[https://foo.com]'),
              '<a href="https://foo.com" style="text-decoration:none">Foo</a>',
            ));
    test(
        'link with custom text, no brackets variant',
        () => expect(
              linkCustomTextNoBrackets('"Foo":https://foo.com'),
              '<a href="https://foo.com" style="text-decoration:none">Foo</a>',
            ));

    test(
        'link with markdown text',
        () => expect(
              linkMarkdownStyle('[https://foo.com](Foo)'),
              '<a href="https://foo.com" style="text-decoration:none">Foo</a>',
            ));

    test('multiple items', () {
      const text = '''
[b]foo[/b]
[i]foo[/i]
[u]foo[/u]
[s]foo[/s]
"Foo":[https://foo.com]
''';

      const expected = '''
<strong>foo</strong>
<em>foo</em>
<u>foo</u>
<s>foo</s>
<a href="https://foo.com" style="text-decoration:none">Foo</a>
''';
      expect(parseDtext(text), expected);
    });
  });
}
