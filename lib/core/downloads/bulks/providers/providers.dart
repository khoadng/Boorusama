// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../manager/download_task_update.dart';
import '../../manager/download_task_updates_notifier.dart';
import '../data/download_repository_provider.dart';
import '../types/download_options.dart';
import '../types/download_record.dart';
import '../types/download_repository.dart';
import 'create_bulk_download_notifier.dart';

final downloadGroupFailedProvider =
    Provider.autoDispose.family<int, String>((ref, group) {
  final failed = ref.watch(downloadTaskUpdatesProvider).failed(group);

  return failed.length;
});

final createBulkDownloadProvider =
    NotifierProvider.autoDispose<CreateBulkDownload2Notifier, DownloadOptions>(
  CreateBulkDownload2Notifier.new,
  dependencies: [
    createBulkDownloadInitialTagsProvider,
    bulkDownloadQualityProvider,
  ],
);

final downloadRepositoryProvider =
    FutureProvider<DownloadRepository>((ref) async {
  final repo = await ref.watch(internalDownloadRepositoryProvider.future);

  return repo;
});

final percentCompletedFromDbProvider =
    FutureProvider.autoDispose.family<double, String>((ref, group) async {
  final repo = await ref.watch(downloadRepositoryProvider.future);

  final completed = await repo.getRecordsBySessionIdAndStatus(
    group,
    DownloadRecordStatus.completed,
  );

  if (completed.isEmpty) return 0.0;

  final total = await repo.getRecordsBySessionId(group);

  if (total.isEmpty) return 0.0;

  return completed.length / total.length;
});

final percentCompletedProvider =
    Provider.autoDispose.family<double, String>((ref, group) {
  final completed = ref.watch(downloadTaskUpdatesProvider).completed(group);

  if (completed.isEmpty) return 0.0;

  final total = ref.watch(downloadTaskUpdatesProvider).all(group);

  if (total.isEmpty) return 0.0;

  return completed.length / total.length;
});
