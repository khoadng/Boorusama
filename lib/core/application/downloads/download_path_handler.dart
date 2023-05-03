// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/functional.dart';

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

bool _isSupportedPlatforms() => isAndroid() || isIOS() || isWindows();

// map DirectoryError to DownloadDirectoryError
DownloadDirectoryError _mapDirectoryErrorToDownloadDirectoryError(
  DirectoryError error,
) {
  switch (error) {
    case DirectoryError.directoryNotFound:
      return DownloadDirectoryError.directoryNotFound;
    case DirectoryError.permissionDenied:
      return DownloadDirectoryError.permissionDenied;
    case DirectoryError.unknownError:
      return DownloadDirectoryError.unknownError;
  }
}

TaskEither<DirectoryError, Directory>
    _tryGetDownloadDirectoryOnSupportedPlatforms() => isAndroid()
        ? _tryGetAndroidDownloadDirectory()
        : isIOS()
            ? _tryGetIosDownloadDirectory()
            : isWindows()
                ? _tryGetWindowsDirectory('/storage/emulated/0/Download')
                : TaskEither.left(DirectoryError.unknownError);

TaskEither<DirectoryError, Directory> _tryGetAndroidDownloadDirectory() =>
    tryGetDirectory('/storage/emulated/0/Download');

TaskEither<DirectoryError, Directory> _tryGetIosDownloadDirectory() =>
    TaskEither.tryCatch(
      () async => await getApplicationDocumentsDirectory(),
      (error, stackTrace) => DirectoryError.unknownError,
    );

TaskEither<DirectoryError, Directory> _tryGetWindowsDirectory(String path) =>
    TaskEither.tryCatch(
      () async => await getDownloadsDirectory(),
      (error, stackTrace) => DirectoryError.unknownError,
    ).flatMap((dir) => dir.toOption().fold(
          () => TaskEither.left(DirectoryError.directoryNotFound),
          (dir) => TaskEither.right(dir),
        ));
