// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import '../../../analytics.dart';
import '../../../blacklists/providers.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/ref.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/permissions.dart';
import '../../../http/http.dart';
import '../../../http/providers.dart';
import '../../../posts/filter/filter.dart';
import '../../../posts/post/post.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/sources/source.dart';
import '../../../premiums/providers.dart';
import '../../../settings/providers.dart';
import '../../../utils/duration_utils.dart';
import '../../downloader.dart';
import '../../filename/generator_impl.dart';
import '../../manager.dart';
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
import 'file_system_download_exist_checker.dart';
import 'providers.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart'
    hide DownloadTask, PermissionStatus;

const _perPage = 100;
const _serviceName = 'Bulk Download Manager';

final bulkDownloadProvider =
    NotifierProvider<BulkDownloadNotifier, BulkDownloadState>(
  BulkDownloadNotifier.new,
);

final bulkDownloadSessionsProvider = Provider<List<BulkDownloadSession>>((ref) {
  return ref.watch(bulkDownloadProvider.select((e) => e.sessions));
});

class BulkDownloadNotifier extends Notifier<BulkDownloadState> {
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
    ref.listen(
      downloadTaskStreamProvider,
      (prev, next) {
        if (prev != next) {
          next.whenData((event) {
            if (event is TaskStatusUpdate) {
              if (event.status == TaskStatus.complete) {
                event.task.filePath().then((value) {
                  final fileSize = File(value).lengthSync();

                  updateRecord(
                    event.task.group,
                    event.task.taskId,
                    DownloadRecordStatus.completed,
                    fileSize: fileSize,
                  );
                });
              }

              updateRecord(
                event.task.group,
                event.task.taskId,
                switch (event.status) {
                  TaskStatus.enqueued => DownloadRecordStatus.pending,
                  TaskStatus.running => DownloadRecordStatus.downloading,
                  TaskStatus.complete => DownloadRecordStatus.completed,
                  TaskStatus.notFound => DownloadRecordStatus.failed,
                  TaskStatus.failed => DownloadRecordStatus.failed,
                  TaskStatus.canceled => DownloadRecordStatus.cancelled,
                  TaskStatus.waitingToRetry => DownloadRecordStatus.downloading,
                  TaskStatus.paused => DownloadRecordStatus.downloading,
                },
              );
            }
          });
        }
      },
    );

    _loadTasks(init: true);
    return const BulkDownloadState();
  }

  Future<void> ensureIntegrity() async {
    final repo = await ref.read(downloadRepositoryProvider.future);

    final interruptedSessions = await repo.getSessionsByStatuses([
      DownloadSessionStatus.running,
      DownloadSessionStatus.dryRun,
    ]);

    final dryRunSessions = interruptedSessions
        .where((e) => e.status == DownloadSessionStatus.dryRun)
        .toList();
    final runningSessions = interruptedSessions
        .where((e) => e.status == DownloadSessionStatus.running)
        .toList();

    // For dry run sessions, just reset to pending cause the data are already stale
    // Also do cleanup by deleting all records associated with the session
    if (dryRunSessions.isNotEmpty) {
      await repo.resetSessions(dryRunSessions.map((e) => e.id).toList());
    }

    // For running sessions, mark them as interrupted
    if (runningSessions.isNotEmpty) {
      await repo.updateSessionsStatus(
        runningSessions.map((e) => e.id).toList(),
        DownloadSessionStatus.interrupted,
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

  Future<List<Post>> _getPosts(
    String tags,
    int page,
  ) async {
    final config = ref.readConfigSearch;
    final postRepo = ref.read(postRepoProvider(config));

    final r = await postRepo.getPostsFromTagsOrEmpty(
      tags,
      page: page,
      limit: _perPage,
    );

    return r.posts;
  }

  Future<void> queueDownloadLater(
    DownloadOptions options, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final androidSdkVersion = downloadConfigs?.androidSdkVersion;

    if (!options.valid(androidSdkInt: androidSdkVersion)) {
      throw const InvalidDownloadOptionsError();
    }

    final task = await _withRepo((repo) => repo.createTask(options));
    final _ = await _withRepo((repo) => repo.createSession(task.id));
    await _loadTasks();

    return;
  }

  Future<void> startPendingSession(String sessionId) async {
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

    await _startDownloadWithSession(task, session);
  }

  Future<void> _startDownloadWithSession(
    DownloadTask task,
    DownloadSession session, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final authConfig = ref.readConfigAuth;
    final config = ref.readConfig;

    final fallbackDownloader = ref.read(downloadServiceProvider(authConfig));
    final downloader = downloadConfigs?.downloader ?? fallbackDownloader;

    final fallbackSettings = ref.read(settingsProvider);
    final settings = downloadConfigs?.settings ?? fallbackSettings;

    final fallbackDownloadFileUrlExtractor =
        ref.read(downloadFileUrlExtractorProvider(authConfig));
    final downloadFileUrlExtractor =
        downloadConfigs?.urlExtractor ?? fallbackDownloadFileUrlExtractor;

    final fallbackHeaders =
        ref.read(cachedBypassDdosHeadersProvider(config.url));
    final headers = downloadConfigs?.headers ?? fallbackHeaders;

    final fileNameBuilder = downloadConfigs?.fileNameBuilder ??
        ref.read(currentBooruBuilderProvider)?.downloadFilenameBuilder ??
        fallbackFileNameBuilder;

    final fallbackBlacklistedTags =
        await ref.read(blacklistTagsProvider(authConfig).future);
    final blacklistedTags =
        downloadConfigs?.blacklistedTags ?? fallbackBlacklistedTags;
    final patterns = blacklistedTags
        .map((tag) => tag.split(' ').map(TagExpression.parse).toList())
        .toList();

    final mediaPermManager = ref.read(mediaPermissionManagerProvider);

    final fileExistChecker =
        downloadConfigs?.existChecker ?? const FileSystemDownloadExistChecker();

    final logger = ref.read(loggerProvider);

    final analytics = ref.read(analyticsProvider);

    final sessionId = session.id;
    DownloadSession? currentSession = session;

    await _loadTasks();

    final permission = await mediaPermManager.check();
    logger.logI(
      _serviceName,
      'Download requested for "${task.tags}" at "${task.path}" with permission status: $permission',
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

    unawaited(
      analytics.logEvent(
        'bulk_download_start',
        parameters: {
          'quality': task.quality,
          'skip_if_exists': task.skipIfExists,
          'notifications': task.notifications,
        },
      ),
    );

    try {
      var page = 1;
      final tags = task.tags?.trim() ?? '';

      if (tags.isEmpty) {
        await _updateSession(
          sessionId,
          status: DownloadSessionStatus.failed,
          error: const EmptyTagsError().toString(),
        );
        return;
      }

      var rawPosts = <Post>[];

      currentSession = await _updateSession(
        sessionId,
        status: DownloadSessionStatus.dryRun,
        currentPage: page,
      );

      final initialPosts = await _getPosts(tags, page);

      if (initialPosts.isEmpty) {
        await _updateSession(
          sessionId,
          status: DownloadSessionStatus.failed,
          error: const NoPostsFoundError().toString(),
        );
        return;
      }

      // Then apply blacklist filtering
      final filteredPosts =
          await _filterBlacklistedTags(initialPosts, patterns);
      rawPosts = filteredPosts;

      while (currentSession?.status == DownloadSessionStatus.dryRun) {
        final records = <DownloadRecord>[];

        for (var i = 0; i < rawPosts.length; i++) {
          final item = rawPosts[i];

          final urlData = await downloadFileUrlExtractor.getDownloadFileUrl(
            post: item,
            quality: task.quality ?? settings.downloadQuality.name,
          );
          if (urlData == null || urlData.url.isEmpty) continue;

          final fileName = await fileNameBuilder.generateForBulkDownload(
            settings,
            config,
            item,
            metadata: {
              'index': i.toString(),
            },
            downloadUrl: urlData.url,
          );

          if (task.skipIfExists) {
            final exists = fileExistChecker.exists(fileName, task.path);

            // skip if file exists
            if (exists) {
              continue;
            }
          }

          records.add(
            DownloadRecord(
              url: urlData.url,
              fileName: fileName,
              fileSize: item.fileSize,
              sessionId: sessionId,
              status: DownloadRecordStatus.pending,
              extension: extension(fileName),
              page: page,
              pageIndex: i,
              createdAt: DateTime.now(),
              headers: {
                ...headers,
                if (urlData.cookie != null)
                  AppHttpHeaders.cookieHeader: urlData.cookie!,
              },
              thumbnailImageUrl: item.thumbnailImageUrl,
              sourceUrl: config.url,
            ),
          );
        }

        if (records.isNotEmpty) {
          // Batch create records
          await _withRepo((repo) => repo.createRecords(records));
        }

        currentSession = await _updateSession(
          sessionId,
          currentPage: page,
        );

        page++;

        // Early exit if session is not in dry run so user doesn't have to wait
        if (currentSession?.status != DownloadSessionStatus.dryRun) {
          break;
        }

        final delay = downloadConfigs?.delayBetweenRequests;
        if (delay != null) {
          await delay.future;
        }

        final items = await _getPosts(tags, page);

        // No more items, stop dry run
        if (items.isEmpty) {
          page--;
          break;
        }

        final filtered = await _filterBlacklistedTags(items, patterns);

        rawPosts = filtered;
      }

      final pendings = await _withRepo(
        (repo) => repo.getPendingRecordsBySessionId(sessionId),
      );

      if (pendings.isEmpty) {
        await _updateSession(
          sessionId,
          status: DownloadSessionStatus.allSkipped,
        );
        return;
      }

      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.running,
        totalPages: page,
      );

      currentSession = await _withRepo((repo) => repo.getSession(sessionId));
      final stats =
          await _withRepo((repo) => repo.getActionSessionStats(sessionId));

      await _updateSessionWithState(sessionId, currentSession, stats: stats);

      for (final record in pendings) {
        await _withRepo(
          (repo) => repo.updateRecord(
            url: record.url,
            sessionId: record.sessionId,
            status: DownloadRecordStatus.downloading,
          ),
        );

        final result = await downloader
            .downloadCustomLocation(
              url: record.url,
              path: task.path,
              filename: record.fileName,
              skipIfExists: false, // We already handled this in the dry run
              headers: record.headers,
              metadata: DownloaderMetadata(
                thumbnailUrl: record.thumbnailImageUrl,
                fileSize: record.fileSize,
                siteUrl: PostSource.from(record.thumbnailImageUrl).url,
                group: sessionId,
              ),
            )
            .run();

        await result.fold(
          (error) async {
            await _withRepo(
              (repo) => repo.updateRecord(
                url: record.url,
                sessionId: record.sessionId,
                error: error.toString(),
                status: DownloadRecordStatus.failed,
              ),
            );
          },
          (info) async {
            await _withRepo(
              (repo) => repo.updateRecord(
                url: record.url,
                sessionId: record.sessionId,
                downloadId: info.id,
              ),
            );
          },
        );

        // Delay to prevent too many requests
        final delay = downloadConfigs?.delayBetweenDownloads;
        if (delay != null) {
          await delay.future;
        }
      }
    } catch (e) {
      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.failed,
        error: e.toString(),
      );
    }
  }

  Future<void> downloadFromOptions(
    DownloadOptions options, {
    DownloadConfigs? downloadConfigs,
  }) async {
    final androidSdkVersion = downloadConfigs?.androidSdkVersion;

    if (!options.valid(androidSdkInt: androidSdkVersion)) {
      throw const InvalidDownloadOptionsError();
    }

    final hasPremium = ref.read(hasPremiumProvider);

    // Only allow one download session for free users
    if (!hasPremium) {
      final activeSessions = await getRunningSessions();

      if (activeSessions > 0) {
        throw const FreeUserMultipleDownloadSessionsError();
      }
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
    final initialSession =
        await _withRepo((repo) => repo.createSession(task.id));

    await _startDownloadWithSession(
      task,
      initialSession,
      downloadConfigs: downloadConfigs,
    );
  }

  Future<void> cancelSession(String sessionId) async {
    try {
      final config = ref.readConfigAuth;
      final downloader = ref.read(downloadServiceProvider(config));
      final session = await _withRepo((repo) => repo.getSession(sessionId));

      if (session == null ||
          (session.status != DownloadSessionStatus.running &&
              session.status != DownloadSessionStatus.failed &&
              session.status != DownloadSessionStatus.pending)) {
        return;
      }

      final records =
          await _withRepo((repo) => repo.getRecordsBySessionId(sessionId));

      await _updateSession(
        sessionId,
        status: DownloadSessionStatus.cancelled,
      );

      unawaited(
        downloader.cancelTasksWithIds(records.map((e) => e.url).toList()),
      );
    } catch (e) {
      state = state.copyWith(
        error: () => e is BulkDownloadError ? e : Exception(e.toString()),
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      // Check if task exists
      final task = await _withRepo((repo) => repo.getTask(taskId));
      if (task == null) {
        state = state.copyWith(
          error: TaskNotFoundError.new,
        );
        return;
      }

      // Check for active sessions
      final sessions =
          await _withRepo((repo) => repo.getSessionsByTaskId(taskId));
      final hasActiveSessions = sessions.any(
        (s) =>
            s.status == DownloadSessionStatus.running ||
            s.status == DownloadSessionStatus.dryRun,
      );

      if (hasActiveSessions) {
        state = state.copyWith(
          error: TaskHasActiveSessionsError.new,
        );
        return;
      }

      // Delete task and related sessions
      await _withRepo((repo) => repo.deleteTask(taskId));

      await _loadTasks();
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      final session = await _withRepo((repo) => repo.getSession(sessionId));

      if (session == null) {
        state = state.copyWith(
          error: SessionNotFoundError.new,
        );
      }

      await _withRepo((repo) => repo.deleteSession(sessionId));
      await _loadTasks();
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }

  Future<void> stopDryRun(String sessionId) async {
    // check if session is in dry run
    final session = await _withRepo((repo) => repo.getSession(sessionId));

    if (session?.status != DownloadSessionStatus.dryRun) return;

    await _updateSession(
      sessionId,
      status: DownloadSessionStatus.running,
    );
  }

  Future<void> tryCompleteSession(String sessionId) async {
    try {
      var session = await _withRepo((repo) => repo.getSession(sessionId));
      if (session == null) {
        state = state.copyWith(
          error: SessionNotFoundError.new,
        );
        return;
      }

      if (session.status != DownloadSessionStatus.running) {
        state = state.copyWith(
          error: SessionNotRunningError.new,
        );
        return;
      }

      final records = await _withRepo(
        (repo) => repo.getRecordsBySessionIdAndStatus(
          sessionId,
          DownloadRecordStatus.completed,
        ),
      );

      // Get total records to compare
      final totalRecords =
          await _withRepo((repo) => repo.getRecordsBySessionId(sessionId));
      final allCompleted = records.length == totalRecords.length;

      if (!allCompleted) {
        state = state.copyWith(
          error: IncompleteDownloadsError.new,
        );
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
        unawaited(
          ref.read(bulkDownloadNotificationProvider).showNotification(
                currentSessionState?.task.tags ?? 'Download completed',
                'Downloaded ${stats.totalItems} files',
              ),
        );
      }

      await _loadTasks();
    } catch (e) {
      state = state.copyWith(
        error: DatabaseOperationError.new,
      );
    }
  }

  Future<void> updateRecord(
    String sessionId,
    String downloadId,
    DownloadRecordStatus status, {
    int? fileSize,
  }) async {
    try {
      final record = await _withRepo(
        (repo) => repo.getRecordByDownloadId(
          sessionId,
          downloadId,
        ),
      );

      if (record == null) {
        state = state.copyWith(
          error: DownloadRecordNotFoundError.new,
        );
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
    } catch (e) {
      state = state.copyWith(
        error: DatabaseOperationError.new,
      );
    }
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

    return session;
  }

  Future<void> createSavedTask(
    DownloadTask task, {
    String? name,
  }) async {
    try {
      await _withRepo(
        (repo) => repo.createSavedTask(
          task.id,
          name ?? 'Untitled',
        ),
      );
      await _loadTasks();
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> editTask(DownloadTask newTask) async {
    try {
      final currentTask = await _withRepo((repo) => repo.getTask(newTask.id));

      // if there is no changes, just return
      if (currentTask == newTask) return;

      await _withRepo((repo) => repo.editTask(newTask));
      await _loadTasks();
    } catch (e) {
      state = state.copyWith(error: () => e);
    }
  }

  Future<void> runSavedTask(SavedDownloadTask savedTask) async {
    try {
      // Start downloading the existing task directly
      await downloadFromTask(savedTask.task);
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
}

Future<List<Post>> _filterBlacklistedTags(
  List<Post> posts,
  Iterable<List<TagExpression>>? patterns,
) =>
    Isolate.run(() => _filterInIsolate(posts, patterns));

List<Post> _filterInIsolate(
  List<Post> posts,
  Iterable<List<TagExpression>>? patterns,
) {
  if (patterns == null || patterns.isEmpty) return posts;

  final filterIds = <int>{};

  for (final post in posts) {
    for (final pattern in patterns) {
      if (post.containsTagPattern(pattern)) {
        filterIds.add(post.id);
        break;
      }
    }
  }

  return posts.where((e) => !filterIds.contains(e.id)).toList();
}
