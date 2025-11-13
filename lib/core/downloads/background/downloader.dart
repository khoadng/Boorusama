// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:foundation/foundation.dart';
import 'package:path/path.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../../ddos/solver/types.dart';
import '../downloader/types.dart';
import '../path/types.dart';
import 'file_downloader_ex.dart';
import 'notification.dart';

class BackgroundDownloader implements DownloadService {
  const BackgroundDownloader({
    this.videoCacheManager,
    this.downloadNotifications,
    this.androidSdkInt,
    this.logger,
  });

  final VideoCacheManager? videoCacheManager;
  final DownloadNotifications? downloadNotifications;
  final int? androidSdkInt;
  final Logger? logger;

  @override
  Future<DownloadResult> download(DownloadOptions options) async {
    final pathInfo = PathInfo.from(options.path);

    final (targetDir, baseDirectory, error) = switch (pathInfo) {
      // Valid Android paths with public directory
      AndroidInternalStorage(:final publicDirectory?, :final path) ||
      AndroidSdCardStorage(
        :final publicDirectory?,
        :final path,
      ) => (path, BaseDirectory.root, null),

      // Android paths without public directory - check scoped storage
      final AndroidPathInfo pathInfo
          when pathInfo.requiresPublicDirectory(androidSdkInt) =>
        (
          null,
          BaseDirectory.root,
          _createScopedStorageError(options.filename, pathInfo.path),
        ),

      // Android paths without public directory - pre-scoped storage
      AndroidInternalStorage(:final path) ||
      AndroidSdCardStorage(:final path) ||
      AndroidOtherStorage(:final path) => (path, BaseDirectory.root, null),

      // iOS/Desktop - allow custom paths
      IOSPath(:final path) ||
      DesktopPath(:final path) => (path, BaseDirectory.root, null),

      // Invalid cases - return errors
      InvalidPath(:final path) => (
        null,
        BaseDirectory.root,
        _createInvalidPathError(options.filename, path),
      ),

      UnsupportedPlatform(:final path) => (
        null,
        BaseDirectory.root,
        _createUnsupportedPlatformError(options.filename, path),
      ),

      // Default path - use system default
      DefaultPath() => await _getDefaultDirectory(),
    };

    // Fail fast if validation error
    if (error != null) {
      return DownloadFailure(error);
    }

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

      _log(
        'Starting download: ${options.url} to $targetDir/${options.filename}',
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
          _log(
            'Downloaded from video cache: ${options.url} to $targetDir/${options.filename}',
          );
          return DownloadSuccess(info);
        } catch (e) {
          // Fall back to normal download if cache copy fails
        }
      }
    }

    return null;
  }

  Future<(String?, BaseDirectory, DownloadError?)>
  _getDefaultDirectory() async {
    return switch (await tryGetDownloadDirectory()) {
      DownloadDirectorySuccess(:final directory) => (
        directory.path,
        BaseDirectory.root,
        null,
      ),
      DownloadDirectoryFailure() => (
        null,
        BaseDirectory.applicationDocuments,
        null,
      ),
    };
  }

  DownloadError _createScopedStorageError(String filename, String path) {
    return GenericDownloadError(
      savedPath: const None(),
      fileName: filename,
      message:
          'Cannot use path "$path" on Android 11+, please use a public directory like Download or Pictures instead.',
    );
  }

  DownloadError _createInvalidPathError(String filename, String path) {
    return GenericDownloadError(
      savedPath: const None(),
      fileName: filename,
      message: 'Invalid path: $path',
    );
  }

  DownloadError _createUnsupportedPlatformError(String filename, String path) {
    return GenericDownloadError(
      savedPath: const None(),
      fileName: filename,
      message: 'Path "$path" is not supported on this platform',
    );
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

  void _log(String message) {
    logger?.debug('BackgroundDownloader', message);
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
