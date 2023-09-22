// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/utils/duration_utils.dart';

const _serviceName = 'Bulk Download Manager';

class BulkDownloadManagerNotifier extends Notifier<void> {
  BulkDownloadStateNotifier get bulkDownloadState =>
      ref.read(bulkDownloadStateProvider.notifier);

  BulkDownloader get downloader => ref.read(bulkDownloadProvider);

  StateController<BulkDownloadManagerStatus> get bulkDownloadStatus =>
      ref.read(bulkDownloadManagerStatusProvider.notifier);

  PostRepository get postRepo => ref.read(postRepoProvider(booruConfig));

  BooruConfig get booruConfig => ref.read(currentBooruConfigProvider);

  LoggerService get logger => ref.read(loggerProvider);

  Future<List<Post>> getPosts(String tags, int page) {
    final options = ref.read(bulkDownloadOptionsProvider);
    return postRepo.getPostsFromTagsOrEmpty(
      tags,
      page,
      limit: options.postPerPage,
    );
  }

  @override
  void build() {
    return;
  }

  void done() {
    bulkDownloadStatus.state = BulkDownloadManagerStatus.initial;
    ref.invalidate(bulkDownloadThumbnailsProvider);
    ref.invalidate(bulkDownloadSelectedTagsProvider);
  }

  Future<void> download({
    required String tags,
  }) async {
    final permission = await Permission.storage.status;
    final deviceInfo = ref.read(deviceInfoProvider);
    final storagePath = ref.read(bulkDownloadOptionsProvider).storagePath;

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

    bulkDownloadStatus.state = BulkDownloadManagerStatus.downloadInProgress;

    final fileNameGenerator =
        ref.read(bulkDownloadFileNameProvider(booruConfig));

    try {
      var page = 1;
      final initialItems = await getPosts(tags, page);
      final itemStack = [initialItems];

      while (itemStack.isNotEmpty) {
        final items = itemStack.removeLast();

        for (var item in items) {
          final downloadUrl = ref.read(downloadUrlProvider(item));
          if (downloadUrl.isEmpty) continue;

          downloader.enqueueDownload(
            url: downloadUrl,
            path: storagePath,
            fileNameBuilder: () =>
                fileNameGenerator.generateFor(item, downloadUrl),
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
        final next = await getPosts(tags, page);
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
}
