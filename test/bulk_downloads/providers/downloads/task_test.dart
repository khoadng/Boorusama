// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/downloads/bulks/data/download_repository_sqlite.dart';
import 'package:boorusama/core/downloads/bulks/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/downloads/bulks/types/bulk_download_error.dart';
import 'common.dart';

const _options = DownloadTestConstants.defaultOptions;
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

  group('Task Deletion', () {
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
        downloadConfigs: _defaultConfigs,
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
  });
}
