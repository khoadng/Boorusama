// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_sqlite3_migration/flutter_sqlite3_migration.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../types/bulk_download_session.dart';
import '../types/download_options.dart';
import '../types/download_record.dart';
import '../types/download_repository.dart';
import '../types/download_session.dart';
import '../types/download_session_stats.dart';
import '../types/download_task.dart';
import 'download_repository_mapper.dart';

const _kDownloadVersion = 0;

class DownloadRepositorySqlite implements DownloadRepository {
  DownloadRepositorySqlite(this.db);

  final Database db;
  final _uuid = const Uuid();

  // New helper to run a transaction.
  void _transaction(void Function() action) {
    db.execute('BEGIN TRANSACTION');
    try {
      action();
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  void initialize() {
    db.execute('PRAGMA foreign_keys = ON');

    _createTableIfNotExists();
    DbMigrationManager.create(
      db: db,
      targetVersion: _kDownloadVersion,
      migrations: [],
    ).runMigrations();
  }

  void _createTableIfNotExists() {
    db
      ..execute('''
        CREATE TABLE IF NOT EXISTS download_tasks (
          id TEXT PRIMARY KEY,
          path TEXT NOT NULL,
          notifications BOOLEAN NOT NULL DEFAULT 0,
          skip_if_exists BOOLEAN NOT NULL DEFAULT 1,
          quality TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          per_page INTEGER NOT NULL DEFAULT 100,
          concurrency INTEGER NOT NULL DEFAULT 5,
          tags TEXT
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS download_sessions (
          id TEXT PRIMARY KEY,
          task_id TEXT NOT NULL,
          started_at INTEGER NOT NULL,
          completed_at INTEGER,
          current_page INTEGER NOT NULL DEFAULT 1,
          status TEXT NOT NULL,
          total_pages INTEGER, 
          error TEXT,
          FOREIGN KEY(task_id) REFERENCES download_tasks(id) ON DELETE CASCADE
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS download_records (
          url TEXT NOT NULL,
          session_id TEXT,
          status TEXT NOT NULL,
          page INTEGER NOT NULL,
          page_index INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          file_size INTEGER,
          file_name TEXT,
          extension TEXT,      
          error TEXT,
          download_id TEXT,
          headers TEXT,
          thumbnail_url TEXT,
          source_url TEXT,
          PRIMARY KEY(url, session_id),
          FOREIGN KEY(session_id) REFERENCES download_sessions(id) ON DELETE CASCADE
        )
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_download_records_session_id 
        ON download_records(session_id)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_download_sessions_task_id 
        ON download_sessions(task_id)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_download_tasks_created_at 
        ON download_tasks(created_at)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_download_records_status_session 
        ON download_records(session_id, status)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_download_records_download_lookup
        ON download_records(session_id, download_id)
      ''')
      ..execute('''
        CREATE INDEX IF NOT EXISTS idx_download_sessions_status_started 
        ON download_sessions(status, started_at)
      ''');
  }

  @override
  Future<DownloadTask> createTask(DownloadOptions options) async {
    final now = DateTime.now();
    final task = DownloadTask(
      id: _uuid.v4(),
      path: options.path,
      notifications: options.notifications,
      skipIfExists: options.skipIfExists,
      quality: options.quality,
      createdAt: now,
      updatedAt: now,
      perPage: options.perPage,
      concurrency: options.concurrency,
      tags: options.tags.join(' '),
    );

    db.execute(
      '''
      INSERT INTO download_tasks (
        id, path, notifications, skip_if_exists, quality, 
        created_at, updated_at, per_page, concurrency, tags
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        task.id,
        task.path,
        if (task.notifications) 1 else 0,
        if (task.skipIfExists) 1 else 0,
        task.quality,
        task.createdAt.millisecondsSinceEpoch,
        task.updatedAt.millisecondsSinceEpoch,
        task.perPage,
        task.concurrency,
        task.tags,
      ],
    );
    return task;
  }

  @override
  Future<List<DownloadTask>> getTasks() async {
    final results =
        db.select('SELECT * FROM download_tasks ORDER BY created_at DESC');
    return results.map(mapToTask).toList();
  }

  @override
  Future<List<DownloadTask>> getTasksByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = db.select(
      'SELECT * FROM download_tasks WHERE id IN (${ids.map((_) => '?').join(',')})',
      ids,
    );
    return results.map(mapToTask).toList();
  }

  @override
  Future<DownloadTask?> getTask(String id) async {
    final results = db.select(
      'SELECT * FROM download_tasks WHERE id = ?',
      [id],
    );
    if (results.isEmpty) return null;
    return mapToTask(results.first);
  }

  @override
  Future<void> deleteTask(String id) async {
    _transaction(() {
      db.execute('DELETE FROM download_tasks WHERE id = ?', [id]);
    });
  }

  @override
  Future<DownloadSession> createSession(String taskId) async {
    final session = DownloadSession(
      id: _uuid.v4(),
      taskId: taskId,
      startedAt: DateTime.now(),
      currentPage: 1,
      status: DownloadSessionStatus.pending,
    );

    db.execute(
      '''
      INSERT INTO download_sessions (
        id, task_id, started_at, completed_at, current_page, status, total_pages
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        session.id,
        session.taskId,
        session.startedAt.millisecondsSinceEpoch,
        session.completedAt?.millisecondsSinceEpoch,
        session.currentPage,
        session.status.name,
        session.totalPages,
      ],
    );
    return session;
  }

  @override
  Future<DownloadSession?> getSession(String id) async {
    final results = db.select(
      'SELECT * FROM download_sessions WHERE id = ?',
      [id],
    );
    if (results.isEmpty) return null;
    return mapToSession(results.first);
  }

  @override
  Future<List<DownloadSession>> getSessionsByTaskId(String taskId) async {
    final results = db.select(
      'SELECT * FROM download_sessions WHERE task_id = ? ORDER BY started_at DESC',
      [taskId],
    );
    return results.map(mapToSession).toList();
  }

  @override
  Future<List<DownloadSession>> getSessionsByStatus(
    DownloadSessionStatus status,
  ) async {
    final results = db.select(
      'SELECT * FROM download_sessions WHERE status = ? ORDER BY started_at DESC',
      [status.name],
    );
    return results.map(mapToSession).toList();
  }

  @override
  Future<List<BulkDownloadSession>> getActiveSessions() async {
    final results = db.select(
      '''
      SELECT 
        s.*,
        t.id as task_id,
        t.path,
        t.notifications,
        t.skip_if_exists,
        t.quality,
        t.created_at as task_created_at,
        t.updated_at as task_updated_at,
        t.per_page,
        t.concurrency,
        t.tags,
        r.thumbnail_url as cover_url,
        r.source_url as site_url,
        COUNT(r.url) as total_items,
        SUM(CASE WHEN r.file_size IS NOT NULL THEN r.file_size ELSE 0 END) as total_size
      FROM download_sessions s
      INNER JOIN download_tasks t ON s.task_id = t.id
      LEFT JOIN download_records r ON s.id = r.session_id
      WHERE s.status != ?
      GROUP BY s.id, t.id
      ORDER BY s.started_at DESC
    ''',
      [DownloadSessionStatus.completed.name],
    );

    return _mapToBulkDownloadSessions(results);
  }

  static const _maxLimit = 100; // Protect against too large queries

  @override
  Future<List<BulkDownloadSession>> getCompletedSessions({
    DateTime? startDate,
    DateTime? endDate,
    int offset = 0,
    int limit = 20,
  }) async {
    // Validate and sanitize pagination parameters
    final sanitizedOffset = offset < 0 ? 0 : offset;
    final sanitizedLimit = limit <= 0
        ? 20
        : limit > _maxLimit
            ? _maxLimit
            : limit;

    final whereClauses = ['s.status = ?'];
    final params = [DownloadSessionStatus.completed.name];

    if (startDate != null) {
      whereClauses.add('s.started_at >= ?');
      params.add(startDate.millisecondsSinceEpoch.toString());
    }

    if (endDate != null) {
      whereClauses.add('s.started_at <= ?');
      params.add(endDate.millisecondsSinceEpoch.toString());
    }

    final query = '''
      SELECT 
        s.*,
        t.id as task_id,
        t.path,
        t.notifications,
        t.skip_if_exists,
        t.quality,
        t.created_at as task_created_at,
        t.updated_at as task_updated_at,
        t.per_page,
        t.concurrency,
        t.tags,
        r.thumbnail_url as cover_url,
        r.source_url as site_url,
        COUNT(r.url) as total_items,
        SUM(CASE WHEN r.file_size IS NOT NULL THEN r.file_size ELSE 0 END) as total_size
      FROM download_sessions s
      INNER JOIN download_tasks t ON s.task_id = t.id
      LEFT JOIN download_records r ON s.id = r.session_id
      WHERE ${whereClauses.join(' AND ')}
      GROUP BY s.id, t.id
      ORDER BY s.started_at DESC
      LIMIT ? OFFSET ?
    ''';

    params.addAll([
      sanitizedLimit.toString(),
      sanitizedOffset.toString(),
    ]);

    final results = db.select(query, params);

    return _mapToBulkDownloadSessions(results);
  }

  List<BulkDownloadSession> _mapToBulkDownloadSessions(List<Row> results) {
    return results.map((row) {
      final session = mapToSession(row);
      final task = mapToTaskFromJoin(row);
      final stats = DownloadSessionStats(
        sessionId: session.id,
        coverUrl: row['cover_url'] as String?,
        totalItems: row['total_items'] as int,
        siteUrl: row['site_url'] as String?,
        estimatedDownloadSize: row['total_size'] as int?,
      );

      return BulkDownloadSession(
        task: task,
        session: session,
        stats: stats,
      );
    }).toList();
  }

  @override
  Future<List<DownloadSession>> getSessionsByStatuses(
    List<DownloadSessionStatus> statuses,
  ) async {
    if (statuses.isEmpty) return [];

    final statusNames = statuses.map((s) => s.name).toList();
    final placeholders = List.filled(statusNames.length, '?').join(',');

    final results = db.select(
      'SELECT * FROM download_sessions WHERE status IN ($placeholders) ORDER BY started_at DESC',
      statusNames,
    );
    return results.map(mapToSession).toList();
  }

  @override
  Future<void> updateSession(
    String id, {
    DownloadSessionStatus? status,
    int? currentPage,
    int? totalPages,
    String? error,
  }) async {
    _transaction(() {
      final setValues = <String>[];
      final params = <Object?>[];

      if (status != null) {
        setValues.add('status = ?');
        params.add(status.name);
      }
      if (currentPage != null) {
        setValues.add('current_page = ?');
        params.add(currentPage);
      }
      if (totalPages != null) {
        setValues.add('total_pages = ?');
        params.add(totalPages);
      }
      if (error != null) {
        setValues.add('error = ?');
        params
            .add(error.isEmpty ? null : error); // Convert empty string to null
      }

      if (setValues.isNotEmpty) {
        params.add(id);
        db.execute(
          '''
          UPDATE download_sessions 
          SET ${setValues.join(', ')} 
          WHERE id = ?
          ''',
          params,
        );
      }
    });
  }

  @override
  Future<void> completeSession(String id) async {
    _transaction(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      db.execute(
        '''
        UPDATE download_sessions 
        SET status = ?, completed_at = ? 
        WHERE id = ?
        ''',
        [DownloadSessionStatus.completed.name, now, id],
      );
    });
  }

  @override
  Future<void> createRecord(DownloadRecord record) async {
    db.execute(
      '''
      INSERT INTO download_records (
        url, session_id, status, page, page_index, created_at,
        file_size, file_name, extension, error, download_id,
        headers, thumbnail_url, source_url
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        record.url,
        record.sessionId,
        record.status.name,
        record.page,
        record.pageIndex,
        record.createdAt.millisecondsSinceEpoch,
        record.fileSize,
        record.fileName,
        record.extension,
        record.error,
        record.downloadId,
        if (record.headers != null) jsonEncode(record.headers) else null,
        record.thumbnailImageUrl,
        record.sourceUrl,
      ],
    );
  }

  @override
  Future<void> createRecords(List<DownloadRecord> records) async {
    if (records.isEmpty) return;

    final batch = db.prepare('''
      INSERT INTO download_records (
        url, session_id, status, page, page_index, created_at,
        file_size, file_name, extension, error, download_id,
        headers, thumbnail_url, source_url
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''');

    try {
      _transaction(() {
        for (final record in records) {
          batch.execute([
            record.url,
            record.sessionId,
            record.status.name,
            record.page,
            record.pageIndex,
            record.createdAt.millisecondsSinceEpoch,
            record.fileSize,
            record.fileName,
            record.extension,
            record.error,
            record.downloadId,
            if (record.headers != null) jsonEncode(record.headers) else null,
            record.thumbnailImageUrl,
            record.sourceUrl,
          ]);
        }
      });
    } finally {
      batch.dispose();
    }
  }

  @override
  Future<List<DownloadRecord>> getRecordsBySessionId(String sessionId) async {
    final results = db.select(
      'SELECT * FROM download_records WHERE session_id = ? ORDER BY page ASC, page_index ASC',
      [sessionId],
    );
    return results.map(mapToRecord).toList();
  }

  @override
  Future<List<DownloadRecord>> getPendingRecordsBySessionId(
    String sessionId,
  ) async {
    final results = db.select(
      'SELECT * FROM download_records WHERE session_id = ? AND status = ? ORDER BY page ASC, page_index ASC',
      [sessionId, DownloadRecordStatus.pending.name],
    );
    return results.map(mapToRecord).toList();
  }

  @override
  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatus(
    String sessionId,
    DownloadRecordStatus status,
  ) async {
    final results = db.select(
      'SELECT * FROM download_records WHERE session_id = ? AND status = ? ORDER BY page ASC, page_index ASC',
      [sessionId, status.name],
    );
    return results.map(mapToRecord).toList();
  }

  @override
  Future<DownloadRecord?> getRecordByDownloadId(
    String sessionId,
    String downloadId,
  ) async {
    final results = db.select(
      'SELECT * FROM download_records WHERE session_id = ? AND download_id = ?',
      [sessionId, downloadId],
    );
    if (results.isEmpty) return null;
    return mapToRecord(results.first);
  }

  @override
  Future<void> updateRecord({
    required String url,
    required String sessionId,
    DownloadRecordStatus? status,
    int? fileSize,
    String? fileName,
    String? extension,
    String? error,
    String? downloadId,
  }) async {
    final setValues = <String>[];
    final params = <Object?>[];

    if (status != null) {
      setValues.add('status = ?');
      params.add(status.name);
    }
    if (fileSize != null) {
      setValues.add('file_size = ?');
      params.add(fileSize);
    }
    if (fileName != null) {
      setValues.add('file_name = ?');
      params.add(fileName);
    }
    if (extension != null) {
      setValues.add('extension = ?');
      params.add(extension);
    }
    if (error != null) {
      setValues.add('error = ?');
      params.add(error);
    }
    if (downloadId != null) {
      setValues.add('download_id = ?');
      params.add(downloadId);
    }

    if (setValues.isEmpty) return;

    params.addAll([url, sessionId]);
    db.execute(
      '''
      UPDATE download_records 
      SET ${setValues.join(', ')} 
      WHERE url = ? AND session_id = ?
      ''',
      params,
    );
  }

  @override
  Future<void> updateRecordByDownloadId({
    required String sessionId,
    required String downloadId,
    DownloadRecordStatus? status,
    int? fileSize,
    String? fileName,
    String? extension,
    String? error,
  }) async {
    final setValues = <String>[];
    final params = <Object?>[];

    if (status != null) {
      setValues.add('status = ?');
      params.add(status.name);
    }
    if (fileSize != null) {
      setValues.add('file_size = ?');
      params.add(fileSize);
    }
    if (fileName != null) {
      setValues.add('file_name = ?');
      params.add(fileName);
    }
    if (extension != null) {
      setValues.add('extension = ?');
      params.add(extension);
    }
    if (error != null) {
      setValues.add('error = ?');
      params.add(error);
    }

    if (setValues.isEmpty) return;

    params.addAll([sessionId, downloadId]);
    db.execute(
      '''
      UPDATE download_records 
      SET ${setValues.join(', ')} 
      WHERE session_id = ? AND download_id = ?
      ''',
      params,
    );
  }

  @override
  Future<void> deleteSession(String id) async {
    _transaction(() {
      db.execute('DELETE FROM download_sessions WHERE id = ?', [id]);
    });
  }

  @override
  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatuses(
    String sessionId,
    List<DownloadRecordStatus> statuses,
  ) async {
    if (statuses.isEmpty) return [];

    final statusNames = statuses.map((s) => s.name).toList();
    final placeholders = List.filled(statusNames.length, '?').join(',');

    final results = db.select(
      '''
      SELECT * FROM download_records 
      WHERE session_id = ? AND status IN ($placeholders)
      ORDER BY page ASC, page_index ASC
      ''',
      [sessionId, ...statusNames],
    );

    return results.map(mapToRecord).toList();
  }

  @override
  Future<void> resetSessions(List<String> sessionIds) async {
    if (sessionIds.isEmpty) return;

    _transaction(() {
      // Delete all records for these sessions
      db
        ..execute(
          '''
        DELETE FROM download_records 
        WHERE session_id IN (${sessionIds.map((_) => '?').join(',')})
        ''',
          sessionIds,
        )

        // Reset sessions to pending state
        ..execute(
          '''
        UPDATE download_sessions 
        SET status = ?, error = NULL, current_page = 1, total_pages = NULL 
        WHERE id IN (${sessionIds.map((_) => '?').join(',')})
        ''',
          [DownloadSessionStatus.pending.name, ...sessionIds],
        );
    });
  }

  @override
  Future<void> updateSessionsStatus(
    List<String> sessionIds,
    DownloadSessionStatus status,
  ) async {
    if (sessionIds.isEmpty) return;

    _transaction(() {
      db.execute(
        '''
        UPDATE download_sessions 
        SET status = ? 
        WHERE id IN (${sessionIds.map((_) => '?').join(',')})
        ''',
        [status.name, ...sessionIds],
      );
    });
  }
}
