// Dart imports:
import 'dart:math';

// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'bulk_download_session.dart';
import 'download_options.dart';
import 'download_record.dart';
import 'download_session.dart';
import 'download_session_stats.dart';
import 'download_task.dart';
import 'saved_download_task.dart';

abstract class DownloadRepository {
  Future<DownloadTask> createTask(DownloadOptions options);
  Future<void> editTask(DownloadTask newTask);
  Future<List<DownloadTask>> getTasks();
  Future<DownloadTask?> getTask(String id);
  Future<List<DownloadTask>> getTasksByIds(List<String> ids);
  Future<void> deleteTask(String id);

  Future<DownloadSession> createSession(DownloadTask task);
  Future<DownloadSession?> getSession(String id);
  Future<List<DownloadSession>> getSessionsByTaskId(String taskId);
  Future<List<DownloadSession>> getSessionsByStatus(
    DownloadSessionStatus status,
  );
  Future<List<DownloadSession>> getSessionsByStatuses(
    List<DownloadSessionStatus> statuses,
  );
  Future<List<BulkDownloadSession>> getActiveSessions();
  Future<List<BulkDownloadSession>> getCompletedSessions({
    DateTime? startDate,
    DateTime? endDate,
    int offset = 0,
    int limit = 20,
  });
  Future<void> deleteSession(String id);
  Future<void> updateSession(
    String id, {
    DownloadSessionStatus? status,
    int? currentPage,
    int? totalPages,
    String? error,
  });
  Future<void> completeSession(String id);

  Future<void> createRecord(DownloadRecord record);
  Future<void> createRecords(List<DownloadRecord> records);
  Future<List<DownloadRecord>> getRecordsBySessionId(
    String sessionId, {
    DownloadRecordStatus? status,
    int? recordPage,
  });

  Future<void> updateRecord({
    required String url,
    required String sessionId,
    DownloadRecordStatus? status,
    int? fileSize,
    String? fileName,
    String? extension,
    String? error,
    String? downloadId,
  });

  Future<void> updateRecordByDownloadId({
    required String sessionId,
    required String downloadId,
    DownloadRecordStatus? status,
    int? fileSize,
    String? fileName,
    String? extension,
    String? error,
  });

  Future<void> updateRecordsByStatus(
    String sessionId, {
    required DownloadRecordStatus to,
    DownloadRecordStatus? from,
  });

  Future<DownloadRecord?> getRecordByDownloadId(
    String sessionId,
    String downloadId,
  );

  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatuses(
    String sessionId,
    List<DownloadRecordStatus> statuses,
  );

  Future<int> getRecordsCountBySessionId(
    String sessionId, {
    DownloadRecordStatus? status,
  });

  // Reset to pending status and delete all associated download records
  Future<void> resetSessions(List<String> sessionIds);

  Future<void> updateSessionsStatus(
    List<String> sessionIds,
    DownloadSessionStatus status,
  );

  Future<DownloadSessionStats> updateStatisticsAndCleanup(
    String sessionId,
  );

  Future<void> createSavedTask(String taskId, String name);
  Future<List<SavedDownloadTask>> getSavedTasks();
  Future<SavedDownloadTask?> getSavedTask(int id);
  Future<void> editSavedTask(SavedDownloadTask task);
  Future<void> deleteSavedTask(int id);
}

extension DownloadRepositoryX on DownloadRepository {
  Future<DownloadSessionStats> getActiveSessionStats(String sessionId) async {
    final records = await getRecordsBySessionId(sessionId);
    if (records.isEmpty) return DownloadSessionStats.empty;

    final fileSizes = records.map((e) => e.fileSize ?? 0).toList()..sort();
    final pages = records.map((e) => e.page).toSet().toList();
    final filesPerPage = pages
        .map(
          (p) => records.where((r) => r.page == p).length,
        )
        .toList();

    final extensionCounts = <String, int>{};
    for (final record in records) {
      if (record.extension != null) {
        extensionCounts.update(
          record.extension!,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final session = await getSession(sessionId);
    if (session == null) return DownloadSessionStats.empty;

    final duration = session.completedAt?.difference(session.startedAt) ??
        DateTime.now().difference(session.startedAt);

    final stats = DownloadSessionStats(
      id: null,
      sessionId: sessionId,
      coverUrl: records.firstOrNull?.thumbnailImageUrl,
      totalItems: records.length,
      siteUrl: records.firstOrNull?.sourceUrl,
      totalSize: fileSizes.sum,
      averageDuration: duration ~/ records.length,
      averageFileSize: fileSizes.isEmpty
          ? null
          : fileSizes.reduce((a, b) => a + b) ~/ fileSizes.length,
      largestFileSize: fileSizes.isEmpty ? null : fileSizes.last,
      smallestFileSize: fileSizes.isEmpty ? null : fileSizes.first,
      medianFileSize:
          fileSizes.isEmpty ? null : fileSizes[fileSizes.length ~/ 2],
      avgFilesPerPage: filesPerPage.isEmpty
          ? null
          : filesPerPage.reduce((a, b) => a + b) / filesPerPage.length,
      maxFilesPerPage: filesPerPage.isEmpty ? null : filesPerPage.reduce(max),
      minFilesPerPage: filesPerPage.isEmpty ? null : filesPerPage.reduce(min),
      extensionCounts: extensionCounts,
    );

    return stats;
  }

  Future<int> getIncompleteDownloadsCount(String sessionId) async {
    final records = await getRecordsBySessionIdAndStatuses(
      sessionId,
      [DownloadRecordStatus.failed, DownloadRecordStatus.pending],
    );

    return records.length;
  }
}
