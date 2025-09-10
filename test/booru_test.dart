// Package imports:
import 'package:foundation/foundation.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/configs/create/src/types/validator/booru_url_error.dart';
import 'package:boorusama/core/configs/create/src/types/validator/booru_url_validator.dart';

void main() {
  group('createBooruUri', () {
    test('Auto appends trailing slash if missing', () {
      final result = createBooruUri('https://example.com');
      expect(result, right(Uri.parse('https://example.com/')));
    });

    test('returns BooruUrlError.nullUrl for null input', () {
      final result = createBooruUri(null);
      expect(result, left(BooruUrlError.nullUrl));
    });

    test('returns BooruUrlError.emptyUrl for empty string', () {
      final result = createBooruUri('');
      expect(result, left(BooruUrlError.emptyUrl));
    });

    test(
      'returns BooruUrlError.stringHasInbetweenSpaces for string with spaces',
      () {
        final result = createBooruUri(
          'https://danbooru.donmai.us/ posts/1234',
        );
        expect(result, left(BooruUrlError.stringHasInbetweenSpaces));
      },
    );

    test('returns BooruUrlError.invalidUrlFormat for "https://a"', () {
      final result = createBooruUri('https://a');
      expect(result, left(BooruUrlError.invalidUrlFormat));
    });

    test(
      'returns BooruUrlError.invalidUrlFormat for "https://.danbooru.com/"',
      () {
        final result = createBooruUri('https://.danbooru.com/');
        expect(result, left(BooruUrlError.invalidUrlFormat));
      },
    );

    test('returns BooruUrlError.missingScheme for URL without scheme', () {
      final result = createBooruUri('danbooru.donmai.us');
      expect(result, left(BooruUrlError.missingScheme));
    });

    test('returns BooruUrlError.notAnHttpOrHttpsUrl for non-HTTP(s) URL', () {
      final result = createBooruUri('ftp://danbooru.donmai.us/');
      expect(result, left(BooruUrlError.notAnHttpOrHttpsUrl));
    });

    test('returns BooruUrlError.redundantWww for URL with www', () {
      final result = createBooruUri('https://www.danbooru.donmai.us/');
      expect(result, left(BooruUrlError.redundantWww));
    });

    test('returns valid Uri for a valid URL', () {
      final result = createBooruUri('https://danbooru.donmai.us/');
      expect(result, right(Uri.parse('https://danbooru.donmai.us/')));
    });
  });
}
