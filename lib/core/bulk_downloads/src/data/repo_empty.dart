// Project imports:
import '../../../configs/config/types.dart';
import '../types/bulk_download_session.dart';
import '../types/download_options.dart';
import '../types/download_record.dart';
import '../types/download_repository.dart';
import '../types/download_session.dart';
import '../types/download_session_stats.dart';
import '../types/download_task.dart';
import '../types/saved_download_task.dart';

class DownloadRepositoryEmpty implements DownloadRepository {
  @override
  Future<DownloadTask> createTask(DownloadOptions options) {
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
  Future<DownloadSession> createSession(
    DownloadTask task,
    BooruConfigAuth auth,
  ) {
    throw Exception('Empty repository, cannot create session');
  }

  @override
  Future<DownloadSession?> getSession(String id) async => null;

  @override
  Future<List<DownloadSession>> getSessionsByTaskId(String taskId) async => [];

  @override
  Future<List<DownloadSession>> getSessionsByStatus(
    DownloadSessionStatus status,
  ) async => [];

  @override
  Future<List<BulkDownloadSession>> getActiveSessions() async => [];

  @override
  Future<List<BulkDownloadSession>> getCompletedSessions({
    DateTime? startDate,
    DateTime? endDate,
    int offset = 0,
    int limit = 20,
  }) async => [];

  @override
  Future<List<DownloadSession>> getSessionsByStatuses(
    List<DownloadSessionStatus> statuses,
  ) async => [];

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
  Future<List<DownloadRecord>> getRecordsBySessionId(
    String sessionId, {
    DownloadRecordStatus? status,
    int? recordPage,
  }) async => [];

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
  Future<DownloadRecord?> getRecordByDownloadId(
    String sessionId,
    String downloadId,
  ) async => null;

  @override
  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatuses(
    String sessionId,
    List<DownloadRecordStatus> statuses,
  ) async => [];

  @override
  Future<void> resetSessions(List<String> sessionIds) async {}

  @override
  Future<void> updateSessionsStatus(
    List<String> sessionIds,
    DownloadSessionStatus status,
  ) async {}

  @override
  Future<void> editTask(DownloadTask newTask) async {}

  @override
  Future<DownloadSessionStats> updateStatisticsAndCleanup(
    String sessionId,
  ) async {
    return DownloadSessionStats.empty;
  }

  @override
  Future<SavedDownloadTask> createSavedTask(
    DownloadTask task,
    String name,
  ) async => throw Exception('Empty repository, cannot create saved task');

  @override
  Future<List<SavedDownloadTask>> getSavedTasks() async => [];

  @override
  Future<SavedDownloadTask?> getSavedTask(int id) async => null;

  @override
  Future<void> editSavedTask(SavedDownloadTask task) async {}

  @override
  Future<void> deleteSavedTask(int id) async {}

  @override
  Future<int> getRecordsCountBySessionId(
    String sessionId, {
    DownloadRecordStatus? status,
  }) async => 0;

  @override
  Future<void> updateRecordsByStatus(
    String sessionId, {
    required DownloadRecordStatus to,
    List<DownloadRecordStatus>? from,
  }) async {}

  @override
  Future<void> deleteAllCompletedSessions() async {}
}
