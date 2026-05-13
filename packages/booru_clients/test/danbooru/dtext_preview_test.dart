// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:test/test.dart';

void main() {
  group('Danbooru dtext preview emoji parser', () {
    test('parses unicode emoji values', () {
      final client = DanbooruClient(
        baseUrl: 'https://danbooru.donmai.us',
      );
      final result = client.parseDTextEmojiValues(
        '<p><emoji data-name="smile" data-mode="inline">&#128516;</emoji></p>',
      );

      expect(result['smile'], isA<DanbooruDTextEmojiText>());
      expect(
        (result['smile']! as DanbooruDTextEmojiText).text,
        '\u{1F604}',
      );
    });

    test('parses image emoji values', () {
      final client = DanbooruClient(
        baseUrl: 'https://danbooru.donmai.us',
      );
      final result = client.parseDTextEmojiValues(
        '<emoji data-name="popcorn"><img src="/images/emoji/popcorn.png" width="20" height="20"></emoji>',
      );
      final emoji = result['popcorn']! as DanbooruDTextEmojiImage;

      expect(emoji.url, 'https://danbooru.donmai.us/images/emoji/popcorn.png');
      expect(emoji.width, 20);
      expect(emoji.height, 20);
    });
  });
}
