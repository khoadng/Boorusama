// Dart imports:
import 'dart:async';

// Package imports:
import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/providers.dart';
import 'package:boorusama/core/bulk_downloads/src/data/repo_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/pages/bulk_download_page.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_configs.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_record.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/core/bulk_downloads/src/widgets/tasks/task_tile.dart';
import 'package:boorusama/core/download_manager/src/pages/download_manager_page.dart';
import 'package:boorusama/core/download_manager/src/widgets/simple_download_tile.dart';
import 'package:boorusama/core/downloads/downloader/providers.dart';
import 'package:boorusama/core/downloads/urls/providers.dart';
import 'package:boorusama/core/posts/post/providers.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/foundation/permissions.dart';

import '../bulk_downloads/providers/downloads/common.dart';
import 'support/controlled_download_service.dart';
import 'support/download_event_driver.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets(
    'pauses, opens details, returns, and stops a bulk download',
    (tester) async {
      final database = sqlite3.openInMemory();
      final repository = DownloadRepositorySqlite(database)..initialize();
      final downloads = ControlledDownloadService(
        taskIdBuilder: (index) => 'bulk-flow-$index',
      );
      final backend = FakeBooruBackend();
      final harness = HeadlessAppHarness(
        booruBackend: backend,
        runtime: backend.createRuntime(downloadService: downloads),
        additionalOverrides: [
          internalDownloadRepositoryProvider.overrideWith(
            (_) => repository,
          ),
          postRepoProvider.overrideWith((_, _) => DummyPostRepository()),
          downloadServiceProvider.overrideWith((_) => downloads),
          mediaPermissionManagerProvider.overrideWithValue(
            AlwaysGrantedPermissionManager(),
          ),
        ],
      );

      try {
        await harness.pump(tester);
        final appContext = tester.element(find.byType(Navigator).first);
        unawaited(GoRouter.of(appContext).push('/bulk_downloads'));
        await harness.pumpUntilFound(tester, find.byType(BulkDownloadPage));

        final container = ProviderScope.containerOf(
          tester.element(find.byType(BulkDownloadPage)),
        );
        await harness.pumpUntil(
          tester,
          () => container.read(bulkDownloadProvider).ready,
        );

        final start = container
            .read(bulkDownloadProvider.notifier)
            .downloadFromOptions(
              DownloadTestConstants.defaultOptions.copyWith(
                skipIfExists: false,
                tags: SearchTagSet.fromList(const ['test_tags']),
              ),
              downloadConfigs: DownloadConfigs(
                downloader: downloads,
                fileNameBuilder: dummyDownloadFileNameBuilder,
                urlExtractor: const UrlInsidePostExtractor(),
                directoryExistChecker:
                    const AlwaysExistsDirectoryExistChecker(),
                headers: const {},
                blacklistedTags: const {},
                delayBetweenDownloads: const Duration(milliseconds: 20),
                delayBetweenRequests: Duration.zero,
              ),
            );

        for (var i = 0; i < 100 && downloads.requests.length < 2; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        if (downloads.requests.length < 2) {
          await start;
          final state = container.read(bulkDownloadProvider);
          final sessions = await repository.getActiveSessions();
          throw TestFailure(
            'Bulk download did not enqueue: error=${state.error}, '
            'sessions=$sessions',
          );
        }
        final sessionId = downloads.requests.first.metadata!.group!;
        final backgroundTasks = downloads.createBackgroundTasks(sessionId);
        final events = DownloadEventDriver(container);
        for (final task in backgroundTasks) {
          events
            ..status(task, bg.TaskStatus.running)
            ..progress(task, 0.25);
        }
        await harness.pumpUntilFound(
          tester,
          find.byType(BulkDownloadTaskTile),
        );

        final runningActions = _taskActionIcons();
        expect(runningActions, findsAtLeastNWidgets(2));
        await tester.tap(runningActions.at(1));
        await harness.pumpUntil(
          tester,
          () => downloads.pausedGroups.contains(sessionId),
          maxPumps: 100,
        );
        expect(
          (await repository.getSession(sessionId))?.status,
          DownloadSessionStatus.paused,
        );

        await tester.tap(find.text('test_tags'));
        await harness.pumpUntilFound(tester, find.byType(DownloadManagerPage));
        expect(
          find.byType(SimpleDownloadTile),
          findsNWidgets(backgroundTasks.length),
        );

        await tester.tap(find.byTooltip('Back').last);
        await harness.pumpUntil(
          tester,
          () => find.byType(DownloadManagerPage).evaluate().isEmpty,
        );
        await harness.pumpUntilFound(tester, find.byType(BulkDownloadPage));
        final pausedActions = _taskActionIcons();
        expect(pausedActions, findsAtLeastNWidgets(2));
        await tester.ensureVisible(pausedActions.first);
        await tester.tap(pausedActions.first);
        await harness.pumpUntil(
          tester,
          () => downloads.cancelledGroups.contains(sessionId),
        );

        await start;
        expect(downloads.cancelledGroups, [sessionId]);
        expect(
          (await repository.getSession(sessionId))?.status,
          DownloadSessionStatus.cancelled,
        );
        expect(
          await repository.getRecordsBySessionId(
            sessionId,
            status: DownloadRecordStatus.cancelled,
          ),
          isNotEmpty,
        );

        events.status(backgroundTasks.first, bg.TaskStatus.complete);
        await tester.pump(const Duration(seconds: 1));

        expect(
          (await repository.getSession(sessionId))?.status,
          DownloadSessionStatus.cancelled,
        );
        expect(find.byType(BulkDownloadPage), findsOneWidget);
        expect(find.byType(DownloadManagerPage), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        await harness.teardown(tester);
        database.close();
      }
    },
  );
}

Finder _taskActionIcons() => find.descendant(
  of: find.byType(BulkDownloadTaskTile),
  matching: find.byType(FaIcon),
);
