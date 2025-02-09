// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../manager/download_task_update.dart';
import '../../manager/download_task_updates_notifier.dart';
import '../types/download_options.dart';
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
