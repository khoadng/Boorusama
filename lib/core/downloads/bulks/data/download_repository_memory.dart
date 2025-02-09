// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../types/bulk_download_session.dart';
import '../types/download_options.dart';
import '../types/download_record.dart';
import '../types/download_repository.dart';
import '../types/download_session.dart';
import '../types/download_task.dart';

class DownloadRepositoryMemory implements DownloadRepository {
  final _uuid = const Uuid();
  final Map<String, DownloadTask> _tasks = {};
  final Map<String, DownloadSession> _sessions = {};
  final Map<String, List<DownloadRecord>> _records = {};

  static const _maxLimit = 100;

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
    _tasks[task.id] = task;
    return task;
  }

  @override
  Future<List<DownloadTask>> getTasks() async {
    return _tasks.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<DownloadTask?> getTask(String id) async {
    return _tasks[id];
  }

  @override
  Future<List<DownloadTask>> getTasksByIds(List<String> ids) async {
    return ids.map((id) => _tasks[id]).whereType<DownloadTask>().toList();
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
    // Remove associated sessions
    _sessions.removeWhere((_, session) => session.taskId == id);
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
    _sessions[session.id] = session;
    return session;
  }

  @override
  Future<DownloadSession?> getSession(String id) async {
    return _sessions[id];
  }

  @override
  Future<List<DownloadSession>> getSessionsByTaskId(String taskId) async {
    return _sessions.values
        .where((session) => session.taskId == taskId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<List<DownloadSession>> getSessionsByStatus(
    DownloadSessionStatus status,
  ) async {
    return _sessions.values
        .where((session) => session.status == status)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<List<BulkDownloadSession>> getActiveSessions() async {
    final sessions = _sessions.values
        .where((session) => session.status != DownloadSessionStatus.completed)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return _toBulkDownloadSessions(sessions);
  }

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

    var filteredSessions = _sessions.values
        .where(
          (session) =>
              session.status == DownloadSessionStatus.completed &&
              (startDate == null || session.startedAt.isAfter(startDate)) &&
              (endDate == null || session.startedAt.isBefore(endDate)),
        )
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Always apply pagination with sanitized values
    filteredSessions =
        filteredSessions.skip(sanitizedOffset).take(sanitizedLimit).toList();

    return _toBulkDownloadSessions(filteredSessions);
  }

  Future<List<BulkDownloadSession>> _toBulkDownloadSessions(
    List<DownloadSession> sessions,
  ) async {
    final result = <BulkDownloadSession>[];

    for (final session in sessions) {
      final task = _tasks[session.taskId];
      if (task == null) continue;

      final stats = await getSessionStats(session.id);

      result.add(
        BulkDownloadSession(
          session: session,
          task: task,
          stats: stats,
        ),
      );
    }

    return result;
  }

  @override
  Future<List<DownloadSession>> getSessionsByStatuses(
    List<DownloadSessionStatus> statuses,
  ) async {
    return _sessions.values
        .where((session) => statuses.contains(session.status))
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<void> updateSession(
    String id, {
    DownloadSessionStatus? status,
    int? currentPage,
    int? totalPages,
    String? error,
  }) async {
    final session = _sessions[id];
    if (session == null) return;

    _sessions[id] = session.copyWith(
      status: status ?? session.status,
      currentPage: currentPage ?? session.currentPage,
      totalPages: totalPages ?? session.totalPages,
      error: error,
    );
  }

  @override
  Future<void> completeSession(String id) async {
    final session = _sessions[id];
    if (session == null) return;

    _sessions[id] = session.copyWith(
      status: DownloadSessionStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  @override
  Future<void> createRecord(DownloadRecord record) async {
    _records[record.sessionId] ??= [];
    _records[record.sessionId]!.add(record);
  }

  @override
  Future<void> createRecords(List<DownloadRecord> records) async {
    for (final record in records) {
      await createRecord(record);
    }
  }

  @override
  Future<List<DownloadRecord>> getRecordsBySessionId(String sessionId) async {
    return (_records[sessionId] ?? [])
      ..sort((a, b) {
        final pageCompare = a.page.compareTo(b.page);
        if (pageCompare != 0) return pageCompare;
        return a.pageIndex.compareTo(b.pageIndex);
      });
  }

  @override
  Future<List<DownloadRecord>> getPendingRecordsBySessionId(
    String sessionId,
  ) async {
    return (_records[sessionId] ?? [])
        .where((record) => record.status == DownloadRecordStatus.pending)
        .toList()
      ..sort((a, b) {
        final pageCompare = a.page.compareTo(b.page);
        if (pageCompare != 0) return pageCompare;
        return a.pageIndex.compareTo(b.pageIndex);
      });
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
    final records = _records[sessionId] ?? [];
    final index = records.indexWhere(
      (record) => record.url == url && record.sessionId == sessionId,
    );
    if (index != -1) {
      records[index] = records[index].copyWith(
        status: status,
        fileSize: fileSize,
        fileName: fileName,
        extension: extension,
        error: error,
        downloadId: downloadId,
      );
    }
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
    final records = _records[sessionId] ?? [];
    final index = records.indexWhere(
      (record) => record.downloadId == downloadId,
    );
    if (index != -1) {
      records[index] = records[index].copyWith(
        status: status,
        fileSize: fileSize,
        fileName: fileName,
        extension: extension,
        error: error,
      );
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.remove(id);
    _records.remove(id);
  }

  @override
  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatus(
    String sessionId,
    DownloadRecordStatus status,
  ) async {
    return (_records[sessionId] ?? [])
        .where((record) => record.status == status)
        .toList()
      ..sort((a, b) {
        final pageCompare = a.page.compareTo(b.page);
        if (pageCompare != 0) return pageCompare;
        return a.pageIndex.compareTo(b.pageIndex);
      });
  }

  @override
  Future<DownloadRecord?> getRecordByDownloadId(
    String sessionId,
    String downloadId,
  ) async {
    final records = _records[sessionId] ?? [];
    return records.firstWhere(
      (record) => record.downloadId == downloadId,
      orElse: () => throw StateError('Record not found'),
    );
  }

  @override
  Future<List<DownloadRecord>> getRecordsBySessionIdAndStatuses(
    String sessionId,
    List<DownloadRecordStatus> statuses,
  ) async {
    if (statuses.isEmpty) return [];

    return (_records[sessionId] ?? [])
        .where((record) => statuses.contains(record.status))
        .toList()
      ..sort((a, b) {
        final pageCompare = a.page.compareTo(b.page);
        if (pageCompare != 0) return pageCompare;
        return a.pageIndex.compareTo(b.pageIndex);
      });
  }

  @override
  Future<void> resetSessions(List<String> sessionIds) async {
    if (sessionIds.isEmpty) return;

    // Remove all records for these sessions
    for (final sessionId in sessionIds) {
      _records.remove(sessionId);
    }

    // Reset sessions to pending state
    for (final sessionId in sessionIds) {
      final session = _sessions[sessionId];
      if (session != null) {
        _sessions[sessionId] = session.copyWith(
          status: DownloadSessionStatus.pending,
          error: null,
          currentPage: 1,
          totalPages: null,
        );
      }
    }
  }

  @override
  Future<void> updateSessionsStatus(
    List<String> sessionIds,
    DownloadSessionStatus status,
  ) async {
    if (sessionIds.isEmpty) return;

    for (final sessionId in sessionIds) {
      final session = _sessions[sessionId];
      if (session != null) {
        _sessions[sessionId] = session.copyWith(status: status);
      }
    }
  }
}
