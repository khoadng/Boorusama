// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/data/repo_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_record.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/core/bulk_downloads/src/types/saved_download_task.dart';
import 'common.dart';

final _options = DownloadTestConstants.defaultOptions;
const _defaultConfigs = DownloadTestConstants.defaultConfigs;

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

  group('Saved Task Operations', () {
    test('should create a new task when creating a saved task', () async {
      // Arrange
      final originalTask = await repository.createTask(_options);
      final notifier = container.read(bulkDownloadProvider.notifier);

      // Act
      final savedTask = await notifier.createSavedTask(
        originalTask,
        name: 'Test Task',
      );

      // Assert
      expect(savedTask, isNotNull);
      expect(savedTask!.task.id, isNot(equals(originalTask.id)));
      expect(savedTask.task.tags, equals(originalTask.tags));
      expect(savedTask.task.path, equals(originalTask.path));
      expect(savedTask.task.quality, equals(originalTask.quality));
      expect(savedTask.task.perPage, equals(originalTask.perPage));
      expect(savedTask.task.skipIfExists, equals(originalTask.skipIfExists));
      expect(savedTask.task.notifications, equals(originalTask.notifications));
    });

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
      await notifier.runSavedTask(
        savedTask,
        downloadConfigs: _defaultConfigs,
      );

      // Assert
      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.length, equals(1));
      expect(sessions.first.status, equals(DownloadSessionStatus.running));

      // Verify records are created with original task settings
      final records = await repository.getRecordsBySessionId(sessions.first.id);
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
      await notifier.runSavedTask(
        savedTask,
        downloadConfigs: _defaultConfigs,
      );

      // Second run
      await notifier.runSavedTask(
        savedTask,
        downloadConfigs: _defaultConfigs,
      );

      // Assert
      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.length, equals(2));

      // Verify both sessions are created with same settings
      for (final session in sessions) {
        expect(session.taskId, equals(task.id));
      }
    });
  });
}
