// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/browser/cookie_conversion.dart';
import 'package:boorusama/foundation/browser/types.dart';

final _older = DateTime.utc(2025, 11, 15);
final _newer = DateTime.utc(2026, 10, 3);

BrowserCookie _cookie(
  String value, {
  DateTime? created,
  String domain = '.example.com',
  String path = '/',
}) => BrowserCookie(
  name: 'clearance',
  value: value,
  domain: domain,
  path: path,
  createdUtc: created,
);

void main() {
  final cases = [
    (
      description: 'keeps only the newest of same-scope duplicates',
      cookies: [
        _cookie('stale', created: _older),
        _cookie('fresh', created: _newer),
      ],
      expected: ['fresh'],
    ),
    (
      description: 'keeps the newest duplicate regardless of browser order',
      cookies: [
        _cookie('fresh', created: _newer),
        _cookie('stale', created: _older),
      ],
      expected: ['fresh'],
    ),
    (
      description: 'keeps every duplicate when creation times are unknown',
      cookies: [_cookie('first'), _cookie('second')],
      expected: ['first', 'second'],
    ),
    (
      description: 'keeps every duplicate when one creation time is unknown',
      cookies: [
        _cookie('first', created: _newer),
        _cookie('second'),
      ],
      expected: ['first', 'second'],
    ),
    (
      description: 'keeps same-name cookies scoped to different paths',
      cookies: [
        _cookie('root', created: _older),
        _cookie('nested', created: _newer, path: '/posts'),
      ],
      expected: ['root', 'nested'],
    ),
  ];

  for (final c in cases) {
    test(c.description, () {
      final result = browserCookiesForRequest(
        uri: Uri.parse('https://example.com/posts'),
        cookies: c.cookies,
        now: DateTime.utc(2026, 10, 4),
      );

      expect(result.map((cookie) => cookie.value), c.expected);
    });
  }
}
