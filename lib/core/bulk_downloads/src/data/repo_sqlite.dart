// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_sqlite3_migration/flutter_sqlite3_migration.dart';
import 'package:foundation/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../foundation/database/utils.dart';
import '../../../configs/config/types.dart';
import '../types/bulk_download_session.dart';
import '../types/download_options.dart';
import '../types/download_record.dart';
import '../types/download_repository.dart';
import '../types/download_session.dart';
import '../types/download_session_stats.dart';
import '../types/download_task.dart';
import '../types/saved_download_task.dart';
import 'mapper.dart';

const _kDownloadVersion = 0;

class DownloadRepositorySqlite
    with DatabaseUtilsMixin
    implements DownloadRepository {
  DownloadRepositorySqlite(this.db);

  @override
  final Database db;
  final _uuid = const Uuid();

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
          tags TEXT,
          blacklisted_tags TEXT,
          filename_format TEXT,
          dup_check_type TEXT
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS saved_download_tasks (
          id INTEGER PRIMARY KEY,
          task_id TEXT NOT NULL UNIQUE,
          name TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY(task_id) REFERENCES download_tasks(id) ON DELETE RESTRICT
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS download_sessions (
          id TEXT PRIMARY KEY,
          task_id TEXT,
          started_at INTEGER NOT NULL,
          completed_at INTEGER,
          current_page INTEGER NOT NULL DEFAULT 1,
          status TEXT NOT NULL,
          total_pages INTEGER, 
          error TEXT,
          task TEXT NOT NULL,
          deleted_at INTEGER,
          auth_hash TEXT,
          site_url TEXT,
          FOREIGN KEY(task_id) REFERENCES download_tasks(id) ON DELETE SET NULL
        )
      ''')
      ..execute('''
        CREATE TABLE IF NOT EXISTS download_records (
          url TEXT NOT NULL,
          session_id TEXT NOT NULL,
          status TEXT NOT NULL,
          page INTEGER NOT NULL,
          page_index SMALLINT NOT NULL,
          created_at INTEGER NOT NULL,
          file_size INTEGER,
          file_name TEXT NOT NULL,
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
        CREATE TABLE IF NOT EXISTS download_session_statistics (
          id INTEGER PRIMARY KEY,
          session_id TEXT UNIQUE,
          cover_url TEXT,      
          site_url TEXT,
          total_files INTEGER,
          total_size BIGINT,
          average_duration INTEGER,  -- in milliseconds
          average_file_size BIGINT,
          largest_file_size BIGINT,
          smallest_file_size BIGINT,
          median_file_size BIGINT,
          avg_files_per_page REAL,
          max_files_per_page INTEGER,
          min_files_per_page INTEGER,
          extension_counts TEXT,     -- JSON object {".jpg": 100, ".png": 50, etc}
          FOREIGN KEY(session_id) REFERENCES download_sessions(id) ON DELETE SET NULL
        )
      ''')
      ..execute(
        'CREATE INDEX IF NOT EXISTS idx_download_records_session_id ON download_records(session_id)',
      )
      ..execute(
        'CREATE INDEX IF NOT EXISTS idx_download_sessions_task_id ON download_sessions(task_id) WHERE deleted_at IS NULL',
      )
      ..execute(
        'CREATE INDEX IF NOT EXISTS idx_download_tasks_created_at ON download_tasks(created_at)',
      )
      ..execute(
        'CREATE INDEX IF NOT EXISTS idx_download_records_status_session ON download_records(session_id, status)',
      )
      ..execute(
        'CREATE INDEX IF NOT EXISTS idx_download_records_download_lookup ON download_records(session_id, download_id)',
      )
      ..execute(
        'CREATE INDEX IF NOT EXISTS idx_download_sessions_status_started ON download_sessions(status, started_at) WHERE deleted_at IS NULL',
      );
  }

  @override
  Future<void> editTask(DownloadTask newTask) async {
    final taskId = newTask.id;
    transaction(() {
      db.execute(
        '''
        UPDATE download_tasks 
        SET path = ?, notifications = ?, skip_if_exists = ?, quality = ?, 
            updated_at = ?, per_page = ?, concurrency = ?, tags = ?, blacklisted_tags = ? 
        WHERE id = ?
        ''',
        [
          newTask.path,
          if (newTask.notifications) 1 else 0,
          if (newTask.skipIfExists) 1 else 0,
          newTask.quality,
          DateTime.now().millisecondsSinceEpoch,
          newTask.perPage,
          newTask.concurrency,
          newTask.tags,
          newTask.blacklistedTags,
          taskId,
        ],
      );
    });
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
      tags: options.tags.toString(),
      blacklistedTags: options.blacklistedTags?.toString(),
    );

    db.execute(
      '''
      INSERT INTO download_tasks (
        id, path, notifications, skip_if_exists, quality, 
        created_at, updated_at, per_page, concurrency, tags, blacklisted_tags
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
        task.blacklistedTags,
      ],
    );
    return task;
  }

  @override
  Future<List<DownloadTask>> getTasks() async {
    final results = db.select(
      'SELECT * FROM download_tasks ORDER BY created_at DESC',
    );
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
    transaction(() {
      db.execute('DELETE FROM download_tasks WHERE id = ?', [id]);
    });
  }

  @override
  Future<DownloadSession> createSession(
    DownloadTask task,
    BooruConfigAuth auth,
  ) async {
    final session = DownloadSession(
      id: _uuid.v4(),
      taskId: task.id,
      task: task,
      startedAt: DateTime.now(),
      currentPage: 1,
      status: DownloadSessionStatus.pending,
      auth: DownloadSessionAuth(
        authHash: auth.computeHash(),
        siteUrl: auth.url,
      ),
    );

    db.execute(
      '''
      INSERT INTO download_sessions (
        id, task_id, started_at, completed_at, current_page, status, 
        total_pages, task, auth_hash, site_url
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        session.id,
        session.taskId,
        session.startedAt.millisecondsSinceEpoch,
        session.completedAt?.millisecondsSinceEpoch,
        session.currentPage,
        session.status.name,
        session.totalPages,
        jsonEncode(task.toJson()),
        session.auth.authHash,
        session.auth.siteUrl,
      ],
    );
    return session;
  }

  @override
  Future<DownloadSession?> getSession(String id) async {
    final results = db.select(
      'SELECT * FROM download_sessions WHERE id = ? AND deleted_at IS NULL',
      [id],
    );
    if (results.isEmpty) return null;
    return mapToSession(results.first);
  }

  @override
  Future<List<DownloadSession>> getSessionsByTaskId(String taskId) async {
    final results = db.select(
      '''
      SELECT * FROM download_sessions 
      WHERE task_id = ? AND deleted_at IS NULL 
      ORDER BY started_at DESC
      ''',
      [taskId],
    );
    return results.map(mapToSession).toList();
  }

  @override
  Future<List<DownloadSession>> getSessionsByStatus(
    DownloadSessionStatus status,
  ) async {
    final results = db.select(
      '''
      SELECT * FROM download_sessions 
      WHERE status = ? AND deleted_at IS NULL 
      ORDER BY started_at DESC
      ''',
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
        t.blacklisted_tags,
        r.thumbnail_url as cover_url,
        r.source_url as site_url,
        COUNT(r.url) as total_items,
        SUM(CASE WHEN r.file_size IS NOT NULL THEN r.file_size ELSE 0 END) as total_size
      FROM download_sessions s
      INNER JOIN download_tasks t ON s.task_id = t.id
      LEFT JOIN download_records r ON s.id = r.session_id
      WHERE s.status != ? AND s.deleted_at IS NULL
      GROUP BY s.id, t.id
      ORDER BY s.started_at DESC
    ''',
      [DownloadSessionStatus.completed.name],
    );

    return results.map((row) {
      final session = mapToSession(row);
      final task = DownloadTask(
        id: row['task_id'] as String,
        path: row['path'] as String,
        notifications: row['notifications'] == 1,
        skipIfExists: row['skip_if_exists'] == 1,
        quality: row['quality'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['task_created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          row['task_updated_at'] as int,
        ),
        perPage: row['per_page'] as int,
        concurrency: row['concurrency'] as int,
        tags: row['tags'] as String?,
        blacklistedTags: row['blacklisted_tags'] as String?,
      );
      final stats = DownloadSessionStats(
        id: null,
        sessionId: session.id,
        coverUrl: row['cover_url'] as String?,
        totalItems: row['total_items'] as int,
        siteUrl: row['site_url'] as String?,
        totalSize: row['total_size'] as int?,
      );

      return BulkDownloadSession(
        task: session.task ?? task,
        session: session,
        stats: stats,
      );
    }).toList();
  }

  static const _maxLimit = 100; // Protect against too large queries

  @override
  Future<List<BulkDownloadSession>> getCompletedSessions({
    DateTime? startDate,
    DateTime? endDate,
    int offset = 0,
    int limit = 20,
  }) async {
    final sanitizedOffset = offset < 0 ? 0 : offset;
    final sanitizedLimit = limit <= 0
        ? 20
        : limit > _maxLimit
        ? _maxLimit
        : limit;

    final whereClauses = ['s.status = ?', 's.deleted_at IS NULL'];
    final params = [DownloadSessionStatus.completed.name];

    if (startDate != null) {
      whereClauses.add('s.started_at >= ?');
      params.add(startDate.millisecondsSinceEpoch.toString());
    }

    if (endDate != null) {
      whereClauses.add('s.started_at <= ?');
      params.add(endDate.millisecondsSinceEpoch.toString());
    }

    final query =
        '''
      SELECT 
        s.id as session_id,
        s.task_id,
        s.started_at,
        s.completed_at,
        s.current_page,
        s.status as session_status,
        s.total_pages,
        s.error,
        s.task,
        stats.id as stats_id,
        stats.cover_url,
        stats.site_url,
        stats.total_files,
        stats.total_size,
        stats.average_duration,
        stats.average_file_size,
        stats.largest_file_size,
        stats.smallest_file_size,
        stats.median_file_size,
        stats.avg_files_per_page,
        stats.max_files_per_page,
        stats.min_files_per_page,
        stats.extension_counts
      FROM download_sessions s
      LEFT JOIN download_session_statistics stats ON s.id = stats.session_id
      WHERE ${whereClauses.join(' AND ')}
      ORDER BY s.started_at DESC
      LIMIT ? OFFSET ?
    ''';

    params.addAll([
      sanitizedLimit.toString(),
      sanitizedOffset.toString(),
    ]);

    final results = db.select(query, params);

    return results.map((row) {
      final taskJson = tryDecodeJson<Map<String, dynamic>?>(
        row['task'],
      ).getOrElse((_) => null);
      final task = taskJson != null ? DownloadTask.fromJson(taskJson) : null;

      final session = DownloadSession(
        id: row['session_id'] as String,
        taskId: row['task_id'] as String,
        task: task,
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          row['started_at'] as int,
        ),
        completedAt: row['completed_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int)
            : null,
        currentPage: row['current_page'] as int,
        status: DownloadSessionStatus.values.byName(
          row['session_status'] as String,
        ),
        totalPages: row['total_pages'] as int?,
        error: row['error'] as String?,
        auth: DownloadSessionAuth(
          authHash: row['auth_hash'] as String?,
          siteUrl: row['site_url'] as String?,
        ),
      );

      final stats = DownloadSessionStats(
        id: row['stats_id'] as int?,
        sessionId: session.id,
        coverUrl: row['cover_url'] as String?,
        siteUrl: row['site_url'] as String?,
        totalItems: row['total_files'] as int? ?? 0,
        totalSize: row['total_size'] as int?,
        averageDuration: row['average_duration'] != null
            ? Duration(milliseconds: row['average_duration'] as int)
            : null,
        averageFileSize: row['average_file_size'] as int?,
        largestFileSize: row['largest_file_size'] as int?,
        smallestFileSize: row['smallest_file_size'] as int?,
        medianFileSize: row['median_file_size'] as int?,
        avgFilesPerPage: row['avg_files_per_page'] as double?,
        maxFilesPerPage: row['max_files_per_page'] as int?,
        minFilesPerPage: row['min_files_per_page'] as int?,
        extensionCounts: row['extension_counts'] != null
            ? Map<String, int>.from(
                jsonDecode(row['extension_counts'] as String),
              )
            : {},
      );

      return BulkDownloadSession(
        task: task ?? DownloadTask.empty(),
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
      '''
      SELECT * FROM download_sessions 
      WHERE status IN ($placeholders) AND deleted_at IS NULL 
      ORDER BY started_at DESC
      ''',
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
    transaction(() {
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
        params.add(
          error.isEmpty ? null : error,
        ); // Convert empty string to null
      }

      if (setValues.isNotEmpty) {
        params.add(id);
        db.execute(
          '''
          UPDATE download_sessions 
          SET ${setValues.join(', ')} 
          WHERE id = ? AND deleted_at IS NULL
          ''',
          params,
        );
      }
    });
  }

  @override
  Future<void> completeSession(String id) async {
    transaction(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      db.execute(
        '''
        UPDATE download_sessions 
        SET status = ?, completed_at = ? 
        WHERE id = ? AND deleted_at IS NULL
        ''',
        [DownloadSessionStatus.completed.name, now, id],
      );
    });
  }

  @override
  Future<void> createRecord(DownloadRecord record) async {
    db.execute(
      '''
      INSERT OR IGNORE INTO download_records (
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
      INSERT OR IGNORE INTO download_records (
        url, session_id, status, page, page_index, created_at,
        file_size, file_name, extension, error, download_id,
        headers, thumbnail_url, source_url
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''');

    try {
      transaction(() {
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
  Future<List<DownloadRecord>> getRecordsBySessionId(
    String sessionId, {
    DownloadRecordStatus? status,
    int? recordPage,
  }) async {
    final whereClause = [
      'session_id = ?',
      if (status != null) 'status = ?',
      if (recordPage != null) 'page = ?',
    ].join(' AND ');

    final params = [
      sessionId,
      ?status?.name,
      ?recordPage,
    ];

    final results = db.select(
      'SELECT * FROM download_records WHERE $whereClause ORDER BY page ASC, page_index ASC',
      params,
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
    transaction(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      db
        ..execute(
          '''
        UPDATE download_sessions 
        SET deleted_at = ? 
        WHERE id = ?
        ''',
          [now, id],
        )
        ..execute(
          '''
        DELETE FROM download_records 
        WHERE session_id = ?
        ''',
          [id],
        );
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

    transaction(() {
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
        AND deleted_at IS NULL
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

    transaction(() {
      db.execute(
        '''
        UPDATE download_sessions 
        SET status = ? 
        WHERE id IN (${sessionIds.map((_) => '?').join(',')})
        AND deleted_at IS NULL
        ''',
        [status.name, ...sessionIds],
      );
    });
  }

  @override
  Future<DownloadSessionStats> updateStatisticsAndCleanup(
    String sessionId,
  ) async {
    final stats = await getActiveSessionStats(sessionId);

    transaction(() {
      db
        ..execute(
          '''
        INSERT OR REPLACE INTO download_session_statistics (
          session_id, cover_url, site_url, total_files, total_size, average_duration,
          average_file_size, largest_file_size, smallest_file_size,
          median_file_size, avg_files_per_page, max_files_per_page,
          min_files_per_page, extension_counts
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
          [
            sessionId,
            stats.coverUrl,
            stats.siteUrl,
            stats.totalItems,
            stats.totalSize,
            stats.averageDuration?.inMilliseconds,
            stats.averageFileSize,
            stats.largestFileSize,
            stats.smallestFileSize,
            stats.medianFileSize,
            stats.avgFilesPerPage,
            stats.maxFilesPerPage,
            stats.minFilesPerPage,
            jsonEncode(stats.extensionCounts),
          ],
        )
        ..execute(
          'DELETE FROM download_records WHERE session_id = ?',
          [sessionId],
        );
    });

    return stats;
  }

  @override
  Future<SavedDownloadTask> createSavedTask(
    DownloadTask task,
    String name,
  ) async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;

    final result = db.select(
      '''
      INSERT INTO saved_download_tasks (
        task_id, name, created_at, updated_at
      ) VALUES (?, ?, ?, ?)
      RETURNING id
      ''',
      [task.id, name, timestamp, timestamp],
    );

    final id = result.first['id'] as int;

    return SavedDownloadTask(
      id: id,
      task: task,
      name: name,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<SavedDownloadTask>> getSavedTasks() async {
    final results = db.select('''
      SELECT 
        s.id,
        s.task_id,
        s.name,
        s.created_at,
        s.updated_at,
        t.path, 
        t.notifications,
        t.skip_if_exists,
        t.quality,
        t.created_at as task_created_at,
        t.updated_at as task_updated_at,
        t.per_page,
        t.concurrency,
        t.tags,
        t.blacklisted_tags
      FROM saved_download_tasks s
      INNER JOIN download_tasks t ON s.task_id = t.id
      ORDER BY s.created_at DESC
    ''');

    return results.map((row) {
      final task = DownloadTask(
        id: row['task_id'] as String,
        path: row['path'] as String,
        notifications: row['notifications'] == 1,
        skipIfExists: row['skip_if_exists'] == 1,
        quality: row['quality'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['task_created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          row['task_updated_at'] as int,
        ),
        perPage: row['per_page'] as int,
        concurrency: row['concurrency'] as int,
        tags: row['tags'] as String?,
        blacklistedTags: row['blacklisted_tags'] as String?,
      );

      return SavedDownloadTask(
        id: row['id'] as int,
        task: task,
        name: row['name'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['created_at'] as int,
        ),
        updatedAt: row['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int)
            : null,
      );
    }).toList();
  }

  @override
  Future<void> deleteSavedTask(int id) async {
    transaction(() {
      db.execute('DELETE FROM saved_download_tasks WHERE id = ?', [id]);
    });
  }

  @override
  Future<SavedDownloadTask?> getSavedTask(int id) async {
    final results = db.select(
      '''
      SELECT 
        s.id,
        s.task_id,
        s.name,
        s.created_at,
        s.updated_at,
        t.path, 
        t.notifications,
        t.skip_if_exists,
        t.quality,
        t.created_at as task_created_at,
        t.updated_at as task_updated_at,
        t.per_page,
        t.concurrency,
        t.tags,
        t.blacklisted_tags
      FROM saved_download_tasks s
      INNER JOIN download_tasks t ON s.task_id = t.id
      WHERE s.id = ?
    ''',
      [id],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final task = DownloadTask(
      id: row['task_id'] as String,
      path: row['path'] as String,
      notifications: row['notifications'] == 1,
      skipIfExists: row['skip_if_exists'] == 1,
      quality: row['quality'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row['task_created_at'] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['task_updated_at'] as int,
      ),
      perPage: row['per_page'] as int,
      concurrency: row['concurrency'] as int,
      tags: row['tags'] as String?,
      blacklistedTags: row['blacklisted_tags'] as String?,
    );

    return SavedDownloadTask(
      id: row['id'] as int,
      task: task,
      name: row['name'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: row['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int)
          : null,
    );
  }

  @override
  Future<void> editSavedTask(SavedDownloadTask task) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    transaction(() {
      db.execute(
        '''
        UPDATE saved_download_tasks 
        SET name = ?, updated_at = ?
        WHERE id = ?
        ''',
        [task.name, now, task.id],
      );
    });
  }

  @override
  Future<int> getRecordsCountBySessionId(
    String sessionId, {
    DownloadRecordStatus? status,
  }) async {
    final query = status != null
        ? 'SELECT COUNT(*) as count FROM download_records WHERE session_id = ? AND status = ?'
        : 'SELECT COUNT(*) as count FROM download_records WHERE session_id = ?';

    final params = status != null ? [sessionId, status.name] : [sessionId];

    final result = db.select(query, params).first;
    return result['count'] as int;
  }

  @override
  Future<void> updateRecordsByStatus(
    String sessionId, {
    required DownloadRecordStatus to,
    List<DownloadRecordStatus>? from,
  }) async {
    transaction(() {
      if (from == null || from.isEmpty) {
        db.execute(
          '''
          UPDATE download_records 
          SET status = ? 
          WHERE session_id = ?
          ''',
          [to.name, sessionId],
        );
      } else {
        final placeholders = from.map((_) => '?').join(',');
        db.execute(
          '''
          UPDATE download_records 
          SET status = ? 
          WHERE session_id = ? AND status IN ($placeholders)
          ''',
          [to.name, sessionId, ...from.map((s) => s.name)],
        );
      }
    });
  }

  @override
  Future<void> deleteAllCompletedSessions() async {
    transaction(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      db.execute(
        '''
        UPDATE download_sessions 
        SET deleted_at = ? 
        WHERE status = ? AND deleted_at IS NULL
        ''',
        [now, DownloadSessionStatus.completed.name],
      );
    });
  }
}
