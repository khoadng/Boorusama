// Dart imports:
import 'dart:async';

// Package imports:
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../downloads/background/types.dart';
import '../types/download_task_update.dart';

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

final taskFileSizeResolverProvider = FutureProvider.autoDispose
    .family<int, Task>((ref, task) async {
      final path = await task.filePath();
      final file = XFile(path);

      return file.length();
    });

extension TaskX on Task {
  bool get isDefaultGroup => group == FileDownloader.defaultGroup;
}

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
