// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';

class CrossplatformBulkDownloader implements BulkDownloader {
  final DownloadManager _downloadManager;
  final _downloadDataController =
      StreamController<BulkDownloadStatus>.broadcast();

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
    _downloadDataController.add(BulkDownloadInitializing(url));

    final fileName = fileNameBuilder();
    final savePath = path != null
        ? tryGetCustomDownloadDirectory(path)
        : tryGetDownloadDirectory();

    final savedPath = await savePath.run();

    if (savedPath.isLeft()) return;
    final dir = savedPath.getRight();

    return dir.fold(
      () => null,
      (t) async {
        final task =
            await _downloadManager.addDownload(url, join(t.path, fileName));

        _downloadDataController.add(BulkDownloadQueued(url));

        task?.progress.addListener(() {
          _downloadDataController.add(BulkDownloadInProgress(
            url,
            task.progress.value,
          ));
        });

        // Add a listener for download completion
        task?.whenDownloadComplete().then((_) {
          _downloadDataController.add(BulkDownloadDone(
            task.request.url,
            task.request.path,
          ));
        }).catchError((error) {
          _downloadDataController
              .addError(error); // Emit error events through the stream
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
}
