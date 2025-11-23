// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../data/providers.dart';
import '../types/download_configs.dart';
import '../types/download_options.dart';
import '../types/download_task.dart';
import '../types/saved_download_task.dart';
import 'bulk_download_notifier.dart';

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
    final savedTask = await bulkNofifier.createSavedTaskFromOptions(options);

    final success = savedTask != null;

    if (success) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<bool> create(DownloadTask task) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);
    final savedTask = await bulkNofifier.createSavedTask(
      task,
      name: task.prettyTags,
    );

    final success = savedTask != null;

    if (success) {
      ref.invalidateSelf();
    }

    return success;
  }

  Future<void> edit(SavedDownloadTask task) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);
    await bulkNofifier.editSavedTask(task);

    ref.invalidateSelf();
  }

  Future<bool> duplicate(SavedDownloadTask task) async {
    final bulkNofifier = ref.read(bulkDownloadProvider.notifier);

    final savedTask = await bulkNofifier.createSavedTask(task.task);

    final success = savedTask != null;

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
