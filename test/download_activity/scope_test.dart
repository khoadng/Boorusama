// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/download_activity/activity.dart';
import 'package:boorusama/core/downloads/downloader/types.dart';

import 'support/download_activity_scope_harness.dart';

void main() {
  testWidgets('requests notification permission once on first activity', (
    tester,
  ) async {
    final harness = DownloadActivityScopeHarness();
    addTearDown(harness.dispose);
    await harness.pump(tester);

    harness.setActivities([
      _bulkActivity(
        phase: DownloadActivityPhase.preparing,
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(harness.permissionRequestCount, 1);

    harness.setActivities([
      _bulkActivity(
        phase: DownloadActivityPhase.running,
        completed: 1,
        total: 4,
      ),
      _bulkActivity(
        id: 'bulk-2',
        phase: DownloadActivityPhase.preparing,
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(harness.permissionRequestCount, 1);
  });

  testWidgets(
    'disabling notifications cancels bulk and suppresses later rendering',
    (tester) async {
      final harness = DownloadActivityScopeHarness();
      addTearDown(harness.dispose);
      await harness.pump(tester);

      harness.setActivities([
        _bulkActivity(
          phase: DownloadActivityPhase.running,
          completed: 2,
          total: 4,
        ),
      ]);
      await tester.pump();
      await tester.pump();

      harness.clearNotificationEvents();
      harness.setNotificationsEnabled(false);
      await tester.pump();
      await tester.pump();

      expect(harness.notificationEvents, contains('configure:false'));
      expect(harness.notificationEvents, contains('cancelAllBulk'));
      expect(harness.notificationEvents, contains('cancelBulk:bulk-1'));

      harness.clearNotificationEvents();
      harness.setActivities([
        _bulkActivity(
          id: 'bulk-2',
          phase: DownloadActivityPhase.preparing,
        ),
      ]);
      await tester.pump();
      await tester.pump();

      expect(harness.notificationEvents, isEmpty);
    },
  );

  testWidgets(
    'only immediate completion outcomes use local single notifications',
    (tester) async {
      final harness = DownloadActivityScopeHarness();
      addTearDown(harness.dispose);
      await harness.pump(tester);

      harness.setActivities([
        _singleCompletion(
          id: 'network',
          source: DownloadCompletionSource.network,
        ),
      ]);
      await tester.pump();
      await tester.pump();

      expect(
        harness.notificationEvents.where(
          (event) => event.startsWith('singleComplete:'),
        ),
        isEmpty,
      );

      harness.setActivities([
        _singleCompletion(
          id: 'network',
          source: DownloadCompletionSource.network,
        ),
        _singleCompletion(
          id: 'cache',
          source: DownloadCompletionSource.cache,
        ),
        const DownloadActivity(
          id: 'existing',
          kind: DownloadActivityKind.single,
          phase: DownloadActivityPhase.skipped,
          label: 'existing.jpg',
          completionSource: DownloadCompletionSource.alreadyPresent,
        ),
      ]);
      await tester.pump();
      await tester.pump();

      expect(
        harness.notificationEvents.where(
          (event) => event.startsWith('singleComplete:'),
        ),
        [
          'singleComplete:cache.jpg:true:null',
          'singleComplete:existing.jpg:true:existing.jpg was already saved',
        ],
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('serializes progress before bulk completion', (tester) async {
    final harness = DownloadActivityScopeHarness();
    addTearDown(harness.dispose);
    await harness.pump(tester);

    final progressGate = Completer<void>();
    harness.setProgressGate(progressGate);
    harness.setActivities([
      _bulkActivity(
        phase: DownloadActivityPhase.running,
        completed: 3,
        total: 4,
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(harness.notificationEvents, contains('bulkProgress:start'));

    harness.setActivities([
      _bulkActivity(
        phase: DownloadActivityPhase.completed,
        completed: 4,
        total: 4,
      ),
    ]);
    await tester.pump();

    expect(
      harness.notificationEvents,
      isNot(contains('bulkComplete:bulk-1:4')),
    );

    progressGate.complete();
    await tester.pump();
    await tester.pump();

    expect(
      harness.notificationEvents,
      containsAllInOrder([
        'bulkProgress:start',
        'bulkProgress:end',
        'cancelBulk:bulk-1',
        'bulkComplete:bulk-1:4',
      ]),
    );
  });
}

DownloadActivity _bulkActivity({
  String id = 'bulk-1',
  required DownloadActivityPhase phase,
  int? completed,
  int? total,
}) {
  return DownloadActivity(
    id: id,
    kind: DownloadActivityKind.bulk,
    phase: phase,
    label: 'Bulk download',
    completedItems: completed,
    totalItems: total,
    progress: completed != null && total != null ? completed / total : null,
  );
}

DownloadActivity _singleCompletion({
  required String id,
  required DownloadCompletionSource source,
}) {
  return DownloadActivity(
    id: id,
    kind: DownloadActivityKind.single,
    phase: DownloadActivityPhase.completed,
    label: '$id.jpg',
    progress: 1,
    completionSource: source,
  );
}
