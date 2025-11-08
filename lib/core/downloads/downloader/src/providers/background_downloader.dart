// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:foundation/foundation.dart';
import 'package:path/path.dart';

// Project imports:
import '../../../../ddos/solver/types.dart';
import '../../../notifications/notification.dart';
import '../../../path/directory.dart';
import '../types/download.dart';
import '../types/metadata.dart';
import 'file_downloader_ex.dart';

class BackgroundDownloader implements DownloadService {
  const BackgroundDownloader({
    this.videoCacheManager,
    this.downloadNotifications,
  });

  final VideoCacheManager? videoCacheManager;
  final DownloadNotifications? downloadNotifications;

  @override
  DownloadTaskInfoOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    int? fileSize,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) => TaskEither.Do(
    ($) async {
      final downloadDirResult = await tryGetDownloadDirectory();
      final downloadDir = switch (downloadDirResult) {
        DownloadDirectorySuccess(:final directory) => directory,
        DownloadDirectoryFailure() => null,
      };
      final isVideo = metadata?.isVideo ?? false;

      // Check if this is a video and if we have it in cache
      if (videoCacheManager case final vcm?
          when isVideo && downloadDir != null) {
        final cachedPath = await vcm.getCachedVideoPath(url);
        if (cachedPath case final cp?) {
          try {
            return _copyCachedContentToTarget(
              cp,
              downloadDir.path,
              filename,
              skipIfExists,
            );
          } catch (e) {
            // Fall back to normal download if cache copy fails
          }
        }
      }

      final task = DownloadTask(
        url: url,
        filename: filename,
        allowPause: true,
        retries: 1,
        baseDirectory: downloadDir != null
            ? BaseDirectory.root
            : BaseDirectory.applicationDocuments,
        directory: downloadDir != null ? downloadDir.path : '',
        updates: Updates.statusAndProgress,
        metaData: metadata?.toJsonString() ?? '',
        headers: headers,
        group: metadata?.group ?? FileDownloader.defaultGroup,
      );

      return FileDownloader().enqueueIfNeeded(
        task,
        skipIfExists: skipIfExists,
      );
    },
  );

  @override
  DownloadTaskInfoOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) => TaskEither.Do(
    ($) async {
      final isVideo = metadata?.isVideo ?? false;

      // Check if this is a video and if we have it in cache
      if (videoCacheManager case final vcm? when isVideo) {
        final cachedPath = await vcm.getCachedVideoPath(url);
        if (cachedPath case final cp?) {
          try {
            return _copyCachedContentToTarget(
              cp,
              path,
              filename,
              skipIfExists,
            );
          } catch (e) {
            // Fall back to normal download if cache copy fails
          }
        }
      }

      // Proceed with normal download
      final task = DownloadTask(
        url: url,
        filename: filename,
        baseDirectory: BaseDirectory.root,
        directory: path,
        allowPause: true,
        retries: 1,
        updates: Updates.statusAndProgress,
        metaData: metadata?.toJsonString() ?? '',
        headers: headers,
        group: metadata?.group ?? FileDownloader.defaultGroup,
      );

      return FileDownloader().enqueueIfNeeded(
        task,
        skipIfExists: skipIfExists,
      );
    },
  );

  @override
  Future<bool> cancelAll(String group) {
    return FileDownloader().cancelAll(group: group);
  }

  @override
  Future<void> pauseAll(String group) {
    return FileDownloader().pauseAll(group: group);
  }

  @override
  Future<void> resumeAll(String group) {
    return FileDownloader().resumeAll(group: group);
  }

  Future<DownloadTaskInfo> _copyCachedContentToTarget(
    String cachedPath,
    String targetDir,
    String filename,
    bool? skipIfExists,
  ) async {
    final sourceFile = File(cachedPath);
    if (!sourceFile.existsSync()) {
      throw Exception('Cached file not found: $cachedPath');
    }

    // Ensure target directory exists
    final targetDirectory = Directory(targetDir);
    if (!targetDirectory.existsSync()) {
      await targetDirectory.create(recursive: true);
    }

    final targetPath = join(targetDir, filename);
    final targetFile = File(targetPath);

    // Check if target file already exists
    if ((skipIfExists ?? false) && targetFile.existsSync()) {
      // Show completion notification for existing file
      if (downloadNotifications case final notifications?) {
        unawaited(
          notifications
              .showDownloadCompleteNotification(
                filename,
                fromCache: true,
                customMessage: '$filename was already saved from cache',
              )
              .catchError((e) {
                // Ignore notification errors
              }),
        );
      }

      return DownloadTaskInfo(
        path: targetPath,
        id: 'cached_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    // Copy cached file to target location
    await sourceFile.copy(targetPath);

    // Show completion notification for successful copy
    if (downloadNotifications case final notifications?) {
      unawaited(
        notifications
            .showDownloadCompleteNotification(
              filename,
              fromCache: true,
            )
            .catchError((e) {
              // Ignore notification errors
            }),
      );
    }

    return DownloadTaskInfo(
      path: targetPath,
      id: 'cached_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class TaskResponseAdapter implements HttpResponse {
  const TaskResponseAdapter(
    this._update,
    this.statusCode,
    this.data,
  );

  final TaskStatusUpdate _update;

  @override
  final int? statusCode;
  @override
  final dynamic data;
  @override
  Uri get requestUri => Uri.tryParse(_update.task.url) ?? Uri();
  @override
  Map<String, dynamic> get headers => Map<String, dynamic>.from(
    _update.responseHeaders ?? <String, String>{},
  );
}

class TaskErrorAdapter implements HttpError {
  const TaskErrorAdapter(this._update);
  final TaskStatusUpdate _update;

  @override
  HttpResponse get response {
    final statusCode = switch (_update.exception) {
      final TaskHttpException e => e.httpResponseCode,
      _ => null,
    };

    final body = switch (_update.exception) {
      final TaskHttpException e => e.description,
      _ => null,
    };

    return TaskResponseAdapter(
      _update,
      statusCode,
      body,
    );
  }

  @override
  Uri get requestUri => Uri.tryParse(_update.task.url) ?? Uri();
  @override
  String? get message => _update.exception?.description;
}
