// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads/download_path_handler.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
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
  permissionDenied,
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
}

class Downloader {
  static of(BuildContext context) => context.read<DownloadService2>();
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
      return DownloadError.permissionDenied;
    case DownloadDirectoryError.unknownError:
      return DownloadError.unknownError;
  }
}

// map DownloadError to message
String _mapDownloadErrorToMessage(DownloadError error) {
  switch (error) {
    case DownloadError.directoryNotFound:
      return 'Directory not found';
    case DownloadError.platformNotSupported:
      return 'Platform not supported';
    case DownloadError.permissionDenied:
      return 'Permission denied';
    case DownloadError.httpRequestError:
      return 'Http request error';
    case DownloadError.unknownError:
      return 'Unknown error';
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
      _download(url: url, fileNameBuilder: fileNameBuilder)
          .flatMap(_reloadMediaIfAndroid)
          .mapLeft((error) => _notifyFailure(notifications, error));

  //FIXME: support custom download location
  DownloadPathOrError _download({
    required String url,
    required DownloadFileNameBuilder fileNameBuilder,
  }) =>
      tryGetDownloadDirectory()
          .mapLeft(_mapDownloadDirectoryErrorToDownloadError)
          .flatMap((dir) => createDownloadPath(fileNameBuilder(), dir))
          .flatMap((path) => _wrapWithNotification(
                downloadWithDio(dio, url: url, path: path),
                notifications: notifications,
                path: path,
              ));
}

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

DownloadPathOrError _reloadMediaIfAndroid(String path) => TaskEither(() async {
      if (isAndroid()) {
        await MediaScanner.loadMedia(path: path);
      }
      return Either.right(path);
    });

DownloadError _notifyFailure(
    DownloadNotifications notifications, DownloadError error) {
  notifications.showFailed(_mapDownloadErrorToMessage(error));
  return error;
}

// download using dio
DownloadPathOrError downloadWithDio(
  Dio dio, {
  required String url,
  required String path,
}) =>
    TaskEither.tryCatch(
      () async => dio.download(url, path).then((value) => path),
      (error, stackTrace) => DownloadError.httpRequestError,
    );

DownloadPathOrError createDownloadPath(
  String fileName,
  Directory directory,
) =>
    TaskEither.fromEither(Either.of(join(directory.path, fileName)));
