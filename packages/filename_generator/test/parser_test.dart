// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:filename_generator/src/generator.dart';

void main() {
  group('formatContainsAnyToken', () {
    test('returns true when any token present', () {
      const format = '{artist}_{md5}.{extension}';
      const tokens = ['artist', 'character'];

      expect(formatContainsAnyToken(format, tokens), isTrue);
    });

    test('returns false when no tokens present', () {
      const format = '{md5}.{extension}';
      const tokens = ['artist', 'character'];

      expect(formatContainsAnyToken(format, tokens), isFalse);
    });

    test('handles tokens with options', () {
      const format = '{artist:case=upper}_{md5}.{extension}';
      const tokens = ['artist', 'character'];

      expect(formatContainsAnyToken(format, tokens), isTrue);
    });

    test('returns false for malformed tokens', () {
      const format = '{artist_{md5}.{extension}'; // missing closing brace
      const tokens = ['artist'];

      expect(formatContainsAnyToken(format, tokens), isFalse);
    });
  });
}
