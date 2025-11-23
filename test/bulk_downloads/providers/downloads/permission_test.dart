// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/data/repo_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/types/bulk_download_error.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'common.dart';

final _options = DownloadTestConstants.defaultOptions;
const _defaultConfigs = DownloadTestConstants.defaultConfigs;

void main() {
  group('Storage Permissions', () {
    late Database db;
    late DownloadRepositorySqlite repository;
    late ProviderContainer container;
    late MediaPermissionManager mediaPermissionManager;

    setUp(() {
      db = sqlite3.openInMemory();
      repository = DownloadRepositorySqlite(db)..initialize();

      mediaPermissionManager = MockMediaPermissionManager();

      container = createBulkDownloadContainer(
        downloadRepository: repository,
        mediaPermissionManager: mediaPermissionManager,
        booruBuilder: MockBooruBuilder(),
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
      when(
        () => mediaPermissionManager.check(),
      ).thenAnswer((_) async => PermissionStatus.denied);
      when(
        () => mediaPermissionManager.request(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      final task = await repository.createTask(_options);

      // Act
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: _defaultConfigs,
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
      when(
        () => mediaPermissionManager.check(),
      ).thenAnswer((_) async => PermissionStatus.denied);
      when(
        () => mediaPermissionManager.request(),
      ).thenAnswer((_) async => PermissionStatus.denied);

      final task = await repository.createTask(_options);

      // Act
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: _defaultConfigs,
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
      when(
        () => mediaPermissionManager.check(),
      ).thenAnswer((_) async => PermissionStatus.permanentlyDenied);

      final task = await repository.createTask(_options);

      // Act
      final notifier = container.read(bulkDownloadProvider.notifier);
      await notifier.downloadFromTaskId(
        task.id,
        downloadConfigs: _defaultConfigs,
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
}
