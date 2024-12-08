// Dart imports:
import 'dart:isolate';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/sources.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/http.dart';
import 'package:boorusama/foundation/permissions.dart';
import '../downloader/metadata.dart';
import '../downloader/providers.dart';
import '../manager/download_task.dart';
import '../manager/download_tasks_notifier.dart';
import 'bulk_download_task.dart';
import 'notifications/providers.dart';

import 'package:background_downloader/background_downloader.dart'
    hide PermissionStatus;

const _serviceName = 'Bulk Download Manager';

const _perPage = 200;

final bulkdownloadProvider =
    NotifierProvider<BulkDownloadNotifier, List<BulkDownloadTask>>(
        BulkDownloadNotifier.new);

class BulkDownloadNotifier extends Notifier<List<BulkDownloadTask>> {
  @override
  List<BulkDownloadTask> build() {
    return [];
  }

  void addTask(BulkDownloadTask task) {
    state = [...state, task];
  }

  void removeTask(String id) {
    state = [
      for (final t in state)
        if (t.id != id) t,
    ];
  }

  void updateTaskStatus(String id, BulkDownloadTaskStatus status) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(status: status) else t,
    ];
  }

  Future<List<Post>> getPosts(
    String tags,
    int page,
    Iterable<List<TagExpression>>? patterns,
  ) async {
    final config = ref.readConfigSearch;
    final postRepo = ref.read(postRepoProvider(config));

    final r = await postRepo.getPostsFromTagsOrEmpty(
      tags,
      page: page,
      limit: _perPage,
    );

    final filteredItems = await _filterBlacklistedTags(r.posts, patterns);

    return filteredItems;
  }

  Future<void> startTask(String taskId) async {
    final deviceInfo = ref.read(deviceInfoProvider);
    final permission = await checkMediaPermissions(deviceInfo);
    final logger = ref.read(loggerProvider);
    final task = state.firstWhereOrNull((e) => e.id == taskId);

    if (task == null) {
      return;
    }

    logger.logI(_serviceName,
        'Download requested for "${task.tags}" at "${task.storagePath}" with permission status: $permission');

    //TODO: ask permission here, set some state to notify user
    if (permission != PermissionStatus.granted) {
      final status = await requestMediaPermissions(deviceInfo);
      if (status != PermissionStatus.granted) {
        logger.logE(_serviceName, 'Permission not granted, aborting download');
        showToast('Permission not granted, aborting download');
        state = [
          for (final t in state)
            if (t.id == taskId)
              t.copyWith(
                status: BulkDownloadTaskStatus.error,
                error: () => 'Permission not granted',
              )
            else
              t,
        ];
        return;
      }
    }

    // saved tags to history
    // ref.read(searchHistoryProvider.notifier).addHistory(task.query);

    updateTaskStatus(task.id, BulkDownloadTaskStatus.queue);

    final authConfig = ref.readConfigAuth;
    final config = ref.readConfig;

    final blacklistedTags =
        await ref.read(blacklistTagsProvider(authConfig).future);

    final patterns = blacklistedTags
        .map((tag) => tag.split(' ').map(TagExpression.parse).toList());

    final tags = task.query;
    final downloader = ref.read(downloadServiceProvider(authConfig));
    final settings = ref.read(settingsProvider);
    final downloadFileUrlExtractor =
        ref.read(downloadFileUrlExtractorProvider(authConfig));

    final fileNameBuilder =
        ref.read(currentBooruBuilderProvider)?.downloadFilenameBuilder;

    if (fileNameBuilder == null) {
      logger.logE('Bulk Download', 'No file name builder found, aborting...');
      return;
    }

    var estimatedDownloadSize = 0;
    var totalItems = 0;
    String? coverUrl;
    final siteUrl = ref.watchConfig.url;
    var pageProgress = const PageProgress(
      completed: 0,
      perPage: _perPage,
    );
    var mixedMedia = false;

    try {
      var page = 1;
      final initialItems = await getPosts(tags, page, patterns);
      final itemStack = [initialItems];

      if (initialItems.isEmpty) {
        showToast('No items found for $tags');
        state = [
          for (final t in state)
            if (t.id == taskId)
              t.copyWith(
                status: BulkDownloadTaskStatus.error,
                error: () => 'No items found',
              )
            else
              t,
        ];
        return;
      }

      coverUrl = initialItems.firstOrNull?.thumbnailImageUrl;

      state = [
        for (final t in state)
          if (t.id == taskId)
            t.copyWith(
              coverUrl: () => coverUrl,
            )
          else
            t,
      ];

      if (task.options.notications) {
        final notifQueue = ref.read(bulkDownloadNotificationQueueProvider);
        notifQueue[task.id] = false;
        ref.read(bulkDownloadNotificationQueueProvider.notifier).state = {
          ...notifQueue
        };
      }

      while (itemStack.isNotEmpty) {
        final currentTask = state.firstWhereOrNull((e) => e.id == taskId);
        if (currentTask?.status == BulkDownloadTaskStatus.inProgress) {
          break;
        }

        final items = itemStack.removeLast();

        for (var index = 0; index < items.length; index++) {
          final item = items[index];

          final urlData = await downloadFileUrlExtractor.getDownloadFileUrl(
            post: item,
            quality: task.options.quality ?? settings.downloadQuality,
          );
          if (urlData == null || urlData.url.isEmpty) continue;

          estimatedDownloadSize += item.fileSize;
          totalItems += 1;
          if (item.isAnimated) {
            mixedMedia = true;
          }

          final fileName = await fileNameBuilder.generateForBulkDownload(
            settings,
            config,
            item,
            metadata: {
              'index': index.toString(),
            },
            downloadUrl: urlData.url,
          );

          await downloader
              .downloadCustomLocation(
                url: urlData.url,
                path: task.path,
                filename: fileName,
                skipIfExists: task.options.skipIfExists,
                headers: {
                  if (urlData.cookie != null)
                    AppHttpHeaders.cookieHeader: urlData.cookie!,
                },
                metadata: DownloaderMetadata(
                  thumbnailUrl: item.thumbnailImageUrl,
                  fileSize: item.fileSize,
                  siteUrl: PostSource.from(item.thumbnailImageUrl).url,
                  group: task.id,
                ),
              )
              .run();
        }

        await const Duration(milliseconds: 200).future;

        page += 1;
        pageProgress = pageProgress.copyWith(
          completed: page,
        );

        state = [
          for (final t in state)
            if (t.id == taskId)
              t.copyWith(
                pageProgress: () => pageProgress,
              )
            else
              t,
        ];

        final next = await getPosts(tags, page, patterns);
        if (next.isNotEmpty) {
          itemStack.add(next);
        }
      }

      state = [
        for (final t in state)
          if (t.id == taskId)
            t.copyWith(
              estimatedDownloadSize: () => estimatedDownloadSize,
              status: BulkDownloadTaskStatus.inProgress,
              coverUrl: () => coverUrl,
              totalItems: () => totalItems,
              siteUrl: () => siteUrl,
              mixedMedia: () => mixedMedia,
            )
          else
            t,
      ];
    } catch (e) {
      logger.logE(_serviceName, 'Download requested for $tags failed: $e');
    }
  }

  Future<bool> cancelAll(String group) async {
    final taskIds = ref
        .read(downloadTasksProvider)
        .all(group)
        .map((e) => e.task.taskId)
        .toList();

    final res = await FileDownloader().cancelTasksWithIds(taskIds);

    updateTaskStatus(group, BulkDownloadTaskStatus.canceled);

    return res;
  }

  Future<void> stopQueuing(String group) async {
    // check if task status is queue
    final status = state.firstWhereOrNull((e) => e.id == group)?.status;

    if (status == BulkDownloadTaskStatus.queue) {
      updateTaskStatus(group, BulkDownloadTaskStatus.inProgress);
    }
  }
}

Future<List<Post>> _filterBlacklistedTags(
  List<Post> posts,
  Iterable<List<TagExpression>>? patterns,
) =>
    Isolate.run(
      () => _filterInIsolate(posts, patterns),
    );

List<Post> _filterInIsolate(
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
