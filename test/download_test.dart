// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/downloads/path/types.dart';

void main() {
  group('PathInfo.from', () {
    group('internal storage paths', () {
      final cases = [
        (
          path: '/storage/emulated/0/Download',
          userSpace: 0,
          publicDirectory: 'Download',
        ),
        (
          path: '/storage/emulated/2/Pictures',
          userSpace: 2,
          publicDirectory: 'Pictures',
        ),
        (
          path: '/storage/emulated/10/Pictures',
          userSpace: 10,
          publicDirectory: 'Pictures',
        ),
        (
          path: '/storage/emulated/0/Apps',
          userSpace: 0,
          publicDirectory: null,
        ),
        (
          path: '/storage/emulated/10/Download/Documents',
          userSpace: 10,
          publicDirectory: 'Download',
        ),
      ];

      for (final c in cases) {
        test(
          'detects user space ${c.userSpace} and public directory for ${c.path}',
          () {
            final info = PathInfo.from(
              c.path,
              platform: TargetPlatform.android,
            );

            expect(info, isA<AndroidInternalStorage>());
            final storage = info as AndroidInternalStorage;
            expect(storage.userSpace, c.userSpace);
            expect(storage.publicDirectory, c.publicDirectory);
          },
        );
      }
    });

    group('SD card paths', () {
      final cases = [
        (path: '/storage/ABCD-6789/Download', publicDirectory: 'Download'),
        (path: '/storage/1234-5678/Pictures', publicDirectory: 'Pictures'),
        (path: '/storage/ABCD-6789/Custom', publicDirectory: null),
      ];

      for (final c in cases) {
        test('extracts device ID and public directory for ${c.path}', () {
          final info = PathInfo.from(
            c.path,
            platform: TargetPlatform.android,
          );

          expect(info, isA<AndroidSdCardStorage>());
          final storage = info as AndroidSdCardStorage;
          expect(storage.deviceId, isNotEmpty);
          expect(storage.publicDirectory, c.publicDirectory);
        });
      }
    });

    group('unrecognized storage paths', () {
      final cases = [
        (
          path: '/storage/emulated/obb/123',
          description: 'non-numeric userspace',
        ),
        (path: 'foobar', description: 'random string'),
      ];

      for (final c in cases) {
        test('handles ${c.description} as other storage', () {
          final info = PathInfo.from(
            c.path,
            platform: TargetPlatform.android,
          );
          expect(info, isA<AndroidOtherStorage>());
        });
      }
    });

    group('default paths', () {
      final cases = [
        (path: null, description: 'null'),
        (path: '', description: 'empty string'),
      ];

      for (final c in cases) {
        test('treats ${c.description} as default path', () {
          final info = PathInfo.from(c.path);
          expect(info, isA<DefaultPath>());
        });
      }
    });
  });

  group('PathInfo isPublicDirectory', () {
    final cases = [
      (path: '/storage/emulated/0/Download', isPublic: true),
      (path: '/storage/emulated/0/Apps', isPublic: false),
      (path: '/storage/ABCD-6789/Pictures', isPublic: true),
      (path: '/storage/ABCD-6789/Custom', isPublic: false),
      (path: null, isPublic: false),
      (path: '', isPublic: false),
    ];

    for (final c in cases) {
      test('returns ${c.isPublic} for ${c.path ?? "null"}', () {
        final info = PathInfo.from(
          c.path,
          platform: TargetPlatform.android,
        );

        final isPublic = switch (info) {
          AndroidPathInfo() => info.isPublicDirectory,
          _ => false,
        };

        expect(isPublic, c.isPublic);
      });
    }
  });

  group('platform-specific path handling', () {
    test('returns IOSPath for iOS platform', () {
      final info = PathInfo.from(
        '/var/mobile/Containers/Data/Application/test',
        platform: TargetPlatform.iOS,
      );
      expect(info, isA<IOSPath>());
    });

    test('returns DesktopPath for macOS platform', () {
      final info = PathInfo.from(
        '/Users/test/Downloads',
        platform: TargetPlatform.macOS,
      );
      expect(info, isA<DesktopPath>());
    });

    test('returns DesktopPath for Windows platform', () {
      final info = PathInfo.from(
        r'C:\Users\test\Downloads',
        platform: TargetPlatform.windows,
      );
      expect(info, isA<DesktopPath>());
    });

    test('returns DesktopPath for Linux platform', () {
      final info = PathInfo.from(
        '/home/test/Downloads',
        platform: TargetPlatform.linux,
      );
      expect(info, isA<DesktopPath>());
    });
  });
}
