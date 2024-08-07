// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/utils/duration_utils.dart';

const _serviceName = 'Bulk Download Manager';

class BulkDownloadManagerNotifier extends FamilyNotifier<void, BooruConfig> {
  BulkDownloadStateNotifier get bulkDownloadState =>
      ref.read(bulkDownloadStateProvider(arg).notifier);

  Downloader get downloader => ref.read(bulkDownloadProvider(arg));

  StateController<BulkDownloadManagerStatus> get bulkDownloadStatus =>
      ref.read(bulkDownloadManagerStatusProvider.notifier);

  PostRepository get postRepo => ref.read(postRepoProvider(arg));

  LoggerService get logger => ref.read(loggerProvider);

  Future<List<Post>> getPosts(
    String tags,
    int page,
    Iterable<List<TagExpression>>? patterns,
  ) async {
    final options = ref.read(bulkDownloadOptionsProvider);

    final r = await postRepo.getPostsFromTagsOrEmpty(
      tags,
      page: page,
      limit: options.postPerPage,
    );

    final filteredItems = _filterBlacklistedTags(r.posts, patterns);

    return filteredItems;
  }

  @override
  void build(BooruConfig arg) {
    return;
  }

  void done() {
    bulkDownloadStatus.state = BulkDownloadManagerStatus.initial;
    ref.invalidate(bulkDownloadThumbnailsProvider);
    ref.invalidate(bulkDownloadSelectedTagsProvider);
  }

  List<Post> _filterBlacklistedTags(
    List<Post> posts,
    Iterable<List<TagExpression>>? patterns,
  ) {
    if (patterns == null || patterns.isEmpty) {
      return posts;
    }

    final filterIds = <int>{};

    for (final post in posts) {
      for (final pattern in patterns) {
        if (post.containsTagPattern(pattern)) {
          filterIds.add(post.id);
          break;
        }
      }
    }

    return posts.where((e) => !filterIds.contains(e.id)).toList();
  }

  Future<void> download({
    required String tags,
  }) async {
    final deviceInfo = ref.read(deviceInfoProvider);
    final permission = await checkMediaPermissions(deviceInfo);
    final options = ref.read(bulkDownloadOptionsProvider);
    final storagePath = options.storagePath;
    final settings = ref.read(settingsProvider);
    final blacklistedTags = options.ignoreBlacklistedTags
        ? await ref.read(blacklistTagsProvider(ref.readConfig).future)
        : null;
    final patterns = blacklistedTags
        ?.map((tag) => tag.split(' ').map(TagExpression.parse).toList());

    logger.logI(_serviceName,
        'Download requested for "$tags" at "$storagePath" with permission status: $permission');

    //TODO: ask permission here, set some state to notify user
    if (permission != PermissionStatus.granted) {
      final status = await requestMediaPermissions(deviceInfo);
      if (status != PermissionStatus.granted) {
        logger.logE(_serviceName, 'Permission not granted, aborting download');
        bulkDownloadStatus.state = BulkDownloadManagerStatus.failure;
        return;
      }
    }

    // saved tags to history
    ref.read(searchHistoryProvider.notifier).addHistory(tags);

    bulkDownloadStatus.state = BulkDownloadManagerStatus.downloadInProgress;

    final fileNameBuilder = ref.readBooruBuilder(arg)?.downloadFilenameBuilder;

    if (fileNameBuilder == null) {
      logger.logE('Bulk Download', 'No file name builder found, aborting...');
      showErrorToast('Download aborted, cannot create file name');
      return;
    }

    try {
      var page = 1;
      final initialItems = await getPosts(tags, page, patterns);
      final itemStack = [initialItems];

      while (itemStack.isNotEmpty) {
        if (bulkDownloadStatus.state == BulkDownloadManagerStatus.cancel) {
          break;
        }

        final items = itemStack.removeLast();

        for (var index = 0; index < items.length; index++) {
          final item = items[index];
          final downloadUrl = getDownloadFileUrl(item, settings);
          if (downloadUrl == null || downloadUrl.isEmpty) continue;

          downloader.enqueueDownload(
            url: downloadUrl,
            path: storagePath,
            fileNameBuilder: () => fileNameBuilder.generateForBulkDownload(
              settings,
              arg,
              item,
              metadata: {
                'index': index.toString(),
              },
            ),
          );

          ref.read(bulkDownloadThumbnailsProvider.notifier).state = {
            ...ref.read(bulkDownloadThumbnailsProvider),
            downloadUrl: item.thumbnailImageUrl,
          };

          ref.read(bulkDownloadFileSizeProvider.notifier).state = {
            ...ref.read(bulkDownloadFileSizeProvider),
            downloadUrl: item.fileSize,
          };

          bulkDownloadState.addDownloadSize(item.fileSize);
        }

        await const Duration(milliseconds: 200).future;

        page += 1;
        final next = await getPosts(tags, page, patterns);
        if (next.isNotEmpty) {
          itemStack.add(next);
        }
      }
    } catch (e) {
      logger.logE(_serviceName, 'Download requested for $tags failed: $e');
    }
  }

  Future<void> reset() async {
    await downloader.cancelAll();
    ref.invalidate(bulkDownloadThumbnailsProvider);
    ref.invalidate(bulkDownloadSelectedTagsProvider);
  }

  Future<void> retry(String url, String fileName) async {
    bulkDownloadState.updateDownloadToInitilizingState(url);

    final storagePath = ref.read(bulkDownloadOptionsProvider).storagePath;

    await downloader.enqueueDownload(
      url: url,
      path: storagePath,
      fileNameBuilder: () => fileName,
    );
  }

  Future<void> pause(String url) async {
    bulkDownloadState.updateDownloadToInitilizingState(url);
    await downloader.pause(url);
  }

  Future<void> resume(String url) async {
    bulkDownloadState.updateDownloadToInitilizingState(url);
    await downloader.resume(url);
  }

  Future<void> cancelAll() async {
    bulkDownloadStatus.state = BulkDownloadManagerStatus.cancel;
    await downloader.cancelAll();
  }

  Future<void> retryAll() async {
    final failed = bulkDownloadState.state.downloadStatuses.values
        .whereType<DownloadFailed>();
    for (final download in failed) {
      retry(download.url, download.fileName);
    }
  }
}
