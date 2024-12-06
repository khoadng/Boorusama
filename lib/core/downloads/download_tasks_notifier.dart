// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadTaskState extends Equatable {
  const DownloadTaskState({
    required Map<String, List<TaskUpdate>> tasks,
  }) : _tasks = tasks;
  final Map<String, List<TaskUpdate>> _tasks;

  DownloadTaskState _updateWith(String group, List<TaskUpdate> updates) {
    return DownloadTaskState(
      tasks: {
        ..._tasks,
        group: updates,
      },
    );
  }

  DownloadTaskState? _clear(String group) {
    if (!_tasks.containsKey(group)) return null;

    final removed = _tasks.remove(group);
    if (removed == null) return null;

    return DownloadTaskState(
      tasks: {
        ..._tasks,
      },
    );
  }

  @override
  List<Object?> get props => [_tasks];
}

extension DownloadTaskStateX on DownloadTaskState {
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
      .where((e) =>
          e.status == TaskStatus.failed || e.status == TaskStatus.notFound)
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

final downloadTasksProvider =
    NotifierProvider<DownloadTasksNotifier, DownloadTaskState>(
        DownloadTasksNotifier.new);

class DownloadTasksNotifier extends Notifier<DownloadTaskState> {
  @override
  DownloadTaskState build() {
    return const DownloadTaskState(
      tasks: {},
    );
  }

  void clear(
    String group, {
    void Function()? onFailed,
  }) {
    final newState = state._clear(group);

    if (newState != null) {
      state = newState;
    } else {
      onFailed?.call();
    }
  }

  void addOrUpdate(TaskUpdate update) {
    final totalTasks = state._tasks;
    final group = update.task.group;

    final updates = totalTasks[group] ?? [];

    final index = updates.indexWhere((element) => element.task == update.task);

    if (index == -1) {
      updates.add(update);
    } else {
      updates[index] = update;
    }

    state = state._updateWith(group, updates);
  }
}
