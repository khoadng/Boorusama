// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../../foundation/utils/duration_utils.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../http/client/providers.dart';
import '../../../downloads/filename/providers.dart';
import '../../../downloads/filename/types.dart';
import '../../../downloads/urls/providers.dart';
import '../../../http/client/types.dart';
import '../../../posts/post/types.dart';
import '../../../search/selected_tags/types.dart';
import '../../../settings/providers.dart';
import '../data/filesystem.dart';
import '../data/providers.dart';
import '../types/bulk_download_error.dart';
import '../types/download_configs.dart';
import '../types/download_record.dart';
import '../types/download_session.dart';
import '../types/download_task.dart';
import 'dry_run_state.dart';
import 'providers.dart';

final dryRunNotifierProvider =
    AsyncNotifierProvider.family<DryRunNotifier, DryRunState, String>(
      DryRunNotifier.new,
    );

class DryRunNotifier extends FamilyAsyncNotifier<DryRunState, String> {
  @override
  Future<DryRunState> build(String sessionId) async {
    final repo = await ref.read(downloadRepositoryProvider.future);
    final session = await repo.getSession(sessionId);

    if (session == null) return const DryRunState.notFound();

    return DryRunState.initial();
  }

  Future<void> start(
    DownloadSession session,
    DownloadTask task,
    CancelToken cancelToken,
    DownloadConfigs? downloadConfigs, {
    required Future<bool> Function() shouldContinue,
    required Future<void> Function(int page) onPageProgress,
  }) async {
    final currentState = await future;

    state = AsyncData(
      currentState.copyWith(
        status: const DryRunStatusRunning(),
      ),
    );

    try {
      final config = ref.readConfig;
      final l = ref.read(loggerProvider);
      final downloadFileUrlExtractor =
          downloadConfigs?.urlExtractor ??
          ref.read(downloadFileUrlExtractorProvider(config.auth));
      final headers =
          downloadConfigs?.headers ??
          ref.read(httpHeadersProvider(config.auth));
      final fileNameBuilder =
          downloadConfigs?.fileNameBuilder ??
          ref.read(downloadFilenameBuilderProvider(config.auth)) ??
          fallbackFileNameBuilder;
      final fetcher = ref.read(
        postFetcherProvider((
          filter: config.filter,
          config: config.search,
          downloadConfigs: downloadConfigs,
        )).notifier,
      );
      final fallbackSettings = ref.read(settingsProvider);
      final settings = downloadConfigs?.settings ?? fallbackSettings;
      final fallbackExistChecker = ref.read(
        defaultDownloadExistCheckerProvider,
      );
      final fileExistChecker =
          downloadConfigs?.existChecker ?? fallbackExistChecker;
      final asyncTokenDelay =
          downloadConfigs?.asyncTokenDelay ??
          const Duration(milliseconds: 1000);

      var page = 1;
      final tags = SearchTagSet.fromString(task.tags);
      final sessionId = session.id;
      final allRecords = <DownloadRecord>[];

      if (tags.isEmpty) {
        await _setFailedState(const EmptyTagsError().toString());
        return;
      }

      final firstResult = await fetcher.getPosts(
        tags: tags,
        page: page,
        task: task,
      );

      if (firstResult.isEmpty) {
        await _setFailedState(const NoPostsFoundError().toString());
        return;
      }

      var rawPosts = firstResult.posts;
      var preloadResult = await _preload(
        fileNameBuilder,
        rawPosts,
        config,
        cancelToken,
        page: page,
        l: l,
      );

      var cumulativeIndex = 0;

      while (await shouldContinue()) {
        if (cancelToken.isCancelled) {
          await _setCancelledState(
            page,
            allRecords: allRecords,
          );
          return;
        }

        final records = <DownloadRecord>[];
        l._log('Dry run page $page started for session $sessionId');

        await onPageProgress(page);
        state = AsyncData((await future).copyWith(currentPage: () => page));

        for (var i = 0; i < rawPosts.length; i++) {
          if (cancelToken.isCancelled) {
            l._log('Session $sessionId cancelled during dry run');

            // Preserve state up to this point
            allRecords.addAll(records);

            await _setCancelledState(
              page,
              allRecords: allRecords,
            );
            return;
          }

          l._log(
            'Processing post ${i + 1}/${rawPosts.length} for session $sessionId',
          );

          preloadResult = await _preload(
            fileNameBuilder,
            rawPosts,
            config,
            cancelToken,
            page: page,
            l: l,
          );

          if (preloadResult.isAsyncNoPreload) {
            state = AsyncData(
              (await future).copyWith(currentItemIndex: () => i),
            );
          }

          final item = rawPosts[i];
          final urlData = await downloadFileUrlExtractor?.getDownloadFileUrl(
            post: item,
            quality: task.quality ?? settings.downloadQuality.name,
          );

          if (urlData == null || urlData.url.isEmpty) continue;

          final fileName = await fileNameBuilder.generateForBulkDownload(
            settings,
            config.download,
            item,
            metadata: {
              'index': cumulativeIndex.toString(),
            },
            downloadUrl: urlData.url,
            cancelToken: cancelToken,
            asyncTokenDelay: asyncTokenDelay,
          );

          l._log('Resolved filename for post ${item.id}: $fileName');

          if (task.skipIfExists) {
            final exists = fileExistChecker.exists(fileName, task.path);
            if (exists) {
              cumulativeIndex++;
              l._log(
                'Skipping post ${item.id} because file already exists: $fileName',
              );
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
                ...?headers,
                AppHttpHeaders.cookieHeader: ?urlData.cookie,
              },
              thumbnailImageUrl: item.thumbnailImageUrl,
              sourceUrl: config.url,
            ),
          );

          l._log(
            'Post ${item.id} processed, fileName: $fileName, downloadUrl: ${urlData.url}',
          );
          cumulativeIndex++;
        }

        allRecords.addAll(records);

        state = AsyncData(
          (await future).copyWith(
            allRecords: allRecords,
            totalPages: page,
          ),
        );

        l._log(
          'Dry run page $page processed, found ${records.length} valid records',
        );

        page++;

        final delay = downloadConfigs?.delayBetweenRequests;
        if (delay != null) {
          await delay.future;
        } else {
          await Future.delayed(const Duration(milliseconds: 200));
        }

        l._log('Fetching page $page for session $sessionId');

        final nextResult = await fetcher.getPosts(
          tags: tags,
          page: page,
          task: task,
        );

        if (nextResult.isEmpty) {
          page--;
          l._log('No more items found, ending dry run for session $sessionId');
          break;
        }

        rawPosts = nextResult.posts;
      }

      l._log('Dry run ended for session $sessionId');

      state = AsyncData(
        (await future).copyWith(
          status: const DryRunStatusCompleted(),
          allRecords: allRecords,
          totalPages: page,
        ),
      );
    } catch (e) {
      await _setFailedState(e.toString());
    }
  }

  Future<PreloadResult> _preload(
    DownloadFilenameGenerator<Post> fileNameBuilder,
    List<Post> rawPosts,
    BooruConfig config,
    CancelToken cancelToken, {
    required int page,
    required Logger? l,
  }) async {
    final preloadResult = await fileNameBuilder.preloadForBulkDownload(
      rawPosts,
      config.auth,
      config.download,
      cancelToken,
    );

    switch (preloadResult) {
      case AsyncNoPreload():
        state = AsyncData(
          (await future).copyWith(
            status: const DryRunStatusRunning.slowRun(),
            currentPage: () => page,
          ),
        );
      case AsyncPreload(preload: final preloadFn):
        l?._log('Preloading for ${rawPosts.length} posts');
        state = AsyncData(
          (await future).copyWith(
            status: const DryRunStatusRunning.preparing(),
            currentPage: () => page,
          ),
        );
        await preloadFn();
        state = AsyncData(
          (await future).copyWith(
            status: const DryRunStatusRunning(),
            currentPage: () => page,
          ),
        );
      case Sync():
        break;
    }
    return preloadResult;
  }

  Future<void> _setFailedState(String error) async {
    final currentState = await future;
    state = AsyncData(
      currentState.copyWith(
        status: const DryRunStatusFailed(),
        error: error,
      ),
    );
  }

  Future<void> _setCancelledState(
    int totalPages, {
    required List<DownloadRecord> allRecords,
  }) async {
    state = AsyncData(
      (await future).copyWith(
        status: const DryRunStatusCancelled(),
        totalPages: totalPages,
        allRecords: allRecords,
      ),
    );
  }
}

extension _BulkDownloadLogger on Logger {
  void _log(String message) {
    debug('BulkDownload', message);
  }
}
