// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:coreutils/src/cookie.dart';

void main() {
  group('CookieUtils', () {
    group('parseCookieHeader', () {
      test('should handle real-world base64 encoded values', () {
        const input =
            'auth=eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ==; session=abc123';
        final result = CookieUtils.parseCookieHeader(input);

        expect(result['auth'], 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ==');
        expect(result['session'], 'abc123');
      });

      test('should handle URL encoded values', () {
        const input =
            'redirect_url=https%3A%2F%2Fexample.com%2Fpath%3Fquery%3Dvalue';
        final result = CookieUtils.parseCookieHeader(input);

        expect(
          result['redirect_url'],
          'https%3A%2F%2Fexample.com%2Fpath%3Fquery%3Dvalue',
        );
      });

      test('should handle empty values', () {
        const input = 'empty=; valid=value; another_empty=';
        final result = CookieUtils.parseCookieHeader(input);

        expect(result, {
          'empty': '',
          'valid': 'value',
          'another_empty': '',
        });
      });

      test('should handle malformed cookies from real servers', () {
        const input =
            'session=abc123; ; theme=dark; =orphaned_value; standalone';
        final result = CookieUtils.parseCookieHeader(input);

        expect(result, {
          'session': 'abc123',
          'theme': 'dark',
        });
      });
    });

    group('formatCookieHeader', () {
      test('should format cookie map to header string', () {
        final input = {
          'session': 'abc123',
          'theme': 'dark',
        };
        final result = CookieUtils.formatCookieHeader(input);

        expect(result, 'session=abc123; theme=dark');
      });

      test('should handle empty map', () {
        final result = CookieUtils.formatCookieHeader({});
        expect(result, isEmpty);
      });

      test('should skip entries with empty keys', () {
        final input = {
          'session': 'abc123',
          '': 'ignored',
          'theme': 'dark',
        };
        final result = CookieUtils.formatCookieHeader(input);

        expect(result, 'session=abc123; theme=dark');
      });
    });

    group('mergeCookieHeaders', () {
      test('should preserve existing auth cookies while adding a', () {
        const existing = 'PHPSESSID=abc123; user_id=456; api_key=secret';
        const toMerge = 'a=1';
        final result = CookieUtils.mergeCookieHeaders(existing, toMerge);

        final parsed = CookieUtils.parseCookieHeader(result);
        expect(parsed['PHPSESSID'], 'abc123');
        expect(parsed['user_id'], '456');
        expect(parsed['api_key'], 'secret');
        expect(parsed['a'], '1');
      });

      test('should override existing setting', () {
        const existing = 'PHPSESSID=abc123; a=0; theme=dark';
        const toMerge = 'a=1';
        final result = CookieUtils.mergeCookieHeaders(existing, toMerge);

        final parsed = CookieUtils.parseCookieHeader(result);
        expect(parsed['a'], '1'); // Should be overridden
        expect(parsed['PHPSESSID'], 'abc123');
        expect(parsed['theme'], 'dark');
      });

      test('should handle complex cookie scenarios', () {
        const existing =
            '_ga=GA1.2.123; _gid=GA1.2.456; cf_clearance=token; session_token=longhash';
        const toMerge = 'a=1; b=0';
        final result = CookieUtils.mergeCookieHeaders(existing, toMerge);

        final parsed = CookieUtils.parseCookieHeader(result);
        expect(parsed.length, 6); // All cookies preserved + new ones
        expect(parsed['a'], '1');
        expect(parsed['b'], '0');
        expect(parsed['_ga'], 'GA1.2.123');
        expect(parsed['session_token'], 'longhash');
      });
    });
  });
}
