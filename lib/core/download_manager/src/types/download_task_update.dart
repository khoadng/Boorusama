// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../downloads/background/types.dart';

class DownloadTaskUpdateState extends Equatable {
  const DownloadTaskUpdateState({
    required Map<String, List<TaskUpdate>> tasks,
  }) : _tasks = tasks;
  final Map<String, List<TaskUpdate>> _tasks;

  DownloadTaskUpdateState updateWith(String group, List<TaskUpdate> updates) {
    return DownloadTaskUpdateState(
      tasks: {
        ..._tasks,
        group: updates,
      },
    );
  }

  DownloadTaskUpdateState? clear(String group) {
    if (!_tasks.containsKey(group)) return null;

    final removed = _tasks.remove(group);
    if (removed == null) return null;

    return DownloadTaskUpdateState(
      tasks: {
        ..._tasks,
      },
    );
  }

  @override
  List<Object?> get props => [_tasks];
}

extension DownloadTaskStateX on DownloadTaskUpdateState {
  bool allCompleted(String group) {
    final items = completed(group);

    return items.length == all(group).length;
  }

  List<TaskUpdate> all(String group) => _tasks[group] ?? [];

  Map<String, List<TaskUpdate>> get tasks => {..._tasks};

  List<TaskUpdate> completed(String group) => all(group)
      .whereType<TaskStatusUpdate>()
      .where((e) => e.status == TaskStatus.complete)
      .toList();

  List<TaskUpdate> inProgress(String group) =>
      all(group).whereType<TaskProgressUpdate>().toList();

  List<TaskUpdate> pending(String group) => all(group)
      .whereType<TaskStatusUpdate>()
      .where((e) => e.status == TaskStatus.enqueued)
      .toList();

  List<TaskUpdate> failed(String group) => all(group)
      .whereType<TaskStatusUpdate>()
      .where(
        (e) => e.status == TaskStatus.failed || e.status == TaskStatus.notFound,
      )
      .toList();

  List<TaskUpdate> canceled(String group) => all(group)
      .whereType<TaskStatusUpdate>()
      .where((e) => e.status == TaskStatus.canceled)
      .toList();

  List<TaskUpdate> paused(String group) => all(group)
      .whereType<TaskStatusUpdate>()
      .where((e) => e.status == TaskStatus.paused)
      .toList();
}
