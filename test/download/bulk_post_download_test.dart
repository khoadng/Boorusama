// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';

const _downloadFolderPath = '/storage/emulated/0/Download';
const _rootFolderPath = '/storage/emulated/0/Test';
const _sdCardPath = '/storage/ABCD-123/Foo';

void main() {
  group('[internal storage test]', () {
    test('internal', () {
      expect(isInternalStorage('/storage/emulated/0/Download'), isTrue);
    });

    test('SD card', () {
      expect(isInternalStorage('/storage/ABCD-6789/Download'), isFalse);
    });

    test('null', () {
      expect(isInternalStorage(null), isFalse);
    });

    test('random string', () {
      expect(isInternalStorage('foobar'), isFalse);
    });
  });

  group('[valid storage test]', () {
    test('empty path => false', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: '',
              ),
            )
            .hasValidStoragePath(hasScopeStorage: false),
        isFalse,
      );
    });

    test('No scoped storage, internal storage => true', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: _downloadFolderPath,
              ),
            )
            .hasValidStoragePath(hasScopeStorage: false),
        isTrue,
      );
    });

    test('No scoped storage, SD card => false', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: _sdCardPath,
              ),
            )
            .hasValidStoragePath(hasScopeStorage: false),
        isFalse,
      );
    });

    test('Scoped storage, SD card => false', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: _sdCardPath,
              ),
            )
            .hasValidStoragePath(hasScopeStorage: true),
        isFalse,
      );
    });

    test('Scoped storage, internal storage, public folder => true', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: _downloadFolderPath,
              ),
            )
            .hasValidStoragePath(hasScopeStorage: true),
        isTrue,
      );
    });

    test('Scoped storage, internal storage, non public folder => false', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: _rootFolderPath,
              ),
            )
            .hasValidStoragePath(hasScopeStorage: true),
        isFalse,
      );
    });
  });

  group('[warning visibility test]', () {
    test('empty folder path => false', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: '',
              ),
            )
            .hasValidStoragePath(hasScopeStorage: false),
        isFalse,
      );
    });

    test('valid folder path => false', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: _downloadFolderPath,
              ),
            )
            .shouldDisplayWarning(hasScopeStorage: true),
        isFalse,
      );
    });

    test('invalid folder path => true', () {
      expect(
        BulkDownloadManagerState.initial()
            .copyWith(
              options: const DownloadOptions(
                onlyDownloadNewFile: false,
                storagePath: _rootFolderPath,
              ),
            )
            .shouldDisplayWarning(hasScopeStorage: true),
        isTrue,
      );
    });
  });
}
