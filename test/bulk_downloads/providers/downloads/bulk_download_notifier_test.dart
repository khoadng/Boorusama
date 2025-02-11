// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/downloads/bulks/data/download_repository_sqlite.dart';
import 'package:boorusama/core/downloads/bulks/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/downloads/bulks/types/bulk_download_error.dart';
import 'package:boorusama/core/downloads/bulks/types/download_configs.dart';
import 'package:boorusama/core/downloads/bulks/types/download_record.dart';
import 'package:boorusama/core/downloads/bulks/types/download_repository.dart';
import 'package:boorusama/core/downloads/bulks/types/download_session.dart';
import 'common.dart';

const _options = DownloadTestConstants.defaultOptions;
final _posts = DownloadTestConstants.posts;

void main() {
  late Database db;
  late DownloadRepositorySqlite repository;
  late ProviderContainer container;

  setUp(() {
    db = sqlite3.openInMemory();
    repository = DownloadRepositorySqlite(db)..initialize();

    container = createBulkDownloadContainer(
      downloadRepository: repository,
      booruBuilder: MockBooruBuilder(),
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
      expect(sessions.first.totalPages, DownloadTestConstants.lastPage);
      expect(sessions.first.currentPage, DownloadTestConstants.lastPage);
      expect(sessions.first.error, isNull);

      final records = await repository.getRecordsBySessionId(sessions.first.id);
      expect(records.length, DownloadTestConstants.posts.length);

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
      final records = await repository.getRecordsBySessionId(sessions.first.id);

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
      final records = await repository.getRecordsBySessionId(sessions.first.id);

      // Verify sample images were used
      expect(records[0].url, equals('test-sample-url-1'));
      expect(records[1].url, equals('test-sample-url-2'));
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

      final records = await repository.getRecordsBySessionId(sessions.first.id);
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

    test('should handle multiple running sessions for the same task', () async {
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
        sessions.where((s) => s.status == DownloadSessionStatus.running).length,
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

    test('should reflect saved task changes in active sessions', () async {
      // Arrange
      final task = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.createSavedTask(task);

      // Get the saved task
      final savedTasks = await repository.getSavedTasks();
      expect(savedTasks.length, equals(1));
      final savedTask = savedTasks.first;

      // Edit the saved task with new tags
      final editedTask = task.copyWith(tags: 'new_tag');
      await notifier.editTask(editedTask);

      // Start a session from the saved task
      await notifier.runSavedTask(savedTask);

      // Assert
      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.length, equals(1));

      // Verify that the session uses the updated tags
      final state = container.read(bulkDownloadProvider);
      final activeSession = state.sessions.first;
      expect(activeSession.task.tags, equals('new_tag'));
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

      final records = await repository.getRecordsBySessionId(sessions.first.id);
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
    test('should handle database operation failures during updates', () async {
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
      final records = await repository.getRecordsBySessionId(sessions.first.id);
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
}
