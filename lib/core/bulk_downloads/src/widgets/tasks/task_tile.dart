// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/toast.dart';
import '../../../../config_widgets/website_logo.dart';
import '../../../../configs/config/providers.dart';
import '../../../../download_manager/providers.dart';
import '../../../../download_manager/types.dart';
import '../../../../images/booru_image.dart';
import '../../../../premiums/providers.dart';
import '../../../../router.dart';
import '../../../../themes/theme/types.dart';
import '../../../../widgets/booru_context_menu.dart';
import '../../../../widgets/context_menu_tile.dart';
import '../../../../widgets/widgets.dart';
import '../../providers/bulk_download_notifier.dart';
import '../../providers/dry_run.dart';
import '../../providers/dry_run_state.dart';
import '../../providers/providers.dart';
import '../../types/bulk_download_error_interpreter.dart';
import '../../types/bulk_download_session.dart';
import '../../types/download_session.dart';
import '../../types/download_session_stats.dart';
import 'buttons.dart';
import 'task_progress_bar.dart';

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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: _InfoText(session),
                                  ),
                                  if (ref.watch(showPremiumFeatsProvider))
                                    if (session.session.status ==
                                        DownloadSessionStatus.suspended)
                                      const _SuspendTaskChip()
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
                                  BulkDownloadActionButtonBar(session: session),
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

class _SuspendTaskChip extends StatelessWidget {
  const _SuspendTaskChip();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CompactChip(
      label: context.t.bulk_downloads.status.suspended,
      textStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSecondaryContainer,
        fontSize: 13,
      ),
      backgroundColor: colorScheme.secondaryContainer,
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
              context.t.tag.related.more,
              style: TextStyle(
                color: colorScheme.hintColor,
                fontSize: 11,
              ),
            ),
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

    return BooruContextMenu(
      menuItemsBuilder: (context) => [
        ContextMenuTile(
          title: context.t.bulk_downloads.actions.delete,
          onTap: () {
            ref.read(bulkDownloadProvider.notifier).deleteSession(session.id);
          },
        ),
        ContextMenuTile(
          title: context.t.bulk_downloads.actions.copy_path,
          onTap: () => AppClipboard.copyWithDefaultToast(context, path),
        ),
      ],
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
                ref.router.push(
                  '/download_manager?group=$id',
                );
              } else {
                showSimpleSnackBar(
                  context: context,
                  duration: const Duration(seconds: 3),
                  content: Text(
                    context.t.download.nothing_to_show,
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
            child: ConfigAwareWebsiteLogo(
              url: session.session.auth.siteUrl,
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

    final fileSizeText = fileSize != null && fileSize > 0
        ? Filesize.parse(fileSize, round: 1)
        : null;

    final totalItemText = context.t.bulk_downloads.file_counter(n: totalItems);

    final infoText = [
      if (task.quality == 'original' && fileSizeText != null) fileSizeText,
      totalItemText,
    ].nonNulls.join(' • ');

    return Text(
      switch (status) {
        DownloadSessionStatus.pending => context.t.bulk_downloads.created,
        DownloadSessionStatus.dryRun =>
          ref
              .watch(dryRunNotifierProvider(session.id))
              .maybeWhen(
                data: (data) => switch (data) {
                  DryRunState(
                    status: DryRunStatusRunning(
                      isPreparing: true,
                    ),
                    :final currentPage,
                  ) =>
                    currentPage != null
                        ? context.t.bulk_downloads.scanning_page
                              .preparing_with_page(
                                page: currentPage,
                              )
                        : context.t.bulk_downloads.scanning_page.preparing,
                  DryRunState(
                    status: DryRunStatusRunning(),
                    :final currentPage?,
                    :final currentItemIndex?,
                  ) =>
                    context.t.bulk_downloads.scanning_page.with_page_and_index(
                      page: currentPage,
                      index: currentItemIndex + 1,
                    ),
                  DryRunState(
                    status: DryRunStatusRunning(),
                    :final currentPage?,
                    currentItemIndex: _,
                  ) =>
                    context.t.bulk_downloads.scanning_page.with_page(
                      page: currentPage,
                    ),
                  final _ => context.t.bulk_downloads.scanning_page.null_page,
                },
                orElse: () => context.t.bulk_downloads.scanning_page.null_page,
              ),
        DownloadSessionStatus.failed => context.t.generic.errors.error,
        DownloadSessionStatus.allSkipped =>
          context.t.bulk_downloads.completed_with_no_new_files,
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
              BulkDownloadTaskProgressBar(session: session),
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
                trimCollapsedText: context.t.misc.trailing_more,
                trimExpandedText: context.t.misc.trailing_less,
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
      child: Consumer(
        builder: (_, ref, _) => BooruImage(
          config: ref.watchConfigAuth,
          imageUrl: url ?? '',
          fit: BoxFit.cover,
        ),
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
