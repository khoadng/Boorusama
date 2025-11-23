// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/data/repo_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_options.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_record.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/core/search/selected_tags/search_tag_set.dart';
import '../providers/downloads/common.dart';

final _options = DownloadOptions(
  path: '/test/path',
  notifications: true,
  skipIfExists: true,
  quality: 'high',
  perPage: 100,
  concurrency: 5,
  tags: SearchTagSet.fromList(const ['tag1', 'tag2']),
);

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

  group('DownloadRepositorySqlite', () {
    group('core operations', () {
      test('should handle basic CRUD operations', () async {
        // Create and verify task
        final task = await repository.createTask(_options);
        final result = await repository.getTask(task.id);
        expect(result, isNotNull);
        expect(result!.id, equals(task.id));

        // Create and verify session
        final session = await repository.createSession(task, _auth);
        var sessionResult = await repository.getSession(session.id);
        expect(sessionResult, isNotNull);
        expect(sessionResult!.taskId, equals(task.id));

        // Create and verify record
        final record = DownloadRecord(
          url: 'https://example.com/image.jpg',
          sessionId: session.id,
          status: DownloadRecordStatus.pending,
          page: 1,
          pageIndex: 0,
          createdAt: DateTime.now(),
          fileName: 'image.jpg',
        );
        await repository.createRecord(record);

        // Update and verify status changes
        await repository.updateSession(
          session.id,
          status: DownloadSessionStatus.completed,
        );
        sessionResult = await repository.getSession(session.id);
        expect(sessionResult?.status, equals(DownloadSessionStatus.completed));

        await repository.updateRecord(
          url: record.url,
          sessionId: record.sessionId,
          status: DownloadRecordStatus.completed,
        );

        final records = await repository.getRecordsBySessionId(
          record.sessionId,
        );
        expect(records.first.status, equals(DownloadRecordStatus.completed));
      });

      test('should update record by download ID', () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task, _auth);

        final record = DownloadRecord(
          url: 'https://example.com/image.jpg',
          sessionId: session.id,
          status: DownloadRecordStatus.pending,
          page: 1,
          pageIndex: 0,
          createdAt: DateTime.now(),
          fileName: 'image.jpg',
          downloadId: 'download-123',
        );

        await repository.createRecord(record);

        await repository.updateRecordByDownloadId(
          sessionId: session.id,
          downloadId: 'download-123',
          status: DownloadRecordStatus.completed,
          fileName: 'updated.jpg',
        );

        final updated = await repository.getRecordByDownloadId(
          session.id,
          'download-123',
        );

        expect(updated?.status, equals(DownloadRecordStatus.completed));
        expect(updated?.fileName, equals('updated.jpg'));
      });
    });

    group('foreign key SET NULL behavior', () {
      test('sessions should handle null task_id after task deletion', () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task, _auth);

        // Create some records for the session
        await repository.createRecord(
          DownloadRecord(
            url: 'https://example.com/1.jpg',
            sessionId: session.id,
            status: DownloadRecordStatus.completed,
            page: 1,
            pageIndex: 0,
            createdAt: DateTime.now(),
            fileName: '1.jpg',
          ),
        );

        // Before deletion - verify relationships
        var sessionResult = await repository.getSession(session.id);
        expect(sessionResult?.taskId, equals(task.id));

        // Delete task - should set session's task_id to null but keep session
        await repository.deleteTask(task.id);

        // Verify task is gone
        final deletedTask = await repository.getTask(task.id);
        expect(deletedTask, isNull);

        // Verify session still exists but with null task_id
        sessionResult = await repository.getSession(session.id);
        expect(sessionResult, isNotNull);
        expect(sessionResult?.taskId, isNull);

        // Verify session records are still intact
        final records = await repository.getRecordsBySessionId(session.id);
        expect(records, isNotEmpty);
      });

      test(
        'statistics should handle null session_id after session deletion',
        () async {
          final task = await repository.createTask(_options);
          final session = await repository.createSession(task, _auth);

          // Insert test statistics
          db.execute(
            '''
          INSERT INTO download_session_statistics 
          (session_id, total_files, total_size) 
          VALUES (?, 100, 1000)
        ''',
            [session.id],
          );

          // Verify initial state
          var stats = db.select(
            'SELECT * FROM download_session_statistics WHERE session_id = ?',
            [session.id],
          ).first;
          expect(stats['session_id'], equals(session.id));

          // Delete session
          await repository.deleteSession(session.id);

          // Verify statistics entry still exists
          stats = db.select(
            'SELECT * FROM download_session_statistics WHERE id = ?',
            [stats['id']],
          ).first;
          expect(stats['session_id'], isNotNull);
        },
      );
    });

    group('saved tasks', () {
      test('should save task and retrieve it', () async {
        final task = await repository.createTask(_options);
        await repository.createSavedTask(task, 'My Download Task');

        final savedTasks = await repository.getSavedTasks();
        expect(savedTasks, hasLength(1));
        expect(savedTasks.first.name, equals('My Download Task'));
        expect(savedTasks.first.task.id, equals(task.id));
      });

      test(
        'should retrieve latest version when no active version specified',
        () async {
          // Create initial task
          final task = await repository.createTask(_options);
          await repository.createSavedTask(task, 'Task with versions');

          // Make some edits
          await repository.editTask(task.copyWith(path: '/path1'));
          await repository.editTask(task.copyWith(path: '/path2'));

          final savedTasks = await repository.getSavedTasks();
          expect(savedTasks.first.task.path, equals('/path2'));
        },
      );
    });

    group('session soft deletion', () {
      test('should soft delete session and exclude from queries', () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task, _auth);

        // Add some records
        await repository.createRecord(
          DownloadRecord(
            url: 'https://example.com/1.jpg',
            sessionId: session.id,
            status: DownloadRecordStatus.pending,
            page: 1,
            pageIndex: 0,
            createdAt: DateTime.now(),
            fileName: '1.jpg',
          ),
        );

        // Verify session exists before deletion
        var fetchedSession = await repository.getSession(session.id);
        expect(fetchedSession, isNotNull);

        // Delete session
        await repository.deleteSession(session.id);

        // Session should not be retrievable after deletion
        fetchedSession = await repository.getSession(session.id);
        expect(fetchedSession, isNull);

        // Session should not appear in task's sessions
        final taskSessions = await repository.getSessionsByTaskId(task.id);
        expect(taskSessions, isEmpty);

        // Session should not appear in status queries
        final pendingSessions = await repository.getSessionsByStatus(
          DownloadSessionStatus.pending,
        );
        expect(pendingSessions, isEmpty);

        // Session should not appear in multi-status queries
        final sessions = await repository.getSessionsByStatuses([
          DownloadSessionStatus.pending,
          DownloadSessionStatus.completed,
        ]);
        expect(sessions, isEmpty);

        // Records are also deleted
        final records = await repository.getRecordsBySessionId(session.id);
        expect(records, isEmpty);
      });

      test(
        'should exclude soft deleted sessions from active sessions',
        () async {
          final task = await repository.createTask(_options);
          final session = await repository.createSession(task, _auth);

          // Verify session appears in active sessions initially
          var activeSessions = await repository.getActiveSessions();
          expect(activeSessions, hasLength(1));

          // Delete session
          await repository.deleteSession(session.id);

          // Session should not appear in active sessions
          activeSessions = await repository.getActiveSessions();
          expect(activeSessions, isEmpty);
        },
      );

      test(
        'should exclude soft deleted sessions from completed sessions',
        () async {
          final task = await repository.createTask(_options);
          final session = await repository.createSession(task, _auth);

          // Complete the session
          await repository.completeSession(session.id);

          // Verify session appears in completed sessions initially
          var completedSessions = await repository.getCompletedSessions();
          expect(completedSessions, hasLength(1));

          // Delete session
          await repository.deleteSession(session.id);

          // Session should not appear in completed sessions
          completedSessions = await repository.getCompletedSessions();
          expect(completedSessions, isEmpty);
        },
      );

      test(
        'should handle re-creating session with same ID after soft deletion',
        () async {
          final task = await repository.createTask(_options);
          final session = await repository.createSession(task, _auth);
          final sessionId = session.id;

          // Delete session
          await repository.deleteSession(sessionId);

          // Try to create a new session with the same ID
          final newSession = await repository.createSession(task, _auth);
          expect(
            newSession.id,
            isNot(equals(sessionId)),
            reason: 'New session should have different ID',
          );

          final sessions = await repository.getSessionsByTaskId(task.id);
          expect(
            sessions.length,
            equals(1),
            reason: 'Should only have one active session',
          );
        },
      );

      test('should handle session statistics after soft deletion', () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task, _auth);

        // Add records and update statistics
        await repository.createRecord(
          DownloadRecord(
            url: 'https://example.com/1.jpg',
            sessionId: session.id,
            status: DownloadRecordStatus.completed,
            page: 1,
            pageIndex: 0,
            createdAt: DateTime.now(),
            fileName: '1.jpg',
            fileSize: 1000,
          ),
        );

        await repository.updateStatisticsAndCleanup(session.id);

        // Delete session
        await repository.deleteSession(session.id);

        // Verify statistics are still accessible
        final stats = db.select(
          'SELECT * FROM download_session_statistics WHERE session_id = ?',
          [session.id],
        );
        expect(
          stats,
          isNotEmpty,
          reason: 'Statistics should still exist after session deletion',
        );
      });
    });

    group('edge cases', () {
      test('should handle duplicate record creation', () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task, _auth);

        final record = DownloadRecord(
          url: 'https://example.com/duplicate.jpg',
          sessionId: session.id,
          status: DownloadRecordStatus.pending,
          page: 1,
          pageIndex: 0,
          createdAt: DateTime.now(),
          fileName: 'duplicate.jpg',
        );

        await repository.createRecord(record);
        await repository.createRecord(record);

        final records = await repository.getRecordsBySessionId(session.id);
        expect(records, hasLength(1));
      });
    });
  });
}
