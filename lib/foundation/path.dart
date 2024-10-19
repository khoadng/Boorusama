// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/functional.dart';
import 'platform.dart';

export 'package:path/path.dart';
export 'package:path_provider/path_provider.dart';

enum DownloadDirectoryError {
  directoryNotFound,
  webPlatformNotSupported,
  unImplementedPlatform,
  permissionDenied,
  unknownError,
}

TaskEither<DownloadDirectoryError, Directory> tryGetDownloadDirectory() =>
    isWeb()
        ? TaskEither.left(DownloadDirectoryError.webPlatformNotSupported)
        : _isSupportedPlatforms()
            ? _tryGetDownloadDirectoryOnSupportedPlatforms()
                .mapLeft(_mapDirectoryErrorToDownloadDirectoryError)
            : TaskEither.left(DownloadDirectoryError.unImplementedPlatform);

TaskEither<DownloadDirectoryError, Directory> tryGetCustomDownloadDirectory(
        String path) =>
    isWeb()
        ? TaskEither.left(DownloadDirectoryError.webPlatformNotSupported)
        : tryGetDirectory(path)
            .mapLeft(_mapDirectoryErrorToDownloadDirectoryError);

bool _isSupportedPlatforms() =>
    isAndroid() || isIOS() || isWindows() || isLinux();

// map DirectoryError to DownloadDirectoryError
DownloadDirectoryError _mapDirectoryErrorToDownloadDirectoryError(
  DirectoryError error,
) =>
    switch (error) {
      DirectoryError.directoryNotFound =>
        DownloadDirectoryError.directoryNotFound,
      DirectoryError.permissionDenied =>
        DownloadDirectoryError.permissionDenied,
      DirectoryError.unknownError => DownloadDirectoryError.unknownError
    };

TaskEither<DirectoryError, Directory>
    _tryGetDownloadDirectoryOnSupportedPlatforms() => isAndroid()
        ? _tryGetAndroidDownloadDirectory()
        : isIOS()
            ? _tryGetIosDownloadDirectory()
            : isWindows()
                ? _tryGetWindowsDirectory('/storage/emulated/0/Download')
                : isLinux()
                    ? _tryGetLinuxDownloadDirectory()
                    : TaskEither.left(DirectoryError.unknownError);

TaskEither<DirectoryError, Directory> _tryGetAndroidDownloadDirectory() =>
    tryGetDirectory('/storage/emulated/0/Download');

TaskEither<DirectoryError, Directory> _tryGetIosDownloadDirectory() =>
    TaskEither.tryCatch(
      () async => getApplicationDocumentsDirectory(),
      (error, stackTrace) => DirectoryError.unknownError,
    );

TaskEither<DirectoryError, Directory> _tryGetWindowsDirectory(String path) =>
    TaskEither.tryCatch(
      () async => getDownloadsDirectory(),
      (error, stackTrace) => DirectoryError.unknownError,
    ).flatMap((dir) => dir.toOption().fold(
          () => TaskEither.left(DirectoryError.directoryNotFound),
          (dir) => TaskEither.right(dir),
        ));

TaskEither<DirectoryError, Directory> _tryGetLinuxDownloadDirectory() =>
    TaskEither.tryCatch(
      () async => getDownloadsDirectory(),
      (error, stackTrace) => DirectoryError.unknownError,
    ).flatMap((dir) => dir.toOption().fold(
          () => TaskEither.left(DirectoryError.directoryNotFound),
          (dir) => TaskEither.right(dir),
        ));

const _kAppTemporaryDirectoryName = String.fromEnvironment('APP_NAME');

Future<Directory> getAppTemporaryDirectory() async {
  final dir = await getTemporaryDirectory();

  // On Windows, the temporary directory is a global directory so we need to create a subdirectory for the app to avoid deleting other app's files
  if (isWindows()) {
    final name = _getAppWindowsTemporaryDirectoryName();

    final appDir = Directory(join(dir.path, name));
    if (!appDir.existsSync()) {
      await appDir.create();
    }
    return appDir;
  }

  return dir;
}

String _getAppWindowsTemporaryDirectoryName() {
  final name = _kAppTemporaryDirectoryName.isNotEmpty
      ? _kAppTemporaryDirectoryName
      : 'boorusama';

  final sanitized = name.replaceAll(' ', '_').toLowerCase();

  return sanitized;
}
