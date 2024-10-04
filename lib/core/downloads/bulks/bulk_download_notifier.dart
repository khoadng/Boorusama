// Package imports:
import 'package:background_downloader/background_downloader.dart'
    hide PermissionStatus;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/router.dart';

const _serviceName = 'Bulk Download Manager';

enum BulkDownloadTaskStatus {
  created,
  queue,
  inProgress,
  canceled,
  error,
}

class PageProgress extends Equatable {
  const PageProgress({
    required this.completed,
    required this.perPage,
  });

  PageProgress copyWith({
    int? completed,
    int? perPage,
  }) {
    return PageProgress(
      completed: completed ?? this.completed,
      perPage: perPage ?? this.perPage,
    );
  }

  final int completed;
  final int perPage;

  @override
  List<Object?> get props => [completed];
}

class BulkDownloadOptions extends Equatable {
  const BulkDownloadOptions({
    required this.notications,
    required this.skipIfExists,
  });

  const BulkDownloadOptions.defaults()
      : notications = true,
        skipIfExists = true;

  BulkDownloadOptions copyWith({
    bool? notications,
    bool? skipIfExists,
  }) {
    return BulkDownloadOptions(
      notications: notications ?? this.notications,
      skipIfExists: skipIfExists ?? this.skipIfExists,
    );
  }

  final bool notications;
  final bool skipIfExists;

  @override
  List<Object?> get props => [notications, skipIfExists];
}

class BulkDownloadTask extends Equatable with DownloadMixin {
  const BulkDownloadTask({
    required this.id,
    required this.status,
    required this.tags,
    required this.path,
    required this.estimatedDownloadSize,
    required this.coverUrl,
    required this.totalItems,
    required this.mixedMedia,
    required this.siteUrl,
    required this.pageProgress,
    required this.options,
    required this.error,
  });

  BulkDownloadTask.randomId({
    required this.tags,
    required this.path,
  })  : id = 'task${DateTime.now().millisecondsSinceEpoch}',
        estimatedDownloadSize = null,
        coverUrl = null,
        totalItems = null,
        mixedMedia = null,
        siteUrl = null,
        pageProgress = null,
        error = null,
        options = const BulkDownloadOptions.defaults(),
        status = BulkDownloadTaskStatus.created;

  BulkDownloadTask copyWith({
    String? id,
    BulkDownloadTaskStatus? status,
    List<String>? tags,
    String? path,
    int? Function()? estimatedDownloadSize,
    String? Function()? coverUrl,
    int? Function()? totalItems,
    bool? Function()? mixedMedia,
    String? Function()? siteUrl,
    PageProgress? Function()? pageProgress,
    BulkDownloadOptions? options,
    String? Function()? error,
  }) {
    return BulkDownloadTask(
      id: id ?? this.id,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      path: path ?? this.path,
      estimatedDownloadSize:
          estimatedDownloadSize?.call() ?? this.estimatedDownloadSize,
      coverUrl: coverUrl?.call() ?? this.coverUrl,
      totalItems: totalItems?.call() ?? this.totalItems,
      mixedMedia: mixedMedia?.call() ?? this.mixedMedia,
      siteUrl: siteUrl?.call() ?? this.siteUrl,
      pageProgress: pageProgress?.call() ?? this.pageProgress,
      options: options ?? this.options,
      error: error?.call() ?? this.error,
    );
  }

  final String id;
  final BulkDownloadTaskStatus status;
  final List<String> tags;
  final String path;
  final int? estimatedDownloadSize;
  final int? totalItems;
  final bool? mixedMedia;
  final String? coverUrl;
  final String? siteUrl;
  final PageProgress? pageProgress;

  final BulkDownloadOptions options;

  final String? error;

  @override
  List<Object?> get props => [
        id,
        status,
        tags,
        path,
        estimatedDownloadSize,
        coverUrl,
        totalItems,
        mixedMedia,
        siteUrl,
        pageProgress,
        options,
        error,
      ];

  @override
  String? get storagePath => path;
}

extension BulkDownloadTaskX on BulkDownloadTask {
  String get query => tags.join(' ');
  String get displayName => tags.join(', ');
}

const _perPage = 200;

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

  Future<List<Post>> getPosts(
    String tags,
    int page,
    Iterable<List<TagExpression>>? patterns,
  ) async {
    final config = ref.readConfig;
    final postRepo = ref.read(postRepoProvider(config));

    final r = await postRepo.getPostsFromTagsOrEmpty(
      tags,
      page: page,
      limit: _perPage,
    );

    final filteredItems = _filterBlacklistedTags(r.posts, patterns);

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

    // check if there is any running task
    final runningTask = state.firstWhereOrNull(
      (e) => e.status == BulkDownloadTaskStatus.inProgress,
    );

    if (runningTask != null) {
      // check if it is completed
      final completed =
          ref.read(downloadTasksProvider).allCompleted(runningTask.id);

      if (!completed) {
        const msg =
            'Please wait for the current download to finish first before starting another one';

        ref.read(bulkDownloadErrorNotificationQueueProvider.notifier).state =
            msg;

        return;
      }
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

    final config = ref.readConfig;

    final blacklistedTags =
        await ref.read(blacklistTagsProvider(config).future);

    final patterns = blacklistedTags
        .map((tag) => tag.split(' ').map(TagExpression.parse).toList());

    final tags = task.query;
    final downloader = ref.read(downloadServiceProvider(config));
    final settings = ref.read(settingsProvider);

    final fileNameBuilder =
        ref.readBooruBuilder(config)?.downloadFilenameBuilder;

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

          final downloadUrl = getDownloadFileUrl(item, settings);
          if (downloadUrl == null || downloadUrl.isEmpty) continue;

          estimatedDownloadSize += item.fileSize;
          totalItems += 1;
          if (item.isAnimated) {
            mixedMedia = true;
          }

          await downloader
              .downloadCustomLocation(
                url: downloadUrl,
                path: task.path,
                filename: fileNameBuilder.generateForBulkDownload(
                  settings,
                  config,
                  item,
                  metadata: {
                    'index': index.toString(),
                  },
                ),
                skipIfExists: task.options.skipIfExists,
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

final bulkDownloadOnTapStreamProvider = StreamProvider<String>(
  (ref) {
    return ref.watch(bulkDownloadNotificationProvider).tapStream;
  },
);

class BulkDownloadNotificationScope extends ConsumerWidget {
  const BulkDownloadNotificationScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      downloadTasksProvider,
      (prev, cur) {
        final notifQueue = ref.read(bulkDownloadNotificationQueueProvider);

        if (notifQueue.isEmpty) return;

        for (final group in cur.tasks.keys) {
          if (!notifQueue.containsKey(group)) {
            continue;
          }

          final curComleted = cur.allCompleted(group);

          if (curComleted) {
            final task = ref.read(bulkdownloadProvider).firstWhereOrNull(
                  (e) => e.id == group,
                );

            if (task == null) return;

            ref.read(bulkDownloadNotificationProvider).showNotification(
                  task.displayName,
                  'Downloaded ${task.totalItems} files',
                );

            notifQueue.remove(group);

            ref.read(bulkDownloadNotificationQueueProvider.notifier).state = {
              ...notifQueue
            };
          }
        }
      },
    );

    ref.listen(
      bulkDownloadErrorNotificationQueueProvider,
      (prev, cur) {
        if (cur == null) return;

        ref.read(bulkDownloadErrorNotificationQueueProvider.notifier).state =
            null;

        showErrorToast(context, cur);
      },
    );

    ref.listen(
      bulkDownloadOnTapStreamProvider,
      (prev, cur) {
        if (prev == null) return;

        context.pushNamed(kBulkdownload);
      },
    );

    return child;
  }
}
