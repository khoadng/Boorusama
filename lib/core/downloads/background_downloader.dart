// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:media_scanner/media_scanner.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/booru.dart';
import 'package:boorusama/core/configs/booru_config.dart';
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/downloads/download_service.dart';
import 'package:boorusama/core/downloads/types.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/functional.dart' as fp;
import 'package:boorusama/router.dart';

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

extension TaskUpdateX on TaskUpdate {
  int? get fileSize => switch (this) {
        TaskStatusUpdate s => () {
            final defaultSize =
                DownloaderMetadata.fromJsonString(task.metaData).fileSize;
            final fileSizeString = s.responseHeaders.toOption().fold(
                  () => '',
                  (headers) => headers[AppHttpHeaders.contentLengthHeader],
                );
            final fileSize =
                fileSizeString != null ? int.tryParse(fileSizeString) : null;

            return fileSize ?? defaultSize;
          }(),
        TaskProgressUpdate p => p.expectedFileSize,
      };
}

class BackgroundDownloader implements DownloadService {
  @override
  DownloadPathOrError download({
    required String url,
    required DownloadFilenameBuilder fileNameBuilder,
    DownloaderMetadata? metadata,
    int? fileSize,
    bool? skipIfExists,
  }) =>
      fp.TaskEither.Do(
        ($) async {
          final downloadDirTask = await tryGetDownloadDirectory().run();
          final downloadDir = downloadDirTask.fold((l) => null, (r) => r);

          final task = DownloadTask(
            url: url,
            filename: fileNameBuilder(),
            allowPause: true,
            retries: 1,
            baseDirectory: downloadDir != null
                ? BaseDirectory.root
                : BaseDirectory.applicationDocuments,
            directory: downloadDir != null ? downloadDir.path : '',
            updates: Updates.statusAndProgress,
            metaData: metadata?.toJsonString() ?? '',
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
    required DownloadFilenameBuilder fileNameBuilder,
    DownloaderMetadata? metadata,
    bool? skipIfExists,
  }) =>
      fp.TaskEither.Do(
        ($) async {
          final task = DownloadTask(
            url: url,
            filename: fileNameBuilder(),
            baseDirectory: BaseDirectory.root,
            directory: path,
            allowPause: true,
            retries: 1,
            updates: Updates.statusAndProgress,
            metaData: metadata?.toJsonString() ?? '',
          );

          return FileDownloader().enqueueIfNeeded(
            task,
            skipIfExists: skipIfExists,
          );
        },
      );
}

class BackgroundDownloaderBuilder extends ConsumerWidget {
  const BackgroundDownloaderBuilder({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useLegacy = ref
        .watch(settingsProvider.select((value) => value.useLegacyDownloader));

    return useLegacy
        ? child
        : BackgroundDownloaderScope(
            onTapNotification: (task, notificationType) {
              context.go(
                '/download_manager?filter=${notificationType.name}',
              );
            },
            child: child,
          );
  }
}

class BackgroundDownloaderScope extends ConsumerStatefulWidget {
  const BackgroundDownloaderScope({
    super.key,
    required this.onTapNotification,
    required this.child,
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
    final totalTasks = ref.read(downloadTasksProvider);

    final index =
        totalTasks.indexWhere((element) => element.task == update.task);

    if (update case TaskStatusUpdate()) {
      if (update.status case TaskStatus.complete) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            final path = await update.task.filePath();
            if (isAndroid()) {
              await MediaScanner.loadMedia(path: path);
            } else if (isIOS()) {
              Gal.putImage(path);
            }
          },
        );
      } else if (update.status case TaskStatus.notFound) {
        // retry 404 url
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            try {
              final config = ref.readConfig;

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

    if (index == -1) {
      ref.read(downloadTasksProvider.notifier).state = [
        ...totalTasks,
        update,
      ];
      return;
    } else {
      totalTasks[index] = update;
      ref.read(downloadTasksProvider.notifier).state = [
        ...totalTasks,
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    final tq = MemoryTaskQueue()
      ..minInterval = const Duration(milliseconds: 50);

    FileDownloader().addTaskQueue(tq);

    FileDownloader()
        .registerCallbacks(
            taskNotificationTapCallback: myNotificationTapCallback)
        .configureNotificationForGroup(
          FileDownloader.defaultGroup,
          running: const TaskNotification(
            '{filename}',
            '{progress}',
          ),
          complete: const TaskNotification(
            '{filename}',
            'completed',
          ),
          error: const TaskNotification(
            '{filename}',
            'failed',
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

final downloadTasksProvider = StateProvider<List<TaskUpdate>>((ref) {
  return [];
});
