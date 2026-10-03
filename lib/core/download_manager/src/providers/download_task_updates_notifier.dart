// Riverpod owns this controller and closes it from the provider's onDispose.
// ignore_for_file: close_sinks

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../downloads/background/types.dart';
import '../data/file_downloader_task_client.dart';
import '../types/download_task_update.dart';

final downloadTaskUpdatesProvider =
    NotifierProvider<DownloadTaskUpdatesNotifier, DownloadTaskUpdateState>(
      DownloadTaskUpdatesNotifier.new,
    );

final downloadTaskStreamControllerProvider =
    Provider<StreamController<TaskUpdate>>((ref) {
      final controller = StreamController<TaskUpdate>.broadcast();

      ref.onDispose(() {
        unawaited(controller.close());
      });

      return controller;
    });

final downloadTaskStreamProvider = StreamProvider<TaskUpdate>((ref) {
  final controller = ref.watch(downloadTaskStreamControllerProvider);
  return controller.stream;
});

final downloadTaskEventIngressProvider = Provider<DownloadTaskEventIngress>(
  (ref) => DownloadTaskEventIngress(
    updateSnapshot: (update) =>
        ref.read(downloadTaskUpdatesProvider.notifier).addOrUpdate(update),
    publishStream: (update) =>
        ref.read(downloadTaskStreamControllerProvider).add(update),
  ),
  name: 'downloadTaskEventIngressProvider',
);

final taskFileSizeResolverProvider = FutureProvider.autoDispose
    .family<int, Task>((ref, task) {
      return ref.watch(downloadTaskClientProvider).fileSize(task);
    });

/// Publishes each platform event to both the retained snapshot and the stream.
/// The provider owns the broadcast controller; this ingress only writes to it.
final class DownloadTaskEventIngress {
  const DownloadTaskEventIngress({
    required void Function(TaskUpdate update) updateSnapshot,
    required void Function(TaskUpdate update) publishStream,
  }) : _updateSnapshot = updateSnapshot,
       _publishStream = publishStream;

  final void Function(TaskUpdate update) _updateSnapshot;
  final void Function(TaskUpdate update) _publishStream;

  void publish(TaskUpdate update) {
    _updateSnapshot(update);
    _publishStream(update);
  }
}

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
