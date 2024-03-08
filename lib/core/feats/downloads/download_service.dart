// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:media_scanner/media_scanner.dart';

// Project imports:
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/functional.dart';

enum FileSystemDownloadErrorType {
  directoryNotFound,
  restrictedDirectory,
  needElevatedPermission,
  readOnlyDirectory,
  failedToCreateFile,
  fileNameTooLong,
}

sealed class DownloadError {
  DownloadError({
    required this.savedPath,
    required this.fileName,
  });

  final Option<String> savedPath;
  final String fileName;
}

final class HttpDownloadError extends DownloadError {
  HttpDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.exception,
  });

  final DioException exception;
}

final class GenericDownloadError extends DownloadError {
  GenericDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.message,
  });

  final String message;
}

final class FileSystemDownloadError extends DownloadError {
  FileSystemDownloadError({
    required super.savedPath,
    required super.fileName,
    required this.error,
  }) {
    if (error is PathNotFoundException) {
      type = FileSystemDownloadErrorType.directoryNotFound;
    } else {
      type = switch (error.osError?.errorCode) {
        1 => FileSystemDownloadErrorType.needElevatedPermission,
        13 => FileSystemDownloadErrorType.restrictedDirectory,
        30 => FileSystemDownloadErrorType.readOnlyDirectory,
        36 => FileSystemDownloadErrorType.fileNameTooLong,
        _ => FileSystemDownloadErrorType.failedToCreateFile,
      };
    }
  }

  late FileSystemDownloadErrorType type;
  final FileSystemException error;
}

typedef DownloadPathOrError = TaskEither<DownloadError, String>;

abstract class DownloadService {
  DownloadPathOrError download({
    required String url,
    required DownloadFilenameBuilder fileNameBuilder,
  });

  DownloadPathOrError downloadCustomLocation({
    required String url,
    required String path,
    required DownloadFilenameBuilder fileNameBuilder,
  });
}

extension DownloadWithSettingsX on DownloadService {
  DownloadPathOrError downloadWithSettings(
    Settings settings, {
    required String url,
    String? folderName,
    required DownloadFilenameBuilder fileNameBuilder,
  }) {
    final downloadPath = settings.downloadPath;

    return downloadPath != null && downloadPath.isNotEmpty
        ? downloadCustomLocation(
            url: url,
            path: join(downloadPath, folderName),
            fileNameBuilder: fileNameBuilder,
          )
        : download(
            url: url,
            fileNameBuilder: fileNameBuilder,
          );
  }
}

// map DownloadError to message
String mapDownloadErrorToMessage(DownloadError error) => switch (error) {
      FileSystemDownloadError e => switch (e.type) {
          FileSystemDownloadErrorType.directoryNotFound =>
            'Directory ${error.savedPath} not found',
          FileSystemDownloadErrorType.restrictedDirectory =>
            'Restricted directory, cannot download to  ${error.savedPath}',
          FileSystemDownloadErrorType.failedToCreateFile =>
            'Failed to create file: ${error.error.message}',
          FileSystemDownloadErrorType.needElevatedPermission =>
            'Need elevated permission in order to download to  ${error.savedPath}',
          FileSystemDownloadErrorType.readOnlyDirectory =>
            'Read only directory, cannot download to  ${error.savedPath}',
          FileSystemDownloadErrorType.fileNameTooLong =>
            'File name is too long, total length is  ${error.fileName.length}'
        },
      HttpDownloadError e =>
        'Http request error ${e.exception.response?.statusCode}, failed to download ${e.fileName}',
      GenericDownloadError e => e.message,
    };

class DioDownloadService implements DownloadService {
  DioDownloadService(
    this.dio,
    this.notifications, {
    this.retryOn404 = false,
    this.retryExtensions = const ['.jpg', '.png', '.webp'],
  });

  final Dio dio;
  final DownloadNotifications notifications;
  final bool retryOn404;
  final List<String> retryExtensions;

  @override
  DownloadPathOrError download({
    required String url,
    required DownloadFilenameBuilder fileNameBuilder,
  }) =>
      retryOn404
          ? _download(
              urls: retryExtensions
                  .map((e) => removeFileExtension(url) + e)
                  .toList(),
              fileNameBuilder: fileNameBuilder,
            )
              .flatMap(_reloadMedia)
              .mapLeft((error) => _notifyFailure(notifications, error))
          : downloadUrl(
                  dio: dio,
                  notifications: notifications,
                  url: url,
                  fileNameBuilder: fileNameBuilder)
              .flatMap(_reloadMedia)
              .mapLeft((error) => _notifyFailure(notifications, error));

  DownloadPathOrError _download({
    required List<String> urls,
    required DownloadFilenameBuilder fileNameBuilder,
  }) {
    if (urls.isEmpty) {
      return TaskEither.left(GenericDownloadError(
        savedPath: none(),
        fileName: fileNameBuilder(),
        message:
            'Multiple tries failed to download ${fileNameBuilder()}, all urls are invalid',
      ));
    }

    final url = urls.first;

    return downloadUrl(
      dio: dio,
      notifications: notifications,
      url: url,
      fileNameBuilder: fileNameBuilder,
    ).orElse((error) => switch (error) {
          HttpDownloadError e => e.exception.response?.statusCode == 404
              ? _download(
                  urls: urls..remove(url),
                  fileNameBuilder: fileNameBuilder,
                )
              : TaskEither.left(e),
          _ => TaskEither.left(error),
        });
  }

  //FIXME: should merge with _download, i'm playing it safe for now
  DownloadPathOrError _downloadCustomLocation({
    required List<String> urls,
    required DownloadFilenameBuilder fileNameBuilder,
    required String path,
  }) {
    if (urls.isEmpty) {
      return TaskEither.left(GenericDownloadError(
        savedPath: none(),
        fileName: fileNameBuilder(),
        message:
            'Multiple tries failed to download ${fileNameBuilder()}, all urls are invalid',
      ));
    }

    final url = urls.first;

    return downloadUrlCustomLocation(
      dio: dio,
      notifications: notifications,
      path: path,
      url: url,
      fileNameBuilder: fileNameBuilder,
    ).orElse((error) => switch (error) {
          HttpDownloadError e => e.exception.response?.statusCode == 404
              ? _download(
                  urls: urls..remove(url),
                  fileNameBuilder: fileNameBuilder,
                )
              : TaskEither.left(e),
          _ => TaskEither.left(error),
        });
  }

  @override
  DownloadPathOrError downloadCustomLocation({
    required String url,
    required String path,
    required DownloadFilenameBuilder fileNameBuilder,
  }) =>
      retryOn404
          ? _downloadCustomLocation(
              urls: retryExtensions
                  .map((e) => removeFileExtension(url) + e)
                  .toList(),
              fileNameBuilder: fileNameBuilder,
              path: path,
            )
              .flatMap(_reloadMedia)
              .mapLeft((error) => _notifyFailure(notifications, error))
          : downloadUrlCustomLocation(
              dio: dio,
              notifications: notifications,
              path: path,
              url: url,
              fileNameBuilder: fileNameBuilder,
            )
              .flatMap(_reloadMedia)
              .mapLeft((error) => _notifyFailure(notifications, error));
}

DownloadPathOrError _reloadMedia(String path) => TaskEither(() async {
      if (isAndroid()) {
        await MediaScanner.loadMedia(path: path);
      } else if (isIOS()) {
        await Gal.putImage(path);
      }
      return Either.right(path);
    });

String removeFileExtension(String url) {
  final lastDotIndex = url.lastIndexOf('.');
  if (lastDotIndex != -1) {
    return url.substring(0, lastDotIndex);
  } else {
    // If there is no '.', return the original URL
    return url;
  }
}

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
