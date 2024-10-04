// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/filesize.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import '../l10n.dart';
import 'bulk_download_notifier.dart';
import 'providers.dart';

class BulkDownloadTaskTile extends ConsumerWidget {
  const BulkDownloadTaskTile({
    super.key,
    required this.task,
  });

  final BulkDownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileSize = task.estimatedDownloadSize;
    final fileSizeText = fileSize != null && fileSize > 0
        ? Filesize.parse(fileSize, round: 1)
        : null;

    final totalItemText = task.totalItems != null
        ? DownloadTranslations.bulkDownloadTitleInfoCounter(
            !(task.totalItems == 1),
            task.mixedMedia == true,
          ).replaceAll('{}', task.totalItems.toString())
        : null;

    final infoText = [
      fileSizeText,
      totalItemText,
    ].whereNotNull().join(' • ');

    final siteUrl = task.siteUrl;

    final isCompleted = ref.watch(downloadGroupCompletedProvider(task.id));
    final failedCount = ref.watch(downloadGroupFailedProvider(task.id));

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            DownloadTranslations.bulkDownloadDelete.tr(),
            onPressed: () {
              ref.read(bulkdownloadProvider.notifier).removeTask(
                    task.id,
                  );
            },
          ),
          ContextMenuButtonConfig(
            DownloadTranslations.bulkDownloadCopyPath.tr(),
            onPressed: () {
              AppClipboard.copyWithDefaultToast(
                context,
                task.path,
              );
            },
          ),
        ],
      ),
      child: InkWell(
        onTap: task.status != BulkDownloadTaskStatus.queue &&
                task.status != BulkDownloadTaskStatus.created
            ? () {
                context.push(
                  '/download_manager?group=${task.id}',
                );
              }
            : null,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 60,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: task.coverUrl.toOption().fold(
                      () => SizedBox(
                        height: 72,
                        child: Card(
                          color: context.colorScheme.tertiaryContainer,
                          child: const Icon(
                            Symbols.image,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      (t) => _Thumbnail(url: t),
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (siteUrl != null)
                          BooruLogo.fromConfig(
                            ref.watchConfig,
                            width: 18,
                            height: 18,
                          ),
                        Expanded(
                          child: Padding(
                            padding: siteUrl != null
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : EdgeInsets.zero,
                            child: Text(
                              switch (task.status) {
                                BulkDownloadTaskStatus.created =>
                                  DownloadTranslations.bulkDownloadCreatedStatus
                                      .tr(),
                                BulkDownloadTaskStatus.queue =>
                                  DownloadTranslations
                                          .bulkDownloadInProgressStatus(
                                              task.pageProgress?.completed)
                                      .tr(),
                                BulkDownloadTaskStatus.error =>
                                  task.error ?? 'Error',
                                _ => infoText,
                              },
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                color: context.theme.hintColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        switch (task.status) {
                          BulkDownloadTaskStatus.created => _ActionButton(
                              task: task,
                              title:
                                  DownloadTranslations.bulkDownloadStart.tr(),
                              onPressed: () {
                                ref
                                    .read(bulkdownloadProvider.notifier)
                                    .startTask(
                                      task.id,
                                    );
                              },
                            ),
                          BulkDownloadTaskStatus.inProgress => !isCompleted
                              ? _ActionButton(
                                  task: task,
                                  onPressed: () {
                                    ref
                                        .read(bulkdownloadProvider.notifier)
                                        .cancelAll(
                                          task.id,
                                        );
                                  },
                                  title: DownloadTranslations.bulkDownloadCancel
                                      .tr(),
                                )
                              : const SizedBox(
                                  height: 24,
                                ),
                          BulkDownloadTaskStatus.queue => _ActionButton(
                              task: task,
                              onPressed: () {
                                ref
                                    .read(bulkdownloadProvider.notifier)
                                    .stopQueuing(
                                      task.id,
                                    );
                              },
                              title: DownloadTranslations.bulkDownloadStop.tr(),
                            ),
                          _ => const SizedBox(
                              height: 24,
                            ),
                        },
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Title(
                                data: task.displayName,
                                strikeThrough: task.status ==
                                    BulkDownloadTaskStatus.canceled,
                                color: task.status ==
                                        BulkDownloadTaskStatus.canceled
                                    ? context.theme.hintColor
                                    : null,
                              ),
                              !isCompleted &&
                                          task.status ==
                                              BulkDownloadTaskStatus
                                                  .inProgress ||
                                      task.status ==
                                          BulkDownloadTaskStatus.queue
                                  ? Builder(
                                      builder: (context) {
                                        final progress = ref.watch(
                                          percentCompletedProvider(task.id),
                                        );
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LinearPercentIndicator(
                                              lineHeight: 2,
                                              percent: progress,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              animation: true,
                                              animateFromLastPercent: true,
                                              trailing: Text(
                                                '${(progress * 100).floor()}%',
                                              ),
                                            ),
                                            if (failedCount > 0)
                                              Text(
                                                '$failedCount failed',
                                                style: TextStyle(
                                                  color:
                                                      context.colorScheme.error,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    )
                                  : ReadMoreText(
                                      task.path,
                                      trimLines: 1,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: ' more',
                                      trimExpandedText: ' less',
                                      lessStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: context.colorScheme.primary,
                                      ),
                                      moreStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: context.colorScheme.primary,
                                      ),
                                      style: TextStyle(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 12,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.task,
    required this.title,
    required this.onPressed,
  });

  final BulkDownloadTask task;
  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const ShrinkVisualDensity(),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.url,
  });

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: BooruImage(
        imageUrl: url ?? '',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.data,
    this.strikeThrough = false,
    this.color,
  });

  final String data;
  final bool strikeThrough;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
        decoration: strikeThrough ? TextDecoration.lineThrough : null,
      ),
    );
  }
}
