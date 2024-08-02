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
  final dm.DownloadManager _downloadManager;
  final LoggerService? logger;
  final _downloadDataController = BehaviorSubject<DownloadStatus>();
  final void Function(Object error)? onError;

  CrossplatformDownloader({
    required UserAgentGenerator userAgentGenerator,
    this.logger,
    this.onError,
  }) : _downloadManager = dm.DownloadManager(
          onError: (error) =>
              logger?.logE('Bulk Downloader', 'Download error: $error'),
          dio: Dio(
            BaseOptions(
              headers: {
                AppHttpHeaders.userAgentHeader: userAgentGenerator.generate(),
              },
            ),
          ),
          maxConcurrentTasks: 6,
        );

  @override
  Future<void> enqueueDownload({
    required String url,
    String? path,
    required DownloadFilenameBuilder fileNameBuilder,
  }) async {
    final fileName = fileNameBuilder();
    _downloadDataController.add(DownloadInitializing(url, fileName));

    final savePath = path != null
        ? tryGetCustomDownloadDirectory(path)
        : tryGetDownloadDirectory();

    final savedPath = await savePath.run();

    if (savedPath.isLeft()) return;
    final dir = savedPath.getRight();

    return dir.fold(
      () => null,
      (t) async {
        final filePath = join(t.path, fileName);
        if (File(filePath).existsSync()) {
          _downloadDataController.add(DownloadDone(
            url,
            fileName,
            t.path,
            alreadyExists: true,
          ));
          return;
        }

        final task =
            await _downloadManager.addDownload(url, join(t.path, fileName));

        _downloadDataController.add(DownloadQueued(url, fileName));

        task?.progress.addListener(() {
          if (task.status.value == dm.DownloadStatus.downloading) {
            _downloadDataController.add(DownloadInProgress(
              url,
              fileName,
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
            dm.DownloadStatus.queued => DownloadQueued(url, fileName),
            dm.DownloadStatus.downloading => DownloadInProgress(
                url,
                fileName,
                task.progress.value,
              ),
            dm.DownloadStatus.paused => DownloadPaused(
                url,
                fileName,
                task.progress.value,
              ),
            dm.DownloadStatus.failed => DownloadFailed(url, fileName),
            dm.DownloadStatus.canceled => task.progress.value == 1
                ? DownloadDone(url, fileName, task.request.path)
                : DownloadCanceled(url, fileName),
            dm.DownloadStatus.completed => DownloadDone(
                url,
                fileName,
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
    List<String> urls = _downloadManager
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
