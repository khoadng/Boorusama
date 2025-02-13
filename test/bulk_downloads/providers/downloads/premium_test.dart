// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/downloads/bulks/data/download_repository_sqlite.dart';
import 'package:boorusama/core/downloads/bulks/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/downloads/bulks/types/bulk_download_error.dart';
import 'package:boorusama/core/downloads/bulks/types/download_configs.dart';
import 'package:boorusama/core/downloads/bulks/types/download_session.dart';
import 'common.dart';

void main() {
  late Database db;
  late DownloadRepositorySqlite repository;

  setUp(() {
    db = sqlite3.openInMemory();
    repository = DownloadRepositorySqlite(db)..initialize();
  });

  tearDown(() {
    db.dispose();
  });

  group('Running Sessions', () {
    test('non-premium users cannot have more than one running session',
        () async {
      // Arrange
      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
        hasPremium: false,
      );

      final notifier = container.read(bulkDownloadProvider.notifier);
      final task =
          await repository.createTask(DownloadTestConstants.defaultOptions);

      // Act - Create first session
      await notifier.downloadFromTask(
        task,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      // Try to create second session
      await notifier.downloadFromTask(
        task,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      final state = container.read(bulkDownloadProvider);
      expect(
        state.error.toString(),
        const FreeUserMultipleDownloadSessionsError().toString(),
      );
    });

    test(
        'non-premium users cannot start pending session when there is already an running session',
        () async {
      // Arrange
      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
        hasPremium: false,
      );

      final notifier = container.read(bulkDownloadProvider.notifier);
      final task =
          await repository.createTask(DownloadTestConstants.defaultOptions);

      // Act - Create first session and start downloading
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      // Create second session but don't start downloading yet
      await notifier.queueDownloadLater(
        DownloadTestConstants.defaultOptions,
        downloadConfigs: const DownloadConfigs(
          delayBetweenDownloads: null,
          androidSdkVersion: AndroidVersions.android15,
        ),
      );

      // Try to start the pending session
      final pendingSession = await repository.getSessionsByStatus(
        DownloadSessionStatus.pending,
      );

      await notifier.startPendingSession(pendingSession.first.id);

      final state = container.read(bulkDownloadProvider);
      expect(
        state.error.toString(),
        const FreeUserMultipleDownloadSessionsError().toString(),
      );
    });

    test(
        'non-premium users cannot start a new session after pausing an existing one',
        () async {
      // Arrange
      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
        hasPremium: false,
      );

      final notifier = container.read(bulkDownloadProvider.notifier);

      // Create and start first session
      final firstTask =
          await repository.createTask(DownloadTestConstants.defaultOptions);
      await notifier.downloadFromTask(
        firstTask,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      // Pause first session
      final session = await repository.getSessionsByStatus(
        DownloadSessionStatus.running,
      );
      await notifier.pauseSession(session.first.id);

      // Try to start second session
      final secondTask =
          await repository.createTask(DownloadTestConstants.defaultOptions);
      await notifier.downloadFromTask(
        secondTask,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      // Assert
      final state = container.read(bulkDownloadProvider);
      expect(
        state.error.toString(),
        const FreeUserMultipleDownloadSessionsError().toString(),
      );
    });
  });

  group('Suspend/Resume', () {
    test('non-premium users cannot suspend sessions', () async {
      // Arrange
      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
        hasPremium: false,
      );

      final notifier = container.read(bulkDownloadProvider.notifier);
      final task =
          await repository.createTask(DownloadTestConstants.defaultOptions);
      final session = await repository.createSession(task);

      // Set session to running state
      await repository.updateSession(
        session.id,
        status: DownloadSessionStatus.running,
      );

      // Act
      await notifier.suspendSession(session.id);

      // Assert
      final state = container.read(bulkDownloadProvider);
      expect(
        state.error.toString(),
        const NonPremiumSuspendResumeError().toString(),
      );

      // Verify session status hasn't changed
      final updatedSession = await repository.getSession(session.id);
      expect(updatedSession?.status, DownloadSessionStatus.running);
    });

    test('non-premium users cannot resume suspended sessions', () async {
      // Arrange
      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
        hasPremium: false,
      );

      final notifier = container.read(bulkDownloadProvider.notifier);
      final task =
          await repository.createTask(DownloadTestConstants.defaultOptions);
      final session = await repository.createSession(task);

      // Set session to suspended state
      await repository.updateSession(
        session.id,
        status: DownloadSessionStatus.suspended,
      );

      // Act
      await notifier.resumeSuspendedSession(session.id);

      // Assert
      final state = container.read(bulkDownloadProvider);
      expect(
        state.error.toString(),
        const NonPremiumSuspendResumeError().toString(),
      );

      // Verify session status hasn't changed
      final updatedSession = await repository.getSession(session.id);
      expect(updatedSession?.status, DownloadSessionStatus.suspended);
    });
  });

  group('Saved Tasks', () {
    test('non-premium users cannot create more than one saved task', () async {
      // Arrange
      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
        hasPremium: false,
      );

      final notifier = container.read(bulkDownloadProvider.notifier);
      final task =
          await repository.createTask(DownloadTestConstants.defaultOptions);

      // Act - Create first saved task
      await notifier.createSavedTask(task, name: 'First Task');

      // Try to create second saved task
      final secondTask =
          await repository.createTask(DownloadTestConstants.defaultOptions);
      await notifier.createSavedTask(secondTask, name: 'Second Task');

      // Assert
      final state = container.read(bulkDownloadProvider);
      expect(
        state.error.toString(),
        const NonPremiumSavedTaskLimitError().toString(),
      );

      // Verify only one saved task exists
      final savedTasks = await repository.getSavedTasks();
      expect(savedTasks.length, 1);
      expect(savedTasks.first.name, 'First Task');
    });
  });
}
