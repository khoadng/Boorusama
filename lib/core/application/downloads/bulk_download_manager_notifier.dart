// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/permission.dart';
import 'package:boorusama/core/provider.dart';

class BulkDownloadManagerNotifier extends Notifier<void> {
  BulkDownloadStateNotifier get bulkDownloadState =>
      ref.read(bulkDownloadStateProvider.notifier);

  BulkDownloader get downloader => ref.read(bulkDownloadProvider);

  StateController<BulkDownloadManagerStatus> get bulkDownloadStatus =>
      ref.read(bulkDownloadManagerStatusProvider.notifier);

  PostRepository get postRepo => ref.read(postRepoProvider);

  @override
  void build() {
    ref.listen(
      bulkdDownloadDataProvider,
      (previous, next) {
        next.whenData((value) {
          bulkDownloadState.updateDownloadStatus(url: value.url, status: value);
        });
      },
    );

    return;
  }

  void switchToTagSelect() {
    bulkDownloadStatus.state = BulkDownloadManagerStatus.dataSelected;
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
    //TODO: ask permission here, set some state to notify user
    if (permission != PermissionStatus.granted) {
      final status = await requestMediaPermissions(deviceInfo);
      if (status != PermissionStatus.granted) {
        bulkDownloadStatus.state = BulkDownloadManagerStatus.failure;
        return;
      }
    }

    final storagePath = ref.read(bulkDownloadOptionsProvider).storagePath;

    bulkDownloadStatus.state = BulkDownloadManagerStatus.downloadInProgress;

    final fileNameGenerator = ref.read(bulkDownloadFileNameProvider);

    var page = 1;
    final initialItems = await postRepo.getPostsFromTagsOrEmpty(tags, page);
    final itemStack = [initialItems];

    while (itemStack.isNotEmpty) {
      final items = itemStack.removeLast();

      for (var item in items) {
        downloader.enqueueDownload(
          url: item.downloadUrl,
          path: storagePath,
          fileNameBuilder: () => fileNameGenerator.generateFor(item),
        );

        ref.read(bulkDownloadThumbnailsProvider.notifier).state = {
          ...ref.read(bulkDownloadThumbnailsProvider),
          item.downloadUrl: item.thumbnailImageUrl,
        };

        bulkDownloadState.addDownloadSize(item.fileSize);
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    page += 1;
    final next = await postRepo.getPostsFromTagsOrEmpty(tags, page, limit: 20);
    if (next.isNotEmpty) {
      itemStack.add(next);
    }
  }

  Future<void> reset() async {
    await downloader.cancelAll();
    ref.invalidate(bulkDownloadThumbnailsProvider);
    ref.invalidate(bulkDownloadStateProvider);
    ref.invalidate(bulkDownloadSelectedTagsProvider);
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
