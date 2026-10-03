import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../downloads/background/types.dart';
import '../types/download_task_client.dart';

final downloadTaskClientProvider = Provider<DownloadTaskClient>(
  (ref) => FileDownloaderTaskClient(),
  name: 'downloadTaskClientProvider',
);

/// Production delegation to background_downloader.
final class FileDownloaderTaskClient implements DownloadTaskClient {
  @override
  Future<bool> pause(DownloadTask task) => FileDownloader().pause(task);

  @override
  Future<bool> resume(DownloadTask task) => FileDownloader().resume(task);

  @override
  Future<bool> retry(
    Task task, {
    required Map<String, String> headers,
    required Map<String, String> bypassHeaders,
  }) => FileDownloader().retryTask(
    task,
    headers: headers,
    bypassHeaders: bypassHeaders,
  );

  @override
  Future<bool> cancel(String taskId) =>
      FileDownloader().cancelTaskWithId(taskId);

  @override
  Future<bool> canResume(Task task) => FileDownloader().taskCanResume(task);

  @override
  Future<String> filePath(Task task) => task.filePath();

  @override
  Future<int> fileSize(Task task) async => XFile(await filePath(task)).length();
}
