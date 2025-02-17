// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/download_configs.dart';
import '../types/download_options.dart';
import '../types/download_task.dart';
import '../types/saved_download_task.dart';
import 'bulk_download_notifier.dart';
import 'providers.dart';

class SavedDownloadTasksNotifier
    extends AsyncNotifier<List<SavedDownloadTask>> {
  @override
  Future<List<SavedDownloadTask>> build() async {
    final repo = await ref.watch(downloadRepositoryProvider.future);
    final tasks = await repo.getSavedTasks();

    return tasks;
  }

  Future<bool> createFromOptions(DownloadOptions options) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);
    final success = await bulkNofifier.createSavedTaskFromOptions(options);

    if (success) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<bool> create(DownloadTask task) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);
    final success = await bulkNofifier.createSavedTask(
      task,
      name: task.tags,
    );

    if (success) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<bool> duplicate(SavedDownloadTask task) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);
    final options = DownloadOptions.fromTask(task.task);

    final success = await bulkNofifier.createSavedTaskFromOptions(options);

    if (success) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<void> delete(SavedDownloadTask task) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);
    await bulkNofifier.deleteSavedTask(task.id);

    ref.invalidateSelf();
  }

  Future<void> run(
    SavedDownloadTask task, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);
    await bulkNofifier.runSavedTask(
      task,
      downloadConfigs: downloadConfigs,
    );

    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final savedDownloadTasksProvider =
    AsyncNotifierProvider<SavedDownloadTasksNotifier, List<SavedDownloadTask>>(
  SavedDownloadTasksNotifier.new,
);
