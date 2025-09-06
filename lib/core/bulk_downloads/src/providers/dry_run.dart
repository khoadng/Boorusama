// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../../foundation/utils/duration_utils.dart';
import '../../../configs/config/types.dart';
import '../../../configs/ref.dart';
import '../../../downloads/filename/providers.dart';
import '../../../downloads/filename/types.dart';
import '../../../downloads/urls/providers.dart';
import '../../../http/http.dart';
import '../../../http/providers.dart';
import '../../../search/selected_tags/tag.dart';
import '../../../settings/providers.dart';
import '../types/bulk_download_error.dart';
import '../types/download_configs.dart';
import '../types/download_record.dart';
import '../types/download_session.dart';
import '../types/download_task.dart';
import 'file_system_exist_checker.dart';
import 'providers.dart';

const kBulkDownloadAsyncDelay = Duration(milliseconds: 1000);

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
        status: DryRunStatus.running,
      ),
    );

    try {
      final config = ref.readConfig;
      final logger = ref.read(loggerProvider);
      final downloadFileUrlExtractor =
          downloadConfigs?.urlExtractor ??
          ref.read(downloadFileUrlExtractorProvider(config.auth));
      final headers =
          downloadConfigs?.headers ??
          ref.read(cachedBypassDdosHeadersProvider(config.url));
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
      final fileExistChecker =
          downloadConfigs?.existChecker ??
          const FileSystemDownloadExistChecker();

      var page = 1;
      final tags = SearchTagSet.fromString(task.tags);
      final sessionId = session.id;
      final allRecords = <DownloadRecord>[];

      if (tags.isEmpty) {
        final currentState = await future;
        state = AsyncData(
          currentState.copyWith(
            status: DryRunStatus.failed,
            error: const EmptyTagsError().toString(),
          ),
        );
        return;
      } else {
        final firstResult = await fetcher.getPosts(
          tags: tags,
          page: page,
          task: task,
        );

        if (firstResult.isEmpty) {
          final currentState = await future;
          state = AsyncData(
            currentState.copyWith(
              status: DryRunStatus.failed,
              error: const NoPostsFoundError().toString(),
            ),
          );
          return;
        } else {
          var rawPosts = firstResult.posts;

          final preloadResult = await fileNameBuilder.preloadForBulkDownload(
            rawPosts,
            config.auth,
            config.download,
          );

          final asyncFilenameNoPreload =
              preloadResult == PreloadResult.asyncNoPreload;
          var cumulativeIndex = 0;

          while (await shouldContinue()) {
            final records = <DownloadRecord>[];
            logger.verbose(
              'BulkDownload',
              'Dry run page $page started for session $sessionId',
            );

            await onPageProgress(page);

            final currentState = await future;

            // Update current page state
            state = AsyncData(
              currentState.copyWith(currentPage: page),
            );

            for (var i = 0; i < rawPosts.length; i++) {
              logger.verbose(
                'BulkDownload',
                'Processing post ${i + 1}/${rawPosts.length} for session $sessionId',
              );

              if (cancelToken.isCancelled) {
                logger.verbose(
                  'BulkDownload',
                  'Session $sessionId cancelled during dry run',
                );
                final currentState = await future;
                state = AsyncData(
                  currentState.copyWith(
                    status: DryRunStatus.cancelled,
                    totalPages: page,
                  ),
                );
                return;
              }

              if (!await shouldContinue()) {
                break;
              }

              final item = rawPosts[i];

              final urlData = await downloadFileUrlExtractor
                  ?.getDownloadFileUrl(
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
              );

              if (asyncFilenameNoPreload) {
                logger.verbose(
                  'BulkDownload',
                  'Waiting for async token delay for post ${item.id}',
                );
                await Future.delayed(kBulkDownloadAsyncDelay);
              }

              logger.verbose(
                'BulkDownload',
                'Resolved filename for post ${item.id}: $fileName',
              );

              if (task.skipIfExists) {
                final exists = fileExistChecker.exists(fileName, task.path);
                if (exists) {
                  cumulativeIndex++;
                  logger.verbose(
                    'BulkDownload',
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

              logger.verbose(
                'BulkDownload',
                'Post ${item.id} processed, fileName: $fileName, downloadUrl: ${urlData.url}',
              );

              cumulativeIndex++;
            }

            if (cancelToken.isCancelled) {
              final currentState = await future;
              state = AsyncData(
                currentState.copyWith(
                  status: DryRunStatus.cancelled,
                  totalPages: page,
                ),
              );
              return;
            }

            logger.verbose(
              'BulkDownload',
              'Dry run page $page processed, found ${records.length} valid records',
            );

            allRecords.addAll(records);

            // Update records found count
            state = AsyncData(
              (await future).copyWith(recordsFound: allRecords.length),
            );

            page++;

            if (!await shouldContinue()) {
              logger.verbose(
                'BulkDownload',
                'Session $sessionId is no longer in dry run state, exiting dry run',
              );
              break;
            }

            final delay = downloadConfigs?.delayBetweenRequests;
            if (delay != null) {
              await delay.future;
            } else {
              await Future.delayed(const Duration(milliseconds: 200));
            }

            logger.verbose(
              'BulkDownload',
              'Fetching page $page for session $sessionId',
            );

            final nextResult = await fetcher.getPosts(
              tags: tags,
              page: page,
              task: task,
            );

            if (nextResult.isEmpty) {
              page--;
              logger.verbose(
                'BulkDownload',
                'No more items found, ending dry run for session $sessionId',
              );
              break;
            }

            rawPosts = nextResult.posts;
          }

          logger.verbose(
            'BulkDownload',
            'Dry run ended for session $sessionId',
          );

          final currentState = await future;
          state = AsyncData(
            currentState.copyWith(
              status: DryRunStatus.completed,
              allRecords: allRecords,
              totalPages: page,
              recordsFound: allRecords.length,
            ),
          );
        }
      }
    } catch (e) {
      state = AsyncData(
        currentState.copyWith(
          status: DryRunStatus.failed,
          error: e.toString(),
        ),
      );
    }
  }
}

enum DryRunStatus {
  notFound,
  idle,
  running,
  completed,
  cancelled,
  failed,
}

class DryRunState extends Equatable {
  const DryRunState({
    required this.status,
    required this.currentPage,
    required this.recordsFound,
    required this.totalPages,
    this.error,
    this.allRecords = const [],
  });

  const DryRunState.notFound()
    : status = DryRunStatus.notFound,
      currentPage = 0,
      recordsFound = 0,
      totalPages = 0,
      error = null,
      allRecords = const [];

  factory DryRunState.initial() => const DryRunState(
    status: DryRunStatus.idle,
    currentPage: 0,
    recordsFound: 0,
    totalPages: 0,
  );

  final DryRunStatus status;
  final int currentPage;
  final int recordsFound;
  final int totalPages;
  final String? error;
  final List<DownloadRecord> allRecords;

  DryRunState copyWith({
    DryRunStatus? status,
    int? currentPage,
    int? recordsFound,
    int? totalPages,
    String? error,
    List<DownloadRecord>? allRecords,
  }) {
    return DryRunState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      recordsFound: recordsFound ?? this.recordsFound,
      totalPages: totalPages ?? this.totalPages,
      error: error ?? this.error,
      allRecords: allRecords ?? this.allRecords,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentPage,
    recordsFound,
    totalPages,
    error,
    allRecords,
  ];
}
