// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'download_task.dart';

final downloadTasksProvider =
    NotifierProvider<DownloadTasksNotifier, DownloadTaskState>(
  DownloadTasksNotifier.new,
);

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
    final newState = state.clear(group);

    if (newState != null) {
      state = newState;
    } else {
      onFailed?.call();
    }
  }

  void addOrUpdate(TaskUpdate update) {
    final totalTasks = state.tasks;
    final group = update.task.group;

    final updates = totalTasks[group] ?? [];

    final index = updates.indexWhere((element) => element.task == update.task);

    if (index == -1) {
      updates.add(update);
    } else {
      updates[index] = update;
    }

    state = state.updateWith(group, updates);
  }
}
