// Dart imports:
import 'dart:async';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'download_task_update.dart';

final downloadTaskUpdatesProvider =
    NotifierProvider<DownloadTaskUpdatesNotifier, DownloadTaskUpdateState>(
  DownloadTaskUpdatesNotifier.new,
);

final downloadTaskStreamControllerProvider =
    Provider<StreamController<TaskUpdate>>((ref) {
  final controller = StreamController<TaskUpdate>.broadcast();

  ref.onDispose(() {
    controller.close();
  });

  return controller;
});

final downloadTaskStreamProvider = StreamProvider<TaskUpdate>((ref) {
  final controller = ref.watch(downloadTaskStreamControllerProvider);

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

class DownloadTaskUpdatesNotifier extends Notifier<DownloadTaskUpdateState> {
  @override
  DownloadTaskUpdateState build() {
    return const DownloadTaskUpdateState(
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
