// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/types/bulk_download_session.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session_stats.dart';
import 'package:boorusama/core/download_activity/providers.dart';
import 'package:boorusama/core/download_activity/types.dart';
import 'package:boorusama/core/downloads/downloader/src/types/metadata.dart';
import 'package:boorusama/core/downloads/downloader/types.dart' as app;

import 'package:boorusama/core/bulk_downloads/src/types/download_task.dart'
    as bulk;

void main() {
  group('normal download activity', () {
    final task = DownloadTask(
      taskId: 'normal-1',
      url: 'https://example.test/image.jpg',
      filename: 'image.jpg',
      metaData: const DownloaderMetadata(
        thumbnailUrl: 'https://example.test/thumb.jpg',
        fileSize: 42,
        siteUrl: 'https://example.test',
        group: null,
      ).toJsonString(),
    );

    final cases = {
      TaskStatus.enqueued: DownloadActivityPhase.queued,
      TaskStatus.running: DownloadActivityPhase.running,
      TaskStatus.complete: DownloadActivityPhase.completed,
      TaskStatus.notFound: DownloadActivityPhase.failed,
      TaskStatus.failed: DownloadActivityPhase.failed,
      TaskStatus.canceled: DownloadActivityPhase.cancelled,
      TaskStatus.waitingToRetry: DownloadActivityPhase.waitingToRetry,
      TaskStatus.paused: DownloadActivityPhase.paused,
    };

    for (final entry in cases.entries) {
      test('maps ${entry.key.name} to ${entry.value.name}', () {
        final activity = downloadActivityFromTaskUpdate(
          TaskStatusUpdate(task, entry.key),
        );

        expect(activity.id, 'normal-1');
        expect(activity.kind, DownloadActivityKind.single);
        expect(activity.phase, entry.value);
        expect(activity.label, 'image.jpg');
        expect(activity.thumbnailUrl, 'https://example.test/thumb.jpg');
      });
    }

    test('preserves native progress', () {
      final activity = downloadActivityFromTaskUpdate(
        TaskProgressUpdate(task, 0.625),
      );

      expect(activity.phase, DownloadActivityPhase.running);
      expect(activity.progress, 0.625);
    });

    test('keeps a Wi-Fi task waiting while Wi-Fi is unavailable', () {
      final activity = downloadActivityFromTaskUpdate(
        TaskStatusUpdate(
          task.copyWith(requiresWiFi: true),
          TaskStatus.enqueued,
        ),
        connectedToWifi: false,
      );

      expect(activity.phase, DownloadActivityPhase.waitingForWifi);
    });
  });

  group('bulk download activity', () {
    final cases = {
      DownloadSessionStatus.pending: DownloadActivityPhase.queued,
      DownloadSessionStatus.dryRun: DownloadActivityPhase.preparing,
      DownloadSessionStatus.running: DownloadActivityPhase.running,
      DownloadSessionStatus.completed: DownloadActivityPhase.completed,
      DownloadSessionStatus.allSkipped: DownloadActivityPhase.skipped,
      DownloadSessionStatus.failed: DownloadActivityPhase.failed,
      DownloadSessionStatus.paused: DownloadActivityPhase.paused,
      DownloadSessionStatus.suspended: DownloadActivityPhase.suspended,
      DownloadSessionStatus.cancelled: DownloadActivityPhase.cancelled,
    };

    for (final entry in cases.entries) {
      test('maps ${entry.key.name} to ${entry.value.name}', () {
        final activity = downloadActivityFromBulkSession(
          _bulkSession(entry.key),
          progress: 0.4,
        );

        expect(activity.id, 'session-1');
        expect(activity.kind, DownloadActivityKind.bulk);
        expect(activity.phase, entry.value);
        expect(activity.label, 'cat dog');
        final completed =
            entry.key == DownloadSessionStatus.completed ||
            entry.key == DownloadSessionStatus.allSkipped;
        expect(activity.progress, completed ? 1 : 0.4);
        expect(activity.completedItems, completed ? 10 : 4);
        expect(activity.totalItems, 10);
      });
    }
  });

  test('records immediate completion and failure outcomes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(
      immediateDownloadActivitiesProvider.notifier,
    );

    notifier
      ..recordImmediateOutcome(
        const app.DownloadCompleted(
          app.DownloadTaskInfo(path: '/downloads/cached.jpg', id: 'cached-1'),
          source: app.DownloadCompletionSource.cache,
        ),
        label: 'cached.jpg',
      )
      ..recordImmediateOutcome(
        app.DownloadFailure(
          app.GenericDownloadError(
            savedPath: const None(),
            fileName: 'failed.jpg',
            message: 'network failed',
          ),
        ),
        label: 'failed.jpg',
      );

    final activities = container.read(immediateDownloadActivitiesProvider);
    expect(activities, hasLength(2));
    expect(activities.first.phase, DownloadActivityPhase.failed);
    expect(
      activities.last.completionSource,
      app.DownloadCompletionSource.cache,
    );
  });
}

BulkDownloadSession _bulkSession(DownloadSessionStatus status) {
  final task = bulk.DownloadTask(
    id: 'task-1',
    path: '/downloads',
    skipIfExists: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
    perPage: 20,
    concurrency: 2,
    tags: 'cat dog',
  );
  final session = DownloadSession(
    id: 'session-1',
    taskId: task.id,
    startedAt: DateTime(2025),
    currentPage: 1,
    status: status,
    auth: const DownloadSessionAuth(
      authHash: null,
      siteUrl: 'https://example.test',
    ),
    task: task,
  );

  return BulkDownloadSession(
    task: task,
    session: session,
    stats: const DownloadSessionStats(
      id: null,
      sessionId: 'session-1',
      totalItems: 10,
    ),
  );
}
