// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'bulk_download_session.dart';
import 'download_options.dart';
import 'download_record.dart';
import 'download_session.dart';
import 'download_session_stats.dart';
import 'download_task.dart';

abstract class DownloadRepository {
  Future<DownloadTask> createTask(DownloadOptions options);
  Future<List<DownloadTask>> getTasks();
  Future<DownloadTask?> getTask(String id);
  Future<List<DownloadTask>> getTasksByIds(List<String> ids);
  Future<void> deleteTask(String id);

  Future<DownloadSession> createSession(String taskId);
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
  Future<List<DownloadRecord>> getRecordsBySessionId(String sessionId);
  Future<List<DownloadRecord>> getPendingRecordsBySessionId(String sessionId);

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

  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatus(
    String sessionId,
    DownloadRecordStatus status,
  );

  Future<DownloadRecord?> getRecordByDownloadId(
    String sessionId,
    String downloadId,
  );

  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatuses(
    String sessionId,
    List<DownloadRecordStatus> statuses,
  );

  // Reset to pending status and delete all associated download records
  Future<void> resetSessions(List<String> sessionIds);

  Future<void> updateSessionsStatus(
    List<String> sessionIds,
    DownloadSessionStatus status,
  );
}

extension DownloadRepositoryX on DownloadRepository {
  Future<DownloadSessionStats> getSessionStats(String sessionId) async {
    final records = await getRecordsBySessionId(sessionId);
    if (records.isEmpty) {
      return DownloadSessionStats.empty;
    }

    final estimatedSize = records.map((e) => e.fileSize).nonNulls.sum;

    return DownloadSessionStats(
      sessionId: sessionId,
      coverUrl: records.firstOrNull?.thumbnailImageUrl,
      totalItems: records.length,
      siteUrl: records.firstOrNull?.sourceUrl,
      estimatedDownloadSize: estimatedSize <= 0 ? null : estimatedSize,
    );
  }

  Future<int> getIncompleteDownloadsCount(String sessionId) async {
    final records = await getRecordsBySessionIdAndStatuses(
      sessionId,
      [DownloadRecordStatus.failed, DownloadRecordStatus.pending],
    );

    return records.length;
  }
}
