// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final _currentSessionProvider =
    Provider.autoDispose.family<BulkDownloadSession, String>(
  (ref, id) {
    final sessions = ref.watch(bulkDownloadSessionsProvider);

    return sessions.firstWhere((element) => element.session.id == id);
  },
  dependencies: [
    _currentSessionIdProvider,
  ],
);

final _currentSessionIdProvider = Provider.autoDispose<String>((ref) {
  throw UnimplementedError();
});

class BulkDownloadTaskTile extends ConsumerWidget {
  const BulkDownloadTaskTile({
    required this.sessionId,
    super.key,
  });

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        _currentSessionIdProvider.overrideWithValue(sessionId),
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
    final id = ref.watch(_currentSessionIdProvider);
    final path =
        ref.watch(_currentSessionProvider(id).select((e) => e.task.path));

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            DownloadTranslations.bulkDownloadDelete.tr(),
            onPressed: () {
              ref.read(bulkDownloadProvider.notifier).deleteSession(id);
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
    final id = ref.watch(_currentSessionIdProvider);
    final status =
        ref.watch(_currentSessionProvider(id).select((e) => e.session.status));

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
  const _CoverImage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentSessionIdProvider);
    final stats = ref.watch(_currentSessionProvider(id).select((e) => e.stats));

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
  const _Logo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentSessionIdProvider);
    final stats = ref.watch(_currentSessionProvider(id).select((e) => e.stats));

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
  const _ActionButtons();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_currentSessionIdProvider);
    final session = ref.watch(_currentSessionProvider(sessionId));
    final status = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.session.status),
    );

    return switch (status) {
      DownloadSessionStatus.pending => _ActionButton(
          title: DownloadTranslations.bulkDownloadStart.tr(),
          onPressed: () {
            ref
                .read(bulkDownloadProvider.notifier)
                .downloadFromTask(session.task);
          },
        ),
      DownloadSessionStatus.running => const _CancelAllButton(),
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
  const _InfoText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_currentSessionIdProvider);
    final stats =
        ref.watch(_currentSessionProvider(sessionId).select((e) => e.stats));

    final fileSize = stats.estimatedDownloadSize;
    final totalItems = stats.totalItems;
    final status = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.session.status),
    );
    final pageProgress = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.pageProgress),
    );

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
        switch (status) {
          DownloadSessionStatus.pending =>
            DownloadTranslations.bulkDownloadCreatedStatus.tr(),
          DownloadSessionStatus.dryRun =>
            DownloadTranslations.bulkDownloadInProgressStatus(
              pageProgress.completed,
            ).tr(),
          DownloadSessionStatus.failed => 'Error',
          DownloadSessionStatus.interrupted => 'Interrupted',
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
  const _Subtitle();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_currentSessionIdProvider);
    final status = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.session.status),
    );
    final path = ref
        .watch(_currentSessionProvider(sessionId).select((e) => e.task.path));

    return status == DownloadSessionStatus.running ||
            status == DownloadSessionStatus.dryRun ||
            status == DownloadSessionStatus.interrupted
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressBar(),
              _FailedCount(),
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
              const _ErrorText(),
            ],
          );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_currentSessionIdProvider);
    final status = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.session.status),
    );

    return switch (status) {
      DownloadSessionStatus.dryRun => _buildLinear(),
      DownloadSessionStatus.interrupted =>
        ref.watch(percentCompletedFromDbProvider(sessionId)).maybeWhen(
              data: (progress) => _buildPercent(progress),
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

  Widget _buildPercent(double progress) {
    return LinearPercentIndicator(
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
  const _CancelAllButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_currentSessionIdProvider);
    final status = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.session.status),
    );
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
  const _FailedCount();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(_currentSessionIdProvider);
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
  const _ErrorText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_currentSessionIdProvider);
    final error = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.session.error),
    );

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
  const _Title();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_currentSessionIdProvider);
    final tags = ref
        .watch(_currentSessionProvider(sessionId).select((e) => e.task.tags));
    final status = ref.watch(
      _currentSessionProvider(sessionId).select((e) => e.session.status),
    );
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
