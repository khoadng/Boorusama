// Dart imports:
import 'dart:io' hide HttpResponse;

// Package imports:
import 'package:background_downloader/background_downloader.dart';

// Project imports:
import '../downloader/types.dart';

extension FileDownloaderX on FileDownloader {
  Future<DownloadTaskInfo> enqueueIfNeeded(
    DownloadTask task, {
    bool? skipIfExists,
  }) async {
    final file = await task.filePath();

    if (skipIfExists ?? false) {
      if (File(file).existsSync()) {
        return DownloadTaskInfo(
          path: file,
          id: task.taskId,
        );
      }
    }

    await enqueue(task);

    return DownloadTaskInfo(
      path: file,
      id: task.taskId,
    );
  }

  Future<void> retryTask(
    Task task, {
    Map<String, String>? headers,
  }) async {
    final taskToRetry = headers != null && headers.isNotEmpty
        ? task.copyWith(headers: headers)
        : task;

    await enqueue(taskToRetry);
  }
}
