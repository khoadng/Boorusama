// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/functional.dart';
import 'download_path_handler.dart';
import 'notification.dart';

DownloadPathOrError downloadUrl({
  required Dio dio,
  required DownloadNotifications notifications,
  required String url,
  required DownloadFileNameBuilder fileNameBuilder,
}) =>
    tryGetDownloadDirectory()
        .mapLeft(_mapDownloadDirectoryErrorToDownloadError)
        .flatMap((dir) => joinDownloadPath(fileNameBuilder(), dir))
        .flatMap((path) => _wrapWithNotification(
              downloadWithDio(dio, url: url, path: path),
              notifications: notifications,
              path: path,
            ));

DownloadPathOrError downloadUrlCustomLocation({
  required Dio dio,
  required DownloadNotifications notifications,
  required String path,
  required String url,
  required DownloadFileNameBuilder fileNameBuilder,
}) =>
    tryGetCustomDownloadDirectory(path)
        .mapLeft(_mapDownloadDirectoryErrorToDownloadError)
        .flatMap((dir) => joinDownloadPath(fileNameBuilder(), dir))
        .flatMap((path) => _wrapWithNotification(
              downloadWithDio(dio, url: url, path: path),
              notifications: notifications,
              path: path,
            ));

// download using dio
DownloadPathOrError downloadWithDio(
  Dio dio, {
  required String url,
  required String path,
}) =>
    TaskEither.tryCatch(
      () async => dio.download(url, path).then((value) => path),
      (error, stackTrace) {
        // check if permission denied
        if (error is FileSystemException) {
          if (error.osError != null && error.osError!.errorCode == 13) {
            return DownloadError.restrictedDirectory;
          } else if (error.osError != null && error.osError!.errorCode == 1) {
            return DownloadError.needElevatedPermission;
          } else if (error.osError != null && error.osError!.errorCode == 30) {
            return DownloadError.readOnlyDirectory;
          } else if (error.osError != null && error.osError!.errorCode == 36) {
            return DownloadError.fileNameTooLong;
          } else if (error is PathNotFoundException) {
            return DownloadError.directoryNotFound;
          } else {
            return DownloadError.failedToCreateFile;
          }
        } else {
          return DownloadError.httpRequestError;
        }
      },
    );

DownloadPathOrError joinDownloadPath(
  String fileName,
  Directory directory,
) =>
    TaskEither.fromEither(Either.of(join(directory.path, fileName)));

DownloadPathOrError _wrapWithNotification(
  DownloadPathOrError fn, {
  required DownloadNotifications notifications,
  required String path,
  bool enableNotification = true,
}) {
  final fileName = path.split('/').last;

  if (enableNotification) {
    notifications.showInProgress(fileName);
  }
  return fn.map((r) {
    if (enableNotification) {
      notifications.showCompleted(fileName);
    }
    return r;
  });
}

DownloadError _mapDownloadDirectoryErrorToDownloadError(
  DownloadDirectoryError error,
) {
  switch (error) {
    case DownloadDirectoryError.directoryNotFound:
      return DownloadError.directoryNotFound;
    case DownloadDirectoryError.unImplementedPlatform:
    case DownloadDirectoryError.webPlatformNotSupported:
      return DownloadError.platformNotSupported;
    case DownloadDirectoryError.permissionDenied:
      return DownloadError.restrictedDirectory;
    case DownloadDirectoryError.unknownError:
      return DownloadError.unknownError;
  }
}
