// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/foundation/http/user_agent_generator.dart';
import 'package:boorusama/foundation/platform.dart';

class CrossplatformBulkDownloader implements BulkDownloader {
  final DownloadManager _downloadManager;
  final _downloadDataController = BehaviorSubject<BulkDownloadStatus>();

  CrossplatformBulkDownloader(UserAgentGenerator userAgentGenerator)
      : _downloadManager = DownloadManager(
          dio: Dio(
            BaseOptions(
              headers: {
                'User-Agent': userAgentGenerator.generate(),
              },
            ),
          ),
          maxConcurrentTasks: 6,
        );

  @override
  Future<void> enqueueDownload({
    required String url,
    String? path,
    required DownloadFileNameBuilder fileNameBuilder,
  }) async {
    final fileName = fileNameBuilder();
    _downloadDataController.add(BulkDownloadInitializing(url, fileName));

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
          _downloadDataController.add(BulkDownloadDone(
            url,
            fileName,
            t.path,
            alreadyExists: true,
          ));
          return;
        }

        final task =
            await _downloadManager.addDownload(url, join(t.path, fileName));

        _downloadDataController.add(BulkDownloadQueued(url, fileName));

        task?.progress.addListener(() {
          if (task.status.value == DownloadStatus.downloading) {
            _downloadDataController.add(BulkDownloadInProgress(
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
            DownloadStatus.queued => BulkDownloadQueued(url, fileName),
            DownloadStatus.downloading => BulkDownloadInProgress(
                url,
                fileName,
                task.progress.value,
              ),
            DownloadStatus.paused => BulkDownloadPaused(
                url,
                fileName,
                task.progress.value,
              ),
            DownloadStatus.failed => BulkDownloadFailed(url, fileName),
            DownloadStatus.canceled => task.progress.value == 1
                ? BulkDownloadDone(url, fileName, task.request.path)
                : BulkDownloadCanceled(url, fileName),
            DownloadStatus.completed => BulkDownloadDone(
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
  Stream<BulkDownloadStatus> get stream => _downloadDataController.stream;

  @override
  Future<void> pause(String url) {
    return _downloadManager.pauseDownload(url);
  }

  @override
  Future<void> resume(String url) {
    return _downloadManager.resumeDownload(url);
  }
}
