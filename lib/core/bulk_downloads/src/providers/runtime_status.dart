// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BulkDownloadRuntimeStage {
  resolvingProtectedLink,
  waitingBeforeRequest,
  waitingBeforeDownload,
  waitingForCurrentDownload,
  waitingForProtectionRetry,
  backingOff,
}

class BulkDownloadRuntimeStatus extends Equatable {
  const BulkDownloadRuntimeStatus({
    required this.stage,
    this.remaining,
    this.page,
    this.index,
  });

  final BulkDownloadRuntimeStage stage;
  final Duration? remaining;
  final int? page;
  final int? index;

  @override
  List<Object?> get props => [stage, remaining, page, index];
}

final bulkDownloadRuntimeStatusProvider =
    NotifierProvider<
      BulkDownloadRuntimeStatusNotifier,
      Map<String, BulkDownloadRuntimeStatus>
    >(BulkDownloadRuntimeStatusNotifier.new);

class BulkDownloadRuntimeStatusNotifier
    extends Notifier<Map<String, BulkDownloadRuntimeStatus>> {
  @override
  Map<String, BulkDownloadRuntimeStatus> build() => const {};

  void set(String sessionId, BulkDownloadRuntimeStatus status) {
    state = {
      ...state,
      sessionId: status,
    };
  }

  void clear(String sessionId) {
    if (!state.containsKey(sessionId)) return;

    state = {
      for (final entry in state.entries)
        if (entry.key != sessionId) entry.key: entry.value,
    };
  }
}
