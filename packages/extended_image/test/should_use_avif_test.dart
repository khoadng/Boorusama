import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:extended_image/src/extended_image.dart';

void main() {
  group('shouldUseAvif', () {
    test('returns false when platform is null', () {
      expect(shouldUseAvif('test.avif'), false);
    });

    test('returns false for iOS', () {
      expect(
        shouldUseAvif(
          'test.avif',
          platform: TargetPlatform.iOS,
        ),
        false,
      );
    });

    test('returns false for macOS', () {
      expect(
        shouldUseAvif(
          'test.avif',
          platform: TargetPlatform.macOS,
        ),
        false,
      );
    });

    group('URL variations', () {
      test('handles URLs with query parameters', () {
        expect(
          shouldUseAvif(
            'test.avif?width=100',
            platform: TargetPlatform.android,
            androidVersion: 30,
          ),
          true,
        );
      });

      test('returns false for non-avif extensions', () {
        expect(
          shouldUseAvif(
            'test.jpg',
            platform: TargetPlatform.android,
            androidVersion: 30,
          ),
          false,
        );
      });

      test('returns false for URLs without extensions', () {
        expect(
          shouldUseAvif(
            'test',
            platform: TargetPlatform.android,
            androidVersion: 30,
          ),
          false,
        );
      });
    });
  });
}
