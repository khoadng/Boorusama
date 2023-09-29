// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

void main() {
  group('mapBooruUrlToUri', () {
    test('returns BooruUrlError.nullUrl for null input', () {
      final result = mapBooruUrlToUri(null);
      expect(result, left(BooruUrlError.nullUrl));
    });

    test('returns BooruUrlError.emptyUrl for empty string', () {
      final result = mapBooruUrlToUri('');
      expect(result, left(BooruUrlError.emptyUrl));
    });

    test(
        'returns BooruUrlError.stringHasInbetweenSpaces for string with spaces',
        () {
      final result = mapBooruUrlToUri('https://danbooru.donmai.us/ posts/1234');
      expect(result, left(BooruUrlError.stringHasInbetweenSpaces));
    });

    test('returns BooruUrlError.invalidUrlFormat for "https://a"', () {
      final result = mapBooruUrlToUri('https://a');
      expect(result, left(BooruUrlError.invalidUrlFormat));
    });

    test('returns BooruUrlError.invalidUrlFormat for "https://.danbooru.com/"',
        () {
      final result = mapBooruUrlToUri('https://.danbooru.com/');
      expect(result, left(BooruUrlError.invalidUrlFormat));
    });

    test('returns BooruUrlError.missingScheme for URL without scheme', () {
      final result = mapBooruUrlToUri('danbooru.donmai.us');
      expect(result, left(BooruUrlError.missingScheme));
    });

    test('returns BooruUrlError.notAnHttpOrHttpsUrl for non-HTTP(s) URL', () {
      final result = mapBooruUrlToUri('ftp://danbooru.donmai.us/');
      expect(result, left(BooruUrlError.notAnHttpOrHttpsUrl));
    });

    test(
        'returns BooruUrlError.missingLastSlash for URL without trailing slash',
        () {
      final result = mapBooruUrlToUri('https://danbooru.donmai.us');
      expect(result, left(BooruUrlError.missingLastSlash));
    });

    test('returns BooruUrlError.redundantWww for URL with www', () {
      final result = mapBooruUrlToUri('https://www.danbooru.donmai.us/');
      expect(result, left(BooruUrlError.redundantWww));
    });

    test('returns valid Uri for a valid URL', () {
      final result = mapBooruUrlToUri('https://danbooru.donmai.us/');
      expect(result, right(Uri.parse('https://danbooru.donmai.us/')));
    });
  });
}
