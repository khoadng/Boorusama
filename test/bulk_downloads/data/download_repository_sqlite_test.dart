// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/downloads/bulks/data/download_repository_sqlite.dart';
import 'package:boorusama/core/downloads/bulks/types/download_options.dart';
import 'package:boorusama/core/downloads/bulks/types/download_record.dart';
import 'package:boorusama/core/downloads/bulks/types/download_session.dart';

const _options = DownloadOptions(
  path: '/test/path',
  notifications: true,
  skipIfExists: true,
  quality: 'high',
  perPage: 100,
  concurrency: 5,
  tags: ['tag1', 'tag2'],
);

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
        final session = await repository.createSession(task.id);
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

        final records =
            await repository.getRecordsBySessionId(record.sessionId);
        expect(records.first.status, equals(DownloadRecordStatus.completed));
      });

      test('should update record by download ID', () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task.id);

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

      test('deleteTask should cascade delete sessions and records', () async {
        final task = await repository.createTask(_options);

        // Create multiple sessions
        final session1 = await repository.createSession(task.id);

        final session2 = await repository.createSession(task.id);

        // Create records for each session
        await repository.createRecord(
          DownloadRecord(
            url: 'https://example.com/1.jpg',
            sessionId: session1.id,
            status: DownloadRecordStatus.completed,
            page: 1,
            pageIndex: 0,
            createdAt: DateTime.now(),
            fileName: '1.jpg',
          ),
        );

        await repository.createRecord(
          DownloadRecord(
            url: 'https://example.com/2.jpg',
            sessionId: session1.id,
            status: DownloadRecordStatus.pending,
            page: 1,
            pageIndex: 1,
            createdAt: DateTime.now(),
            fileName: '2.jpg',
          ),
        );

        await repository.createRecord(
          DownloadRecord(
            url: 'https://example.com/3.jpg',
            sessionId: session2.id,
            status: DownloadRecordStatus.pending,
            page: 1,
            pageIndex: 0,
            createdAt: DateTime.now(),
            fileName: '3.jpg',
          ),
        );

        // Verify initial state
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(2));

        final records1 = await repository.getRecordsBySessionId(session1.id);
        expect(records1.length, equals(2));

        final records2 = await repository.getRecordsBySessionId(session2.id);
        expect(records2.length, equals(1));

        // Delete task
        await repository.deleteTask(task.id);

        // Verify everything is deleted
        final deletedTask = await repository.getTask(task.id);
        expect(deletedTask, isNull);

        final deletedSessions = await repository.getSessionsByTaskId(task.id);
        expect(deletedSessions, isEmpty);

        final deletedRecords1 =
            await repository.getRecordsBySessionId(session1.id);
        expect(deletedRecords1, isEmpty);

        final deletedRecords2 =
            await repository.getRecordsBySessionId(session2.id);
        expect(deletedRecords2, isEmpty);

        // Verify counts directly from tables
        final taskCount = db
            .select('SELECT COUNT(*) as count FROM download_tasks')
            .first['count'] as int;
        final sessionCount = db
            .select('SELECT COUNT(*) as count FROM download_sessions')
            .first['count'] as int;
        final recordCount = db
            .select('SELECT COUNT(*) as count FROM download_records')
            .first['count'] as int;

        expect(taskCount, equals(0));
        expect(sessionCount, equals(0));
        expect(recordCount, equals(0));
      });
    });
  });
}
