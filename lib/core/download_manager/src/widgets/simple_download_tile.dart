// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../foundation/platform.dart';
import '../../../../foundation/url_launcher.dart';
import '../../../downloads/background/types.dart';
import '../../../downloads/configs/widgets.dart';
import '../../../downloads/downloader/types.dart';
import '../../../themes/theme/types.dart';
import '../../../widgets/drag_line.dart';
import '../providers/task_update_ex.dart';

final _checkResumableProvider = FutureProvider.autoDispose.family<bool, Task>((
  ref,
  task,
) {
  return FileDownloader().taskCanResume(task);
});

class SimpleDownloadTile extends ConsumerWidget {
  const SimpleDownloadTile({
    required this.task,
    required this.onResume,
    required this.onPause,
    required this.onResumeFailed,
    required this.onRestart,
    required this.onCancel,
    this.onTap,
    super.key,
  });

  final TaskUpdate task;
  final void Function() onResume;
  final void Function() onPause;
  final void Function() onResumeFailed;
  final void Function() onRestart;
  final void Function() onCancel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = DownloaderMetadata.fromJsonString(task.task.metaData);

    return DownloadTileBuilder(
      url: task.task.url,
      thumbnailUrl: metadata.thumbnailUrl,
      siteUrl: metadata.siteUrl,
      fileSize: task.fileSize,
      networkSpeed: switch (task) {
        TaskStatusUpdate _ => null,
        final TaskProgressUpdate p => p.hasNetworkSpeed ? p.networkSpeed : null,
      },
      timeRemaining: switch (task) {
        TaskStatusUpdate _ => null,
        final TaskProgressUpdate p =>
          p.hasTimeRemaining ? p.timeRemaining : null,
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _ModalOptions(task: task),
        );
      },
      onTap: onTap,
      onCancel: task.canCancel ? onCancel : null,
      builder: (_) => RawDownloadTile(
        fileName: task.task.filename,
        strikeThrough: task.isCanceled,
        color: task.isCanceled ? Theme.of(context).colorScheme.hintColor : null,
        trailing: switch (task) {
          final TaskStatusUpdate s => switch (s.status) {
            TaskStatus.failed =>
              ref
                  .watch(_checkResumableProvider(task.task))
                  .when(
                    data: (value) => value
                        ? IconButton(
                            onPressed: () => onResumeFailed.call(),
                            icon: const Icon(
                              Symbols.refresh,
                              fill: 1,
                            ),
                          )
                        : IconButton(
                            onPressed: () => onRestart.call(),
                            icon: const Icon(
                              Symbols.refresh,
                              fill: 1,
                            ),
                          ),
                    loading: () => const Center(
                      child: SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
            TaskStatus.paused => IconButton(
              onPressed: () => onResume.call(),
              icon: const Icon(
                Symbols.play_arrow,
                fill: 1,
              ),
            ),
            TaskStatus.running => IconButton(
              onPressed: () => onPause(),
              icon: const Icon(
                Symbols.pause,
                fill: 1,
              ),
            ),
            TaskStatus.complete => const Icon(
              Symbols.download_done,
              color: Colors.green,
            ),
            TaskStatus.enqueued => const SizedBox.shrink(),
            TaskStatus.notFound => const SizedBox.shrink(),
            TaskStatus.canceled => const SizedBox.shrink(),
            TaskStatus.waitingToRetry => const Center(
              child: CircularProgressIndicator(),
            ),
          },
          TaskProgressUpdate _ => IconButton(
            onPressed: () => onPause(),
            icon: const Icon(
              Symbols.pause,
              fill: 1,
            ),
          ),
        },
        subtitle: switch (task) {
          final TaskStatusUpdate s => _TaskSubtitle(task: s),
          final TaskProgressUpdate p =>
            p.progress >= 0
                ? LinearPercentIndicator(
                    lineHeight: 2,
                    percent: p.progress,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    animation: true,
                    animateFromLastPercent: true,
                    trailing: Text(
                      '${(p.progress * 100).floor()}%',
                    ),
                  )
                : const SizedBox.shrink(),
        },
        url: task.task.url,
      ),
    );
  }
}

final _filePathProvider = FutureProvider.autoDispose.family<String, Task>(
  (ref, task) => task.filePath(),
);

class _TaskSubtitle extends ConsumerWidget {
  const _TaskSubtitle({
    required this.task,
  });

  final TaskStatusUpdate task;

  String _prettifyFilePathIfNeeded(String path) {
    if (isAndroid()) {
      if (path.startsWith('/storage/emulated/0/')) {
        return path.replaceAll('/storage/emulated/0/', '/');
      }
    }

    return path;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = task.status;
    final exception = task.exception;
    final theme = Theme.of(context);

    return ReadMoreText(
      exception == null
          ? switch (status) {
              TaskStatus.complete =>
                ref
                    .watch(_filePathProvider(task.task))
                    .maybeWhen(
                      data: (data) => _prettifyFilePathIfNeeded(data),
                      orElse: () => '...',
                    ),
              _ => status.name.sentenceCase,
            }
          : '${exception.getErrorDescription()} ',
      trimLines: 1,
      trimMode: TrimMode.Line,
      trimCollapsedText: context.t.misc.trailing_more,
      trimExpandedText: context.t.misc.trailing_less,
      lessStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      moreStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      style: TextStyle(
        color: theme.colorScheme.hintColor,
        fontSize: 12,
      ),
    );
  }
}

class _ModalOptions extends ConsumerWidget {
  const _ModalOptions({
    required this.task,
  });

  final TaskUpdate task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = Navigator.of(context);
    final path = ref.watch(_filePathProvider(task.task)).valueOrNull;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const DragLine(),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: Text(context.t.post.action.view_in_browser),
              onTap: () {
                launchExternalUrlString(task.task.url);
                navigator.pop();
              },
            ),
            if (path != null)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(context.t.post.detail.share.image),
                onTap: () {
                  navigator.pop();

                  SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(path)],
                      subject: task.task.filename,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

extension TaskCancelX on TaskUpdate {
  bool get isCanceled => switch (this) {
    final TaskStatusUpdate u => u.status == TaskStatus.canceled,
    TaskProgressUpdate _ => false,
  };

  bool get canCancel => switch (this) {
    final TaskStatusUpdate u => switch (u.status) {
      TaskStatus.failed => false,
      TaskStatus.paused => false,
      TaskStatus.running => true,
      TaskStatus.enqueued => true,
      TaskStatus.complete => false,
      TaskStatus.notFound => false,
      TaskStatus.canceled => false,
      TaskStatus.waitingToRetry => true,
    },
    TaskProgressUpdate _ => true,
  };
}

extension TaskExceptionX on TaskException {
  String? getErrorDescription() {
    final map = toJson();
    final responseCode = map['httpResponseCode'] as int?;

    return switch (responseCode) {
      416 =>
        'HTTP 416 Requested range not satisfiable, this is likely because you have an invalid download location or filename rule. Please change the download location or filename rule and try again.',
      _ => 'Failed: $description',
    };
  }
}
