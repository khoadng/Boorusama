// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../../foundation/permissions.dart';
import '../../../../foundation/platform.dart';
import '../../../../foundation/utils/duration_utils.dart';
import '../../../analytics/providers.dart';
import '../../../configs/config/providers.dart';
import '../../../download_manager/providers.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../downloads/downloader/types.dart' as d;
import '../../../posts/sources/types.dart';
import '../../../premiums/providers.dart';
import '../notifications/providers.dart';
import '../types/bulk_download_error.dart';
import '../types/bulk_download_session.dart';
import '../types/bulk_download_state.dart';
import '../types/download_configs.dart';
import '../types/download_options.dart';
import '../types/download_record.dart';
import '../types/download_repository.dart';
import '../types/download_session.dart';
import '../types/download_session_stats.dart';
import '../types/download_task.dart';
import '../types/saved_download_task.dart';
import 'bulk_progress.dart';
import 'dry_run.dart';
import 'dry_run_state.dart';
import 'file_system_exist_checker.dart';
import 'providers.dart';
import 'saved_task_lock_notifier.dart';
import 'session_cancellation_provider.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart'
    hide DownloadTask, PermissionStatus;

const _serviceName = 'Bulk Download Manager';
const kBulkDownloadAsyncDelay = Duration(milliseconds: 1000);

final bulkDownloadProvider =
    NotifierProvider<BulkDownloadNotifier, BulkDownloadState>(
      BulkDownloadNotifier.new,
    );

final bulkDownloadSessionsProvider = Provider<List<BulkDownloadSession>>((ref) {
  return ref.watch(bulkDownloadProvider.select((e) => e.sessions));
});

extension SessionActionX on BulkDownloadSession {
  bool get actionable {
    final status = session.status;

    return status == DownloadSessionStatus.completed ||
            status == DownloadSessionStatus.cancelled ||
            status == DownloadSessionStatus.failed ||
            status == DownloadSessionStatus.allSkipped
        ? false
        : true;
  }

  bool get canViewInvidualProgresses {
    final status = session.status;

    return status == DownloadSessionStatus.running ||
        status == DownloadSessionStatus.paused;
  }
}

class BulkDownloadNotifier extends Notifier<BulkDownloadState> {
  CancelToken _createSessionToken(String sessionId) {
    return ref
        .read(sessionCancellationProvider.notifier)
        .createToken(sessionId);
  }

  void _cancelSessionToken(String sessionId) {
    ref.read(sessionCancellationProvider.notifier).cancelToken(sessionId);
  }

  Future<T> _withRepo<T>(Future<T> Function(DownloadRepository repo) fn) async {
    final repo = await ref.read(downloadRepositoryProvider.future);
    return fn(repo);
  }

  Future<T?> _withRepoNull<T>(
    Future<T?> Function(DownloadRepository repo) fn,
  ) async {
    final repo = await ref.read(downloadRepositoryProvider.future);
    return fn(repo);
  }

  @override
  BulkDownloadState build() {
    final completionTimers = <String, Timer>{};
    final progressUpdateTimers = <String, Timer>{};

    final progressNotifier = ref.watch(bulkDownloadProgressProvider.notifier);
    final sessionCancellationNotifier = ref.watch(
      sessionCancellationProvider.notifier,
    );

    void scheduleProgressUpdate(String sessionId) {
      if (progressUpdateTimers.containsKey(sessionId)) {
        // A timer is already scheduled; skip this event.
        return;
      }
      progressUpdateTimers[sessionId] = Timer(
        const Duration(milliseconds: 500),
        () async {
          final repo = await ref.read(downloadRepositoryProvider.future);
          final completedCount = await repo.getRecordsCountBySessionId(
            sessionId,
            status: DownloadRecordStatus.completed,
          );
          final totalCount = await repo.getRecordsCountBySessionId(sessionId);

          final session = await repo.getSession(sessionId);

          // Only show progress if session is running AND notifications are enabled
          if (session?.status == DownloadSessionStatus.running &&
              (session?.task?.notifications ?? false) &&
              !isIOS()) {
            final notification = ref.read(bulkDownloadNotificationProvider);
            await notification.showProgressNotification(
              sessionId,
              session?.task?.prettyTags ?? 'Downloading...',
              '$completedCount/$totalCount files',
              completed: completedCount,
              total: totalCount,
            );
          }

          // Always update progress state regardless of notifications
          progressNotifier.updateProgressFromCounts(
            sessionId,
            completedCount,
            totalCount,
          );

          progressUpdateTimers.remove(sessionId);
        },
      );
    }

    void scheduleCompletionCheck(String sessionId) {
      completionTimers[sessionId]?.cancel();

      completionTimers[sessionId] = Timer(
        const Duration(milliseconds: 100),
        () {
          tryCompleteSession(sessionId);
          completionTimers.remove(sessionId);
        },
      );
    }

    ref
      ..listen(
        downloadTaskStreamProvider,
        (prev, next) {
          if (prev != next) {
            next.whenData((event) {
              if (event.task.isDefaultGroup) {
                return;
              }

              if (event is TaskStatusUpdate) {
                if (event.status == TaskStatus.complete) {
                  ref
                      .read(taskFileSizeResolverProvider(event.task).future)
                      .then(
                        (fileSize) {
                          updateRecordFromTaskStream(
                            event.task.group,
                            event.task.taskId,
                            DownloadRecordStatus.completed,
                            fileSize: fileSize,
                          );
                        },
                      );

                  scheduleCompletionCheck(event.task.group);
                }

                updateRecordFromTaskStream(
                  event.task.group,
                  event.task.taskId,
                  switch (event.status) {
                    TaskStatus.enqueued => DownloadRecordStatus.pending,
                    TaskStatus.running => DownloadRecordStatus.downloading,
                    TaskStatus.complete => DownloadRecordStatus.completed,
                    TaskStatus.notFound => DownloadRecordStatus.failed,
                    TaskStatus.failed => DownloadRecordStatus.failed,
                    TaskStatus.canceled => DownloadRecordStatus.cancelled,
                    TaskStatus.waitingToRetry =>
                      DownloadRecordStatus.downloading,
                    TaskStatus.paused => DownloadRecordStatus.paused,
                  },
                );
              } else if (event is TaskProgressUpdate) {
                scheduleProgressUpdate(event.task.group);
              }
            });
          }
        },
      )
      ..onDispose(() {
        for (final timer in completionTimers.values) {
          timer.cancel();
        }

        for (final timer in progressUpdateTimers.values) {
          timer.cancel();
        }

        sessionCancellationNotifier.cancelAll();
      });

    _loadTasks(init: true);
    return const BulkDownloadState();
  }

  Future<void> ensureIntegrity() async {
    final repo = await ref.read(downloadRepositoryProvider.future);

    final interruptedSessions = await repo.getSessionsByStatuses([
      DownloadSessionStatus.running,
      DownloadSessionStatus.dryRun,
      DownloadSessionStatus.paused,
    ]);

    final dryRunSessions = interruptedSessions
        .where((e) => e.status == DownloadSessionStatus.dryRun)
        .toList();
    final runningSessions = interruptedSessions
        .where(
          (e) =>
              e.status == DownloadSessionStatus.running ||
              e.status == DownloadSessionStatus.paused,
        )
        .toList();

    // For dry run sessions, just reset to pending cause the data are already stale
    // Also do cleanup by deleting all records associated with the session
    if (dryRunSessions.isNotEmpty) {
      await repo.resetSessions(dryRunSessions.map((e) => e.id).toList());
    }

    // For running and paused sessions, mark them as suspended
    if (runningSessions.isNotEmpty) {
      await repo.updateSessionsStatus(
        runningSessions.map((e) => e.id).toList(),
        DownloadSessionStatus.suspended,
      );
    }
  }

  Future<void> _loadTasks({
    bool init = false,
  }) async {
    try {
      if (init) {
        await ensureIntegrity();
      }

      final sessions = await _withRepo((repo) => repo.getActiveSessions());

      state = state.copyWith(
        sessions: sessions,
        ready: init ? true : null,
      );
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<bool> _shouldExitForFreeUser() async {
    final hasPremium = ref.read(hasPremiumProvider);

    // check for session limit for non-premium users
    if (!hasPremium) {
      final sessions = await _withRepo(
        (repo) => repo.getSessionsByStatuses([
          DownloadSessionStatus.running,
          DownloadSessionStatus.paused,
          DownloadSessionStatus.dryRun,
        ]),
      );

      if (sessions.isNotEmpty) {
        state = state.copyWith(
          error: FreeUserMultipleDownloadSessionsError.new,
        );
        return true;
      }
    }

    return false;
  }

  Future<void> queueDownloadLater(
    DownloadOptions options, {
    DownloadConfigs? downloadConfigs,
    void Function(BulkDownloadOptionsError e)? onOptionsError,
  }) async {
    final androidSdkVersion = downloadConfigs?.androidSdkVersion;
    final config = ref.readConfigAuth;

    if (!options.valid(androidSdkInt: androidSdkVersion)) {
      onOptionsError?.call(const InvalidDownloadOptionsError());
      return;
    }

    final task = await _withRepo((repo) => repo.createTask(options));
    final _ = await _withRepo((repo) => repo.createSession(task, config));
    await _loadTasks();

    return;
  }

  Future<void> startPendingSession(
    String sessionId, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final session = await _withRepo((repo) => repo.getSession(sessionId));

    if (session == null) {
      state = state.copyWith(
        error: SessionNotFoundError.new,
      );
      return;
    }

    if (session.status != DownloadSessionStatus.pending) {
      state = state.copyWith(
        error: () => Exception('Session is not in pending state'),
      );
      return;
    }

    final taskId = session.taskId;

    if (taskId == null) {
      state = state.copyWith(
        error: TaskNotFoundError.new,
      );
      return;
    }

    final task = await _withRepo((repo) => repo.getTask(taskId));

    if (task == null) {
      state = state.copyWith(
        error: TaskNotFoundError.new,
      );
      return;
    }

    await _startDownloadWithSession(
      task,
      session,
      downloadConfigs: downloadConfigs,
    );
  }

  Future<void> _startDownloadWithSession(
    DownloadTask task,
    DownloadSession session, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final path = task.path;
    final directoryChecker =
        downloadConfigs?.directoryExistChecker ??
        const FileSystemDirectoryExistChecker();

    // Check if directory exists
    if (!directoryChecker.exists(path)) {
      await _updateSession(
        session.id,
        status: DownloadSessionStatus.failed,
        error: const DirectoryNotFoundError().toString(),
      );
      await _loadTasks();
      return;
    }

    final mediaPermManager = ref.read(mediaPermissionManagerProvider);

    final notificationPermManager =
        downloadConfigs?.notificationPermissionManager != null
        ? downloadConfigs!.notificationPermissionManager!
        : ref.read(notificationPermissionManagerProvider);

    final logger = ref.read(loggerProvider);

    final sessionId = session.id;
    DownloadSession? currentSession = session;

    await _loadTasks();

    final shouldExit = await _shouldExitForFreeUser();

    if (shouldExit) {
      return;
    }

    final permission = await mediaPermManager.check();
    logger.info(
      _serviceName,
      'Download requested for "${task.prettyTags}" at "${task.path}" with permission status: $permission',
    );

    if (permission == PermissionStatus.permanentlyDenied) {
      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.failed,
        error: const StoragePermanentlyDeniedError().toString(),
      );
      return;
    }

    if (permission != PermissionStatus.granted) {
      final status = await mediaPermManager.request();
      if (status != PermissionStatus.granted) {
        await _updateSession(
          sessionId,
          status: DownloadSessionStatus.failed,
          error: const StoragePermissionDeniedError().toString(),
        );
        return;
      }
    }

    if (task.notifications) {
      await notificationPermManager.requestIfNotGranted();
    }

    ref.read(analyticsProvider).whenData((analytics) {
      analytics?.logEvent(
        'bulk_download_start',
        parameters: {
          'quality': task.quality,
          'skip_if_exists': task.skipIfExists,
          'notifications': task.notifications,
        },
      );
    });

    try {
      final cancelToken = _createSessionToken(sessionId);

      if (downloadConfigs?.onDownloadStart != null) {
        downloadConfigs!.onDownloadStart!();
      }

      currentSession = await _updateSession(
        sessionId,
        status: DownloadSessionStatus.dryRun,
        currentPage: 1,
      );

      if (currentSession == null) {
        await _updateSession(
          sessionId,
          status: DownloadSessionStatus.failed,
          error: 'Session not found after initial update',
        );
        return;
      }

      // Start dry run using the notifier family
      final dryRunNotifier = ref.read(
        dryRunNotifierProvider(sessionId).notifier,
      );

      await dryRunNotifier.start(
        currentSession,
        task,
        cancelToken,
        downloadConfigs,
        onPageProgress: (page) async {
          currentSession = await _updateSession(
            sessionId,
            currentPage: page,
          );
        },
        shouldContinue: () async {
          final session = await _withRepoNull(
            (repo) => repo.getSession(sessionId),
          );
          return session?.status == DownloadSessionStatus.dryRun;
        },
      );

      // Get final dry run state
      final dryRunState = await ref.read(
        dryRunNotifierProvider(sessionId).future,
      );

      // Handle dry run result
      if (dryRunState.status is DryRunStatusFailed) {
        await _updateSession(
          sessionId,
          status: DownloadSessionStatus.failed,
          error: dryRunState.error,
        );
        return;
      }

      // Batch create all records
      if (dryRunState.allRecords.isNotEmpty) {
        await _withRepo((repo) => repo.createRecords(dryRunState.allRecords));
      }

      // Cancel token right after dry run is done
      _cancelSessionToken(sessionId);

      final pendingCount = await _withRepo(
        (repo) => repo.getRecordsCountBySessionId(
          sessionId,
          status: DownloadRecordStatus.pending,
        ),
      );

      if (pendingCount == 0) {
        await _updateSession(
          sessionId,
          status: DownloadSessionStatus.allSkipped,
        );
        return;
      }

      final stats = await _withRepo(
        (repo) => repo.getActiveSessionStats(sessionId),
      );

      await _updateSessionWithState(sessionId, currentSession, stats: stats);

      currentSession = await _updateSession(
        sessionId,
        status: DownloadSessionStatus.running,
        totalPages: dryRunState.totalPages,
      );

      await _downloadSessionPages(
        sessionId: sessionId,
        task: task,
        startPage: 1,
        endPage: dryRunState.totalPages,
        downloadConfigs: downloadConfigs,
      );
    } catch (e) {
      _cancelSessionToken(sessionId);

      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.failed,
        error: e.toString(),
      );
    }
  }

  Future<void> pauseSession(String sessionId) async {
    try {
      final session = await _withRepo((repo) => repo.getSession(sessionId));

      if (session == null) {
        state = state.copyWith(
          error: SessionNotFoundError.new,
        );
        return;
      }

      if (session.status != DownloadSessionStatus.running) {
        state = state.copyWith(
          error: () => Exception('Session is not in running state'),
        );
        return;
      }

      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.paused,
      );
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> suspendSession(String sessionId) async {
    try {
      final hasPremium = ref.read(hasPremiumProvider);
      if (!hasPremium) {
        state = state.copyWith(
          error: NonPremiumSuspendError.new,
        );
        return;
      }

      final session = await _withRepo((repo) => repo.getSession(sessionId));

      if (session == null) {
        state = state.copyWith(
          error: SessionNotFoundError.new,
        );
        return;
      }

      if (session.status != DownloadSessionStatus.running) {
        state = state.copyWith(
          error: () => Exception('Session is not in running state'),
        );
        return;
      }

      final downloader = ref.read(downloadServiceProvider);

      // Cancel async token operations for suspended session
      _cancelSessionToken(sessionId);

      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.suspended,
      );

      final nonCompletedStatuses = DownloadRecordStatus.values
          .where((e) => e != DownloadRecordStatus.completed)
          .toList();

      await _withRepo(
        (repo) => repo.updateRecordsByStatus(
          sessionId,
          from: nonCompletedStatuses,
          to: DownloadRecordStatus.pending,
        ),
      );

      await downloader.cancelAll(sessionId);
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> resumeSuspendedSession(
    String sessionId, {
    DownloadConfigs? downloadConfigs,
  }) async {
    try {
      final hasPremium = ref.read(hasPremiumProvider);
      if (!hasPremium) {
        state = state.copyWith(
          error: NonPremiumResumeError.new,
        );
        return;
      }

      final session = await _withRepo((repo) => repo.getSession(sessionId));

      if (session == null) {
        state = state.copyWith(
          error: SessionNotFoundError.new,
        );
        return;
      }

      if (session.status != DownloadSessionStatus.suspended) {
        state = state.copyWith(
          error: () => Exception('Session is not in suspended state'),
        );
        return;
      }

      final taskId = session.taskId;
      if (taskId == null) {
        state = state.copyWith(
          error: TaskNotFoundError.new,
        );
        return;
      }

      final task = await _withRepo((repo) => repo.getTask(taskId));
      if (task == null) {
        state = state.copyWith(
          error: TaskNotFoundError.new,
        );
        return;
      }

      final authOk = await _ensureAuthConfigIntegrity(
        session,
        downloadConfigs: downloadConfigs,
      );

      if (!authOk) {
        return;
      }

      // Reset to initial page so we can start from the beginning
      // This is to ensure that we don't miss any items, completed items will be skipped anyway
      const page = 1;
      final totalPages = session.totalPages;

      if (totalPages == null) {
        state = state.copyWith(
          error: () =>
              Exception('Session is missing page information, cannot resume'),
        );
        return;
      }

      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.running,
        currentPage: page,
      );
      await _downloadSessionPages(
        sessionId: sessionId,
        task: task,
        startPage: page,
        endPage: totalPages,
        downloadConfigs: downloadConfigs,
      );
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> resumeSession(
    String sessionId, {
    DownloadConfigs? downloadConfigs,
  }) async {
    try {
      final currentSession = await _withRepo(
        (repo) => repo.getSession(sessionId),
      );

      if (currentSession == null) {
        state = state.copyWith(error: SessionNotFoundError.new);
        return;
      }

      if (currentSession.status != DownloadSessionStatus.paused) {
        state = state.copyWith(
          error: () => Exception('Session is not in paused state'),
        );
        return;
      }

      final taskId = currentSession.taskId;
      if (taskId == null) {
        state = state.copyWith(error: TaskNotFoundError.new);
        return;
      }

      final task = await _withRepo((repo) => repo.getTask(taskId));
      if (task == null) {
        state = state.copyWith(error: TaskNotFoundError.new);
        return;
      }

      final authOk = await _ensureAuthConfigIntegrity(
        currentSession,
        downloadConfigs: downloadConfigs,
      );

      if (!authOk) {
        return;
      }

      // Check if download is already 100% completed
      final completedCount = await _withRepo(
        (repo) => repo.getRecordsCountBySessionId(
          sessionId,
          status: DownloadRecordStatus.completed,
        ),
      );
      final totalRecords = await _withRepo(
        (repo) => repo.getRecordsCountBySessionId(sessionId),
      );

      if (completedCount == totalRecords) {
        await tryCompleteSession(
          sessionId,
          countInfo: (
            total: totalRecords,
            completed: completedCount,
          ),
        );
        return;
      }

      var page = currentSession.currentPage;
      final totalPages = currentSession.totalPages;

      if (totalPages == null) {
        state = state.copyWith(
          error: () =>
              Exception('Session is missing page information, cannot resume'),
        );
        return;
      }

      // Handle data race that causes page equal to totalPages but not all records are completed
      if (totalPages == page && completedCount < totalRecords) {
        await _updateSession(
          sessionId,
          currentPage: 1,
        );

        page = 1;
      }

      final downloader = ref.read(downloadServiceProvider);

      // Continue downloading items that were paused
      unawaited(downloader.resumeAll(sessionId));

      await _updateSession(sessionId, status: DownloadSessionStatus.running);
      await _downloadSessionPages(
        sessionId: sessionId,
        task: task,
        startPage: page,
        endPage: totalPages,
        downloadConfigs: downloadConfigs,
      );
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> downloadFromOptions(
    DownloadOptions options, {
    DownloadConfigs? downloadConfigs,
    void Function(BulkDownloadOptionsError e)? onOptionsError,
  }) async {
    final androidSdkVersion = downloadConfigs?.androidSdkVersion;

    if (!options.valid(androidSdkInt: androidSdkVersion)) {
      onOptionsError?.call(const InvalidDownloadOptionsError());
      return;
    }

    final task = await _withRepo((repo) => repo.createTask(options));
    await downloadFromTask(
      task,
      downloadConfigs: downloadConfigs,
    );
  }

  Future<void> downloadFromTaskId(
    String taskId, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final task = await _withRepo((repo) => repo.getTask(taskId));
    if (task == null) {
      state = state.copyWith(
        error: TaskNotFoundError.new,
      );
      return;
    }

    await downloadFromTask(
      task,
      downloadConfigs: downloadConfigs,
    );
  }

  Future<void> downloadFromTask(
    DownloadTask task, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final config = ref.readConfigAuth;
    final initialSession = await _withRepo(
      (repo) => repo.createSession(task, config),
    );

    await _startDownloadWithSession(
      task,
      initialSession,
      downloadConfigs: downloadConfigs,
    );
  }

  Future<void> cancelSession(String sessionId) async {
    try {
      final downloader = ref.read(downloadServiceProvider);
      final session = await _withRepo((repo) => repo.getSession(sessionId));
      final progressNotifier = ref.read(bulkDownloadProgressProvider.notifier);
      final notification = ref.read(bulkDownloadNotificationProvider);

      // Cancel notification immediately
      await notification.cancelNotification(sessionId);

      // Cancel async token operations immediately
      _cancelSessionToken(sessionId);

      if (session == null ||
          (session.status != DownloadSessionStatus.running &&
              session.status != DownloadSessionStatus.paused &&
              session.status != DownloadSessionStatus.failed &&
              session.status != DownloadSessionStatus.pending)) {
        return;
      }

      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.cancelled,
      );

      await _withRepo(
        (repo) => repo.updateRecordsByStatus(
          sessionId,
          from: [DownloadRecordStatus.downloading],
          to: DownloadRecordStatus.cancelled,
        ),
      );

      unawaited(
        downloader.cancelAll(sessionId),
      );

      await progressNotifier.removeSession(sessionId);
    } catch (e) {
      state = state.copyWith(
        error: () => e is BulkDownloadError ? e : Exception(e.toString()),
      );
    }
  }

  Future<bool> deleteSession(String sessionId) async {
    final progressNotifier = ref.read(bulkDownloadProgressProvider.notifier);

    try {
      final session = await _withRepo((repo) => repo.getSession(sessionId));

      if (session == null) {
        state = state.copyWith(
          error: SessionNotFoundError.new,
        );
        return false;
      }

      // Add check for running or dry run sessions
      if (session.status == DownloadSessionStatus.running ||
          session.status == DownloadSessionStatus.dryRun) {
        state = state.copyWith(
          error: RunningSessionDeletionError.new,
        );
        return false;
      }

      // Cancel any remaining async token operations before deletion
      _cancelSessionToken(sessionId);

      await _withRepo((repo) => repo.deleteSession(sessionId));

      await progressNotifier.removeSession(sessionId);

      await _loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: () => e);
      return false;
    }
  }

  Future<void> deleteAllCompletedSessions() async {
    try {
      await _withRepo((repo) => repo.deleteAllCompletedSessions());
      await _loadTasks();
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }

  void setError(BulkDownloadError error) {
    state = state.copyWith(error: () => error);
  }

  Future<void> stopDryRun(String sessionId) async {
    final session = await _withRepo((repo) => repo.getSession(sessionId));

    if (session?.status != DownloadSessionStatus.dryRun) return;

    _cancelSessionToken(sessionId);

    await _updateSession(
      sessionId,
      status: DownloadSessionStatus.running,
    );
  }

  Future<void> tryCompleteSession(
    String sessionId, {
    RecordCountInfo? countInfo,
  }) async {
    final progressNotifier = ref.read(bulkDownloadProgressProvider.notifier);

    var session = await _withRepo((repo) => repo.getSession(sessionId));
    if (session == null) {
      return;
    }

    if (countInfo == null) {
      if (session.status != DownloadSessionStatus.running) {
        return;
      }
    }

    var total = countInfo?.total;
    var completed = countInfo?.completed;

    total ??= await _withRepo(
      (repo) => repo.getRecordsCountBySessionId(sessionId),
    );
    completed ??= await _withRepo(
      (repo) => repo.getRecordsCountBySessionId(
        sessionId,
        status: DownloadRecordStatus.completed,
      ),
    );

    final allCompleted = total == completed;

    if (!allCompleted) {
      return;
    }

    session = await _updateSession(
      sessionId,
      status: DownloadSessionStatus.completed,
    );

    // Calculate final statistics and cleanup
    final stats = await _withRepo(
      (repo) => repo.updateStatisticsAndCleanup(sessionId),
    );

    final currentSessionState = state.sessions.firstWhereOrNull(
      (e) => e.session.id == sessionId,
    );

    if (currentSessionState?.task.notifications ?? true) {
      final notification = ref.read(bulkDownloadNotificationProvider);
      unawaited(
        notification.showCompleteNotification(
          currentSessionState?.task.prettyTags ?? 'Download completed',
          'Downloaded ${stats.totalItems} files',
          notificationId: sessionId.hashCode,
        ),
      );
    }

    // Clean up cancel token for completed session
    _cancelSessionToken(sessionId);

    await progressNotifier.removeSession(sessionId);

    state = state.copyWith(
      hasUnseenFinishedSessions: true,
    );

    await _loadTasks();
  }

  Future<bool> _ensureAuthConfigIntegrity(
    DownloadSession currentSession, {
    DownloadConfigs? downloadConfigs,
  }) async {
    // Check if auth config is not changed
    final currentAuthHash = ref.readConfigAuth.computeHash();
    final sessionAuthHash = currentSession.auth.authHash;

    if (sessionAuthHash != currentAuthHash) {
      final confirmation = downloadConfigs?.authChangedConfirmation;

      if (confirmation != null) {
        final confirmed = await confirmation();
        if (!confirmed) {
          return false;
        }
      } else {
        state = state.copyWith(
          error: () => Exception(
            'Current profile is different from the session profile',
          ),
        );
        return false;
      }
    }

    return true;
  }

  void clearUnseenFinishedSessions() {
    state = state.copyWith(
      hasUnseenFinishedSessions: false,
    );
  }

  Future<void> updateRecordFromTaskStream(
    String sessionId,
    String downloadId,
    DownloadRecordStatus status, {
    int? fileSize,
  }) async {
    final record = await _withRepo(
      (repo) => repo.getRecordByDownloadId(
        sessionId,
        downloadId,
      ),
    );

    if (record == null) {
      return;
    }

    final session = await _withRepo((repo) => repo.getSession(sessionId));

    if (session == null) {
      return;
    }

    // if suspended, do not update records, we will update all records manually
    if (session.status == DownloadSessionStatus.suspended &&
        status == DownloadRecordStatus.cancelled) {
      return;
    }

    await _withRepo(
      (repo) => repo.updateRecordByDownloadId(
        sessionId: sessionId,
        downloadId: downloadId,
        status: status,
        fileSize: fileSize,
      ),
    );
  }

  Future<int> getRunningSessions() async {
    final sessions = await _withRepo(
      (repo) => repo.getSessionsByStatuses([
        DownloadSessionStatus.running,
        DownloadSessionStatus.dryRun,
      ]),
    );

    return sessions.length;
  }

  Future<void> _updateSessionWithState(
    String sessionId,
    DownloadSession? session, {
    DownloadSessionStats? stats,
  }) async {
    state = state.copyWith(
      sessions: [
        for (final s in state.sessions)
          if (s.session.id == sessionId)
            s.copyWith(
              session: session,
              stats: stats ?? s.stats,
            )
          else
            s,
      ],
    );
  }

  Future<DownloadSession?> _updateSession(
    String sessionId, {
    DownloadSessionStatus? status,
    String? error,
    int? currentPage,
    int? totalPages,
  }) async {
    await _withRepo(
      (repo) => repo.updateSession(
        sessionId,
        status: status,
        error: error,
        currentPage: currentPage,
        totalPages: totalPages,
      ),
    );
    final session = await _withRepoNull((repo) => repo.getSession(sessionId));
    await _updateSessionWithState(
      sessionId,
      session,
    );

    // Handle notifications based on status and notification settings
    final notification = ref.read(bulkDownloadNotificationProvider);

    // Only show notifications if task.notifications is true
    if (session?.task?.notifications ?? false) {
      if (session?.status == DownloadSessionStatus.dryRun) {
        // Show/update indeterminate progress during dry run
        await notification.showNotification(
          session?.task?.prettyTags ?? 'Preparing download...',
          'Scanning page ${currentPage ?? 1}',
          indeterminate: true,
          notificationId: sessionId.hashCode,
        );
      } else if (status != null &&
          (status == DownloadSessionStatus.completed ||
              status == DownloadSessionStatus.failed ||
              status == DownloadSessionStatus.cancelled ||
              status == DownloadSessionStatus.allSkipped ||
              status == DownloadSessionStatus.running ||
              status == DownloadSessionStatus.suspended)) {
        await notification.cancelNotification(sessionId);
      }
    }

    return session;
  }

  Future<SavedDownloadTask?> createSavedTask(
    DownloadTask task, {
    String? name,
  }) async {
    try {
      final hasPremium = ref.read(hasPremiumProvider);

      if (!hasPremium) {
        final savedTasks = await _withRepo((repo) => repo.getSavedTasks());
        if (savedTasks.isNotEmpty) {
          state = state.copyWith(
            error: NonPremiumSavedTaskLimitError.new,
          );
          return null;
        }
      }

      // Clone the task to prevent any changes to the original task
      final clonedOptions = DownloadOptions.fromTask(task);
      final clonedTask = await _withRepo(
        (repo) => repo.createTask(clonedOptions),
      );

      final savedTask = await _withRepo(
        (repo) => repo.createSavedTask(
          clonedTask,
          name ?? 'Untitled',
        ),
      );
      await _loadTasks();

      return savedTask;
    } catch (e) {
      state = state.copyWith(error: () => e);
      return null;
    }
  }

  Future<void> editSavedTask(SavedDownloadTask newTask) async {
    try {
      await _withRepo((repo) => repo.editTask(newTask.task));
      await _withRepo((repo) => repo.editSavedTask(newTask));
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> runSavedTask(
    SavedDownloadTask savedTask, {
    DownloadConfigs? downloadConfigs,
  }) async {
    try {
      final lockState = await ref.read(savedTaskLockProvider.future);

      if (lockState.isLocked(savedTask.task.id)) {
        state = state.copyWith(
          error: NonPremiumSavedTaskLimitError.new,
        );
        return;
      }

      // Start downloading the existing task directly
      await downloadFromTask(
        savedTask.task,
        downloadConfigs: downloadConfigs,
      );
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> deleteSavedTask(int id) async {
    try {
      await _withRepo((repo) => repo.deleteSavedTask(id));
      await _loadTasks();
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> _downloadSessionPages({
    required String sessionId,
    required DownloadTask task,
    required int startPage,
    required int endPage,
    required DownloadConfigs? downloadConfigs,
  }) async {
    final fallbackDownloader = ref.read(downloadServiceProvider);
    final downloader = downloadConfigs?.downloader ?? fallbackDownloader;

    for (var currentPage = startPage; currentPage <= endPage; currentPage++) {
      final currentSession = await _updateSession(
        sessionId,
        currentPage: currentPage,
      );

      // Check if session is still running
      if (currentSession?.status != DownloadSessionStatus.running) {
        final status = currentSession?.status;

        if (status == DownloadSessionStatus.paused) {
          await downloader.pauseAll(sessionId);
        }

        break;
      }

      await _downloadRecordsForPage(
        sessionId,
        task,
        currentPage,
        downloader,
        downloadConfigs,
      );

      final delay = downloadConfigs?.delayBetweenRequests;
      if (delay != null) {
        await delay.future;
      } else {
        await const Duration(milliseconds: 200).future;
      }
    }
  }

  Future<void> _downloadRecordsForPage(
    String sessionId,
    DownloadTask task,
    int currentPage,
    d.DownloadService downloader,
    DownloadConfigs? downloadConfigs,
  ) async {
    final records = await _withRepo(
      (repo) => repo.getRecordsBySessionId(
        sessionId,
        recordPage: currentPage,
        status: DownloadRecordStatus.pending,
      ),
    );

    if (records.isEmpty) return;

    for (final record in records) {
      // Check if session is still running
      final currentSession = await _withRepoNull(
        (repo) => repo.getSession(sessionId),
      );

      if (currentSession?.status != DownloadSessionStatus.running) {
        break;
      }

      final result = await downloader.download(
        d.DownloadOptions(
          url: record.url,
          path: task.path,
          filename: record.fileName,
          skipIfExists: false, // We already handled this in the dry run
          headers: record.headers,
          metadata: d.DownloaderMetadata(
            thumbnailUrl: record.thumbnailImageUrl,
            fileSize: record.fileSize,
            siteUrl: PostSource.from(record.thumbnailImageUrl).url,
            group: sessionId,
          ),
        ),
      );

      switch (result) {
        case d.DownloadFailure(:final error):
          await _withRepo(
            (repo) => repo.updateRecord(
              url: record.url,
              sessionId: record.sessionId,
              error: error.toString(),
              status: DownloadRecordStatus.failed,
            ),
          );
        case d.DownloadSuccess(:final info):
          await _withRepo(
            (repo) => repo.updateRecord(
              url: record.url,
              sessionId: record.sessionId,
              downloadId: info.id,
              status: DownloadRecordStatus.downloading,
            ),
          );
      }

      // Delay to prevent too many requests
      final delay = downloadConfigs?.delayBetweenDownloads;
      if (delay != null) {
        await delay.future;
      } else {
        await const Duration(milliseconds: 200).future;
      }
    }
  }

  Future<SavedDownloadTask?> createSavedTaskFromOptions(
    DownloadOptions options, {
    String? name,
  }) async {
    try {
      final task = await _withRepo((repo) => repo.createTask(options));
      return createSavedTask(task, name: name);
    } catch (e) {
      state = state.copyWith(error: () => e);
      return null;
    }
  }
}

typedef RecordCountInfo = ({int completed, int total});
