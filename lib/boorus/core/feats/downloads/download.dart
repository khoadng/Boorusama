// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';

DownloadPathOrError downloadUrl({
  required Dio dio,
  required DownloadNotifications notifications,
  required String url,
  required DownloadFileNameBuilder fileNameBuilder,
  bool enableNotification = true,
}) =>
    TaskEither.Do(($) async {
      final dir = await $(tryGetDownloadDirectory()
          .mapLeft((error) => _mapDownloadDirectoryErrorToDownloadError(
                error,
                fileNameBuilder(),
                none(),
              )));

      final path = await $(joinDownloadPath(fileNameBuilder(), dir));

      return _wrapWithNotification(
        () => $(downloadWithDio(dio, url: url, path: path)),
        notifications: notifications,
        path: path,
        enableNotification: enableNotification,
      );
    });

DownloadPathOrError downloadUrlCustomLocation({
  required Dio dio,
  required DownloadNotifications notifications,
  required String path,
  required String url,
  required DownloadFileNameBuilder fileNameBuilder,
  bool enableNotification = true,
}) =>
    TaskEither.Do(($) async {
      final dir = await $(tryGetCustomDownloadDirectory(path)
          .mapLeft((error) => _mapDownloadDirectoryErrorToDownloadError(
                error,
                fileNameBuilder(),
                none(),
              )));

      final filePath = await $(joinDownloadPath(fileNameBuilder(), dir));

      return _wrapWithNotification(
        () => $(downloadWithDio(dio, url: url, path: filePath)),
        notifications: notifications,
        path: path,
        enableNotification: enableNotification,
      );
    });

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

Future<String> _wrapWithNotification(
  Future<String> Function() fn, {
  required DownloadNotifications notifications,
  required String path,
  bool enableNotification = true,
}) async {
  final fileName = path.split('/').last;

  if (enableNotification) {
    await notifications.showInProgress(fileName, path);
  }

  final result = await fn();
  if (enableNotification) {
    await notifications.showCompleted(fileName, path);
  }

  return result;
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
