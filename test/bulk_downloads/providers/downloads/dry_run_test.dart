// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/data/repo_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/dry_run.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/dry_run_state.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
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
    )..read(bulkDownloadProvider);
  });

  tearDown(() {
    db.dispose();
    container.dispose();
  });

  group('Dry Run - File Discovery', () {
    test('should find files across multiple pages', () async {
      // Arrange
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs,
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusCompleted>());
      expect(
        dryRunState.allRecords.length,
        equals(DownloadTestConstants.posts.length),
      );
      expect(dryRunState.totalPages, equals(DownloadTestConstants.lastPage));

      // Verify records from different pages
      final pages = dryRunState.allRecords.map((r) => r.page).toSet();
      expect(pages.length, greaterThan(1));
    });

    test('should continue when some pages have no valid files', () async {
      // Arrange
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act - Use blacklist to filter out some pages completely
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs.copyWith(
          blacklistedTags: {'tag1', 'tag3'}, // Filters page 1 posts
        ),
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusCompleted>());
      expect(
        dryRunState.allRecords.length,
        lessThan(DownloadTestConstants.posts.length),
      );

      // Should still find files from other pages
      expect(dryRunState.allRecords.length, greaterThan(0));
    });
  });

  group('Dry Run - File Skip Logic', () {
    late ExistCheckerMock existChecker;

    setUp(() {
      existChecker = ExistCheckerMock();
    });

    test('should skip files that already exist', () async {
      // Arrange
      when(() => existChecker.exists(any(), any())).thenAnswer((invocation) {
        final filename = invocation.positionalArguments[0] as String;
        // Skip first two files
        return filename.contains('test-original-url-1') ||
            filename.contains('test-original-url-2');
      });

      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs.copyWith(
          existChecker: existChecker,
        ),
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusCompleted>());
      expect(
        dryRunState.allRecords.length,
        equals(DownloadTestConstants.posts.length - 2),
      );

      // Verify skipped files are not in records
      final urls = dryRunState.allRecords.map((r) => r.url).toList();
      expect(urls.contains('test-original-url-1'), isFalse);
      expect(urls.contains('test-original-url-2'), isFalse);
    });

    test('should not skip files when skipIfExists is disabled', () async {
      // Arrange
      when(() => existChecker.exists(any(), any())).thenReturn(true);

      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions.copyWith(skipIfExists: false),
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs.copyWith(
          existChecker: existChecker,
        ),
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusCompleted>());
      expect(
        dryRunState.allRecords.length,
        equals(DownloadTestConstants.posts.length),
      );

      // Verify exist checker was never called
      verifyNever(() => existChecker.exists(any(), any()));
    });
  });

  group('Dry Run - Cancellation', () {
    test('should stop when cancelled mid-process', () async {
      // Arrange
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );
      final cancelToken = CancelToken();

      // Act - Start dry run and cancel after short delay
      unawaited(
        dryRunNotifier.start(
          session,
          task,
          cancelToken,
          DownloadTestConstants.defaultConfigs.copyWith(
            delayBetweenRequests: const Duration(milliseconds: 100),
          ),
          shouldContinue: () async => true,
          onPageProgress: (_) async {},
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      cancelToken.cancel();

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusCancelled>());
    });

    test('should stop when shouldContinue returns false', () async {
      // Arrange
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      var shouldContinueCallCount = 0;

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs,
        shouldContinue: () async {
          shouldContinueCallCount++;
          return shouldContinueCallCount <= 2; // Stop after 2 calls
        },
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusCompleted>());
      expect(dryRunState.allRecords.length, greaterThan(0));
      expect(
        dryRunState.allRecords.length,
        lessThan(DownloadTestConstants.posts.length),
      );
    });
  });

  group('Dry Run - Error Handling', () {
    test('should fail when tags are empty', () async {
      // Arrange
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions.copyWith(
          tags: SearchTagSet.empty(),
        ),
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs,
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusFailed>());
      expect(dryRunState.error, contains('Tags cannot be empty'));
    });

    test('should handle filename generation errors gracefully', () async {
      // Arrange
      final mockBuilder = MockAsyncFilenameBuilder(
        hasAsyncTokens: true,
        preloadResult: AsyncPreload.noop(),
        shouldFailGenerate: true,
      );

      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs.copyWith(
          fileNameBuilder: mockBuilder,
        ),
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusFailed>());
    });
  });

  group('Dry Run - Async Filename Handling', () {
    test('should call preload for async filename builders', () async {
      // Arrange
      final mockBuilder = MockAsyncFilenameBuilder(
        hasAsyncTokens: true,
        preloadResult: AsyncPreload.noop(),
      );

      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs.copyWith(
          fileNameBuilder: mockBuilder,
        ),
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      expect(mockBuilder.preloadCallCount, greaterThan(0));
      expect(mockBuilder.preloadedChunks.length, greaterThan(0));
      expect(
        mockBuilder.generatedPosts.length,
        equals(DownloadTestConstants.posts.length),
      );

      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );
      expect(dryRunState.status, isA<DryRunStatusCompleted>());
    });

    test('should enter slow mode when async tokens have no preload', () async {
      // Arrange
      final mockBuilder = MockAsyncFilenameBuilder(
        hasAsyncTokens: true,
        preloadResult: const AsyncNoPreload(),
      );

      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act - Start dry run in background
      unawaited(
        dryRunNotifier.start(
          session,
          task,
          CancelToken(),
          DownloadTestConstants.defaultConfigs.copyWith(
            fileNameBuilder: mockBuilder,
          ),
          shouldContinue: () async => true,
          onPageProgress: (_) async {},
        ),
      );

      // Wait for slow mode to activate
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );

      expect(dryRunState.status, isA<DryRunStatusRunning>());
      final runningStatus = dryRunState.status as DryRunStatusRunning;
      expect(runningStatus.isSlowRun, isTrue);
    });

    test('should handle preload failure gracefully', () async {
      // Arrange
      final mockBuilder = MockAsyncFilenameBuilder(
        hasAsyncTokens: true,
        preloadResult: AsyncPreload.noop(),
        shouldFailPreload: true,
      );

      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final session = await repository.createSession(
        task,
        DownloadTestConstants.defaultAuthConfig,
      );

      final dryRunNotifier = container.read(
        dryRunNotifierProvider(session.id).notifier,
      );

      // Act
      await dryRunNotifier.start(
        session,
        task,
        CancelToken(),
        DownloadTestConstants.defaultConfigs.copyWith(
          fileNameBuilder: mockBuilder,
        ),
        shouldContinue: () async => true,
        onPageProgress: (_) async {},
      );

      // Assert
      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );
      expect(dryRunState.status, isA<DryRunStatusFailed>());
    });

    test(
      'should preserve partial records when stopping slow mode mid-page',
      () async {
        // Arrange
        final mockBuilder = MockAsyncFilenameBuilder(
          hasAsyncTokens: true,
          preloadResult: const AsyncNoPreload(),
        );

        final task = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );
        final session = await repository.createSession(
          task,
          DownloadTestConstants.defaultAuthConfig,
        );

        final dryRunNotifier = container.read(
          dryRunNotifierProvider(session.id).notifier,
        );
        final bulkNotifier = container.read(bulkDownloadProvider.notifier);

        // Act - Start slow dry run with short async delay
        unawaited(
          dryRunNotifier.start(
            session,
            task,
            CancelToken(),
            DownloadTestConstants.defaultConfigs.copyWith(
              fileNameBuilder: mockBuilder,
              delayBetweenRequests: const Duration(
                milliseconds: 200,
              ),
              asyncTokenDelay: const Duration(
                milliseconds: 50,
              ),
            ),
            shouldContinue: () async => true,
            onPageProgress: (_) async {},
          ),
        );

        // Wait for slow mode to start processing posts within first page
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify we're in slow mode and processing items
        var dryRunState = await container.read(
          dryRunNotifierProvider(session.id).future,
        );
        expect(dryRunState.status, isA<DryRunStatusRunning>());
        final runningStatus = dryRunState.status as DryRunStatusRunning;
        expect(runningStatus.isSlowRun, isTrue);

        // Stop dry run while processing posts
        await bulkNotifier.stopDryRun(session.id);

        // Wait for dry run to finish processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - Should preserve records processed before stop
        dryRunState = await container.read(
          dryRunNotifierProvider(session.id).future,
        );

        expect(dryRunState.allRecords.length, greaterThan(0));
        expect(
          dryRunState.allRecords.length,
          lessThanOrEqualTo(DownloadTestConstants.posts.length),
        );
        expect(dryRunState.totalPages, equals(1));

        // Verify session transitioned to pending state
        final finalSession = await repository.getSession(session.id);
        expect(finalSession?.status, equals(DownloadSessionStatus.pending));

        // Verify all preserved records are from page 1
        final recordPages = dryRunState.allRecords.map((r) => r.page).toSet();
        expect(recordPages, equals({1}));
      },
    );
  });

  group('Dry Run - State Transitions', () {
    test('should transition from dry run to running when stopped', () async {
      // Arrange
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final notifier = container.read(bulkDownloadProvider.notifier);

      unawaited(
        notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: DownloadTestConstants.defaultConfigs.copyWith(
            delayBetweenRequests: const Duration(milliseconds: 200),
          ),
        ),
      );

      // Wait for session to be created and dry run to start
      await Future.delayed(const Duration(milliseconds: 50));

      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.first.status, equals(DownloadSessionStatus.dryRun));

      // Act
      await notifier.stopDryRun(sessions.first.id);

      // Assert
      final updatedSession = await repository.getSession(sessions.first.id);
      expect(updatedSession?.status, equals(DownloadSessionStatus.running));
    });

    test('should prevent deletion of session during dry run', () async {
      // Arrange
      final task = await repository.createTask(
        DownloadTestConstants.defaultOptions,
      );
      final notifier = container.read(bulkDownloadProvider.notifier);

      unawaited(
        notifier.downloadFromTaskId(
          task.id,
          downloadConfigs: DownloadTestConstants.defaultConfigs.copyWith(
            delayBetweenRequests: const Duration(milliseconds: 2000),
          ),
        ),
      );

      // Wait for dry run to start
      await Future.delayed(const Duration(milliseconds: 50));

      final sessions = await repository.getSessionsByTaskId(task.id);
      expect(sessions.first.status, equals(DownloadSessionStatus.dryRun));

      // Act
      await notifier.deleteSession(sessions.first.id);

      // Assert
      final existingSession = await repository.getSession(sessions.first.id);
      expect(existingSession, isNotNull);

      final state = container.read(bulkDownloadProvider);
      expect(state.error, isNotNull);
      expect(state.error.toString(), contains('runningSessionDeletionError'));
    });
  });
}
