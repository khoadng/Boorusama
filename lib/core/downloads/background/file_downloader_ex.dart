// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/filesystem.dart';
import '../../configs/network/types.dart';
import '../downloader/types.dart';

extension FileDownloaderX on FileDownloader {
  Future<DownloadResult> enqueueIfNeeded(
    DownloadTask task, {
    bool? skipIfExists,
    required AppFileSystem fs,
  }) async {
    final file = await task.filePath();

    if (skipIfExists ?? false) {
      if (fs.fileExistsSync(file)) {
        return DownloadSkipped(
          DownloadTaskInfo(
            path: file,
            id: task.taskId,
          ),
        );
      }
    }

    final accepted = await enqueue(task);
    if (!accepted) {
      return DownloadFailure(
        GenericDownloadError(
          savedPath: const None(),
          fileName: task.filename,
          message: 'Download could not be enqueued',
        ),
      );
    }

    return DownloadEnqueued(
      DownloadTaskInfo(
        path: file,
        id: task.taskId,
      ),
    );
  }

  Future<bool> retryTask(
    Task task, {
    Map<String, String>? headers,
    Map<String, String> bypassHeaders = const {},
    void Function(Map<String, String>)? onPrepared,
    // Preserve asynchronous delivery of header preparation failures.
    // ignore: unnecessary_async
  }) async {
    final profileHeaders =
        DownloaderMetadata.fromJsonString(task.metaData).mediaHostOverridden
        ? MediaRequest.filterSourceHeaders(headers ?? const {})
        : headers ?? const <String, String>{};
    if (profileHeaders.isEmpty && bypassHeaders.isEmpty) {
      onPrepared?.call(task.headers);
      return enqueue(task);
    }

    final mergedHeaders = Map<String, String>.from(task.headers);
    // Stored task headers already belong to task.url. Filter only newly
    // supplied profile headers, then apply clearance obtained for task.url.
    for (final header in [
      ...profileHeaders.entries,
      ...bypassHeaders.entries,
    ]) {
      final existingKeys = mergedHeaders.keys
          .where((key) => key.toLowerCase() == header.key.toLowerCase())
          .toList();
      existingKeys.forEach(mergedHeaders.remove);
      mergedHeaders[header.key] = header.value;
    }

    onPrepared?.call(mergedHeaders);
    return enqueue(task.copyWith(headers: mergedHeaders));
  }
}
