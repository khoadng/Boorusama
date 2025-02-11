// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/downloads/bulks/data/download_repository_sqlite.dart';
import 'package:boorusama/core/downloads/bulks/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/downloads/bulks/types/bulk_download_error.dart';
import 'package:boorusama/core/downloads/bulks/types/download_configs.dart';
import 'package:boorusama/core/downloads/bulks/types/download_record.dart';
import 'package:boorusama/core/downloads/bulks/types/download_repository.dart';
import 'package:boorusama/core/downloads/bulks/types/download_session.dart';
import 'common.dart';

const _options = DownloadTestConstants.defaultOptions;

void main() {
  late Database db;
  late DownloadRepositorySqlite repository;
  late ProviderContainer container;

  setUp(() {
    db = sqlite3.openInMemory();
    repository = DownloadRepositorySqlite(db)..initialize();

    container = createBulkDownloadContainer(
      downloadRepository: repository,
      booruBuilder: MockBooruBuilder(),
    )..read(bulkDownloadProvider); // Initialize provider
  });

  tearDown(() {
    db.dispose();
    container.dispose();
  });

  group('Session Deletion', () {
    test('should remove session and its records when deleted', () async {
      // Arrange
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);

      // Start a task to create a session
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      // Get session ID from the first session
      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.length, equals(1));
      final sessionId = sessions.first.id;

      // Verify session exists in state
      var state = container.read(bulkDownloadProvider);
      expect(
        state.sessions.any((d) => d.session.id == sessionId),
        isTrue,
      );

      // Act
      await notifier.deleteSession(sessionId);

      // Assert
      // Verify session is removed from state
      state = container.read(bulkDownloadProvider);
      expect(
        state.sessions.any((d) => d.session.id == sessionId),
        isFalse,
      );

      // Verify session is removed from database
      final deletedSession = await repository.getSession(sessionId);
      expect(deletedSession, isNull);

      // Verify associated records are also deleted
      final records = await repository.getRecordsBySessionId(sessionId);
      expect(records, isEmpty);

      // Verify state is updated
      state = container.read(bulkDownloadProvider);
      expect(state.sessions, isEmpty);
    });

    test('should handle non-existent session deletion gracefully', () async {
      // Act
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.deleteSession('non-existent-session-id');

      // Assert
      final state = container.read(bulkDownloadProvider);
      expect(state.error, isNotNull);
    });
  });

  group('Session Completion', () {
    test('should not complete session when it is not in running state',
        () async {
      // Arrange
      final task = await repository.createTask(_options);
      final session = await repository.createSession(task.id);

      // Session starts as pending
      final notifier = container.read(bulkDownloadProvider.notifier);

      // Act
      await notifier.tryCompleteSession(session.id);

      // Assert
      final state = container.read(bulkDownloadProvider);
      expect(
        state.error,
        isA<SessionNotRunningError>(),
      );
    });

    test('should handle multiple records completing simultaneously', () async {
      // Arrange
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      final sessions = await repository.getSessionsByTaskId(task.id);
      final sessionId = sessions.first.id;
      final records = await repository.getRecordsBySessionId(sessionId);

      // Simulate concurrent updates
      await Future.wait([
        for (final record in records)
          notifier.updateRecord(
            sessionId,
            record.downloadId!,
            DownloadRecordStatus.completed,
          ),
      ]);

      // Act
      await notifier.tryCompleteSession(sessionId);

      // Assert
      final session = await repository.getSession(sessionId);
      expect(session?.status, equals(DownloadSessionStatus.completed));
    });

    test('should calculate final statistics and cleanup on session completion',
        () async {
      // Arrange
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      final sessions = await repository.getSessionsByTaskId(task.id);
      final sessionId = sessions.first.id;
      final records = await repository.getRecordsBySessionId(sessionId);

      // Mark all records as completed
      for (final record in records) {
        await notifier.updateRecord(
          sessionId,
          record.downloadId!,
          DownloadRecordStatus.completed,
          fileSize: 1000, // Mock file size
        );
      }

      // Act
      await notifier.tryCompleteSession(sessionId);

      // Assert
      final session = await repository.getSession(sessionId);
      expect(session?.status, equals(DownloadSessionStatus.completed));

      // Verify records were cleaned up
      final remainingRecords =
          await repository.getRecordsBySessionId(sessionId);
      expect(remainingRecords.isEmpty, isTrue);
    });

    test('should preserve session statistics after cleanup', () async {
      // Arrange
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      final sessions = await repository.getSessionsByTaskId(task.id);
      final sessionId = sessions.first.id;

      // Store initial stats
      final initialStats = await repository.getActionSessionStats(sessionId);

      // Complete all records
      final records = await repository.getRecordsBySessionId(sessionId);
      for (final record in records) {
        await notifier.updateRecord(
          sessionId,
          record.downloadId!,
          DownloadRecordStatus.completed,
          fileSize: 1000, // Mock file size
        );
      }

      // Act
      await notifier.tryCompleteSession(sessionId);

      // Assert
      final completed = await repository.getCompletedSessions();
      final finalStats = completed.first.stats;

      // Verify stats were preserved
      expect(finalStats.totalItems, equals(initialStats.totalItems));
      expect(finalStats.coverUrl, equals(initialStats.coverUrl));
      expect(finalStats.siteUrl, equals(initialStats.siteUrl));
    });

    test('should handle non-existent sessions gracefully', () async {
      // Act
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.tryCompleteSession('non-existent-session');

      // Assert
      expect(
        container.read(bulkDownloadProvider).error,
        isA<SessionNotFoundError>(),
      );
    });
  });

  group('Session Dry Run', () {
    test('should transition from dry run to running state when stopped',
        () async {
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);

      unawaited(
        notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(
            delayBetweenRequests: Duration(milliseconds: 200),
          ),
        ),
      );

      // Wait for session to be created
      await Future.delayed(
        const Duration(milliseconds: 50),
        () async {
          final sessions = await repository.getSessionsByTaskId(task.id);

          // Verify initial dry run state
          expect(sessions.first.status, equals(DownloadSessionStatus.dryRun));

          // Stop dry run
          await notifier.stopDryRun(sessions.first.id);

          // Verify state transition
          final updatedSession = await repository.getSession(sessions.first.id);
          expect(
            updatedSession?.status,
            equals(DownloadSessionStatus.running),
          );

          // Verify notifier state
          final state = container.read(bulkDownloadProvider);
          expect(
            state.sessions
                .firstWhere((d) => d.session.id == sessions.first.id)
                .session
                .status,
            equals(DownloadSessionStatus.running),
          );
        },
      );
    });
  });

  group('Session Cancellation', () {
    test('should cancel session before processing starts', () async {
      // Arrange
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);
      final session = await repository.createSession(task.id);

      // Act
      await notifier.cancelSession(session.id);

      // Assert
      final updatedSession = await repository.getSession(session.id);
      expect(updatedSession?.status, equals(DownloadSessionStatus.cancelled));
    });

    test('should cancel only the specified session mid-download', () async {
      // Arrange
      final task1 = await repository.createTask(_options);
      final task2 = await repository.createTask(
        _options.copyWith(
          tags: ['different_tags'],
        ),
      );
      final notifier = container.read(bulkDownloadProvider.notifier);

      // Start both downloads
      unawaited(
        notifier.downloadFromTask(
          task1,
          downloadConfigs: const DownloadConfigs(
            delayBetweenDownloads: null,
          ),
        ),
      );

      unawaited(
        notifier.downloadFromTask(
          task2,
          downloadConfigs: const DownloadConfigs(
            delayBetweenDownloads: null,
          ),
        ),
      );

      // Wait for sessions to be created and start running
      await Future.delayed(const Duration(milliseconds: 100));

      final sessions = await repository.getActiveSessions();
      expect(sessions.length, equals(2));

      // Act - cancel first session
      await notifier.cancelSession(sessions.first.id);

      // Assert
      final updatedSessions = await repository.getActiveSessions();
      expect(updatedSessions.length, equals(2));

      // Verify first session is cancelled
      final cancelledSession = await repository.getSession(sessions.first.id);
      expect(
        cancelledSession?.status,
        equals(DownloadSessionStatus.cancelled),
      );

      // Verify second session is still running
      final runningSession = await repository.getSession(sessions.last.id);
      expect(
        runningSession?.status,
        equals(DownloadSessionStatus.running),
      );

      // Verify state reflects changes
      final state = container.read(bulkDownloadProvider);
      final stateSession = state.sessions.firstWhere(
        (s) => s.session.id == sessions.first.id,
      );
      expect(
        stateSession.session.status,
        equals(DownloadSessionStatus.cancelled),
      );
    });

    test('should stop current download session when cancelled', () async {
      // Arrange
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTask(
        task,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      // Get session ID
      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.length, equals(1));
      final sessionId = sessions.first.id;

      // Act
      await notifier.cancelSession(sessionId);

      // Assert
      final updatedSession = await repository.getSession(sessionId);
      expect(updatedSession?.status, equals(DownloadSessionStatus.cancelled));

      // Verify state update
      final state = container.read(bulkDownloadProvider);
      final taskStatus =
          state.sessions.firstWhere((e) => e.session.id == sessionId);
      expect(
        taskStatus.session.status,
        equals(DownloadSessionStatus.cancelled),
      );
    });
  });

  group('Session Resume', () {
    test('should mark running session as interrupted on app restart', () async {
      // Arrange
      var myContainer = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
      );
      final task = await repository.createTask(_options);
      var notifier = myContainer.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTask(
        task,
        downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
      );

      // Get session ID
      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.length, equals(1));
      final sessionId = sessions.first.id;

      // Simulate app restart
      myContainer.dispose();
      myContainer = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
      );

      notifier = myContainer.read(bulkDownloadProvider.notifier);

      // Wait for notifier to load
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify session is marked as interrupted
      final interruptedSession = await repository.getSession(sessionId);
      expect(
        interruptedSession?.status,
        equals(DownloadSessionStatus.interrupted),
      );

      // Verify state reflects changes
      final state = myContainer.read(bulkDownloadProvider);
      final stateSession = state.sessions.firstWhere(
        (s) => s.session.id == sessionId,
      );

      expect(
        stateSession.session.status,
        equals(DownloadSessionStatus.interrupted),
      );
    });

    test('should mark dry run session as pending when interrupted', () async {
      // Arrange
      var myContainer = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
      );
      final task = await repository.createTask(_options);
      var notifier = myContainer.read(bulkDownloadProvider.notifier);

      unawaited(
        notifier.downloadFromTask(
          task,
          downloadConfigs: const DownloadConfigs(
            delayBetweenRequests: Duration(milliseconds: 2000),
          ),
        ),
      );

      // Wait for dry run to start
      await Future.delayed(const Duration(milliseconds: 50));

      // Get session ID from the first session
      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.length, equals(1));
      final sessionId = sessions.first.id;

      // Verify session is in dry run
      expect(sessions.first.status, equals(DownloadSessionStatus.dryRun));

      // Simulate app restart before completing dry run
      myContainer.dispose();
      myContainer = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
      );
      notifier = myContainer.read(bulkDownloadProvider.notifier);

      // Wait for notifier to load
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify session is reset to pending
      final resetSession = await repository.getSession(sessionId);
      expect(
        resetSession?.status,
        equals(DownloadSessionStatus.pending),
      );

      // Verify state reflects changes
      final state = myContainer.read(bulkDownloadProvider);
      final stateSession = state.sessions.firstWhere(
        (s) => s.session.id == sessionId,
      );

      expect(
        stateSession.session.status,
        equals(DownloadSessionStatus.pending),
      );

      // Verify all records are cleaned up
      final records = await repository.getRecordsBySessionId(sessionId);
      expect(records, isEmpty);
    });
  });
}
