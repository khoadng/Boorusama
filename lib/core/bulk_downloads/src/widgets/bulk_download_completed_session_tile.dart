// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/toast.dart';
import '../../../config_widgets/website_logo.dart';
import '../../../configs/ref.dart';
import '../../../images/booru_image.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../pages/bulk_download_saved_task_page.dart';
import '../providers/bulk_download_notifier.dart';
import '../providers/saved_download_task_provider.dart';
import '../routes/internal_routes.dart';
import '../types/bulk_download_session.dart';
import '../types/download_session_stats.dart';
import '../types/download_task.dart';
import '../types/l10n.dart';

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
          final success = await notifier.deleteSession(session.id);

          if (success) {
            onDelete();
          }
          return success;
        }

        return false;
      },
      child: ConstrainedBox(
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
                            _CreateSavedTaskButton(
                              task: session.task,
                            ),
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
      ),
    );
  }
}

class _CreateSavedTaskButton extends ConsumerWidget {
  const _CreateSavedTaskButton({
    required this.task,
  });

  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(savedDownloadTasksProvider.notifier);

    return CircularIconButton(
      backgroundColor: colorScheme.surfaceContainer,
      icon: Icon(
        FontAwesomeIcons.clone,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onPressed: () async {
        final success = await notifier.create(task);

        if (success) {
          if (context.mounted) {
            showSimpleSnackBar(
              context: context,
              content: Text(DownloadTranslations.templateCreated),
              action: SnackBarAction(
                label: context.t.generic.action.view,
                textColor: colorScheme.surface,
                onPressed: () {
                  goToBulkDownloadSavedTasksPage(ref);
                },
              ),
            );
          }
        }
      },
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
        ? ConfigAwareWebsiteLogo.fromConfig(
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
            DownloadTranslations.delete(context),
            onPressed: () async {
              await ref
                  .read(bulkDownloadProvider.notifier)
                  .deleteSession(session.session.id);
              onDelete();
            },
          ),
          ContextMenuButtonConfig(
            DownloadTranslations.copyPath,
            onPressed: () => AppClipboard.copyWithDefaultToast(context, path),
          ),
          ContextMenuButtonConfig(
            DownloadTranslations.createTemplate,
            onPressed: () async {
              final navigator = Navigator.of(context);
              final success = await ref
                  .read(savedDownloadTasksProvider.notifier)
                  .create(session.task);

              if (success) {
                await navigator.push(
                  CupertinoPageRoute(
                    builder: (context) => const BulkDownloadSavedTaskPage(),
                  ),
                );
              } else {
                // Do nothing
              }
            },
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

    final totalItemText = DownloadTranslations.titleInfoCounter(
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
    final tags = session.task.prettyTags;

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
