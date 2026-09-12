// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/networking/network_provider.dart';
import '../bulk_downloads/src/providers/bulk_download_notifier.dart';
import '../bulk_downloads/src/providers/bulk_progress.dart';
import '../bulk_downloads/src/types/bulk_download_session.dart';
import '../bulk_downloads/src/types/download_session.dart';
import '../download_manager/providers.dart';
import '../download_manager/types.dart';
import '../downloads/background/types.dart';
import '../downloads/downloader/types.dart';
import 'types.dart';

final immediateDownloadActivitiesProvider =
    NotifierProvider<
      ImmediateDownloadActivitiesNotifier,
      List<DownloadActivity>
    >(ImmediateDownloadActivitiesNotifier.new);

class ImmediateDownloadActivitiesNotifier
    extends Notifier<List<DownloadActivity>> {
  @override
  List<DownloadActivity> build() => const [];

  void record(DownloadActivity activity) {
    state = [
      activity,
      ...state.where((existing) => existing.id != activity.id),
    ].take(100).toList(growable: false);
  }

  void recordImmediateOutcome(
    DownloadResult result, {
    required String label,
    String? thumbnailUrl,
  }) {
    final now = DateTime.now();
    final activity = switch (result) {
      DownloadEnqueued() => null,
      DownloadCompleted(:final info, :final source) => DownloadActivity(
        id: info.id,
        kind: DownloadActivityKind.single,
        phase: DownloadActivityPhase.completed,
        label: label,
        progress: 1,
        thumbnailUrl: thumbnailUrl,
        completedAt: now,
        completionSource: source,
      ),
      DownloadSkipped(:final info) => DownloadActivity(
        id: info.id,
        kind: DownloadActivityKind.single,
        phase: DownloadActivityPhase.skipped,
        label: label,
        progress: 1,
        thumbnailUrl: thumbnailUrl,
        completedAt: now,
        completionSource: DownloadCompletionSource.alreadyPresent,
      ),
      DownloadFailure(:final error) => DownloadActivity(
        id: 'failed_${now.microsecondsSinceEpoch}',
        kind: DownloadActivityKind.single,
        phase: DownloadActivityPhase.failed,
        label: label,
        thumbnailUrl: thumbnailUrl,
        error: error.getErrorMessage(),
        completedAt: now,
      ),
    };

    if (activity != null) record(activity);
  }
}

final downloadActivitiesProvider = Provider<List<DownloadActivity>>((ref) {
  final taskUpdates = ref.watch(downloadTaskUpdatesProvider);
  final bulkSessions = ref.watch(bulkDownloadSessionsProvider);
  final bulkProgress =
      ref.watch(bulkDownloadProgressProvider).valueOrNull ?? {};
  final immediate = ref.watch(immediateDownloadActivitiesProvider);
  final connectedToWifi = ref.watch(connectedToWifiProvider);

  final normal =
      taskUpdates.tasks[FileDownloader.defaultGroup]
          ?.map(
            (update) => downloadActivityFromTaskUpdate(
              update,
              connectedToWifi: connectedToWifi,
            ),
          )
          .toList() ??
      const <DownloadActivity>[];
  final bulk = bulkSessions
      .map(
        (session) => downloadActivityFromBulkSession(
          session,
          progress: bulkProgress[session.id],
        ),
      )
      .toList();

  return [
    ...immediate.where(
      (activity) => normal.every((normal) => normal.id != activity.id),
    ),
    ...normal,
    ...bulk,
  ];
});

DownloadActivity downloadActivityFromTaskUpdate(
  TaskUpdate update, {
  bool connectedToWifi = true,
}) {
  final metadata = DownloaderMetadata.fromJsonString(update.task.metaData);
  final phase = switch (update) {
    TaskProgressUpdate() => DownloadActivityPhase.running,
    TaskStatusUpdate(:final status) => switch (status) {
      TaskStatus.enqueued when update.task.requiresWiFi && !connectedToWifi =>
        DownloadActivityPhase.waitingForWifi,
      TaskStatus.enqueued => DownloadActivityPhase.queued,
      TaskStatus.running => DownloadActivityPhase.running,
      TaskStatus.complete => DownloadActivityPhase.completed,
      TaskStatus.notFound || TaskStatus.failed => DownloadActivityPhase.failed,
      TaskStatus.canceled => DownloadActivityPhase.cancelled,
      TaskStatus.waitingToRetry => DownloadActivityPhase.waitingToRetry,
      TaskStatus.paused => DownloadActivityPhase.paused,
    },
  };

  return DownloadActivity(
    id: update.task.taskId,
    kind: DownloadActivityKind.single,
    phase: phase,
    label: update.task.filename,
    progress: switch (update) {
      TaskProgressUpdate(:final progress) when progress >= 0 => progress,
      TaskStatusUpdate(:final status) when status == TaskStatus.complete => 1,
      _ => null,
    },
    thumbnailUrl: metadata.thumbnailUrl,
    error: switch (update) {
      TaskStatusUpdate(:final exception?) => exception.description,
      _ => null,
    },
    completionSource: phase == DownloadActivityPhase.completed
        ? DownloadCompletionSource.network
        : null,
  );
}

DownloadActivity downloadActivityFromBulkSession(
  BulkDownloadSession value, {
  double? progress,
}) {
  final session = value.session;
  final total = value.stats.totalItems;
  final phase = switch (session.status) {
    DownloadSessionStatus.pending => DownloadActivityPhase.queued,
    DownloadSessionStatus.dryRun => DownloadActivityPhase.preparing,
    DownloadSessionStatus.running => DownloadActivityPhase.running,
    DownloadSessionStatus.completed => DownloadActivityPhase.completed,
    DownloadSessionStatus.allSkipped => DownloadActivityPhase.skipped,
    DownloadSessionStatus.failed => DownloadActivityPhase.failed,
    DownloadSessionStatus.paused => DownloadActivityPhase.paused,
    DownloadSessionStatus.suspended => DownloadActivityPhase.suspended,
    DownloadSessionStatus.cancelled => DownloadActivityPhase.cancelled,
  };

  return DownloadActivity(
    id: session.id,
    kind: DownloadActivityKind.bulk,
    phase: phase,
    label: value.task.prettyTags ?? 'Download',
    progress: progress,
    completedItems: progress == null ? null : (progress * total).round(),
    totalItems: total,
    thumbnailUrl: value.stats.coverUrl,
    error: session.error,
    startedAt: session.startedAt,
    completedAt: session.completedAt,
  );
}
