import 'package:background_downloader/background_downloader.dart' as bg;

import 'package:boorusama/core/downloads/downloader/types.dart' as app_download;

/// Records app-owned enqueue requests and returns stable native task IDs.
final class ControlledDownloadService implements app_download.DownloadService {
  ControlledDownloadService({String Function(int index)? taskIdBuilder})
    : _taskIdBuilder =
          taskIdBuilder ?? ((index) => 'download-flow-${index + 1}');

  final String Function(int index) _taskIdBuilder;
  final requests = <app_download.DownloadOptions>[];
  final taskIds = <String>[];
  final pausedGroups = <String>[];
  final cancelledGroups = <String>[];

  @override
  Future<app_download.DownloadResult> download(
    app_download.DownloadOptions options,
  ) async {
    final id = _taskIdBuilder(requests.length);
    requests.add(options);
    taskIds.add(id);
    return app_download.DownloadEnqueued(
      app_download.DownloadTaskInfo(
        path: options.path ?? '/fake-downloads/${options.filename}',
        id: id,
      ),
    );
  }

  bg.DownloadTask taskAt(int index, {String? group}) {
    final options = requests[index];
    final id = taskIds[index];
    return bg.DownloadTask(
      taskId: id,
      url: options.url,
      filename: options.filename,
      group: group ?? options.metadata?.group ?? bg.FileDownloader.defaultGroup,
      metaData: options.metadata?.toJsonString() ?? '',
    );
  }

  List<bg.DownloadTask> createBackgroundTasks(String group) => [
    for (var index = 0; index < requests.length; index++)
      taskAt(index, group: group),
  ];

  @override
  Future<void> pauseAll(String group) async {
    pausedGroups.add(group);
  }

  @override
  Future<void> resumeAll(String group) async {}

  @override
  Future<bool> cancelAll(String group) async {
    cancelledGroups.add(group);
    return true;
  }
}
