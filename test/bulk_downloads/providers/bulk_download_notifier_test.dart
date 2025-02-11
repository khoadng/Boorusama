// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/analytics.dart';
import 'package:boorusama/core/blacklists/providers.dart';
import 'package:boorusama/core/boorus/booru/booru.dart';
import 'package:boorusama/core/boorus/engine/engine.dart';
import 'package:boorusama/core/boorus/engine/providers.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/downloads/bulks/data/download_repository_provider.dart';
import 'package:boorusama/core/downloads/bulks/data/download_repository_sqlite.dart';
import 'package:boorusama/core/downloads/bulks/notifications.dart';
import 'package:boorusama/core/downloads/bulks/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/downloads/bulks/types/bulk_download_error.dart';
import 'package:boorusama/core/downloads/bulks/types/download_configs.dart';
import 'package:boorusama/core/downloads/bulks/types/download_options.dart';
import 'package:boorusama/core/downloads/bulks/types/download_record.dart';
import 'package:boorusama/core/downloads/bulks/types/download_repository.dart';
import 'package:boorusama/core/downloads/bulks/types/download_session.dart';
import 'package:boorusama/core/downloads/bulks/types/saved_download_task.dart';
import 'package:boorusama/core/downloads/downloader.dart';
import 'package:boorusama/core/downloads/filename.dart';
import 'package:boorusama/core/downloads/urls.dart';
import 'package:boorusama/core/foundation/loggers.dart';
import 'package:boorusama/core/foundation/permissions.dart';
import 'package:boorusama/core/http/providers.dart';
import 'package:boorusama/core/info/device_info.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/core/posts/post/providers.dart';
import 'package:boorusama/core/premiums/providers.dart';
import 'package:boorusama/core/search/queries/tag_query_composer.dart';
import 'package:boorusama/core/search/selected_tags/selected_tag_controller.dart';
import 'package:boorusama/core/settings/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import '../common.dart';

const _options = DownloadOptions(
  path: '/test/path',
  notifications: true,
  skipIfExists: true,
  perPage: 2,
  concurrency: 5,
  tags: ['test_tags'],
);

class MockMediaPermissionManager extends Mock
    implements MediaPermissionManager {}

class DummyLogger implements Logger {
  @override
  void log(String serviceName, String message, {LogLevel? level}) {}

  @override
  void logE(String serviceName, String message) {}

  @override
  void logI(String serviceName, String message) {}

  @override
  void logW(String serviceName, String message) {}
}

final _posts = [
  // page 1
  DummyPost(
    id: 1,
    thumbnailImageUrl: 'test-thumbnail-url-1',
    originalImageUrl: 'test-original-url-1',
    sampleImageUrl: 'test-sample-url-1',
    tags: {'tag1', 'tag2'},
  ),
  DummyPost(
    id: 2,
    thumbnailImageUrl: 'test-thumbnail-url-2',
    originalImageUrl: 'test-original-url-2',
    sampleImageUrl: 'test-sample-url-2',
    tags: {'tag3', 'tag4'},
  ),
  // page 2
  DummyPost(
    id: 3,
    thumbnailImageUrl: 'test-thumbnail-url-3',
    originalImageUrl: 'test-original-url-3',
    sampleImageUrl: 'test-sample-url-3',
    tags: {'tag5', 'tag6'},
  ),
  DummyPost(
    id: 4,
    thumbnailImageUrl: 'test-thumbnail-url-4',
    originalImageUrl: 'test-original-url-4',
    sampleImageUrl: 'test-sample-url-4',
    tags: {'tag7'},
  ),
  // page 3
  DummyPost(
    id: 5,
    thumbnailImageUrl: 'test-thumbnail-url-5',
    originalImageUrl: 'test-original-url-5',
    sampleImageUrl: 'test-sample-url-5',
    tags: {'tag8'},
  ),
  DummyPost(
    id: 6,
    thumbnailImageUrl: 'test-thumbnail-url-6',
    originalImageUrl: 'test-original-url-6',
    sampleImageUrl: 'test-sample-url-6',
    tags: {'tag9'},
  ),
  // page 4
  DummyPost(
    id: 7,
    thumbnailImageUrl: 'test-thumbnail-url-7',
    originalImageUrl: 'test-original-url-7',
    sampleImageUrl: 'test-sample-url-7',
    tags: {'tag10'},
  ),
];

const _perPage = 2;
final _lastPage = (_posts.length / _perPage).ceil();

class DummyPostRepository implements PostRepository {
  @override
  PostsOrError<Post> getPosts(String tags, int page, {int? limit}) {
    final posts = _posts.skip((page - 1) * _perPage).take(_perPage).toList();

    return TaskEither.right(PostResult(posts: posts, total: null));
  }

  @override
  PostsOrError<Post> getPostsFromController(
    SelectedTagController controller,
    int page, {
    int? limit,
  }) =>
      getPosts('', page);

  @override
  TagQueryComposer get tagComposer =>
      DefaultTagQueryComposer(config: booruConfigSearch);
}

final booruConfigSearch = BooruConfigSearch.fromConfig(
  booruConfig,
);

final booruConfigAuth = BooruConfigAuth.fromConfig(
  booruConfig,
);

final booruConfig = BooruConfig.defaultConfig(
  booruType: BooruType.danbooru,
  url: 'test-url',
  customDownloadFileNameFormat: null,
);

class MockBooruBuilder extends Mock implements BooruBuilder {}

class MockNotification extends Mock implements BulkDownloadNotifications {}

class DummyDownloadService implements DownloadService {
  @override
  DownloadTaskInfoOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) {
    return TaskEither.right(
      DownloadTaskInfo(
        path: 'path',
        id: url,
      ),
    );
  }

  @override
  DownloadTaskInfoOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) {
    return TaskEither.right(
      DownloadTaskInfo(path: 'path', id: url),
    );
  }

  @override
  Future<bool> cancelTasksWithIds(List<String> ids) {
    return Future.value(true);
  }
}

final dummyDownloadFileNameBuilder = DownloadFileNameBuilder<DummyPost>(
  tokenHandlers: {},
  sampleData: [],
  defaultFileNameFormat: 'test-default-format',
  defaultBulkDownloadFileNameFormat: 'test-default-bulk-format',
);

void main() {
  group('Core', () {
    late Database db;
    late DownloadRepositorySqlite repository;
    late ProviderContainer container;
    late MockBooruBuilder booruBuilder;
    late BulkDownloadNotifications notifications;

    setUp(() {
      db = sqlite3.openInMemory();
      repository = DownloadRepositorySqlite(db)..initialize();
      booruBuilder = MockBooruBuilder();
      notifications = MockNotification();

      when(() => booruBuilder.downloadFilenameBuilder).thenReturn(
        dummyDownloadFileNameBuilder,
      );

      when(
        () => notifications.showNotification(
          any(),
          any(),
          payload: any(named: 'payload'),
          progress: any(named: 'progress'),
          total: any(named: 'total'),
          indeterminate: any(named: 'indeterminate'),
        ),
      ).thenAnswer((_) => Future.value());

      container = _createContainer(
        repository,
        booruBuilder,
        notifications: notifications,
      )..read(bulkDownloadProvider); // Initialize provider
    });

    tearDown(() {
      db.dispose();
      container.dispose();
    });

    group('Download Operations', () {
      test('should process multiple pages and create records for all posts',
          () async {
        // Arrange
        final task = await repository.createTask(_options);

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTask(
          task,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, 1);
        expect(sessions.first.status, DownloadSessionStatus.running);
        expect(sessions.first.totalPages, _lastPage);
        expect(sessions.first.currentPage, _lastPage);
        expect(sessions.first.error, isNull);

        final records =
            await repository.getRecordsBySessionId(sessions.first.id);
        expect(records.length, _posts.length);

        // Verify page 1 records
        final page1Records = records.where((r) => r.page == 1).toList();
        expect(page1Records.length, equals(2));
        expect(page1Records[0].url, equals('test-original-url-1'));
        expect(page1Records[0].downloadId, 'test-original-url-1');
        expect(page1Records[1].url, equals('test-original-url-2'));
        expect(page1Records[1].downloadId, 'test-original-url-2');

        // Verify page 2 records
        final page2Records = records.where((r) => r.page == 2).toList();
        expect(page2Records.length, equals(2));
        expect(page2Records[0].url, equals('test-original-url-3'));
        expect(page2Records[0].downloadId, 'test-original-url-3');
        expect(page2Records[1].url, equals('test-original-url-4'));
        expect(page2Records[1].downloadId, 'test-original-url-4');

        // Verify state
        final state = container.read(bulkDownloadProvider);
        expect(state.sessions.length, equals(1));
      });

      test('should stop current download session when cancelled', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTask(
          task,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Get session ID
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        final sessionId = sessions.first.id;

        // Act
        await notifier.cancelSession(sessionId);

        // Assert
        final updatedSession = await repository.getSession(sessionId);
        expect(updatedSession?.status, equals(DownloadSessionStatus.cancelled));

        // Verify state update
        final state = container.read(bulkDownloadProvider);
        final taskStatus =
            state.sessions.firstWhere((e) => e.session.id == sessionId);
        expect(
          taskStatus.session.status,
          equals(DownloadSessionStatus.cancelled),
        );
      });

      test('should exclude posts containing blacklisted tags', () async {
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(
            delayBetweenDownloads: null,
            blacklistedTags: {'tag1'},
          ),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        final records =
            await repository.getRecordsBySessionId(sessions.first.id);

        // Verify blacklisted posts were filtered
        expect(records.length, _posts.length - 1);
      });

      test('should download images in specified quality', () async {
        final task = await repository.createTask(
          _options.copyWith(
            quality: 'sample',
          ),
        );

        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(
            delayBetweenDownloads: null,
          ),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        final records =
            await repository.getRecordsBySessionId(sessions.first.id);

        // Verify sample images were used
        expect(records[0].url, equals('test-sample-url-1'));
        expect(records[1].url, equals('test-sample-url-2'));
      });

      test('should transition from dry run to running state when stopped',
          () async {
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        unawaited(
          notifier.downloadFromTaskId(
            task.id,
            downloadConfigs: const DownloadConfigs(
              delayBetweenRequests: Duration(milliseconds: 200),
            ),
          ),
        );

        // Wait for session to be created
        await Future.delayed(
          const Duration(milliseconds: 50),
          () async {
            final sessions = await repository.getSessionsByTaskId(task.id);

            // Verify initial dry run state
            expect(sessions.first.status, equals(DownloadSessionStatus.dryRun));

            // Stop dry run
            await notifier.stopDryRun(sessions.first.id);

            // Verify state transition
            final updatedSession =
                await repository.getSession(sessions.first.id);
            expect(
              updatedSession?.status,
              equals(DownloadSessionStatus.running),
            );

            // Verify notifier state
            final state = container.read(bulkDownloadProvider);
            expect(
              state.sessions
                  .firstWhere((d) => d.session.id == sessions.first.id)
                  .session
                  .status,
              equals(DownloadSessionStatus.running),
            );
          },
        );
      });

      test('should provide accurate download statistics', () async {
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(
            delayBetweenDownloads: null,
          ),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);

        final stats = await repository.getActionSessionStats(sessions.first.id);

        expect(stats.totalItems, _posts.length);
      });

      test('should remove session and its records when deleted', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Start a task to create a session
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Get session ID from the first session
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        final sessionId = sessions.first.id;

        // Verify session exists in state
        var state = container.read(bulkDownloadProvider);
        expect(
          state.sessions.any((d) => d.session.id == sessionId),
          isTrue,
        );

        // Act
        await notifier.deleteSession(sessionId);

        // Assert
        // Verify session is removed from state
        state = container.read(bulkDownloadProvider);
        expect(
          state.sessions.any((d) => d.session.id == sessionId),
          isFalse,
        );

        // Verify session is removed from database
        final deletedSession = await repository.getSession(sessionId);
        expect(deletedSession, isNull);

        // Verify associated records are also deleted
        final records = await repository.getRecordsBySessionId(sessionId);
        expect(records, isEmpty);

        // Verify state is updated
        state = container.read(bulkDownloadProvider);
        expect(state.sessions, isEmpty);
      });

      test(
          'should continue downloading when first page is completely filtered out',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(
            delayBetweenDownloads: null,
            blacklistedTags: {
              'tag1',
              'tag3',
            }, // This will filter out all posts from page 1
          ),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));

        final records =
            await repository.getRecordsBySessionId(sessions.first.id);
        expect(
          records.length,
          _posts.length - 2,
        );

        // Verify records are not from page 1
        final pages = records.map((r) => r.page).toSet();
        expect(pages, isNot(contains(1)));

        // Verify session status
        expect(sessions.first.status, equals(DownloadSessionStatus.running));
      });

      test('should have session stats available when session is running',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.downloadFromTask(
          task,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));

        final stats = await repository.getActionSessionStats(sessions.first.id);
        expect(stats.totalItems, equals(_posts.length));
        expect(stats.coverUrl, equals('test-thumbnail-url-1'));
        expect(stats.siteUrl, equals('test-url'));
      });

      test('should handle multiple running sessions for the same task',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Start first session
        await notifier.downloadFromTask(
          task,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Start second session
        await notifier.downloadFromTask(
          task,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Get all sessions for the task
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(2));

        // Verify both sessions are running
        expect(
          sessions
              .where((s) => s.status == DownloadSessionStatus.running)
              .length,
          equals(2),
        );

        // Verify state contains both sessions
        final state = container.read(bulkDownloadProvider);
        final stateSessions = state.sessions.where((s) => s.task.id == task.id);
        expect(stateSessions.length, equals(2));

        // Verify sessions have different IDs
        final sessionIds = sessions.map((s) => s.id).toSet();
        expect(sessionIds.length, equals(2));

        // Verify both sessions are correctly tracked in state
        for (final session in sessions) {
          expect(
            state.sessions.any((s) => s.session.id == session.id),
            isTrue,
            reason: 'Session ${session.id} should be in state',
          );
        }
      });
    });

    group('Error Scenarios', () {
      test('should handle task operations gracefully when errors occur',
          () async {
        // Arrange
        const taskId = 'test-task-id';

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          taskId,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(state.error, isNotNull);
        expect(state.sessions, isEmpty);
      });

      test('should clear error state when requested', () async {
        // Arrange
        const taskId = 'test-task-id';

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          taskId,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        expect(container.read(bulkDownloadProvider).error, isNotNull);

        // Act
        notifier.clearError();

        // Assert
        expect(container.read(bulkDownloadProvider).error, isNull);
      });

      test('should handle non-existent session deletion gracefully', () async {
        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.deleteSession('non-existent-session-id');

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(state.error, isNotNull);
      });

      test('should not delete non-existent task', () async {
        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.deleteTask('non-existent-task-id');

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(state.error, isA<TaskNotFoundError>());
      });

      test('should not delete task with active downloads', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Start task to create an active session
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Act
        await notifier.deleteTask(task.id);

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(state.error, isA<TaskHasActiveSessionsError>());

        // Verify task still exists
        final existingTask = await repository.getTask(task.id);
        expect(existingTask, isNotNull);
      });

      test('should not start download when no tags are provided', () async {
        // Arrange
        final task = await repository.createTask(_options.copyWith(tags: []));

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        expect(sessions.first.status, equals(DownloadSessionStatus.failed));

        expect(
          sessions.first.error,
          const EmptyTagsError().toString(),
        );
      });

      test('should not accept empty tag in tag list', () async {
        // Arrange
        final task = await repository.createTask(_options.copyWith(tags: ['']));

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        expect(sessions.first.status, equals(DownloadSessionStatus.failed));

        expect(
          sessions.first.error,
          const EmptyTagsError().toString(),
        );
      });

      test('should not accept whitespace-only tags', () async {
        // Arrange
        final task =
            await repository.createTask(_options.copyWith(tags: ['   ']));

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        expect(sessions.first.status, equals(DownloadSessionStatus.failed));

        expect(
          sessions.first.error,
          const EmptyTagsError().toString(),
        );
      });

      test('should handle non-existent records gracefully', () async {
        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.updateRecord(
          'non-existent-session',
          'non-existent-download',
          DownloadRecordStatus.completed,
        );

        // Assert
        expect(
          container.read(bulkDownloadProvider).error,
          isA<DownloadRecordNotFoundError>(),
        );
      });

      test('should handle non-existent sessions gracefully', () async {
        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.tryCompleteSession('non-existent-session');

        // Assert
        expect(
          container.read(bulkDownloadProvider).error,
          isA<SessionNotFoundError>(),
        );
      });

      test('should handle database operation failures', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        db.dispose(); // Force database error

        // Act
        await notifier.updateRecord(
          sessions.first.id,
          'any-download-id',
          DownloadRecordStatus.completed,
        );

        // Assert
        expect(
          container.read(bulkDownloadProvider).error,
          isA<DatabaseOperationError>(),
        );
      });

      test(
          'should continue downloading when multiple consecutive pages are filtered out',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(
            delayBetweenDownloads: null,
            blacklistedTags: {
              'tag5',
              'tag7',
              'tag8',
              'tag9',
            },
          ),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));

        final records =
            await repository.getRecordsBySessionId(sessions.first.id);
        expect(
          records.length,
          equals(3),
        ); // Should have records from pages 1 and 4

        // Verify records are from correct pages
        final pages = records.map((r) => r.page).toSet();
        expect(pages, equals({1, 4}));

        // Verify URLs are correct
        final urls = records.map((r) => r.url).toSet();
        expect(
          urls,
          equals({
            'test-original-url-1',
            'test-original-url-2',
            'test-original-url-7',
          }),
        );

        // Verify session status
        expect(sessions.first.status, equals(DownloadSessionStatus.running));
      });
    });

    group('Record Updates', () {
      test('should handle database operation failures during updates',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        db.dispose(); // Force database error

        // Act
        await notifier.updateRecord(
          sessions.first.id,
          'any-download-id',
          DownloadRecordStatus.completed,
        );

        // Assert
        expect(
          container.read(bulkDownloadProvider).error,
          isA<DatabaseOperationError>(),
        );
      });

      test('should skip update for already completed records', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        final records =
            await repository.getRecordsBySessionId(sessions.first.id);
        final record = records.first;

        // First update
        await notifier.updateRecord(
          sessions.first.id,
          record.downloadId!,
          DownloadRecordStatus.completed,
        );

        // Second update
        await notifier.updateRecord(
          sessions.first.id,
          record.downloadId!,
          DownloadRecordStatus.completed,
        );

        // Assert - no errors should occur
        expect(container.read(bulkDownloadProvider).error, isNull);

        final updatedRecord = await repository.getRecordByDownloadId(
          sessions.first.id,
          record.downloadId!,
        );
        expect(updatedRecord?.status, equals(DownloadRecordStatus.completed));
      });
    });

    group('Session Completion', () {
      test('should not complete session when it is not in running state',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final session = await repository.createSession(task.id);

        // Session starts as pending
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.tryCompleteSession(session.id);

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(
          state.error,
          isA<SessionNotRunningError>(),
        );
      });

      test('should handle multiple records completing simultaneously',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        final sessionId = sessions.first.id;
        final records = await repository.getRecordsBySessionId(sessionId);

        // Simulate concurrent updates
        await Future.wait([
          for (final record in records)
            notifier.updateRecord(
              sessionId,
              record.downloadId!,
              DownloadRecordStatus.completed,
            ),
        ]);

        // Act
        await notifier.tryCompleteSession(sessionId);

        // Assert
        final session = await repository.getSession(sessionId);
        expect(session?.status, equals(DownloadSessionStatus.completed));
      });

      test(
          'should calculate final statistics and cleanup on session completion',
          () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        final sessionId = sessions.first.id;
        final records = await repository.getRecordsBySessionId(sessionId);

        // Mark all records as completed
        for (final record in records) {
          await notifier.updateRecord(
            sessionId,
            record.downloadId!,
            DownloadRecordStatus.completed,
            fileSize: 1000, // Mock file size
          );
        }

        // Act
        await notifier.tryCompleteSession(sessionId);

        // Assert
        final session = await repository.getSession(sessionId);
        expect(session?.status, equals(DownloadSessionStatus.completed));

        // Verify records were cleaned up
        final remainingRecords =
            await repository.getRecordsBySessionId(sessionId);
        expect(remainingRecords.isEmpty, isTrue);
      });

      test('should preserve session statistics after cleanup', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        final sessions = await repository.getSessionsByTaskId(task.id);
        final sessionId = sessions.first.id;

        // Store initial stats
        final initialStats = await repository.getActionSessionStats(sessionId);

        // Complete all records
        final records = await repository.getRecordsBySessionId(sessionId);
        for (final record in records) {
          await notifier.updateRecord(
            sessionId,
            record.downloadId!,
            DownloadRecordStatus.completed,
            fileSize: 1000, // Mock file size
          );
        }

        // Act
        await notifier.tryCompleteSession(sessionId);

        // Assert
        final completed = await repository.getCompletedSessions();
        final finalStats = completed.first.stats;

        // Verify stats were preserved
        expect(finalStats.totalItems, equals(initialStats.totalItems));
        expect(finalStats.coverUrl, equals(initialStats.coverUrl));
        expect(finalStats.siteUrl, equals(initialStats.siteUrl));
      });
    });

    group('Storage Permissions', () {
      late Database db;
      late DownloadRepositorySqlite repository;
      late ProviderContainer container;
      late MediaPermissionManager mediaPermissionManager;
      late MockBooruBuilder booruBuilder;

      setUp(() {
        db = sqlite3.openInMemory();
        repository = DownloadRepositorySqlite(db)..initialize();

        mediaPermissionManager = MockMediaPermissionManager();
        booruBuilder = MockBooruBuilder();

        when(() => booruBuilder.downloadFilenameBuilder).thenReturn(
          dummyDownloadFileNameBuilder,
        );

        container = ProviderContainer(
          overrides: [
            internalDownloadRepositoryProvider.overrideWith((_) => repository),
            currentReadOnlyBooruConfigSearchProvider
                .overrideWithValue(booruConfigSearch),
            currentReadOnlyBooruConfigAuthProvider
                .overrideWithValue(booruConfigAuth),
            currentReadOnlyBooruConfigProvider.overrideWithValue(booruConfig),
            postRepoProvider.overrideWith((__, _) => DummyPostRepository()),
            downloadServiceProvider
                .overrideWith((__, _) => DummyDownloadService()),
            loggerProvider.overrideWithValue(DummyLogger()),
            mediaPermissionManagerProvider
                .overrideWithValue(mediaPermissionManager),
            settingsProvider.overrideWithValue(Settings.defaultSettings),
            downloadFileUrlExtractorProvider
                .overrideWith((__, _) => const UrlInsidePostExtractor()),
            cachedBypassDdosHeadersProvider.overrideWith((_, __) => {}),
            analyticsProvider.overrideWith((_) => NoAnalyticsInterface()),
            currentBooruBuilderProvider.overrideWith((_) => booruBuilder),
            blacklistTagsProvider.overrideWith((_, __) => {}),
            hasPremiumProvider.overrideWithValue(true),
          ],
        );
      });

      tearDown(() {
        db.dispose();
        container.dispose();
      });

      // Already cover by core features test
      // test('should proceed with download when permission is already granted',
      //     {});

      test('should request permission when not already granted', () async {
        // Arrange
        when(() => mediaPermissionManager.check())
            .thenAnswer((_) async => PermissionStatus.denied);
        when(() => mediaPermissionManager.request())
            .thenAnswer((_) async => PermissionStatus.granted);

        final task = await repository.createTask(_options);

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        verify(() => mediaPermissionManager.check()).called(1);
        verify(() => mediaPermissionManager.request()).called(1);

        // Verify download started
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        expect(sessions.first.status, equals(DownloadSessionStatus.running));
        expect(container.read(bulkDownloadProvider).error, isNull);
      });

      test('should fail when permission is denied', () async {
        // Arrange
        when(() => mediaPermissionManager.check())
            .thenAnswer((_) async => PermissionStatus.denied);
        when(() => mediaPermissionManager.request())
            .thenAnswer((_) async => PermissionStatus.denied);

        final task = await repository.createTask(_options);

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        verify(() => mediaPermissionManager.check()).called(1);
        verify(() => mediaPermissionManager.request()).called(1);

        // Verify error
        final session = await repository.getSessionsByTaskId(task.id);
        expect(
          session.first.error,
          const StoragePermissionDeniedError().toString(),
        );
      });

      test('should fail when permission is permanently denied', () async {
        // Arrange
        when(() => mediaPermissionManager.check())
            .thenAnswer((_) async => PermissionStatus.permanentlyDenied);

        final task = await repository.createTask(_options);

        // Act
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Assert
        verify(() => mediaPermissionManager.check()).called(1);
        verifyNever(() => mediaPermissionManager.request());

        // Verify error state
        final session = await repository.getSessionsByTaskId(task.id);
        expect(
          session.first.error,
          const StoragePermanentlyDeniedError().toString(),
        );
      });
    });

    group('Session Cancellation', () {
      test('should cancel session before processing starts', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);
        final session = await repository.createSession(task.id);

        // Act
        await notifier.cancelSession(session.id);

        // Assert
        final updatedSession = await repository.getSession(session.id);
        expect(updatedSession?.status, equals(DownloadSessionStatus.cancelled));
      });

      test('should cancel only the specified session mid-download', () async {
        // Arrange
        final task1 = await repository.createTask(_options);
        final task2 = await repository.createTask(
          _options.copyWith(
            tags: ['different_tags'],
          ),
        );
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Start both downloads
        unawaited(
          notifier.downloadFromTask(
            task1,
            downloadConfigs: const DownloadConfigs(
              delayBetweenDownloads: null,
            ),
          ),
        );

        unawaited(
          notifier.downloadFromTask(
            task2,
            downloadConfigs: const DownloadConfigs(
              delayBetweenDownloads: null,
            ),
          ),
        );

        // Wait for sessions to be created and start running
        await Future.delayed(const Duration(milliseconds: 100));

        final sessions = await repository.getActiveSessions();
        expect(sessions.length, equals(2));

        // Act - cancel first session
        await notifier.cancelSession(sessions.first.id);

        // Assert
        final updatedSessions = await repository.getActiveSessions();
        expect(updatedSessions.length, equals(2));

        // Verify first session is cancelled
        final cancelledSession = await repository.getSession(sessions.first.id);
        expect(
          cancelledSession?.status,
          equals(DownloadSessionStatus.cancelled),
        );

        // Verify second session is still running
        final runningSession = await repository.getSession(sessions.last.id);
        expect(
          runningSession?.status,
          equals(DownloadSessionStatus.running),
        );

        // Verify state reflects changes
        final state = container.read(bulkDownloadProvider);
        final stateSession = state.sessions.firstWhere(
          (s) => s.session.id == sessions.first.id,
        );
        expect(
          stateSession.session.status,
          equals(DownloadSessionStatus.cancelled),
        );
      });
    });

    group('Session resume', () {
      test('should mark running session as interrupted on app restart',
          () async {
        // Arrange
        var myContainer = _createContainer(repository, booruBuilder);
        final task = await repository.createTask(_options);
        var notifier = myContainer.read(bulkDownloadProvider.notifier);
        await notifier.downloadFromTask(
          task,
          downloadConfigs: const DownloadConfigs(delayBetweenDownloads: null),
        );

        // Get session ID
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        final sessionId = sessions.first.id;

        // Simulate app restart
        myContainer.dispose();
        myContainer = _createContainer(repository, booruBuilder);

        notifier = myContainer.read(bulkDownloadProvider.notifier);

        // Wait for notifier to load
        await Future.delayed(const Duration(milliseconds: 10));

        // Verify session is marked as interrupted
        final interruptedSession = await repository.getSession(sessionId);
        expect(
          interruptedSession?.status,
          equals(DownloadSessionStatus.interrupted),
        );

        // Verify state reflects changes
        final state = myContainer.read(bulkDownloadProvider);
        final stateSession = state.sessions.firstWhere(
          (s) => s.session.id == sessionId,
        );

        expect(
          stateSession.session.status,
          equals(DownloadSessionStatus.interrupted),
        );
      });

      test('should mark dry run session as pending when interrupted', () async {
        // Arrange
        var myContainer = _createContainer(repository, booruBuilder);
        final task = await repository.createTask(_options);
        var notifier = myContainer.read(bulkDownloadProvider.notifier);

        unawaited(
          notifier.downloadFromTask(
            task,
            downloadConfigs: const DownloadConfigs(
              delayBetweenRequests: Duration(milliseconds: 2000),
            ),
          ),
        );

        // Wait for dry run to start
        await Future.delayed(const Duration(milliseconds: 50));

        // Get session ID from the first session
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        final sessionId = sessions.first.id;

        // Verify session is in dry run
        expect(sessions.first.status, equals(DownloadSessionStatus.dryRun));

        // Simulate app restart before completing dry run
        myContainer.dispose();
        myContainer = _createContainer(repository, booruBuilder);
        notifier = myContainer.read(bulkDownloadProvider.notifier);

        // Wait for notifier to load
        await Future.delayed(const Duration(milliseconds: 50));

        // Verify session is reset to pending
        final resetSession = await repository.getSession(sessionId);
        expect(
          resetSession?.status,
          equals(DownloadSessionStatus.pending),
        );

        // Verify state reflects changes
        final state = myContainer.read(bulkDownloadProvider);
        final stateSession = state.sessions.firstWhere(
          (s) => s.session.id == sessionId,
        );

        expect(
          stateSession.session.status,
          equals(DownloadSessionStatus.pending),
        );

        // Verify all records are cleaned up
        final records = await repository.getRecordsBySessionId(sessionId);
        expect(records, isEmpty);
      });
    });

    group('Download Skipping', () {
      late ExistCheckerMock existChecker;

      setUp(() {
        existChecker = ExistCheckerMock();
      });

      test('should skip individual files that already exist', () async {
        // Arrange
        when(() => existChecker.exists(any(), any())).thenAnswer((i) {
          final filename = i.positionalArguments[0] as String;
          return filename
              .contains('test-original-url-1'); // Only first file exists
        });

        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.downloadFromTask(
          task,
          downloadConfigs: DownloadConfigs(
            delayBetweenDownloads: null,
            existChecker: existChecker,
          ),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        final records =
            await repository.getRecordsBySessionId(sessions.first.id);

        // Verify first file was skipped
        final skippedRecord = records.firstWhereOrNull(
          (r) => r.url.contains('test-original-url-1'),
        );
        expect(skippedRecord, isNull);

        // Verify other files were not skipped
        final notSkippedRecords =
            records.where((r) => !r.url.contains('test-original-url-1'));
        for (final record in notSkippedRecords) {
          expect(record.status, equals(DownloadRecordStatus.downloading));
        }

        verify(() => existChecker.exists(any(), any())).called(_posts.length);
      });

      test('should skip all files when they all exist', () async {
        // Arrange
        when(() => existChecker.exists(any(), any())).thenReturn(true);

        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.downloadFromTask(
          task,
          downloadConfigs: DownloadConfigs(
            delayBetweenDownloads: null,
            existChecker: existChecker,
          ),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        final records =
            await repository.getRecordsBySessionId(sessions.first.id);

        // Verify all records were skipped
        for (final record in records) {
          expect(record.status, equals(DownloadRecordStatus.downloading));
        }

        verify(() => existChecker.exists(any(), any())).called(_posts.length);
      });

      test('should not skip any files when skipIfExists is disabled', () async {
        // Arrange
        when(() => existChecker.exists(any(), any())).thenReturn(true);

        final task = await repository.createTask(
          _options.copyWith(skipIfExists: false),
        );
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.downloadFromTask(
          task,
          downloadConfigs: DownloadConfigs(
            delayBetweenDownloads: null,
            existChecker: existChecker,
          ),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        final records =
            await repository.getRecordsBySessionId(sessions.first.id);

        // Verify no records were skipped
        for (final record in records) {
          expect(record.status, equals(DownloadRecordStatus.downloading));
        }

        // Verify exist checker was never called
        verifyNever(() => existChecker.exists(any(), any()));
      });

      test('should complete session when all files are skipped', () async {
        // Arrange
        when(() => existChecker.exists(any(), any())).thenReturn(true);

        final task = await repository.createTask(_options);
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.downloadFromTask(
          task,
          downloadConfigs: DownloadConfigs(
            delayBetweenDownloads: null,
            existChecker: existChecker,
          ),
        );

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.first.status, equals(DownloadSessionStatus.allSkipped));
      });
    });

    group('Download Queueing', () {
      const downloadOptions = DownloadOptions(
        path: '/storage/emulated/0/Download',
        notifications: false,
        skipIfExists: false,
        perPage: 100,
        concurrency: 1,
        tags: ['tag1', 'tag2'],
      );
      const downloadConfigs = DownloadConfigs(
        delayBetweenDownloads: null,
        // Test platform is Android so we can set this to make sure it's passed the options check
        androidSdkVersion: AndroidVersions.android15,
      );

      test('should create pending session when queueing download', () async {
        // Arrange
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.queueDownloadLater(
          downloadOptions,
          downloadConfigs: downloadConfigs,
        );

        // Assert
        final tasks = await repository.getTasks();
        expect(tasks.length, equals(1));

        final sessions = await repository.getSessionsByTaskId(tasks.first.id);
        expect(sessions.length, equals(1));
        expect(sessions.first.status, equals(DownloadSessionStatus.pending));

        // Verify state
        final state = container.read(bulkDownloadProvider);
        expect(state.sessions.length, equals(1));
        expect(
          state.sessions.first.session.status,
          equals(DownloadSessionStatus.pending),
        );
      });

      test('should start pending session when requested', () async {
        // Arrange
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier.queueDownloadLater(
          downloadOptions,
          downloadConfigs: downloadConfigs,
        );

        final sessions = await repository.getActiveSessions();
        expect(sessions.length, equals(1));
        final sessionId = sessions.first.id;

        // Act
        await notifier.startPendingSession(sessionId);

        // Assert
        final updatedSession = await repository.getSession(sessionId);
        expect(
          updatedSession?.status,
          equals(DownloadSessionStatus.running),
        );

        // Verify state reflects the running session
        final state = container.read(bulkDownloadProvider);
        final sessionState = state.sessions.firstWhere(
          (s) => s.session.id == sessionId,
        );
        expect(
          sessionState.session.status,
          equals(DownloadSessionStatus.running),
        );
      });

      test('should fail to start non-pending session', () async {
        // Arrange
        final notifier = container.read(bulkDownloadProvider.notifier);
        await notifier
            .downloadFromOptions(downloadOptions); // Creates running session

        final sessions = await repository.getActiveSessions();
        final sessionId = sessions.first.id;

        // Act
        await notifier.startPendingSession(sessionId);

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(state.error, isNotNull);
        expect(
          state.error.toString(),
          contains('Session is not in pending state'),
        );
      });

      test('should handle non-existent session start gracefully', () async {
        // Arrange
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.startPendingSession('non-existent-session');

        // Assert
        final state = container.read(bulkDownloadProvider);
        expect(state.error, isA<SessionNotFoundError>());
      });
    });

    group('Saved Task Operations', () {
      test('should rerun saved task with same settings', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final savedTask = SavedDownloadTask(
          id: 1,
          task: task,
          createdAt: DateTime.now(),
          name: 'Test Task',
        );
        final notifier = container.read(bulkDownloadProvider.notifier);

        // Act
        await notifier.runSavedTask(savedTask);

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(1));
        expect(sessions.first.status, equals(DownloadSessionStatus.running));

        // Verify records are created with original task settings
        final records =
            await repository.getRecordsBySessionId(sessions.first.id);
        expect(records.isNotEmpty, isTrue);

        // Check all records have settings matching original task
        for (final record in records) {
          expect(record.extension, isNotNull);
          expect(record.sessionId, sessions.first.id);
          expect(record.status, equals(DownloadRecordStatus.downloading));
        }
      });

      test('should allow multiple reruns of the same saved task', () async {
        // Arrange
        final task = await repository.createTask(_options);
        final savedTask = SavedDownloadTask(
          id: 1,
          task: task,
          createdAt: DateTime.now(),
        );
        final notifier = container.read(bulkDownloadProvider.notifier);

        // First run
        await notifier.runSavedTask(savedTask);

        // Second run
        await notifier.runSavedTask(savedTask);

        // Assert
        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.length, equals(2));

        // Verify both sessions are created with same settings
        for (final session in sessions) {
          expect(session.taskId, equals(task.id));
        }
      });
    });
  });
}

ProviderContainer _createContainer(
  DownloadRepositorySqlite repository,
  MockBooruBuilder booruBuilder, {
  BulkDownloadNotifications? notifications,
}) {
  return ProviderContainer(
    overrides: [
      internalDownloadRepositoryProvider.overrideWith((_) => repository),
      currentReadOnlyBooruConfigSearchProvider
          .overrideWithValue(booruConfigSearch),
      currentReadOnlyBooruConfigAuthProvider.overrideWithValue(booruConfigAuth),
      currentReadOnlyBooruConfigProvider.overrideWithValue(booruConfig),
      postRepoProvider.overrideWith((__, _) => DummyPostRepository()),
      downloadServiceProvider.overrideWith((__, _) => DummyDownloadService()),
      mediaPermissionManagerProvider.overrideWithValue(
        _AlwaysGrantedPermissionManager(),
      ),
      loggerProvider.overrideWithValue(DummyLogger()),
      settingsProvider.overrideWithValue(Settings.defaultSettings),
      downloadFileUrlExtractorProvider
          .overrideWith((__, _) => const UrlInsidePostExtractor()),
      cachedBypassDdosHeadersProvider.overrideWith((_, __) => {}),
      analyticsProvider.overrideWith((_) => NoAnalyticsInterface()),
      currentBooruBuilderProvider.overrideWith((_) => booruBuilder),
      blacklistTagsProvider.overrideWith((_, __) => {}),
      hasPremiumProvider.overrideWithValue(true),
      if (notifications != null)
        bulkDownloadNotificationProvider.overrideWithValue(notifications),
    ],
  );
}

class _AlwaysGrantedPermissionManager implements MediaPermissionManager {
  @override
  Future<PermissionStatus> check() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> request() async => PermissionStatus.granted;

  @override
  DeviceInfo get deviceInfo => DeviceInfo.empty();
}

class ExistCheckerMock extends Mock implements DownloadExistChecker {}
