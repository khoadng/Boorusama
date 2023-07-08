// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';

void main() {
  group('[userspace internal storage test]', () {
    test('userspace default', () {
      expect(isUserspaceInternalStorage('/storage/emulated/0/Download'), true);
    });

    test('another userspace', () {
      expect(isUserspaceInternalStorage('/storage/emulated/2/Pictures'), true);
    });

    test('obb', () {
      expect(isUserspaceInternalStorage('/storage/emulated/obb/123'), false);
    });
  });

  group('[internal storage test]', () {
    test('internal', () {
      expect(isInternalStorage('/storage/emulated/0/Download'), true);
    });

    test('internal, different userspace', () {
      expect(isInternalStorage('/storage/emulated/10/Pictures'), true);
    });

    test('obb', () {
      expect(isInternalStorage('/storage/emulated/obb/123'), true);
    });

    test('SD card', () {
      expect(isInternalStorage('/storage/ABCD-6789/Download'), false);
    });

    test('null', () {
      expect(isInternalStorage(null), false);
    });

    test('random string', () {
      expect(isInternalStorage('foobar'), false);
    });

    test('empty string', () {
      expect(isInternalStorage(''), false);
    });
  });

  group('[public directories test]', () {
    test('public folders', () {
      expect(isPublicDirectories('/storage/emulated/0/Download'), true);
    });

    test('a custom folder', () {
      expect(isPublicDirectories('/storage/emulated/0/Apps'), false);
    });

    test('OBB folder', () {
      expect(isPublicDirectories('/storage/emulated/obb/123'), false);
    });

    test('subdirectory of public folders', () {
      expect(
          isPublicDirectories('/storage/emulated/10/Download/Documents'), true);
    });
  });
}
