// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../types/download_record.dart';
import '../types/download_session.dart';
import '../types/download_task.dart';

DownloadTask mapToTask(Row row) {
  // Get column name with fallback
  final id = row['task_id'] ?? row['id'];
  final createdAt = row['task_created_at'] ?? row['created_at'];
  final updatedAt = row['task_updated_at'] ?? row['updated_at'];

  if (id == null || createdAt == null || updatedAt == null) {
    throw Exception('Invalid task data: missing required fields');
  }

  return DownloadTask(
    id: id as String,
    path: row['path'] as String,
    notifications: row['notifications'] == 1,
    skipIfExists: row['skip_if_exists'] == 1,
    quality: row['quality'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt as int),
    perPage: row['per_page'] as int,
    concurrency: row['concurrency'] as int,
    tags: row['tags'] as String?,
  );
}

DownloadSession mapToSession(Row row) {
  final task = tryDecodeJson<Map<String, dynamic>?>(
    row['task'],
  ).getOrElse((_) => null);

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
    task: task != null ? DownloadTask.fromJson(task) : null,
    auth: DownloadSessionAuth(
      authHash: row['auth_hash'],
      siteUrl: row['site_url'],
    ),
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
