// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';

// Project imports:
import '../../../foundation/media_scanner.dart';
import '../../../foundation/path.dart' as path;
import '../../../foundation/platform.dart';
import '../../configs/config/providers.dart';
import '../../ddos/handler/providers.dart';
import '../../download_manager/providers.dart';
import 'downloader.dart';

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
                    final ext = path.extension(update.task.url);
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
      } else if (update.status case TaskStatus.failed) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final handled = await ref
              .read(httpDdosProtectionBypassProvider)
              .handleError(TaskErrorAdapter(update));
          if (handled) {
            ref.invalidate(bypassDdosHeadersProvider);
          }
        });
      }
    }

    ref.read(downloadTaskUpdatesProvider.notifier).addOrUpdate(update);
    ref.read(downloadTaskStreamControllerProvider).add(update);
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

String removeFileExtension(String url) {
  final lastDotIndex = url.lastIndexOf('.');
  if (lastDotIndex != -1) {
    return url.substring(0, lastDotIndex);
  } else {
    // If there is no '.', return the original URL
    return url;
  }
}
