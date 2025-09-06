// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:filename_generator/filename_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/bulk_downloads/src/data/download_repository_sqlite.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/bulk_download_notifier.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/dry_run.dart';
import 'package:boorusama/core/bulk_downloads/src/providers/dry_run_state.dart';
import 'package:boorusama/core/bulk_downloads/src/types/download_session.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
import 'package:boorusama/core/settings/settings.dart';
import '../../common.dart';
import 'common.dart';

class MockAsyncFilenameBuilder implements DownloadFilenameGenerator<DummyPost> {
  MockAsyncFilenameBuilder({
    this.hasAsyncTokens = false,
    this.preloadResult = PreloadResult.sync,
    this.shouldFailGenerate = false,
    this.shouldFailPreload = false,
  });

  final bool hasAsyncTokens;
  final PreloadResult preloadResult;
  final bool shouldFailGenerate;
  final bool shouldFailPreload;

  final List<DummyPost> generatedPosts = [];
  final List<List<DummyPost>> preloadedChunks = [];
  int preloadCallCount = 0;

  @override
  Future<String> generateForBulkDownload(
    Settings settings,
    BooruConfigDownload config,
    DummyPost post, {
    required String downloadUrl,
    Map<String, String>? metadata,
    CancelToken? cancelToken,
  }) async {
    generatedPosts.add(post);

    if (cancelToken?.isCancelled ?? false) {
      throw DioException(requestOptions: RequestOptions());
    }

    if (shouldFailGenerate) {
      throw Exception('Generate failed');
    }

    final index = metadata?['index'] ?? '0';
    return 'file_${post.id}_$index.jpg';
  }

  @override
  Future<PreloadResult> preloadForBulkDownload(
    List<DummyPost> posts,
    BooruConfigAuth config,
    BooruConfigDownload downloadConfig,
  ) async {
    preloadCallCount++;
    preloadedChunks.add(List.from(posts));

    if (shouldFailPreload) {
      throw Exception('Preload failed');
    }

    return preloadResult;
  }

  @override
  bool formatContainsAsyncToken(String? format) => hasAsyncTokens;

  @override
  List<TokenInfo> get availableTokens => [];
  @override
  List<TextMatcher> get textMatchers => [];
  @override
  List<String> getTokenOptions(String token) => [];
  @override
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption) =>
      null;
  @override
  Future<String> generate(
    Settings settings,
    BooruConfigDownload config,
    DummyPost post, {
    required String downloadUrl,
    Map<String, String>? metadata,
    CancelToken? cancelToken,
  }) async => 'test.jpg';
  @override
  String generateSample(String format) => 'sample.jpg';
  @override
  List<String> generateSamples(String format) => ['sample.jpg'];
  @override
  String get defaultFileNameFormat => '{id}.{extension}';
  @override
  String get defaultBulkDownloadFileNameFormat => '{index}_{id}.{extension}';
}

void main() {
  late Database db;
  late DownloadRepositorySqlite repository;

  setUp(() {
    db = sqlite3.openInMemory();
    repository = DownloadRepositorySqlite(db)..initialize();
  });

  tearDown(() {
    db.dispose();
  });

  group('Bulk Download Async Filename Tests', () {
    test(
      'should call preload when filename builder has async tokens',
      () async {
        final mockBuilder = MockAsyncFilenameBuilder(
          hasAsyncTokens: true,
          preloadResult: PreloadResult.asyncPreload,
        );

        final container = createBulkDownloadContainer(
          downloadRepository: repository,
          booruBuilder: MockBooruBuilder(),
        );

        final notifier = container.read(bulkDownloadProvider.notifier);
        final task = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );

        await notifier.downloadFromTask(
          task,
          downloadConfigs: DownloadTestConstants.defaultConfigs.copyWith(
            fileNameBuilder: mockBuilder,
          ),
        );

        expect(mockBuilder.preloadCallCount, equals(1));
        expect(mockBuilder.preloadedChunks.length, equals(1));
        expect(
          mockBuilder.generatedPosts.length,
          equals(DownloadTestConstants.posts.length),
        );

        container.dispose();
      },
    );

    test(
      'should switch to slow run mode when async tokens with no preload',
      () async {
        final mockBuilder = MockAsyncFilenameBuilder(
          hasAsyncTokens: true,
          preloadResult: PreloadResult.asyncNoPreload,
        );

        final container = createBulkDownloadContainer(
          downloadRepository: repository,
          booruBuilder: MockBooruBuilder(),
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

        await Future.delayed(const Duration(milliseconds: 100));

        final dryRunState = await container.read(
          dryRunNotifierProvider(session.id).future,
        );

        expect(dryRunState.status, isA<DryRunStatusRunning>());
        final runningStatus = dryRunState.status as DryRunStatusRunning;
        expect(runningStatus.isSlowRun, isTrue);

        container.dispose();
      },
    );

    test(
      'should handle stopping dry run during async filename generation',
      () async {
        final mockBuilder = MockAsyncFilenameBuilder(
          hasAsyncTokens: true,
          preloadResult: PreloadResult.asyncNoPreload,
        );

        final container = createBulkDownloadContainer(
          downloadRepository: repository,
          booruBuilder: MockBooruBuilder(),
        );

        final notifier = container.read(bulkDownloadProvider.notifier);
        final task = await repository.createTask(
          DownloadTestConstants.defaultOptions,
        );

        unawaited(
          notifier.downloadFromTask(
            task,
            downloadConfigs: DownloadTestConstants.defaultConfigs.copyWith(
              fileNameBuilder: mockBuilder,
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        final sessions = await repository.getSessionsByTaskId(task.id);
        expect(sessions.first.status, equals(DownloadSessionStatus.dryRun));

        await notifier.stopDryRun(sessions.first.id);

        await Future.delayed(const Duration(milliseconds: 100));

        final stoppedSession = await repository.getSession(sessions.first.id);
        expect(
          stoppedSession?.status,
          equals(DownloadSessionStatus.running),
        );

        container.dispose();
      },
    );

    test('should handle preload failure gracefully', () async {
      final mockBuilder = MockAsyncFilenameBuilder(
        hasAsyncTokens: true,
        preloadResult: PreloadResult.asyncPreload,
        shouldFailPreload: true,
      );

      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
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

      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );
      expect(dryRunState.status, isA<DryRunStatusFailed>());

      container.dispose();
    });

    test('should handle filename generation failure', () async {
      final mockBuilder = MockAsyncFilenameBuilder(
        hasAsyncTokens: true,
        preloadResult: PreloadResult.asyncPreload,
        shouldFailGenerate: true,
      );

      final container = createBulkDownloadContainer(
        downloadRepository: repository,
        booruBuilder: MockBooruBuilder(),
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

      final dryRunState = await container.read(
        dryRunNotifierProvider(session.id).future,
      );
      expect(dryRunState.status, isA<DryRunStatusFailed>());

      container.dispose();
    });
  });
}
