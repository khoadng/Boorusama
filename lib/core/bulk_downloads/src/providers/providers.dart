// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../download_manager/providers.dart';
import '../../../download_manager/types.dart';
import '../data/providers.dart';
import '../types/download_record.dart';
import 'post_fetcher.dart';

final downloadGroupFailedProvider = Provider.autoDispose.family<int, String>((
  ref,
  group,
) {
  final failed = ref.watch(downloadTaskUpdatesProvider).failed(group);

  return failed.length;
});

final percentCompletedFromDbProvider = FutureProvider.autoDispose
    .family<double, String>((ref, group) async {
      final repo = await ref.watch(downloadRepositoryProvider.future);

      final completed = await repo.getRecordsBySessionId(
        group,
        status: DownloadRecordStatus.completed,
      );

      if (completed.isEmpty) return 0.0;

      final total = await ref.watch(totalDownloadCountProvider(group).future);

      if (total == null) return 0.0;

      return completed.length / total;
    });

final totalDownloadCountProvider = FutureProvider.autoDispose
    .family<int?, String>((ref, group) async {
      final repo = await ref.watch(downloadRepositoryProvider.future);

      final total = await repo.getRecordsBySessionId(group);

      return total.length;
    });

final postFetcherProvider =
    AsyncNotifierProvider.family<
      PostFetcher,
      PostFetcherState,
      PostFetcherParams
    >(PostFetcher.new);
