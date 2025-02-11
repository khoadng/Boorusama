// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/downloads/bulks/data/download_repository_sqlite.dart';
import 'package:boorusama/core/downloads/bulks/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/downloads/bulks/types/download_configs.dart';
import 'package:boorusama/core/downloads/bulks/types/download_record.dart';
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
      final records = await repository.getRecordsBySessionId(sessions.first.id);

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
      final records = await repository.getRecordsBySessionId(sessions.first.id);

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
      final records = await repository.getRecordsBySessionId(sessions.first.id);

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
}
