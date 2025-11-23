// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/data/repo_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/saved_task_lock_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/types/bulk_download_error.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'common.dart';

const _defaultConfigs = DownloadTestConstants.defaultConfigs;
final _auth = DownloadTestConstants.defaultAuthConfig;

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
    test(
      'non-premium users cannot have more than one running session',
      () async {
        // Arrange
        final container = createBulkDownloadContainer(
          downloadRepository: repository,
          booruBuilder: MockBooruBuilder(),
          hasPremium: false,
        );

        final notifier = container.read(bulkDownloadProvider.notifier);
        final task = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );

        // Act - Create first session
        await notifier.downloadFromTask(
          task,
          downloadConfigs: _defaultConfigs,
        );

        // Try to create second session
        await notifier.downloadFromTask(
          task,
          downloadConfigs: _defaultConfigs,
        );

        final state = container.read(bulkDownloadProvider);
        expect(
          state.error.toString(),
          const FreeUserMultipleDownloadSessionsError().toString(),
        );
      },
    );

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
        final task = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );

        // Act - Create first session and start downloading
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: _defaultConfigs,
        );

        // Create second session but don't start downloading yet
        await notifier.queueDownloadLater(
          DownloadTestConstants.defaultOptions,
          downloadConfigs: _defaultConfigs.copyWith(
            androidSdkVersion: AndroidVersions.android15,
          ),
        );

        // Try to start the pending session
        final pendingSession = await repository.getSessionsByStatus(
          DownloadSessionStatus.pending,
        );

        await notifier.startPendingSession(
          pendingSession.first.id,
          downloadConfigs: _defaultConfigs.copyWith(
            androidSdkVersion: AndroidVersions.android15,
          ),
        );

        final state = container.read(bulkDownloadProvider);
        expect(
          state.error.toString(),
          const FreeUserMultipleDownloadSessionsError().toString(),
        );
      },
    );

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
        final firstTask = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );
        await notifier.downloadFromTask(
          firstTask,
          downloadConfigs: _defaultConfigs,
        );

        // Pause first session
        final session = await repository.getSessionsByStatus(
          DownloadSessionStatus.running,
        );
        await notifier.pauseSession(session.first.id);

        // Try to start second session
        final secondTask = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );
        await notifier.downloadFromTask(
          secondTask,
          downloadConfigs: _defaultConfigs,
        );

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(
          state.error.toString(),
          const FreeUserMultipleDownloadSessionsError().toString(),
        );
      },
    );
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
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(task, _auth);

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
        const NonPremiumSuspendError().toString(),
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
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(task, _auth);

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
        const NonPremiumResumeError().toString(),
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
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );

      // Act - Create first saved task
      await notifier.createSavedTask(task, name: 'First Task');

      // Try to create second saved task
      final secondTask = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
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

    test('locks all saved tasks except first one when premium expires', () async {
      // Arrange - Create container with premium enabled
      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
      );

      final notifier = container.read(bulkDownloadProvider.notifier);

      // Create multiple saved tasks while having premium
      final task1 = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final task2 = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final task3 = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );

      final savedTask1 = await notifier.createSavedTask(task1, name: 'Task 1');
      await Future.delayed(const Duration(milliseconds: 5));
      final savedTask2 = await notifier.createSavedTask(task2, name: 'Task 2');
      await Future.delayed(const Duration(milliseconds: 5));
      final _ = await notifier.createSavedTask(task3, name: 'Task 3');
      await Future.delayed(const Duration(milliseconds: 5));

      // Verify all tasks can be accessed with premium
      final savedTasks = await repository.getSavedTasks();
      expect(savedTasks.length, 3);

      // Act - Simulate premium expiration by recreating container without premium
      final nonPremiumContainer = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
        hasPremium: false,
      );

      // Verify lock states
      final lockState = await nonPremiumContainer.read(
        savedTaskLockProvider.future,
      );
      expect(
        lockState.lockedIds,
        // All except the newest task should be locked
        {savedTask1!.task.id, savedTask2!.task.id},
      );
    });

    test(
      'automatically unlocks saved tasks when premium is restored',
      () async {
        // Arrange - Start with premium to create tasks
        final initContainer = createBulkDownloadContainer(
          downloadRepository: repository,
          booruBuilder: MockBooruBuilder(),
        );

        final initNotifier = initContainer.read(bulkDownloadProvider.notifier);

        // Create multiple tasks while premium
        final task1 = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );
        final task2 = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );
        final task3 = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );

        final savedTask1 = await initNotifier.createSavedTask(
          task1,
          name: 'Task 1',
        );
        await Future.delayed(const Duration(milliseconds: 5));
        final savedTask2 = await initNotifier.createSavedTask(
          task2,
          name: 'Task 2',
        );
        await Future.delayed(const Duration(milliseconds: 5));
        final _ = await initNotifier.createSavedTask(task3, name: 'Task 3');

        // Act - Simulate premium expiration
        final nonPremiumContainer = createBulkDownloadContainer(
          downloadRepository: repository,
          booruBuilder: MockBooruBuilder(),
          hasPremium: false,
        );

        // Verify tasks are locked when premium expires
        final nonPremiumLockState = await nonPremiumContainer.read(
          savedTaskLockProvider.future,
        );
        expect(
          nonPremiumLockState.lockedIds,
          {savedTask1!.task.id, savedTask2!.task.id},
        );

        // Act - Simulate premium restoration
        final premiumContainer = createBulkDownloadContainer(
          downloadRepository: repository,
          booruBuilder: MockBooruBuilder(),
        );

        // Assert - All tasks should be unlocked
        final restoredLockState = await premiumContainer.read(
          savedTaskLockProvider.future,
        );
        expect(restoredLockState.lockedIds, isEmpty);
      },
    );
  });
}
