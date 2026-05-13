import 'package:dtext/dtext.dart';
import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group('options', () {
    test('expands relative urls with baseUrl', () {
      const options = DTextOptions(baseUrl: 'http://danbooru.donmai.us');

      final cases = {
        'post #1234':
            '<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="http://danbooru.donmai.us/posts/1234">post #1234</a></p>',
        '[[touhou|Touhou]]':
            '<p><a class="dtext-link dtext-wiki-link" href="http://danbooru.donmai.us/wiki_pages/touhou">Touhou</a></p>',
        '{{touhou}}':
            '<p><a class="dtext-link dtext-post-search-link" href="http://danbooru.donmai.us/posts?tags=touhou">touhou</a></p>',
        '"home":#posts':
            '<p><a class="dtext-link" href="http://danbooru.donmai.us#posts">home</a></p>',
        '<@evazion>':
            '<p><a class="dtext-link dtext-user-mention-link" data-user-name="evazion" href="http://danbooru.donmai.us/users?name=evazion">@evazion</a></p>',
      };

      for (final entry in cases.entries) {
        expect(parse(entry.key, options: options), entry.value);
      }
    });

    test('can disable mentions', () {
      expect(
        parse(
          'hi @evazion',
          options: const DTextOptions(enableMentions: false),
        ),
        '<p>hi @evazion</p>',
      );
    });

    test('marks configured domain as internal', () {
      expect(
        parse(
          'https://danbooru.donmai.us/login',
          options: const DTextOptions(domain: 'danbooru.donmai.us'),
        ),
        '<p><a class="dtext-link" href="https://danbooru.donmai.us/login">https://danbooru.donmai.us/login</a></p>',
      );
    });
  });
}
