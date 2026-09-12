// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../../../foundation/media_scanner.dart';
import '../../../foundation/path.dart' as path;
import '../../../foundation/platform.dart';
import '../../configs/config/providers.dart';
import '../../ddos/handler/providers.dart';
import '../../download_manager/providers.dart';
import 'types.dart';

class BackgroundDownloadRuntime extends ConsumerStatefulWidget {
  const BackgroundDownloadRuntime({
    required this.child,
    super.key,
  });

  final Widget child;
  @override
  ConsumerState<BackgroundDownloadRuntime> createState() =>
      _BackgroundDownloadRuntimeState();
}

class _BackgroundDownloadRuntimeState
    extends ConsumerState<BackgroundDownloadRuntime> {
  late StreamSubscription<TaskUpdate> downloadUpdates;

  Future<void> _update(TaskUpdate update) async {
    if (update case TaskStatusUpdate()) {
      final logger = ref.read(loggerProvider);
      final taskLabel =
          'task=${update.task.taskId} '
          'host=${Uri.tryParse(update.task.url)?.host}';
      logger.info(
        'Download',
        '$taskLabel status=${update.status.name} '
            'httpStatus=${TaskErrorAdapter(update).response.statusCode} '
            'exceptionType=${update.exception?.runtimeType}',
      );
      if (update.status case TaskStatus.complete) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            final path = await update.task.filePath();
            if (isAndroid()) {
              await MediaScanner.loadMedia(path: path);
            } else if (isIOS()) {
              try {
                final hasAccess = await Gal.hasAccess(toAlbum: true);
                if (!hasAccess) {
                  await Gal.requestAccess(toAlbum: true);
                }
                await Gal.putImage(path);
              } on GalException catch (e) {
                debugPrint('Failed to save image to gallery: ${e.type}');
              }
            }
          },
        );
      } else if (update.status case TaskStatus.notFound) {
        // retry 404 url
        var willRetry = false;
        try {
          final config = ref.readConfigAuth;

          if (config.booruType.hasUnknownFullImageUrl) {
            willRetry = true;
            await Future<void>.delayed(const Duration(seconds: 1));
            final ext = path.extension(update.task.url);
            final newExt = switch (ext.toLowerCase()) {
              '.jpg' => '.png',
              '.png' => '.webp',
              _ => '.jpg',
            };

            final newUrl = removeFileExtension(update.task.url) + newExt;
            final newFileName =
                removeFileExtension(update.task.filename) + newExt;

            final newTask = update.task.copyWith(
              url: newUrl,
              filename: newFileName,
            );

            await FileDownloader().enqueue(newTask);
          }
        } catch (_) {
          willRetry = false;
        }

        if (willRetry) return;
      } else if (update.status case TaskStatus.failed) {
        final handled = await ref
            .read(httpDdosProtectionBypassProvider)
            .handleError(TaskErrorAdapter(update));
        logger.info('Download', '$taskLabel protectionHandled=$handled');
        if (handled) {
          ref.invalidate(bypassDdosHeadersProvider);
          final headers = await ref.read(
            bypassDdosHeadersProvider(update.task.url).future,
          );
          logger.info(
            'Download',
            '$taskLabel retry requested cookiePresent=${headers.containsKey('cookie')} '
                'userAgentPresent=${headers.containsKey('user-agent')}',
          );
          await FileDownloader().retryTask(update.task, headers: headers);
          logger.info('Download', '$taskLabel retry enqueue returned');
          return;
        }
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

    FileDownloader().configure(
      globalConfig: (
        Config.holdingQueue,
        (5, null, null),
      ),
      androidConfig: (Config.useCronet, true),
    );

    downloadUpdates = FileDownloader().updates.listen((update) {
      unawaited(_update(update));
    });
  }

  @override
  void dispose() {
    super.dispose();
    downloadUpdates.cancel();
    FileDownloader().resetUpdates();
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
