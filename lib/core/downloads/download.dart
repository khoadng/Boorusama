// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';

DownloadPathOrError downloadUrl({
  required Dio dio,
  required DownloadNotifications notifications,
  required String url,
  required DownloadFilenameBuilder fileNameBuilder,
  bool enableNotification = true,
}) =>
    TaskEither.Do(($) async {
      final dir = await $(
          tryGetDownloadDirectory().mapLeft((error) => GenericDownloadError(
                message: error.name,
                fileName: fileNameBuilder(),
                savedPath: none(),
              )));

      final path = await $(joinDownloadPath(fileNameBuilder(), dir));

      return _wrapWithNotification(
        () => $(
          downloadWithDio(
            dio,
            url: url,
            path: path,
            onReceiveProgress: onReceiveProgress(
              notifications,
              fileNameBuilder(),
              path,
              enableNotification,
            ),
          ),
        ),
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
  required DownloadFilenameBuilder fileNameBuilder,
  bool enableNotification = true,
}) =>
    TaskEither.Do(($) async {
      final dir = await $(tryGetCustomDownloadDirectory(path)
          .mapLeft((error) => GenericDownloadError(
                message: error.name,
                fileName: fileNameBuilder(),
                savedPath: none(),
              )));

      final filePath = await $(joinDownloadPath(fileNameBuilder(), dir));

      return _wrapWithNotification(
        () => $(
          downloadWithDio(
            dio,
            url: url,
            path: filePath,
            onReceiveProgress: onReceiveProgress(
              notifications,
              fileNameBuilder(),
              filePath,
              enableNotification,
            ),
          ),
        ),
        notifications: notifications,
        path: filePath,
        enableNotification: enableNotification,
      );
    });

ProgressCallback onReceiveProgress(
  DownloadNotifications notifications,
  String fileName,
  String path,
  bool enableNotification,
) =>
    (received, total) async {
      if (!enableNotification) return;

      await notifications.showUpdatedProgress(
        fileName,
        path,
        received: received,
        total: total,
      );
    };

DownloadPathOrError downloadWithDio(
  Dio dio, {
  required String url,
  required String path,
  required ProgressCallback onReceiveProgress,
}) =>
    TaskEither.tryCatch(
      () {
        var previousPercent = 0;

        return dio.download(
          url,
          path,
          onReceiveProgress: (count, total) {
            final percent = (count / total * 100).toInt();

            if (percent != previousPercent) {
              previousPercent = percent;

              onReceiveProgress(count, total);
            }
          },
        ).then((value) => path);
      },
      (error, stackTrace) {
        final fileName = basename(path);

        return switch (error) {
          final FileSystemException e => FileSystemDownloadError(
              savedPath: some(path),
              fileName: fileName,
              error: e,
            ),
          final DioException e => HttpDownloadError(
              savedPath: some(path),
              fileName: fileName,
              exception: e,
            ),
          _ => GenericDownloadError(
              savedPath: some(path),
              fileName: fileName,
              message: error.toString(),
            ),
        };
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
    await Future.delayed(const Duration(milliseconds: 500));
    await notifications.showCompleted(fileName, path);
  }

  return result;
}
