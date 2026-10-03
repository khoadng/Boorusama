import 'package:background_downloader/background_downloader.dart' as bg;

import 'package:boorusama/core/download_manager/types.dart';

enum DownloadTaskOperation {
  pause,
  resume,
  retry,
  cancel,
  canResume,
  filePath,
  fileSize;

  /// Whether the operation changes the native task, as opposed to a query.
  bool get isControl => switch (this) {
    pause || resume || retry || cancel => true,
    canResume || filePath || fileSize => false,
  };
}

final class RecordedDownloadTaskAction {
  const RecordedDownloadTaskAction(
    this.operation, {
    required this.taskId,
    this.headers = const {},
    this.bypassHeaders = const {},
  });

  final DownloadTaskOperation operation;
  final String taskId;
  final Map<String, String> headers;
  final Map<String, String> bypassHeaders;
}

/// Deterministic platform boundary. Calls never publish task status updates.
final class FakeDownloadTaskClient implements DownloadTaskClient {
  final actions = <RecordedDownloadTaskAction>[];
  final resumableTaskIds = <String>{};
  final filePaths = <String, String>{};
  final fileSizes = <String, int>{};

  var pauseResult = true;
  var resumeResult = true;
  var retryResult = true;
  var cancelResult = true;

  @override
  Future<bool> pause(bg.DownloadTask task) async {
    actions.add(
      RecordedDownloadTaskAction(
        DownloadTaskOperation.pause,
        taskId: task.taskId,
      ),
    );
    return pauseResult;
  }

  @override
  Future<bool> resume(bg.DownloadTask task) async {
    actions.add(
      RecordedDownloadTaskAction(
        DownloadTaskOperation.resume,
        taskId: task.taskId,
      ),
    );
    return resumeResult;
  }

  @override
  Future<bool> retry(
    bg.Task task, {
    required Map<String, String> headers,
    required Map<String, String> bypassHeaders,
  }) async {
    actions.add(
      RecordedDownloadTaskAction(
        DownloadTaskOperation.retry,
        taskId: task.taskId,
        headers: Map.unmodifiable(headers),
        bypassHeaders: Map.unmodifiable(bypassHeaders),
      ),
    );
    return retryResult;
  }

  @override
  Future<bool> cancel(String taskId) async {
    actions.add(
      RecordedDownloadTaskAction(DownloadTaskOperation.cancel, taskId: taskId),
    );
    return cancelResult;
  }

  @override
  Future<bool> canResume(bg.Task task) async {
    actions.add(
      RecordedDownloadTaskAction(
        DownloadTaskOperation.canResume,
        taskId: task.taskId,
      ),
    );
    return resumableTaskIds.contains(task.taskId);
  }

  @override
  Future<String> filePath(bg.Task task) async {
    actions.add(
      RecordedDownloadTaskAction(
        DownloadTaskOperation.filePath,
        taskId: task.taskId,
      ),
    );
    return filePaths[task.taskId] ?? '/fake-downloads/${task.filename}';
  }

  @override
  Future<int> fileSize(bg.Task task) async {
    actions.add(
      RecordedDownloadTaskAction(
        DownloadTaskOperation.fileSize,
        taskId: task.taskId,
      ),
    );
    return fileSizes[task.taskId] ?? 4096;
  }

  List<DownloadTaskOperation> controlsFor(String taskId) => [
    for (final action in actions)
      if (action.taskId == taskId && action.operation.isControl)
        action.operation,
  ];

  RecordedDownloadTaskAction lastControl(String taskId) => actions.lastWhere(
    (action) => action.taskId == taskId && action.operation.isControl,
  );
}
