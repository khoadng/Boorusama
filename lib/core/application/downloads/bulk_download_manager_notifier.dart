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
  @override
  void build() {
    ref.listen(
      bulkdDownloadDataProvider,
      (previous, next) {
        next.whenData((value) {
          final bs = ref.read(bulkDownloadStateProvider);

          ref.read(bulkDownloadStateProvider.notifier).state = bs.copyWith(
            downloadStatuses: {
              ...bs.downloadStatuses,
              value.url: value,
            },
          );
        });
      },
    );

    return;
  }

  void switchToTagSelect() {
    ref.read(bulkDownloadManagerStatusProvider.notifier).state =
        BulkDownloadManagerStatus.dataSelected;
  }

  void done() {
    ref.read(bulkDownloadManagerStatusProvider.notifier).state =
        BulkDownloadManagerStatus.initial;
    ref.invalidate(bulkDownloadThumbnailsProvider);
    ref.invalidate(bulkDownloadStateProvider);
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
        ref.read(bulkDownloadManagerStatusProvider.notifier).state =
            BulkDownloadManagerStatus.failure;
        return;
      }
    }

    final storagePath = ref.read(bulkDownloadOptionsProvider).storagePath;

    ref.read(bulkDownloadManagerStatusProvider.notifier).state =
        BulkDownloadManagerStatus.downloadInProgress;

    final fileNameGenerator = ref.read(bulkDownloadFileNameProvider);

    var page = 1;
    final initialItems =
        await ref.read(postRepoProvider).getPostsFromTagsOrEmpty(tags, page);
    final itemStack = [initialItems];

    while (itemStack.isNotEmpty) {
      final items = itemStack.removeLast();

      for (var item in items) {
        ref.read(bulkDownloadProvider).enqueueDownload(
              url: item.downloadUrl,
              path: storagePath,
              fileNameBuilder: () => fileNameGenerator.generateFor(item),
            );

        final ts = ref.read(bulkDownloadThumbnailsProvider);
        ref.read(bulkDownloadThumbnailsProvider.notifier).state = {
          ...ts,
          item.downloadUrl: item.thumbnailImageUrl,
        };

        final bs = ref.read(bulkDownloadStateProvider);
        ref.read(bulkDownloadStateProvider.notifier).state = bs.copyWith(
          estimatedDownloadSize: bs.estimatedDownloadSize + item.fileSize,
        );
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    page += 1;
    final next = await ref
        .read(postRepoProvider)
        .getPostsFromTagsOrEmpty(tags, page, limit: 20);
    if (next.isNotEmpty) {
      itemStack.add(next);
    }
  }

  Future<void> reset() async {
    await ref.read(bulkDownloadProvider).cancelAll();
    ref.invalidate(bulkDownloadThumbnailsProvider);
    ref.invalidate(bulkDownloadStateProvider);
    ref.invalidate(bulkDownloadSelectedTagsProvider);
  }

  Future<void> cancelAll() async {
    await ref.read(bulkDownloadProvider).cancelAll();
  }
}
