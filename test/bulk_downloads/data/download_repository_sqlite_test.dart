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
    });

    group('foreign key SET NULL behavior', () {
      test('sessions should handle null task_id after task deletion', () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task.id);

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

      test('statistics should handle null session_id after session deletion',
          () async {
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task.id);

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

        // Verify statistics entry still exists but with null session_id
        stats = db.select(
          'SELECT * FROM download_session_statistics WHERE id = ?',
          [stats['id']],
        ).first;
        expect(stats['session_id'], isNull);
      });
    });

    group('editTask', () {
      test('should create a version record only for changed fields', () async {
        // Create initial task
        final task = await repository.createTask(_options);

        // Modify only some fields
        final modifiedTask = task.copyWith(
          path: '/new/path',
          quality: 'medium',
        );

        await repository.editTask(modifiedTask);

        // Verify version was created with full record
        final versions = db.select(
          'SELECT * FROM download_task_versions WHERE task_id = ?',
          [task.id],
        );

        expect(versions.length, equals(1));
        final version = versions.first;

        // Should have required fields
        expect(version['task_id'], equals(task.id));
        expect(version['version'], equals(1));
        expect(version['created_at'], isNotNull);

        // Should have all fields
        expect(version['path'], equals('/new/path'));
        expect(version['quality'], equals('medium'));
        expect(version['notifications'], equals(1)); // boolean stored as int
        expect(version['skip_if_exists'], equals(1)); // boolean stored as int
        expect(version['per_page'], equals(100));
        expect(version['concurrency'], equals(5));
        expect(version['tags'], equals('tag1 tag2'));
      });

      test('should increment version number for multiple edits', () async {
        final task = await repository.createTask(_options);

        // First edit
        await repository.editTask(
          task.copyWith(path: '/path1'),
        );

        // Second edit
        await repository.editTask(
          task.copyWith(path: '/path2'),
        );

        final versions = db.select(
          'SELECT version FROM download_task_versions WHERE task_id = ? ORDER BY version',
          [task.id],
        );

        expect(versions.length, equals(2));
        expect(versions.first['version'], equals(1));
        expect(versions.last['version'], equals(2));
      });
    });

    group('saved tasks', () {
      test('should save task and retrieve it', () async {
        final task = await repository.createTask(_options);
        await repository.createSavedTask(task.id, 'My Download Task');

        final savedTasks = await repository.getSavedTasks();
        expect(savedTasks, hasLength(1));
        expect(savedTasks.first.name, equals('My Download Task'));
        expect(savedTasks.first.task.id, equals(task.id));
      });

      test('should retrieve latest version when no active version specified',
          () async {
        // Create initial task
        final task = await repository.createTask(_options);
        await repository.createSavedTask(task.id, 'Task with versions');

        // Make some edits
        await repository.editTask(task.copyWith(path: '/path1'));
        await repository.editTask(task.copyWith(path: '/path2'));

        final savedTasks = await repository.getSavedTasks();
        expect(savedTasks.first.task.path, equals('/path2'));
      });

      test('should handle task with active version', () async {
        // Create and save task
        final task = await repository.createTask(_options);
        await repository.createSavedTask(task.id, 'Task with active version');

        // Create versions
        await repository.editTask(task.copyWith(path: '/path1')); // v1
        await repository.editTask(task.copyWith(path: '/path2')); // v2

        // Get first version ID
        final versionId = db.select(
          'SELECT id FROM download_task_versions WHERE task_id = ? AND version = 1',
          [task.id],
        ).first['id'] as int;

        // Set active version to v1
        db.execute(
          'UPDATE saved_download_tasks SET active_version_id = ? WHERE task_id = ?',
          [versionId, task.id],
        );

        final savedTasks = await repository.getSavedTasks();
        expect(savedTasks.first.task.path, equals('/path1'));
        expect(savedTasks.first.activeVersionId, equals(versionId));
      });
    });
  });
}
