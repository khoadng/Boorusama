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
import '../../ddos/solver/types.dart';
import '../../download_manager/providers.dart';
import 'types.dart';
import '../sidecar/data.dart';
import '../sidecar/providers.dart';
import '../downloader/types.dart' show DownloaderMetadata;

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
  final _attempts = <String, ProtectionAttempt>{};

  late StreamSubscription<TaskUpdate> downloadUpdates;

  Future<void> _update(TaskUpdate update) async {
    if (update case TaskStatusUpdate()) {
      // Includes undelivered native completion updates replayed after restart.
      // The headless callback handles completion while the app is not running.
      try {
        if (DownloaderMetadata.fromJsonString(update.task.metaData).sidecarId !=
            null) {
          final store = await ref.read(sidecarStoreProvider.future);
          await finishDownloadSidecar(update, store: store);
        }
      } catch (error) {
        ref
            .read(loggerProvider)
            .error(
              'Download',
              'Metadata finalization failed: ${error.runtimeType}',
              sensitiveMessage: error.toString(),
            );
      }
      final attempt = _attempts.putIfAbsent(
        update.task.taskId,
        () => ref
            .read(httpDdosProtectionBypassProvider)
            .beginAttempt(
              Uri.parse(update.task.url),
              ProtectionSource.download,
            ),
      );
      attempt.record(
        DownloadStatusObserved(
          taskId: update.task.taskId,
          status: update.status.name,
          httpStatus: TaskErrorAdapter(update).response.statusCode,
          errorType: update.exception?.runtimeType.toString(),
          retries: attempt.retries,
        ),
        sensitive: ProtectionRequestDetails(Uri.parse(update.task.url)),
      );
      attempt.observeHeaders(update.task.headers);
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
      } else if (update.status == TaskStatus.failed) {
        final handled = await ref
            .read(httpDdosProtectionBypassProvider)
            .handleError(TaskErrorAdapter(update), attempt: attempt);
        if (handled) {
          attempt.record(const RetryPreparationStarted());
          try {
            ref.invalidate(bypassDdosHeadersProvider);
            final headers = await ref.read(
              bypassDdosHeadersProvider(update.task.url).future,
            );
            attempt.retries++;
            attempt.record(RetryDispatched(attempt.retries));
            final enqueued = await FileDownloader().retryTask(
              update.task,
              bypassHeaders: headers,
              onPrepared: attempt.observeHeaders,
            );
            attempt.record(RetryEnqueued(enqueued));
            if (!enqueued) _attempts.remove(update.task.taskId);
            return;
          } catch (error) {
            attempt.record(
              ProtectionOperationFailed(
                ProtectionOperation.enqueueRetry,
                error.runtimeType.toString(),
              ),
            );
            _attempts.remove(update.task.taskId);
            rethrow;
          }
        }
      }
      if (update.status.isFinalState) _attempts.remove(update.task.taskId);
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

    ref
        .read(loggerProvider)
        .info('Download', 'backend configured androidCronet=true');
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
    _attempts.clear();
    FileDownloader().resetUpdates();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sidecarRecoveryProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        ref
            .read(loggerProvider)
            .error(
              'Download',
              'Metadata recovery failed: ${error.runtimeType}',
              sensitiveMessage: error.toString(),
            );
      }
    });
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
