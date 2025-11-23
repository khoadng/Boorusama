// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../data/providers.dart';
import '../types/download_record.dart';

final bulkDownloadProgressProvider =
    AsyncNotifierProvider<BulkDownloadProgressNotifier, Map<String, double>>(
      BulkDownloadProgressNotifier.new,
    );

class BulkDownloadProgressNotifier extends AsyncNotifier<Map<String, double>> {
  @override
  Future<Map<String, double>> build() {
    // Initialize progress mapping from persistent storage.
    return _initProgress();
  }

  Future<Map<String, double>> _initProgress() async {
    final repo = await ref.watch(downloadRepositoryProvider.future);
    final sessions = await repo.getActiveSessions();

    final map = <String, double>{};

    for (final session in sessions) {
      final completedCount = await repo.getRecordsCountBySessionId(
        session.id,
        status: DownloadRecordStatus.completed,
      );
      final totalCount = await repo.getRecordsCountBySessionId(session.id);

      final progress = _calculateProgress(completedCount, totalCount);

      map[session.id] = progress;
    }

    return map;
  }

  Future<void> updateProgress(String sessionId, double progress) async {
    final currentState = await future;
    state = AsyncData({
      ...currentState,
      sessionId: progress,
    });
  }

  void updateProgressFromCounts(String sessionId, int completed, int total) {
    final progress = _calculateProgress(completed, total);

    updateProgress(sessionId, progress);
  }

  Future<void> removeSession(String sessionId) async {
    final currentState = await future;
    state = AsyncData({
      ...currentState..remove(sessionId),
    });
  }

  double _calculateProgress(int completed, int total) {
    return total <= 0 ? 0.0 : completed / total;
  }
}
