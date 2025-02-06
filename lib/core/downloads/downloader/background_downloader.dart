// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:gal/gal.dart';

// Project imports:
import '../../boorus/booru/booru.dart';
import '../../configs/ref.dart';
import '../../foundation/media_scanner.dart';
import '../../foundation/path.dart';
import '../../foundation/platform.dart';
import '../../router.dart';
import '../l10n.dart';
import '../manager/download_task_updates_notifier.dart';
import '../path/download_path.dart';
import 'download_service.dart';
import 'metadata.dart';

extension FileDownloadX on FileDownloader {
  Future<String> enqueueIfNeeded(
    DownloadTask task, {
    bool? skipIfExists,
  }) async {
    final file = await task.filePath();

    if (skipIfExists == true) {
      if (File(file).existsSync()) {
        return file;
      }
    }

    await enqueue(task);

    return file;
  }
}

class BackgroundDownloader implements DownloadService {
  @override
  DownloadPathOrError download({
    required String url,
    required String filename,
    DownloaderMetadata? metadata,
    int? fileSize,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) =>
      TaskEither.Do(
        ($) async {
          final downloadDirTask = await tryGetDownloadDirectory().run();
          final downloadDir = downloadDirTask.fold((l) => null, (r) => r);

          final task = DownloadTask(
            url: url,
            filename: filename,
            allowPause: true,
            retries: 1,
            baseDirectory: downloadDir != null
                ? BaseDirectory.root
                : BaseDirectory.applicationDocuments,
            directory: downloadDir != null ? downloadDir.path : '',
            updates: Updates.statusAndProgress,
            metaData: metadata?.toJsonString() ?? '',
            headers: headers,
            group: metadata?.group ?? FileDownloader.defaultGroup,
          );

          return FileDownloader().enqueueIfNeeded(
            task,
            skipIfExists: skipIfExists,
          );
        },
      );

  @override
  DownloadPathOrError downloadCustomLocation({
    required String url,
    required String path,
    required String filename,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
    Map<String, String>? headers,
  }) =>
      TaskEither.Do(
        ($) async {
          final task = DownloadTask(
            url: url,
            filename: filename,
            baseDirectory: BaseDirectory.root,
            directory: path,
            allowPause: true,
            retries: 1,
            updates: Updates.statusAndProgress,
            metaData: metadata?.toJsonString() ?? '',
            headers: headers,
            group: metadata?.group ?? FileDownloader.defaultGroup,
          );

          return FileDownloader().enqueueIfNeeded(
            task,
            skipIfExists: skipIfExists,
          );
        },
      );

  @override
  Future<bool> cancelTasksWithIds(List<String> ids) {
    return FileDownloader().cancelTasksWithIds(ids);
  }
}

class BackgroundDownloaderBuilder extends ConsumerWidget {
  const BackgroundDownloaderBuilder({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundDownloaderScope(
      onTapNotification: (task, notificationType) {
        context.go(
          Uri(
            path: '/download_manager',
            queryParameters: {
              'filter': notificationType.name,
            },
          ).toString(),
        );
      },
      child: child,
    );
  }
}

class BackgroundDownloaderScope extends ConsumerStatefulWidget {
  const BackgroundDownloaderScope({
    required this.onTapNotification,
    required this.child,
    super.key,
  });

  final Widget child;
  final void Function(Task task, NotificationType notificationType)
      onTapNotification;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BackgroundDownloaderScopeState();
}

class _BackgroundDownloaderScopeState
    extends ConsumerState<BackgroundDownloaderScope> {
  late StreamSubscription<TaskUpdate> downloadUpdates;

  void _update(TaskUpdate update) {
    if (update case TaskStatusUpdate()) {
      if (update.status case TaskStatus.complete) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            final path = await update.task.filePath();
            if (isAndroid()) {
              await MediaScanner.loadMedia(path: path);
            } else if (isIOS()) {
              unawaited(Gal.putImage(path));
            }
          },
        );
      } else if (update.status case TaskStatus.notFound) {
        // retry 404 url
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            try {
              final config = ref.readConfigAuth;

              if (config.booruType.hasUnknownFullImageUrl) {
                // retry after 1 second
                Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    final ext = extension(update.task.url);
                    final newExt = switch (ext.toLowerCase()) {
                      '.jpg' => '.png',
                      '.png' => '.webp',
                      _ => '.jpg',
                    };

                    final newUrl =
                        removeFileExtension(update.task.url) + newExt;
                    final newFileName =
                        removeFileExtension(update.task.filename) + newExt;

                    final newTask = update.task.copyWith(
                      url: newUrl,
                      filename: newFileName,
                    );

                    FileDownloader().enqueue(newTask);
                  },
                );
              }
            } catch (e) {
              // do nothing
            }
          },
        );
      }
    }

    ref.read(downloadTaskUpdatesProvider.notifier).addOrUpdate(update);
  }

  @override
  void initState() {
    super.initState();
    final tq = MemoryTaskQueue()
      ..minInterval = const Duration(milliseconds: 50);

    FileDownloader().addTaskQueue(tq);

    FileDownloader()
        .registerCallbacks(
          taskNotificationTapCallback: myNotificationTapCallback,
        )
        .configureNotificationForGroup(
          FileDownloader.defaultGroup,
          running: const TaskNotification(
            '{filename}',
            '{progress}',
          ),
          complete: TaskNotification(
            '{filename}',
            DownloadTranslations.downloadCompletedNotification.tr(),
          ),
          error: TaskNotification(
            '{filename}',
            DownloadTranslations.downloadFailedNotification.tr(),
          ),
          progressBar: true,
        );

    FileDownloader().configure(
      globalConfig: (
        Config.holdingQueue,
        (5, null, null),
      ),
    );

    downloadUpdates = FileDownloader().updates.listen((update) {
      _update(update);
    });
  }

  @override
  void dispose() {
    super.dispose();
    downloadUpdates.cancel();
    FileDownloader().resetUpdates();
  }

  void myNotificationTapCallback(Task task, NotificationType notificationType) {
    widget.onTapNotification(task, notificationType);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
