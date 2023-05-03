// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads/download.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/functional.dart';
import 'notification.dart';

abstract class DownloadService<T> {
  Future<void> download(
    T item, {
    String? path,
    String? folderName,
    required FileNameGenerator fileNameGenerator,
  });
  Future<void> init();
  void dispose();
}

enum DownloadError {
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

typedef DownloadPathOrError = TaskEither<DownloadError, String>;
typedef DownloadFileNameBuilder = String Function();

abstract class DownloadService2 {
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

extension DownloadWithSettingsX on DownloadService2 {
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

class Downloader {
  static DownloadService2 of(BuildContext context) =>
      context.read<DownloadService2>();
}

// map DownloadError to message
String mapDownloadErrorToMessage(
  DownloadError error,
  String? path, {
  String? fileName,
}) {
  switch (error) {
    case DownloadError.directoryNotFound:
      return path == null
          ? 'Download directory not found'
          : 'Directory $path not found';
    case DownloadError.platformNotSupported:
      return 'Platform not supported';
    case DownloadError.restrictedDirectory:
      return path == null
          ? 'Restricted directory, cannot download to this directory'
          : 'Restricted directory, cannot download to $path';
    case DownloadError.httpRequestError:
      return 'Http request error, failed to download';
    case DownloadError.unknownError:
      return 'Unknown error';
    case DownloadError.failedToCreateFile:
      return 'Failed to create file';
    case DownloadError.needElevatedPermission:
      return path == null
          ? 'Need elevated permission in order to download'
          : 'Need elevated permission in order to download to $path';
    case DownloadError.readOnlyDirectory:
      return path == null
          ? 'Read only directory, cannot download to this directory'
          : 'Read only directory, cannot download to $path';
    case DownloadError.fileNameTooLong:
      return fileName == null
          ? 'File name too long'
          : 'File name is too long, total length is ${fileName.length}';
  }
}

class DioDownloadService implements DownloadService2 {
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
      ).flatMap(_reloadMediaIfAndroid).mapLeft((error) => _notifyFailure(
            notifications,
            error,
            null,
            fileName: fileNameBuilder(),
          ));

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
      ).flatMap(_reloadMediaIfAndroid).mapLeft((error) => _notifyFailure(
            notifications,
            error,
            path,
            fileName: fileNameBuilder(),
          ));
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
  String? path, {
  String? fileName,
}) {
  notifications
      .showFailed(mapDownloadErrorToMessage(error, path, fileName: fileName));
  return error;
}
