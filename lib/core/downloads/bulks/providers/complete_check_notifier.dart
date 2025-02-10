// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../manager.dart';
import '../types/download_session.dart';
import 'bulk_download_notifier.dart';

final taskCompleteCheckerProvider =
    NotifierProvider<CompleteCheckNotifier, void>(CompleteCheckNotifier.new);

class CompleteCheckNotifier extends Notifier<void> {
  Timer? _timer;

  @override
  void build() {
    // Cancel any existing timer
    _timer?.cancel();

    // Listen to task count
    final _ = ref.watch(bulkDownloadProvider.select((e) => e.sessions.length));

    // check if all tasks are completed every 1 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final taskUpdates = ref.read(downloadTaskUpdatesProvider);
      // final bulkTasks = ref.read(bulkdownloadProvider);
      final sessions = ref.read(bulkDownloadProvider).sessions;

      // if all bulk download tasks are completed, cancel the timer
      if (sessions
          .every((e) => e.session.status == DownloadSessionStatus.completed)) {
        _print('All sessions are completed');
        timer.cancel();
        return;
      }

      for (final session in sessions
          .where((e) => e.session.status == DownloadSessionStatus.running)) {
        var completedCount = 0;
        final sessionId = session.session.id;

        for (final update in taskUpdates.all(sessionId)) {
          if (update is TaskStatusUpdate &&
              update.status == TaskStatus.complete) {
            completedCount += 1;
          }
        }

        final completed =
            completedCount > 0 && completedCount == session.stats.totalItems;

        if (completed) {
          _print('Session $sessionId is completed, updating status');
          ref.read(bulkDownloadProvider.notifier).tryCompleteSession(
                sessionId,
              );
        }
      }
    });

    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });

    return;
  }
}

void _print(String message) {
  if (!kDebugMode) return;

  debugPrint('[Bulk Download] $message');
}
