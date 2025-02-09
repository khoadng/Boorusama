// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../types/download_record.dart';
import '../types/download_session.dart';
import '../types/download_task.dart';

DownloadTask mapToTask(Row row) {
  return DownloadTask(
    id: row['id'],
    path: row['path'],
    notifications: row['notifications'] == 1,
    skipIfExists: row['skip_if_exists'] == 1,
    quality: row['quality'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']),
    perPage: row['per_page'],
    concurrency: row['concurrency'],
    tags: row['tags'],
  );
}

DownloadTask mapToTaskFromJoin(Row row) {
  return DownloadTask(
    id: row['task_id'] as String,
    path: row['path'] as String,
    notifications: row['notifications'] == 1,
    skipIfExists: row['skip_if_exists'] == 1,
    quality: row['quality'] as String?,
    createdAt:
        DateTime.fromMillisecondsSinceEpoch(row['task_created_at'] as int),
    updatedAt:
        DateTime.fromMillisecondsSinceEpoch(row['task_updated_at'] as int),
    perPage: row['per_page'] as int,
    concurrency: row['concurrency'] as int,
    tags: row['tags'] as String?,
  );
}

DownloadSession mapToSession(Row row) {
  return DownloadSession(
    id: row['id'],
    taskId: row['task_id'],
    startedAt: DateTime.fromMillisecondsSinceEpoch(row['started_at']),
    completedAt: row['completed_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(row['completed_at'])
        : null,
    currentPage: row['current_page'],
    totalPages: row['total_pages'],
    status: DownloadSessionStatus.fromString(row['status']),
    error: row['error'],
  );
}

DownloadRecord mapToRecord(Row row) {
  Map<String, String>? headers;
  if (row['headers'] != null) {
    try {
      final parsed = jsonDecode(row['headers']);
      headers = Map<String, String>.from(parsed);
    } catch (e) {
      headers = {};
    }
  }

  return DownloadRecord(
    url: row['url'],
    sessionId: row['session_id'],
    status: DownloadRecordStatus.fromString(row['status']),
    page: row['page'],
    pageIndex: row['page_index'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']),
    fileSize: row['file_size'],
    fileName: row['file_name'],
    extension: row['extension'],
    error: row['error'],
    downloadId: row['download_id'],
    headers: headers,
    thumbnailImageUrl: row['thumbnail_url'],
    sourceUrl: row['source_url'],
  );
}
