// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../../foundation/clipboard.dart';
import '../../../foundation/toast.dart';
import '../../../images/booru_image.dart';
import '../../../router.dart';
import '../../../theme.dart';
import '../../../utils/flutter_utils.dart';
import '../../../widgets/widgets.dart';
import '../../l10n.dart';
import '../../manager.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/providers.dart';
import '../types/bulk_download_error_interpreter.dart';
import '../types/bulk_download_session.dart';
import '../types/download_session.dart';
import '../types/download_session_stats.dart';

class BulkDownloadTaskTile extends ConsumerWidget {
  const BulkDownloadTaskTile({
    required this.session,
    super.key,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      child: _ContextMenu(
        session: session,
        child: _DetailsInkWell(
          session: session,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverImage(session),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Logo(session),
                          Expanded(
                            child: _InfoText(session),
                          ),
                          _ActionButtons(session),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Title(session),
                                _Subtitle(session),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StartPendingButton(session),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartPendingButton extends ConsumerWidget {
  const _StartPendingButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;
    final status = session.session.status;
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    return status == DownloadSessionStatus.pending
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircularIconButton(
                padding: const EdgeInsets.all(8),
                backgroundColor: colorScheme.surfaceContainer,
                icon: Icon(
                  FontAwesomeIcons.play,
                  fill: 1,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  notifier.startPendingSession(sessionId);
                },
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _ContextMenu extends ConsumerWidget {
  const _ContextMenu({
    required this.session,
    required this.child,
  });

  final BulkDownloadSession session;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = session.task.path;

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            DownloadTranslations.bulkDownloadDelete.tr(),
            onPressed: () {
              ref.read(bulkDownloadProvider.notifier).deleteSession(session.id);
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
    required this.session,
    required this.child,
  });

  final BulkDownloadSession session;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = session.id;
    final status = session.session.status;

    return InkWell(
      onTap: status == DownloadSessionStatus.running
          ? () {
              final updates = ref.read(downloadTaskUpdatesProvider).all(id);

              if (updates.isNotEmpty) {
                context.push(
                  '/download_manager?group=$id',
                );
              } else {
                showSimpleSnackBar(
                  context: context,
                  duration: const Duration(seconds: 3),
                  content: const Text(
                    'Nothing to show, download updates are empty',
                  ),
                );
              }
            }
          : () {},
      child: child,
    );
  }
}

class _CoverImage extends ConsumerWidget {
  const _CoverImage(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl = session.stats.coverUrl;

    return SizedBox(
      width: 72,
      child: coverUrl != null && coverUrl.isNotEmpty
          ? _Thumbnail(url: coverUrl)
          : SizedBox(
              height: 72,
              child: Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: const Icon(
                  Symbols.image,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}

class _Logo extends ConsumerWidget {
  const _Logo(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = session.stats;

    return stats != DownloadSessionStats.empty
        ? BooruLogo.fromConfig(
            ref.watchConfigAuth,
            width: 18,
            height: 18,
          )
        : const SizedBox.shrink();
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;
    final status = session.session.status;

    return switch (status) {
      // DownloadSessionStatus.pending => _ActionButton(
      //     title: DownloadTranslations.bulkDownloadStart.tr(),
      //     onPressed: () {
      //       ref
      //           .read(bulkDownloadProvider.notifier)
      //           .downloadFromTask(session.task);
      //     },
      //   ),
      DownloadSessionStatus.running => _CancelAllButton(session),
      DownloadSessionStatus.dryRun => _ActionButton(
          onPressed: () {
            ref.read(bulkDownloadProvider.notifier).stopDryRun(sessionId);
          },
          title: DownloadTranslations.bulkDownloadStop.tr(),
        ),
      // DownloadSessionStatus.interrupted => _ActionButton(
      //     onPressed: () {
      //       ref.read(bulkDownloadProvider.notifier).resumeSession(sessionId);
      //     },
      //     title: DownloadTranslations.bulkDownloadResume.tr(),
      //   ),
      _ => const SizedBox(
          height: 24,
        ),
    };
  }
}

class _InfoText extends ConsumerWidget {
  const _InfoText(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = session.stats;

    final fileSize = stats.estimatedDownloadSize;
    final totalItems = stats.totalItems;
    final status = session.session.status;
    final pageProgress = session.pageProgress;

    final fileSizeText = fileSize != null && fileSize > 0
        ? Filesize.parse(fileSize, round: 1)
        : null;

    final totalItemText = DownloadTranslations.bulkDownloadTitleInfoCounter(
      !(totalItems == 1),
    ).replaceAll('{}', totalItems.toString());

    final infoText = [
      fileSizeText,
      totalItemText,
    ].nonNulls.join(' • ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        switch (status) {
          DownloadSessionStatus.pending =>
            DownloadTranslations.bulkDownloadCreatedStatus.tr(),
          DownloadSessionStatus.dryRun =>
            DownloadTranslations.bulkDownloadInProgressStatus(
              pageProgress.completed,
            ).tr(),
          DownloadSessionStatus.failed => 'Error',
          DownloadSessionStatus.interrupted => 'Interrupted',
          DownloadSessionStatus.allSkipped => 'Skipped, no new items',
          _ => infoText,
        },
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: TextStyle(
          color: Theme.of(context).colorScheme.hintColor,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Subtitle extends ConsumerWidget {
  const _Subtitle(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = session.session.status;
    final path = session.task.path;

    return status == DownloadSessionStatus.running ||
            status == DownloadSessionStatus.dryRun ||
            status == DownloadSessionStatus.interrupted
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressBar(session),
              _FailedCount(session),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReadMoreText(
                path,
                trimLines: 1,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' more',
                trimExpandedText: ' less',
                lessStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                moreStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.hintColor,
                  fontSize: 12,
                ),
              ),
              _ErrorText(session),
            ],
          );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;
    final status = session.session.status;

    return switch (status) {
      DownloadSessionStatus.dryRun => _buildLinear(),
      DownloadSessionStatus.interrupted =>
        ref.watch(percentCompletedFromDbProvider(sessionId)).maybeWhen(
              data: (progress) => _buildPercent(
                progress,
                animateFromLastPercent: false,
              ),
              orElse: () => _buildLinear(),
            ),
      _ => Builder(
          builder: (context) {
            final progress = ref.watch(
              percentCompletedProvider(sessionId),
            );

            return _buildPercent(progress);
          },
        ),
    };
  }

  Widget _buildPercent(
    double progress, {
    bool animateFromLastPercent = true,
  }) {
    return LinearPercentIndicator(
      lineHeight: 2,
      percent: progress,
      progressColor: Colors.red,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      animation: animateFromLastPercent,
      animateFromLastPercent: animateFromLastPercent,
      trailing: Text(
        '${(progress * 100).floor()}%',
      ),
    );
  }

  Widget _buildLinear() {
    return const Padding(
      padding: EdgeInsets.only(
        top: 10,
        right: 40,
        left: 4,
      ),
      child: LinearProgressIndicator(
        color: Colors.red,
        minHeight: 2,
      ),
    );
  }
}

class _CancelAllButton extends ConsumerWidget {
  const _CancelAllButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;
    final status = session.session.status;
    final isCompleted = status == DownloadSessionStatus.completed;

    return !isCompleted
        ? _ActionButton(
            onPressed: () {
              ref.read(bulkDownloadProvider.notifier).cancelSession(sessionId);
            },
            title: DownloadTranslations.bulkDownloadCancel.tr(),
          )
        : const SizedBox(
            height: 24,
          );
  }
}

class _FailedCount extends ConsumerWidget {
  const _FailedCount(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = session.id;
    final failedCount = ref.watch(downloadGroupFailedProvider(id));

    return failedCount > 0
        ? Text(
            '$failedCount failed',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 11,
            ),
          )
        : const SizedBox.shrink();
  }
}

class _ErrorText extends ConsumerWidget {
  const _ErrorText(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = session.session.error;

    return error != null
        ? Text(
            BulkDownloadErrorInterpreter.fromString(error).toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
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
  const _Title(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = session.task.tags;
    final status = session.session.status;
    final strikeThrough = status == DownloadSessionStatus.cancelled;

    return Text(
      tags ?? 'No tags',
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: status == DownloadSessionStatus.cancelled
            ? Theme.of(context).colorScheme.hintColor
            : null,
        fontWeight: FontWeight.w500,
        decoration: strikeThrough ? TextDecoration.lineThrough : null,
      ),
    );
  }
}
