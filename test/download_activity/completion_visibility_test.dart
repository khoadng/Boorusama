import 'package:boorusama/core/bulk_downloads/providers.dart';
import 'package:boorusama/core/bulk_downloads/types.dart';
import 'package:boorusama/foundation/networking/network_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/download_activity_scope_harness.dart';

void main() {
  testWidgets(
    'bulk completion survives active-session removal before a frame',
    (
      tester,
    ) async {
      final downloads = _BulkDownloads();
      final harness = DownloadActivityScopeHarness(
        useRealActivities: true,
        overrides: [
          bulkDownloadProvider.overrideWith(() => downloads),
          bulkDownloadProgressProvider.overrideWith(_Progress.new),
          connectedToWifiProvider.overrideWithValue(true),
        ],
      );
      addTearDown(harness.dispose);
      await harness.pump(tester);
      await tester.pump();

      final task = DownloadTask(
        id: 'task',
        path: '/downloads',
        skipIfExists: false,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        perPage: 12,
        concurrency: 2,
      );
      final running = BulkDownloadSession(
        task: task,
        session: DownloadSession(
          id: 'batch-12',
          taskId: task.id,
          startedAt: DateTime(2026),
          currentPage: 1,
          status: DownloadSessionStatus.running,
          auth: const DownloadSessionAuth(authHash: null, siteUrl: null),
        ),
        stats: const DownloadSessionStats(
          id: null,
          sessionId: 'batch-12',
          totalItems: 12,
        ),
      );
      downloads.replace(BulkDownloadState(sessions: [running]));
      await tester.pump();
      await tester.pump();
      expect(harness.notificationEvents, contains('bulkProgress:end'));
      harness.clearNotificationEvents();

      final completed = running.copyWith(
        session: running.session.copyWith(
          status: DownloadSessionStatus.completed,
        ),
      );
      downloads.replace(BulkDownloadState(sessions: [completed]));
      downloads.replace(BulkDownloadState(completedSessions: [completed]));
      await tester.pump();
      await tester.pump();

      expect(harness.notificationEvents, [
        'cancelBulk:batch-12',
        'bulkComplete:batch-12:12',
      ]);
      harness.clearNotificationEvents();
      await tester.pump();
      expect(harness.notificationEvents, isEmpty);
    },
  );
}

class _BulkDownloads extends BulkDownloadNotifier {
  @override
  BulkDownloadState build() => const BulkDownloadState();

  void replace(BulkDownloadState value) => state = value;
}

class _Progress extends BulkDownloadProgressNotifier {
  @override
  Future<Map<String, double>> build() async => {'batch-12': 8 / 12};
}
