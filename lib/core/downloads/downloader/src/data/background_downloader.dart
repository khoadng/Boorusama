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
import '../../../path/types.dart';
import '../types/download.dart';
import '../providers/file_downloader_ex.dart';

class BackgroundDownloader implements DownloadService {
  const BackgroundDownloader({
    this.videoCacheManager,
    this.downloadNotifications,
  });

  final VideoCacheManager? videoCacheManager;
  final DownloadNotifications? downloadNotifications;

  @override
  Future<DownloadResult> download(DownloadOptions options) async {
    final (targetDir, baseDirectory) = switch (options.path) {
      // User specified a custom path, use it directly
      final String path when path.isNotEmpty => (path, BaseDirectory.root),
      // No custom path, try to get system download directory
      _ => switch (await tryGetDownloadDirectory()) {
        DownloadDirectorySuccess(:final directory) => (
          directory.path,
          BaseDirectory.root,
        ),
        DownloadDirectoryFailure() => (
          null,
          BaseDirectory.applicationDocuments,
        ),
      },
    };

    return _executeDownload(
      targetDir: targetDir,
      baseDirectory: baseDirectory,
      options: options,
    );
  }

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

  Future<DownloadResult> _executeDownload({
    required String? targetDir,
    required BaseDirectory baseDirectory,
    required DownloadOptions options,
  }) async {
    try {
      final cacheResult = await _tryDownloadFromCache(
        targetDir: targetDir,
        options: options,
      );

      if (cacheResult case final result?) {
        return result;
      }

      final task = DownloadTask(
        url: options.url,
        filename: options.filename,
        allowPause: true,
        retries: 1,
        baseDirectory: baseDirectory,
        directory: targetDir ?? '',
        updates: Updates.statusAndProgress,
        metaData: options.metadata?.toJsonString() ?? '',
        headers: options.headers,
        group: options.metadata?.group ?? FileDownloader.defaultGroup,
      );

      final info = await FileDownloader().enqueueIfNeeded(
        task,
        skipIfExists: options.skipIfExists,
      );

      return DownloadSuccess(info);
    } on FileSystemException catch (e) {
      return DownloadFailure(
        FileSystemDownloadError(
          savedPath: const None(),
          fileName: options.filename,
          error: e,
        ),
      );
    } catch (e) {
      return DownloadFailure(
        GenericDownloadError(
          savedPath: const None(),
          fileName: options.filename,
          message: e.toString(),
        ),
      );
    }
  }

  Future<DownloadResult?> _tryDownloadFromCache({
    required String? targetDir,
    required DownloadOptions options,
  }) async {
    final isVideo = options.metadata?.isVideo ?? false;

    if (videoCacheManager case final vcm? when isVideo && targetDir != null) {
      final cachedPath = await vcm.getCachedVideoPath(options.url);
      if (cachedPath case final cp?) {
        try {
          final info = await _copyCachedContentToTarget(
            cp,
            targetDir,
            options.filename,
            options.skipIfExists,
          );
          return DownloadSuccess(info);
        } catch (e) {
          // Fall back to normal download if cache copy fails
        }
      }
    }

    return null;
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
