import 'package:coreutils/coreutils.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeUrl', () {
    final cases = [
      (
        desc: 'removes query parameters',
        url: 'https://example.com/image.jpg?token=abc',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'returns url as-is when no query or fragment',
        url: 'https://example.com/image.jpg',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'removes multiple query parameters',
        url: 'https://example.com/image.jpg?size=large&format=png',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'returns empty string for empty url',
        url: '',
        expected: '',
      ),
      (
        desc: 'returns empty string for query-only url',
        url: '?token=abc',
        expected: '',
      ),
      (
        desc: 'removes fragment',
        url: 'https://example.com/image.jpg#section',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'removes both query and fragment',
        url: 'https://example.com/image.jpg?token=abc#section',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'removes fragment with query-like content',
        url: 'https://example.com/image.jpg#section?notquery=value',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'preserves port while removing query',
        url: 'https://example.com:8080/image.jpg?token=abc',
        expected: 'https://example.com:8080/image.jpg',
      ),
      (
        desc: 'preserves userinfo while removing query',
        url: 'https://user:pass@example.com/image.jpg?token=abc',
        expected: 'https://user:pass@example.com/image.jpg',
      ),
      (
        desc: 'preserves encoded characters in path',
        url: 'https://example.com/image%20name.jpg?size=large',
        expected: 'https://example.com/image%20name.jpg',
      ),
      (
        desc: 'handles special characters in path',
        url: 'https://example.com/image(1).jpg?token=abc',
        expected: 'https://example.com/image(1).jpg',
      ),
      (
        desc: 'handles query parameter with no value',
        url: 'https://example.com/image.jpg?nocache&token=abc',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'handles multiple fragments',
        url: 'https://example.com/image.jpg#frag1#frag2',
        expected: 'https://example.com/image.jpg',
      ),
      (
        desc: 'encodes unicode characters in path',
        url: 'https://example.com/画像.jpg?param=値',
        expected: 'https://example.com/%E7%94%BB%E5%83%8F.jpg',
      ),
      (
        desc: 'handles trailing dot in filename',
        url: 'https://example.com/image.jpg.?token=abc',
        expected: 'https://example.com/image.jpg.',
      ),
      (
        desc: 'handles path ending with slash',
        url: 'https://example.com/path/?token=abc',
        expected: 'https://example.com/path/',
      ),
    ];

    for (final c in cases) {
      test('${c.desc}: returns "${c.expected}" for "${c.url}"', () {
        expect(normalizeUrl(c.url), c.expected);
      });
    }
  });

  group('urlExtension', () {
    final cases = [
      (
        desc: 'extracts extension from simple url',
        url: 'https://example.com/image.jpg',
        ext: '.jpg',
      ),
      (
        desc: 'extracts extension ignoring query parameters',
        url: 'https://example.com/image.jpg?size=large',
        ext: '.jpg',
      ),
      (
        desc: 'extracts extension from path, not query parameters',
        url: 'https://example.com/file.png?token=abc&format=webp',
        ext: '.png',
      ),
      (
        desc: 'returns empty string when no extension',
        url: 'https://example.com/image',
        ext: '',
      ),
      (
        desc: 'extracts last extension when multiple dots in filename',
        url: 'https://example.com/script.min.js',
        ext: '.js',
      ),
      (
        desc: 'extracts extension ignoring fragment',
        url: 'https://example.com/image.jpg#section.html',
        ext: '.jpg',
      ),
      (
        desc: 'handles case-sensitive extensions',
        url: 'https://example.com/image.JPG',
        ext: '.JPG',
      ),
      (
        desc: 'extracts extension even with trailing slash',
        url: 'https://example.com/image.jpg/',
        ext: '.jpg',
      ),
      (
        desc: 'handles trailing dot in filename',
        url: 'https://example.com/image.jpg.',
        ext: '.',
      ),
      (
        desc: 'returns empty string for hidden files without extension',
        url: 'https://example.com/.htaccess',
        ext: '',
      ),
      (
        desc: 'returns empty string when extension in query only',
        url: 'https://example.com/file?download=image.png',
        ext: '',
      ),
      (
        desc: 'handles unicode characters in filename',
        url: 'https://example.com/画像.jpg',
        ext: '.jpg',
      ),
    ];

    for (final c in cases) {
      test('${c.desc}: returns "${c.ext}" for "${c.url}"', () {
        expect(urlExtension(c.url), c.ext);
      });
    }
  });
}
