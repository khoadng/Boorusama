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
import '../../../downloads/manager.dart';
import '../../../foundation/clipboard.dart';
import '../../../foundation/toast.dart';
import '../../../images/booru_image.dart';
import '../../../router.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../pages/auth_config_changed_dialog.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/providers.dart';
import '../types/bulk_download_error_interpreter.dart';
import '../types/bulk_download_session.dart';
import '../types/download_configs.dart';
import '../types/download_session.dart';
import '../types/download_session_stats.dart';
import '../types/l10n.dart';

class BulkDownloadTaskTile extends ConsumerWidget {
  const BulkDownloadTaskTile({
    required this.session,
    super.key,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: colorScheme.error,
        child: Icon(
          Icons.delete,
          color: colorScheme.onError,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return notifier.deleteSession(session.id);
        }

        return false;
      },
      child: ConstrainedBox(
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
                            if (session.stats.coverUrl != null) _Logo(session),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: _InfoText(session),
                                  ),
                                  if (session.session.status ==
                                      DownloadSessionStatus.suspended)
                                    CompactChip(
                                      label: 'Saved',
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSecondaryContainer,
                                        fontSize: 13,
                                      ),
                                      backgroundColor:
                                          colorScheme.secondaryContainer,
                                    )
                                  else if (session.canViewInvidualProgresses)
                                    const _MoreIndicator(),
                                ],
                              ),
                            ),
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
                                  _ActionButtonBar(session: session),
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

class _MoreIndicator extends StatelessWidget {
  const _MoreIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 18,
      child: Row(
        children: [
          SizedBox(
            height: double.infinity,
            child: Text(
              'tag.related.more',
              style: TextStyle(
                color: colorScheme.hintColor,
                fontSize: 11,
              ),
            ).tr(),
          ),
          SizedBox(
            height: double.infinity,
            child: Icon(
              Symbols.chevron_forward,
              color: colorScheme.hintColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonBar extends StatelessWidget {
  const _ActionButtonBar({
    required this.session,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.session.status;

    if (!session.actionable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
      ),
      child: Wrap(
        spacing: 12,
        children: [
          if (status == DownloadSessionStatus.pending)
            _StartPendingButton(session)
          else if (status == DownloadSessionStatus.dryRun)
            _StopDryRunButton(session),
          if (status == DownloadSessionStatus.running ||
              status == DownloadSessionStatus.paused)
            _CancelAllButton(session),
          if (status == DownloadSessionStatus.running)
            _PauseAllButton(session)
          else if (status == DownloadSessionStatus.paused)
            _ResumeAllButton(session),
          if (status == DownloadSessionStatus.running)
            _SuspendButton(session)
          else if (status == DownloadSessionStatus.suspended)
            _ResumeSuspensionButton(session),
        ],
      ),
    );
  }
}

class _StopDryRunButton extends ConsumerWidget {
  const _StopDryRunButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.forward,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).stopDryRun(sessionId);
      },
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
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.play,
      ),
      onPressed: () {
        notifier.startPendingSession(sessionId);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircularIconButton(
      padding: const EdgeInsets.all(8),
      backgroundColor: colorScheme.surfaceContainer,
      icon: Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: colorScheme.onSurfaceVariant,
            fill: 1,
            size: 18,
          ),
        ),
        child: icon,
      ),
      onPressed: onPressed,
    );
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
            DownloadTranslations.delete.tr(),
            onPressed: () {
              ref.read(bulkDownloadProvider.notifier).deleteSession(session.id);
            },
          ),
          ContextMenuButtonConfig(
            DownloadTranslations.copyPath.tr(),
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

    return InkWell(
      onTap: session.canViewInvidualProgresses
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
    final status = session.session.status;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 72,
      child: coverUrl != null && coverUrl.isNotEmpty
          ? _Thumbnail(url: coverUrl)
          : SizedBox(
              height: 72,
              child: Card(
                color: colorScheme.tertiaryContainer,
                child: Icon(
                  status == DownloadSessionStatus.allSkipped
                      ? Symbols.check
                      : Symbols.image,
                  color: colorScheme.onSurfaceVariant,
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
        ? Padding(
            padding: const EdgeInsets.only(right: 4),
            child: BooruLogo(
              source: session.session.siteUrl,
              width: 18,
              height: 18,
            ),
          )
        : const SizedBox.shrink();
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
    final task = session.task;

    final fileSize = stats.estimatedDownloadSize;
    final totalItems = stats.totalItems;
    final status = session.session.status;
    final pageProgress = session.pageProgress;

    final fileSizeText = fileSize != null && fileSize > 0
        ? Filesize.parse(fileSize, round: 1)
        : null;

    final totalItemText = DownloadTranslations.titleInfoCounter(
      !(totalItems == 1),
    ).replaceAll('{}', totalItems.toString());

    final infoText = [
      if (task.quality == 'original' && fileSizeText != null) fileSizeText,
      totalItemText,
    ].nonNulls.join(' • ');

    return Text(
      switch (status) {
        DownloadSessionStatus.pending =>
          DownloadTranslations.createdStatus.tr(),
        DownloadSessionStatus.dryRun => DownloadTranslations.inProgressStatus(
            pageProgress.completed,
          ).tr(),
        DownloadSessionStatus.failed => 'Error',
        DownloadSessionStatus.allSkipped =>
          DownloadTranslations.allSkippedStatus.tr(),
        _ => infoText,
      },
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: Theme.of(context).colorScheme.hintColor,
        fontSize: 12,
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
            status == DownloadSessionStatus.paused
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
      _ => Builder(
          builder: (context) {
            final progressMap = ref.watch(
              bulkDownloadProgressProvider,
            );

            final progress = progressMap[sessionId];

            return progress != null
                ? _buildPercent(
                    progress,
                  )
                : _buildLinear();
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
        bottom: 8,
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

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.stop,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).cancelSession(sessionId);
      },
    );
  }
}

class _PauseAllButton extends ConsumerWidget {
  const _PauseAllButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.pause,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).pauseSession(sessionId);
      },
    );
  }
}

class _SuspendButton extends ConsumerWidget {
  const _SuspendButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.solidFloppyDisk,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).suspendSession(sessionId);
      },
    );
  }
}

class _ResumeSuspensionButton extends ConsumerWidget {
  const _ResumeSuspensionButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.play,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).resumeSuspendedSession(
          sessionId,
          downloadConfigs: DownloadConfigs(
            authChangedConfirmation: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AuthConfigChangedDialog(session: session),
              );

              return confirmed ?? false;
            },
          ),
        );
      },
    );
  }
}

class _ResumeAllButton extends ConsumerWidget {
  const _ResumeAllButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.play,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).resumeSession(
          sessionId,
          downloadConfigs: DownloadConfigs(
            authChangedConfirmation: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AuthConfigChangedDialog(session: session),
              );

              return confirmed ?? false;
            },
          ),
        );
      },
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
    final tags = session.task.prettyTags;
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
