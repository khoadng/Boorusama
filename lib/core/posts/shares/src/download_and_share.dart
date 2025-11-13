// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../../foundation/path.dart';
import '../../../analytics/providers.dart';
import '../../../configs/config/types.dart';
import '../../../download_manager/providers.dart';
import '../../../download_manager/types.dart';
import '../../../downloads/configs/widgets.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../downloads/downloader/types.dart';
import '../../../downloads/filename/types.dart';
import '../../../downloads/urls/providers.dart';
import '../../../http/client/providers.dart';
import '../../../settings/providers.dart';
import '../../../widgets/booru_dialog.dart';
import '../../post/types.dart';

final _downloadTaskDetailsProvider = Provider.autoDispose
    .family<TaskUpdate?, String>((ref, downloadId) {
      final updates = ref.watch(downloadTaskUpdatesProvider);
      final allTasks = [
        ...updates.inProgress(FileDownloader.defaultGroup),
        ...updates.completed(FileDownloader.defaultGroup),
        ...updates.failed(FileDownloader.defaultGroup),
        ...updates.canceled(FileDownloader.defaultGroup),
      ];

      return allTasks.firstWhereOrNull(
        (update) => update.task.taskId == downloadId,
      );
    });

final _downloadProvider =
    FutureProvider.family<
      DownloadTaskInfo?,
      (BooruConfigAuth, BooruConfigDownload, DownloadFilenameGenerator?, Post)
    >((
      ref,
      params,
    ) {
      final (auth, download, filenameBuilder, post) = params;
      return ref
          .watch(
            downloadNotifierProvider((
              download: download,
              downloadFileUrlExtractor: ref.watch(
                downloadFileUrlExtractorProvider(auth),
              ),
              observer: ref.watch(
                analyticsDownloadObserverProvider(auth),
              ),
              filenameBuilder: filenameBuilder,
              canDownloadMultipleFiles: ref.watch(
                downloadMultipleFileCheckProvider(auth),
              ),
              headers: ref.watch(
                httpHeadersProvider(auth),
              ),
              settings: ref.watch(settingsProvider),
              downloader: ref.watch(downloadServiceProvider),
              logger: ref.watch(loggerProvider),
            )).notifier,
          )
          .download(post);
    });

class DownloadAndShareDialog extends ConsumerWidget {
  const DownloadAndShareDialog({
    required this.post,
    required this.auth,
    required this.download,
    required this.filenameBuilder,
    super.key,
  });

  final Post post;
  final BooruConfigAuth auth;
  final BooruConfigDownload download;
  final DownloadFilenameGenerator? filenameBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(_downloadProvider((auth, download, filenameBuilder, post)))
        .when(
          data: (info) {
            if (info == null) {
              return Center(
                child: Text(
                  'Failed to download post',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }
            return DownloadAndShareDialogInternal(
              info: info,
              thumbnailUrl: post.thumbnailImageUrl,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            return Center(
              child: Text(
                'Error downloading: $error',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          },
        );
  }
}

class DownloadAndShareDialogInternal extends ConsumerWidget {
  const DownloadAndShareDialogInternal({
    required this.info,
    this.thumbnailUrl,
    super.key,
  });

  final DownloadTaskInfo info;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(_downloadTaskDetailsProvider(info.id));
    final fileName = basename(info.path);

    final isCompleted =
        task != null &&
        task is TaskStatusUpdate &&
        task.status == TaskStatus.complete;

    // Auto-share on completion
    ref.listen(_downloadTaskDetailsProvider(info.id), (previous, next) {
      if (next is TaskStatusUpdate && next.status == TaskStatus.complete) {
        Navigator.of(context).pop();
        SharePlus.instance.share(
          ShareParams(
            files: [XFile(info.path)],
            subject: fileName,
          ),
        );
      }
    });

    return BooruDialog(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (task != null)
            DownloadTileBuilder(
              url: task.task.url,
              fileSize: task.fileSize,
              thumbnailUrl: thumbnailUrl,
              networkSpeed: task is TaskProgressUpdate && task.hasNetworkSpeed
                  ? task.networkSpeed
                  : null,
              timeRemaining: task is TaskProgressUpdate && task.hasTimeRemaining
                  ? task.timeRemaining
                  : null,
              onCancel: !isCompleted
                  ? () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            _CancelDownloadConfirmationDialog(info: info),
                      );
                    }
                  : null,
              builder: (url) => RawDownloadTile(
                fileName: fileName,
                trailing: isCompleted
                    ? const Icon(
                        Symbols.download_done,
                        color: Colors.green,
                      )
                    : const SizedBox(width: 48),
                subtitle: task is TaskProgressUpdate && task.progress >= 0
                    ? LinearPercentIndicator(
                        lineHeight: 2,
                        percent: task.progress,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        animation: true,
                        animateFromLastPercent: true,
                        trailing: Text('${(task.progress * 100).floor()}%'),
                      )
                    : const SizedBox.shrink(),
                url: url,
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(info.path)],
                      subject: fileName,
                    ),
                  );
                },
                child: Text(context.t.post.action.share),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'.hc),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CancelDownloadConfirmationDialog extends StatelessWidget {
  const _CancelDownloadConfirmationDialog({
    required this.info,
  });

  final DownloadTaskInfo info;

  @override
  Widget build(BuildContext context) {
    return BooruDialog(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cancel Download'.hc,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Are you sure you want to cancel this download?'.hc,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation
                FileDownloader().cancelTaskWithId(info.id);
                Navigator.of(context).pop(); // Close download dialog
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Cancel Download'.hc,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Keep Downloading'.hc,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
