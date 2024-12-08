// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/images/booru_image.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/filesize.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import '../l10n.dart';
import 'bulk_download_notifier.dart';
import 'bulk_download_task.dart';
import 'providers.dart';

final _currentDownloadTaskProvider =
    Provider.autoDispose.family<BulkDownloadTask, String>(
  (ref, id) {
    final tasks = ref.watch(bulkdownloadProvider);

    return tasks.firstWhere((element) => element.id == id);
  },
  dependencies: [
    _currentDownloadTaskIdProvider,
  ],
);

final _currentDownloadTaskIdProvider = Provider.autoDispose<String>((ref) {
  throw UnimplementedError();
});

class BulkDownloadTaskTile extends ConsumerWidget {
  const BulkDownloadTaskTile({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        _currentDownloadTaskIdProvider.overrideWithValue(taskId),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 60,
        ),
        child: const _ContextMenu(
          child: _DetailsInkWell(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CoverImage(),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Logo(),
                            Expanded(
                              child: _InfoText(),
                            ),
                            _ActionButtons(),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Title(),
                                  _Subtitle(),
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
        ),
      ),
    );
  }
}

class _ContextMenu extends ConsumerWidget {
  const _ContextMenu({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final path =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.path));

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            DownloadTranslations.bulkDownloadDelete.tr(),
            onPressed: () {
              ref.read(bulkdownloadProvider.notifier).removeTask(id);
            },
          ),
          ContextMenuButtonConfig(
            DownloadTranslations.bulkDownloadCopyPath.tr(),
            onPressed: () => AppClipboard.copyWithDefaultToast(context, path),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailsInkWell extends ConsumerWidget {
  const _DetailsInkWell({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final status =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.status));

    return InkWell(
      onTap: status != BulkDownloadTaskStatus.created
          ? () {
              context.push(
                '/download_manager?group=$id',
              );
            }
          : null,
      child: child,
    );
  }
}

class _CoverImage extends ConsumerWidget {
  const _CoverImage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final coverUrl =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.coverUrl));

    return SizedBox(
      width: 72,
      child: coverUrl.toOption().fold(
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
    );
  }
}

class _Logo extends ConsumerWidget {
  const _Logo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final siteUrl =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.siteUrl));

    return siteUrl != null
        ? BooruLogo.fromConfig(
            ref.watchConfigAuth,
            width: 18,
            height: 18,
          )
        : const SizedBox.shrink();
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final status =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.status));

    return switch (status) {
      BulkDownloadTaskStatus.created => _ActionButton(
          title: DownloadTranslations.bulkDownloadStart.tr(),
          onPressed: () {
            ref.read(bulkdownloadProvider.notifier).startTask(id);
          },
        ),
      BulkDownloadTaskStatus.inProgress => const _CancelAllButton(),
      BulkDownloadTaskStatus.queue => _ActionButton(
          onPressed: () {
            ref.read(bulkdownloadProvider.notifier).stopQueuing(id);
          },
          title: DownloadTranslations.bulkDownloadStop.tr(),
        ),
      _ => const SizedBox(
          height: 24,
        ),
    };
  }
}

class _InfoText extends ConsumerWidget {
  const _InfoText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final fileSize = ref.watch(_currentDownloadTaskProvider(id)
        .select((e) => e.estimatedDownloadSize));
    final mixedMedia =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.mixedMedia));
    final totalItems =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.totalItems));
    final status =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.status));
    final pageProgress = ref
        .watch(_currentDownloadTaskProvider(id).select((e) => e.pageProgress));
    final error =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.error));

    final fileSizeText = fileSize != null && fileSize > 0
        ? Filesize.parse(fileSize, round: 1)
        : null;

    final totalItemText = totalItems != null
        ? DownloadTranslations.bulkDownloadTitleInfoCounter(
            !(totalItems == 1),
            mixedMedia == true,
          ).replaceAll('{}', totalItems.toString())
        : null;

    final infoText = [
      fileSizeText,
      totalItemText,
    ].nonNulls.join(' • ');

    final siteUrl =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.siteUrl));

    return Padding(
      padding: siteUrl != null
          ? const EdgeInsets.symmetric(horizontal: 8)
          : EdgeInsets.zero,
      child: Text(
        switch (status) {
          BulkDownloadTaskStatus.created =>
            DownloadTranslations.bulkDownloadCreatedStatus.tr(),
          BulkDownloadTaskStatus.queue =>
            DownloadTranslations.bulkDownloadInProgressStatus(
                    pageProgress?.completed)
                .tr(),
          BulkDownloadTaskStatus.error => error ?? 'Error',
          _ => infoText,
        },
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: TextStyle(
          color: context.colorScheme.hintColor,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Subtitle extends ConsumerWidget {
  const _Subtitle();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final status =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.status));
    final path =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.path));
    final isCompleted = ref.watch(downloadGroupCompletedProvider(id));

    return !isCompleted && status == BulkDownloadTaskStatus.inProgress ||
            status == BulkDownloadTaskStatus.queue
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProgressBar(),
              const _FailedCount(),
            ],
          )
        : ReadMoreText(
            path,
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
              color: Theme.of(context).colorScheme.hintColor,
              fontSize: 12,
            ),
          );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final status =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.status));
    final progress = ref.watch(
      percentCompletedProvider(id),
    );

    return status == BulkDownloadTaskStatus.queue
        ? Padding(
            padding: const EdgeInsets.only(
              top: 10,
              right: 40,
              left: 4,
            ),
            child: LinearProgressIndicator(
              color: Colors.red,
              minHeight: 2,
            ),
          )
        : LinearPercentIndicator(
            lineHeight: 2,
            percent: progress,
            progressColor: Colors.red,
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            animation: true,
            animateFromLastPercent: true,
            trailing: Text(
              '${(progress * 100).floor()}%',
            ),
          );
  }
}

class _CancelAllButton extends ConsumerWidget {
  const _CancelAllButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final isCompleted = ref.watch(downloadGroupCompletedProvider(id));

    return !isCompleted
        ? _ActionButton(
            onPressed: () {
              ref.read(bulkdownloadProvider.notifier).cancelAll(id);
            },
            title: DownloadTranslations.bulkDownloadCancel.tr(),
          )
        : const SizedBox(
            height: 24,
          );
  }
}

class _FailedCount extends ConsumerWidget {
  const _FailedCount();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final failedCount = ref.watch(downloadGroupFailedProvider(id));

    return failedCount > 0
        ? Text(
            '$failedCount failed',
            style: TextStyle(
              color: context.colorScheme.error,
              fontSize: 11,
            ),
          )
        : const SizedBox.shrink();
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.title,
    required this.onPressed,
  });

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

class _Title extends ConsumerWidget {
  const _Title();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentDownloadTaskIdProvider);
    final data = ref
        .watch(_currentDownloadTaskProvider(id).select((e) => e.displayName));
    final status =
        ref.watch(_currentDownloadTaskProvider(id).select((e) => e.status));
    final strikeThrough = status == BulkDownloadTaskStatus.canceled;

    return Text(
      data,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: status == BulkDownloadTaskStatus.canceled
            ? context.colorScheme.hintColor
            : null,
        fontWeight: FontWeight.w500,
        decoration: strikeThrough ? TextDecoration.lineThrough : null,
      ),
    );
  }
}
