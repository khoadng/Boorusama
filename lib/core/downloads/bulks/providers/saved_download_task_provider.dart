// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/saved_download_task.dart';
import 'providers.dart';

final savedDownloadTasksProvider =
    FutureProvider.autoDispose<List<SavedDownloadTask>>((ref) async {
  final repo = await ref.watch(downloadRepositoryProvider.future);
  return repo.getSavedTasks();
});
