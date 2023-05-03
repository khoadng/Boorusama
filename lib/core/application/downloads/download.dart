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
        .mapLeft((error) => _mapDownloadDirectoryErrorToDownloadError(
              error,
              fileNameBuilder(),
              none(),
            ))
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
        .mapLeft((error) => _mapDownloadDirectoryErrorToDownloadError(
              error,
              fileNameBuilder(),
              some(path),
            ))
        .flatMap((dir) => joinDownloadPath(fileNameBuilder(), dir))
        .flatMap((path) => _wrapWithNotification(
              downloadWithDio(dio, url: url, path: path),
              notifications: notifications,
              path: path,
            ));

DownloadPathOrError downloadWithDio(
  Dio dio, {
  required String url,
  required String path,
}) =>
    TaskEither.tryCatch(
      () async => dio.download(url, path).then((value) => path),
      (error, stackTrace) {
        final fileName = basename(path);
        if (error is FileSystemException) {
          if (error.osError?.errorCode == 13) {
            return DownloadError(
              errorType: DownloadErrorType.restrictedDirectory,
              savedPath: some(path),
              fileName: fileName,
            );
          } else if (error.osError?.errorCode == 1) {
            return DownloadError(
              errorType: DownloadErrorType.needElevatedPermission,
              savedPath: some(path),
              fileName: fileName,
            );
          } else if (error.osError?.errorCode == 30) {
            return DownloadError(
              errorType: DownloadErrorType.readOnlyDirectory,
              savedPath: some(path),
              fileName: fileName,
            );
          } else if (error.osError?.errorCode == 36) {
            return DownloadError(
              errorType: DownloadErrorType.fileNameTooLong,
              savedPath: some(path),
              fileName: fileName,
            );
          } else if (error is PathNotFoundException) {
            return DownloadError(
              errorType: DownloadErrorType.directoryNotFound,
              savedPath: some(path),
              fileName: fileName,
            );
          } else {
            return DownloadError(
              errorType: DownloadErrorType.failedToCreateFile,
              savedPath: some(path),
              fileName: fileName,
            );
          }
        } else {
          return DownloadError(
            errorType: DownloadErrorType.httpRequestError,
            savedPath: some(path),
            fileName: fileName,
          );
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
  String fileName,
  Option<String> savedPath,
) {
  switch (error) {
    case DownloadDirectoryError.directoryNotFound:
      return DownloadError(
        errorType: DownloadErrorType.directoryNotFound,
        savedPath: savedPath,
        fileName: fileName,
      );
    case DownloadDirectoryError.unImplementedPlatform:
    case DownloadDirectoryError.webPlatformNotSupported:
      return DownloadError(
        errorType: DownloadErrorType.platformNotSupported,
        savedPath: savedPath,
        fileName: fileName,
      );
    case DownloadDirectoryError.permissionDenied:
      return DownloadError(
        errorType: DownloadErrorType.restrictedDirectory,
        savedPath: savedPath,
        fileName: fileName,
      );
    case DownloadDirectoryError.unknownError:
      return DownloadError(
        errorType: DownloadErrorType.unknownError,
        savedPath: savedPath,
        fileName: fileName,
      );
    default:
      return DownloadError(
        errorType: DownloadErrorType.unknownError,
        savedPath: savedPath,
        fileName: fileName,
      );
  }
}
