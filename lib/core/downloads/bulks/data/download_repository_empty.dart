// Project imports:
import '../types/bulk_download_session.dart';
import '../types/download_options.dart';
import '../types/download_record.dart';
import '../types/download_repository.dart';
import '../types/download_session.dart';
import '../types/download_session_stats.dart';
import '../types/download_task.dart';

class DownloadRepositoryEmpty implements DownloadRepository {
  @override
  Future<DownloadTask> createTask(DownloadOptions options) async {
    throw Exception('Empty repository, cannot create task');
  }

  @override
  Future<List<DownloadTask>> getTasks() async => [];

  @override
  Future<DownloadTask?> getTask(String id) async => null;

  @override
  Future<List<DownloadTask>> getTasksByIds(List<String> ids) async => [];

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<DownloadSession> createSession(String taskId) async {
    return DownloadSession(
      id: '',
      taskId: '',
      startedAt: DateTime.now(),
      currentPage: 0,
      status: DownloadSessionStatus.pending,
    );
  }

  @override
  Future<DownloadSession?> getSession(String id) async => null;

  @override
  Future<List<DownloadSession>> getSessionsByTaskId(String taskId) async => [];

  @override
  Future<List<DownloadSession>> getSessionsByStatus(
    DownloadSessionStatus status,
  ) async =>
      [];

  @override
  Future<List<BulkDownloadSession>> getActiveSessions() async => [];

  @override
  Future<List<BulkDownloadSession>> getCompletedSessions({
    DateTime? startDate,
    DateTime? endDate,
    int offset = 0,
    int limit = 20,
  }) async =>
      [];

  @override
  Future<List<DownloadSession>> getSessionsByStatuses(
    List<DownloadSessionStatus> statuses,
  ) async =>
      [];

  @override
  Future<void> updateSession(
    String id, {
    DownloadSessionStatus? status,
    int? currentPage,
    int? totalPages,
    String? error,
  }) async {}

  @override
  Future<void> completeSession(String id) async {}

  @override
  Future<void> createRecord(DownloadRecord record) async {}

  @override
  Future<void> createRecords(List<DownloadRecord> records) async {}

  @override
  Future<List<DownloadRecord>> getRecordsBySessionId(String sessionId) async =>
      [];

  @override
  Future<List<DownloadRecord>> getPendingRecordsBySessionId(
    String sessionId,
  ) async =>
      [];

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
  }) async {}

  @override
  Future<void> updateRecordByDownloadId({
    required String sessionId,
    required String downloadId,
    DownloadRecordStatus? status,
    int? fileSize,
    String? fileName,
    String? extension,
    String? error,
  }) async {}

  @override
  Future<void> deleteSession(String id) async {}

  @override
  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatus(
    String sessionId,
    DownloadRecordStatus status,
  ) async =>
      [];

  @override
  Future<DownloadRecord?> getRecordByDownloadId(
    String sessionId,
    String downloadId,
  ) async =>
      null;

  @override
  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatuses(
    String sessionId,
    List<DownloadRecordStatus> statuses,
  ) async =>
      [];

  @override
  Future<void> resetSessions(List<String> sessionIds) async {}

  @override
  Future<void> updateSessionsStatus(
    List<String> sessionIds,
    DownloadSessionStatus status,
  ) async {}

  @override
  Future<void> saveTask(String taskId, String name) async {}

  @override
  Future<void> createTaskVersion(
    String taskId,
    DownloadOptions options,
  ) async {}

  @override
  Future<DownloadSessionStats> updateStatisticsAndCleanup(
    String sessionId,
  ) async {
    return DownloadSessionStats.empty;
  }
}
