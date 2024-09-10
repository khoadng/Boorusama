// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart' as dm;
import 'package:media_scanner/media_scanner.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';

class CrossplatformDownloader implements Downloader {
  CrossplatformDownloader({
    required UserAgentGenerator userAgentGenerator,
    Map<String, String>? extraHeaders,
    this.logger,
    this.onError,
  }) : _downloadManager = dm.DownloadManager(
          onError: (error) =>
              logger?.logE('Bulk Downloader', 'Download error: $error'),
          dio: Dio(
            BaseOptions(
              headers: {
                AppHttpHeaders.userAgentHeader: userAgentGenerator.generate(),
                if (extraHeaders != null) ...extraHeaders,
              },
            ),
          ),
          maxConcurrentTasks: 6,
        );
  final dm.DownloadManager _downloadManager;
  final LoggerService? logger;
  final _downloadDataController = BehaviorSubject<DownloadStatus>();
  final void Function(Object error)? onError;

  @override
  Future<void> enqueueDownload({
    required String url,
    String? path,
    required String filename,
  }) async {
    _downloadDataController.add(DownloadInitializing(url, filename));

    final savePath = path != null
        ? tryGetCustomDownloadDirectory(path)
        : tryGetDownloadDirectory();

    final savedPath = await savePath.run();

    if (savedPath.isLeft()) return;
    final dir = savedPath.getRight();

    return dir.fold(
      () => null,
      (t) async {
        final filePath = join(t.path, filename);
        if (File(filePath).existsSync()) {
          _downloadDataController.add(DownloadDone(
            url,
            filename,
            t.path,
            alreadyExists: true,
          ));
          return;
        }

        final task =
            await _downloadManager.addDownload(url, join(t.path, filename));

        _downloadDataController.add(DownloadQueued(url, filename));

        task?.progress.addListener(() {
          if (task.status.value == dm.DownloadStatus.downloading) {
            _downloadDataController.add(DownloadInProgress(
              url,
              filename,
              task.progress.value,
            ));
          }
        });

        task?.whenDownloadComplete().then((value) {
          if (isAndroid()) {
            MediaScanner.loadMedia(path: task.request.path);
          }
        });

        task?.status.addListener(() {
          final status = switch (task.status.value) {
            dm.DownloadStatus.queued => DownloadQueued(url, filename),
            dm.DownloadStatus.downloading => DownloadInProgress(
                url,
                filename,
                task.progress.value,
              ),
            dm.DownloadStatus.paused => DownloadPaused(
                url,
                filename,
                task.progress.value,
              ),
            dm.DownloadStatus.failed => DownloadFailed(url, filename),
            dm.DownloadStatus.canceled => task.progress.value == 1
                ? DownloadDone(url, filename, task.request.path)
                : DownloadCanceled(url, filename),
            dm.DownloadStatus.completed => DownloadDone(
                url,
                filename,
                task.request.path,
              ),
          };
          _downloadDataController.add(status);
        });
      },
    );
  }

  @override
  Future<void> cancelAll() async {
    final List<String> urls = _downloadManager
        .getAllDownloads()
        .map((task) => task.request.url)
        .toList();
    await _downloadManager.cancelBatchDownloads(urls);
  }

  @override
  Stream<DownloadStatus> get stream => _downloadDataController.stream;

  @override
  Future<void> pause(String url) {
    return _downloadManager.pauseDownload(url);
  }

  @override
  Future<void> resume(String url) {
    return _downloadManager.resumeDownload(url);
  }
}
