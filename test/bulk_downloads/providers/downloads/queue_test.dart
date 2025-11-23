// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/data/repo_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/types/bulk_download_error.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_options.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'common.dart';

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
  group('Download Queueing', () {
    final downloadOptions = DownloadOptions(
      path: '/storage/emulated/0/Download',
      notifications: false,
      skipIfExists: false,
      perPage: 100,
      concurrency: 1,
      tags: SearchTagSet.fromList(const ['tag1', 'tag2']),
    );
    final downloadConfigs = DownloadTestConstants.defaultConfigs.copyWith(
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
      await notifier.startPendingSession(
        sessionId,
        downloadConfigs: downloadConfigs,
      );

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
      await notifier.downloadFromOptions(
        downloadOptions,
        downloadConfigs: downloadConfigs,
      ); // Creates running session

      final sessions = await repository.getActiveSessions();
      final sessionId = sessions.first.id;

      // Act
      await notifier.startPendingSession(
        sessionId,
        downloadConfigs: downloadConfigs,
      );

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
      await notifier.startPendingSession(
        'non-existent-session',
        downloadConfigs: downloadConfigs,
      );

      // Assert
      final state = container.read(bulkDownloadProvider);
      expect(state.error, isA<SessionNotFoundError>());
    });
  });
}
