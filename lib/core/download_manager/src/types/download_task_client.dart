import '../../../downloads/background/types.dart';

/// The platform operations used by the download manager for one task.
///
/// Enqueueing remains the responsibility of the download service. This
/// boundary only covers manager controls and task file access.
abstract interface class DownloadTaskClient {
  Future<bool> pause(DownloadTask task);

  Future<bool> resume(DownloadTask task);

  Future<bool> retry(
    Task task, {
    required Map<String, String> headers,
    required Map<String, String> bypassHeaders,
  });

  Future<bool> cancel(String taskId);

  Future<bool> canResume(Task task);

  Future<String> filePath(Task task);

  Future<int> fileSize(Task task);
}
