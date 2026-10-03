// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/download_manager/providers.dart';
import 'package:boorusama/core/download_manager/types.dart';

void main() {
  test('every update to an already tracked group reaches listeners', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final task = DownloadTask(taskId: 'task-1', url: 'https://file.test/1');
    final snapshots = <DownloadTaskUpdateState>[];
    container.listen(
      downloadTaskUpdatesProvider,
      (_, next) => snapshots.add(next),
    );
    final notifier = container.read(downloadTaskUpdatesProvider.notifier);

    notifier
      ..addOrUpdate(TaskStatusUpdate(task, TaskStatus.running))
      ..addOrUpdate(TaskProgressUpdate(task, 0.5))
      ..addOrUpdate(TaskStatusUpdate(task, TaskStatus.complete));

    expect(snapshots, hasLength(3));
    expect(
      snapshots.map((state) => state.tasks[task.group]!.single),
      [
        isA<TaskStatusUpdate>().having(
          (u) => u.status,
          'status',
          TaskStatus.running,
        ),
        isA<TaskProgressUpdate>().having((u) => u.progress, 'progress', 0.5),
        isA<TaskStatusUpdate>().having(
          (u) => u.status,
          'status',
          TaskStatus.complete,
        ),
      ],
    );
  });
}
