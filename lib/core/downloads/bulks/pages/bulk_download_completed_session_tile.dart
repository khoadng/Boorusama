// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../../foundation/clipboard.dart';
import '../../../images/booru_image.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../../l10n.dart';
import '../providers/bulk_download_notifier.dart';
import '../types/bulk_download_session.dart';
import '../types/download_session_stats.dart';

class BulkDownloadCompletedSessionTile extends ConsumerWidget {
  const BulkDownloadCompletedSessionTile({
    required this.session,
    required this.onDelete,
    super.key,
  });

  final BulkDownloadSession session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      child: _ContextMenu(
        session: session,
        onDelete: onDelete,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverImage(
                  session,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Logo(
                            stats: session.stats,
                          ),
                          Expanded(
                            child: _InfoText(
                              session: session,
                            ),
                          ),
                          const _ActionButtons(),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Title(
                                  session: session,
                                ),
                                _Subtitle(
                                  session: session,
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
      ),
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
    final stats = session.stats;

    return SizedBox(
      width: 72,
      child: stats != DownloadSessionStats.empty
          ? _Thumbnail(url: stats.coverUrl)
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
  const _Logo({
    required this.stats,
  });

  final DownloadSessionStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return stats != DownloadSessionStats.empty
        ? BooruLogo.fromConfig(
            ref.watchConfigAuth,
            width: 18,
            height: 18,
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

class _ContextMenu extends ConsumerWidget {
  const _ContextMenu({
    required this.session,
    required this.onDelete,
    required this.child,
  });

  final BulkDownloadSession session;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = session.task.path;

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            DownloadTranslations.bulkDownloadDelete.tr(),
            onPressed: () async {
              await ref
                  .read(bulkDownloadProvider.notifier)
                  .deleteSession(session.session.id);
              onDelete(); // This now triggers _refreshList() instead of a full refresh
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

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox(
      height: 24,
    );
  }
}

class _InfoText extends ConsumerWidget {
  const _InfoText({
    required this.session,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = session.stats;

    final fileSize = stats.estimatedDownloadSize;
    final totalItems = stats.totalItems;

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

    final siteUrl = stats.siteUrl;

    return Padding(
      padding: siteUrl != null
          ? const EdgeInsets.symmetric(horizontal: 8)
          : EdgeInsets.zero,
      child: Text(
        infoText,
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
  const _Subtitle({
    required this.session,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = session.task.path;

    return ReadMoreText(
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
    );
  }
}

class _Title extends ConsumerWidget {
  const _Title({
    required this.session,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = session.task.tags;

    return Text(
      tags ?? 'No tags',
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
