// Package imports:
import 'package:background_downloader/background_downloader.dart';

// Project imports:
import '../../../foundation/filesystem.dart';
import '../downloader/types.dart';

extension FileDownloaderX on FileDownloader {
  Future<DownloadTaskInfo> enqueueIfNeeded(
    DownloadTask task, {
    bool? skipIfExists,
    required AppFileSystem fs,
  }) async {
    final file = await task.filePath();

    if (skipIfExists ?? false) {
      if (fs.fileExistsSync(file)) {
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
