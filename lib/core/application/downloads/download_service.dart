// Package imports:
import 'package:dio/dio.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads/download.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/functional.dart';
import 'notification.dart';

enum DownloadErrorType {
  directoryNotFound,
  platformNotSupported,
  restrictedDirectory,
  needElevatedPermission,
  readOnlyDirectory,
  failedToCreateFile,
  fileNameTooLong,
  httpRequestError,
  unknownError,
}

class DownloadError {
  DownloadError({
    required this.errorType,
    required this.savedPath,
    required this.fileName,
  });

  final DownloadErrorType errorType;
  final Option<String> savedPath;
  final String fileName;
}

typedef DownloadPathOrError = TaskEither<DownloadError, String>;

abstract class DownloadService {
  DownloadPathOrError download({
    required String url,
    required DownloadFileNameBuilder fileNameBuilder,
  });

  DownloadPathOrError downloadCustomLocation({
    required String url,
    required String path,
    required DownloadFileNameBuilder fileNameBuilder,
  });
}

extension DownloadWithSettingsX on DownloadService {
  DownloadPathOrError downloadWithSettings(
    Settings settings, {
    required String url,
    String? folderName,
    required DownloadFileNameBuilder fileNameBuilder,
  }) =>
      settings.downloadPath.toOption().fold(
            () => download(
              url: url,
              fileNameBuilder: fileNameBuilder,
            ),
            (path) => downloadCustomLocation(
              url: url,
              path: join(path, folderName),
              fileNameBuilder: fileNameBuilder,
            ),
          );
}

// map DownloadError to message
String mapDownloadErrorToMessage(DownloadError error) =>
    switch (error.errorType) {
      DownloadErrorType.directoryNotFound =>
        'Directory ${error.savedPath} not found',
      DownloadErrorType.platformNotSupported => 'Platform not supported',
      DownloadErrorType.restrictedDirectory =>
        'Restricted directory, cannot download to  ${error.savedPath}',
      DownloadErrorType.httpRequestError =>
        'Http request error, failed to download',
      DownloadErrorType.unknownError => 'Unknown error',
      DownloadErrorType.failedToCreateFile => 'Failed to create file',
      DownloadErrorType.needElevatedPermission =>
        'Need elevated permission in order to download to  ${error.savedPath}',
      DownloadErrorType.readOnlyDirectory =>
        'Read only directory, cannot download to  ${error.savedPath}',
      DownloadErrorType.fileNameTooLong =>
        'File name is too long, total length is  ${error.fileName.length}'
    };

class DioDownloadService implements DownloadService {
  DioDownloadService(this.dio, this.notifications);

  final Dio dio;
  final DownloadNotifications notifications;

  @override
  DownloadPathOrError download({
    required String url,
    required DownloadFileNameBuilder fileNameBuilder,
  }) =>
      downloadUrl(
        dio: dio,
        notifications: notifications,
        url: url,
        fileNameBuilder: fileNameBuilder,
      )
          .flatMap(_reloadMediaIfAndroid)
          .mapLeft((error) => _notifyFailure(notifications, error));

  @override
  DownloadPathOrError downloadCustomLocation({
    required String url,
    required String path,
    required DownloadFileNameBuilder fileNameBuilder,
  }) =>
      downloadUrlCustomLocation(
        dio: dio,
        notifications: notifications,
        path: path,
        url: url,
        fileNameBuilder: fileNameBuilder,
      )
          .flatMap(_reloadMediaIfAndroid)
          .mapLeft((error) => _notifyFailure(notifications, error));
}

DownloadPathOrError _reloadMediaIfAndroid(String path) => TaskEither(() async {
      if (isAndroid()) {
        await MediaScanner.loadMedia(path: path);
      }
      return Either.right(path);
    });

DownloadError _notifyFailure(
  DownloadNotifications notifications,
  DownloadError error,
) {
  notifications.showFailed(
    mapDownloadErrorToMessage(error),
    error.savedPath.fold(
      () => '',
      (t) => t,
    ),
  );
  return error;
}
