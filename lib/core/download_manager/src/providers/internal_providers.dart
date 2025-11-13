// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../downloads/background/types.dart';
import '../types/download_filter.dart';
import '../types/download_task_update.dart';
import 'download_task_updates_notifier.dart';

final downloadFilterProvider = StateProvider.family<DownloadFilter, String?>((
  ref,
  initialFilter,
) {
  return convertFilter(initialFilter);
});

final downloadGroupProvider = Provider<String>(
  (ref) => FileDownloader.defaultGroup,
  name: 'downloadGroupProvider',
);

final downloadFilteredProvider = Provider.family<List<TaskUpdate>, String?>(
  (ref, initialFilter) {
    final filter = ref.watch(downloadFilterProvider(initialFilter));
    final group = ref.watch(downloadGroupProvider);
    final state = ref.watch(downloadTaskUpdatesProvider);

    return switch (filter) {
      DownloadFilter.pending => state.pending(group),
      DownloadFilter.paused => state.paused(group),
      DownloadFilter.inProgress => state.inProgress(group),
      DownloadFilter.completed => state.completed(group),
      DownloadFilter.failed => state.failed(group),
      DownloadFilter.canceled => state.canceled(group),
    };
  },
  dependencies: [
    downloadGroupProvider,
  ],
);
