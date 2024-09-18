// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';

final downloadGroupCompletedProvider =
    Provider.autoDispose.family<bool, String>((ref, group) {
  return ref.watch(downloadTasksProvider).allCompleted(group);
});

final percentCompletedProvider =
    Provider.autoDispose.family<double, String>((ref, group) {
  final completed = ref.watch(downloadTasksProvider).completed(group);

  if (completed.isEmpty) return 0.0;

  final total = ref.watch(downloadTasksProvider).all(group);

  if (total.isEmpty) return 0.0;

  return completed.length / total.length;
});

final bulkdownloadProvider =
    NotifierProvider<BulkDownloadNotifier, List<BulkDownloadTask>>(
        BulkDownloadNotifier.new);

final bulkDownloadNotificationQueueProvider =
    StateProvider<Map<String, bool>>((ref) => {});

final bulkDownloadNotificationProvider = Provider<BulkDownloadNotifications>(
  (ref) => throw UnimplementedError(),
);