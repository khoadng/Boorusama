// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class BulkDownloadTile extends ConsumerWidget {
  const BulkDownloadTile({
    super.key,
    required this.data,
  });

  final BulkDownloadStatus data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final thumbnails = ref.watch(bulkDownloadThumbnailsProvider);
    final fileSizes = ref.watch(bulkDownloadFileSizeProvider);

    return Card(
      color: context.colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: _Thumbnail(url: thumbnails[data.url]),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    children: [
                      switch (data) {
                        BulkDownloadDone d when d.alreadyExists => Chip(
                            visualDensity: const ShrinkVisualDensity(),
                            backgroundColor: context.theme.colorScheme.primary,
                            label: const Text(
                              'File exists',
                            ),
                          ),
                        _ => const SizedBox.shrink(),
                      },
                      Chip(
                        backgroundColor: context.colorScheme.tertiaryContainer,
                        visualDensity: const ShrinkVisualDensity(),
                        label: Text(sanitizedExtension(data.url)),
                      ),
                      const SizedBox(width: 4),
                      if (fileSizes[data.url] != null &&
                          fileSizes[data.url]! > 0)
                        Chip(
                          backgroundColor:
                              context.colorScheme.tertiaryContainer,
                          visualDensity: const ShrinkVisualDensity(),
                          label: Text(filesize(fileSizes[data.url], 1)),
                        ),
                    ],
                  ),
                ),
                switch (data) {
                  BulkDownloadInitializing _ => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(data: data),
                      trailing: const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  BulkDownloadQueued _ => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(data: data),
                      subtitle: const Text('Queued', maxLines: 1),
                    ),
                  BulkDownloadInProgress d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      trailing: IconButton(
                          onPressed: () => ref
                              .read(bulkDownloaderManagerProvider(config)
                                  .notifier)
                              .pause(d.url),
                          icon: const Icon(Symbols.pause)),
                      title: _Title(data: data),
                      subtitle: LinearPercentIndicator(
                        lineHeight: 2,
                        percent: d.progress,
                        animateFromLastPercent: true,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        animation: true,
                        trailing: Text(
                          '${(d.progress * 100).floor()}%',
                        ),
                      ),
                    ),
                  BulkDownloadPaused d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      trailing: IconButton(
                          onPressed: () => ref
                              .read(bulkDownloaderManagerProvider(config)
                                  .notifier)
                              .resume(d.url),
                          icon: const Icon(Symbols.play_arrow)),
                      title: _Title(data: data),
                      subtitle: LinearPercentIndicator(
                        lineHeight: 2,
                        percent: d.progress,
                        animateFromLastPercent: true,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        animation: true,
                        trailing: Text(
                          '${(d.progress * 100).floor()}%',
                        ),
                      ),
                    ),
                  BulkDownloadFailed d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(data: data),
                      subtitle: const Text('Failed', maxLines: 1),
                      trailing: _RetryButton(
                        url: d.url,
                        fileName: d.fileName,
                      ),
                    ),
                  BulkDownloadCanceled d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(
                        data: data,
                        strikeThrough: true,
                        color: context.theme.hintColor,
                      ),
                      subtitle: const Text('Canceled', maxLines: 1),
                      trailing: _RetryButton(
                        url: d.url,
                        fileName: d.fileName,
                      ),
                    ),
                  BulkDownloadDone d => ListTile(
                      dense: true,
                      visualDensity: const ShrinkVisualDensity(),
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      trailing: const Icon(
                        Symbols.download_done,
                        color: Colors.green,
                      ),
                      onTap: () async {
                        if (isAndroid()) {
                          final intent = AndroidIntent(
                            action: 'action_view',
                            type: 'image/*',
                            data: Uri.parse(d.path).toString(),
                            flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
                          );
                          await intent.launch();
                        }
                      },
                      title: _Title(data: data),
                      // subtitle: d.alreadyExists
                      //     ? const Text('File exists', maxLines: 1)
                      //     : const Text('Done', maxLines: 1),
                    ),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryButton extends ConsumerWidget {
  const _RetryButton({
    required this.url,
    required this.fileName,
  });

  final String url;
  final String fileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return IconButton(
      visualDensity: const ShrinkVisualDensity(),
      onPressed: () => ref
          .read(bulkDownloaderManagerProvider(config).notifier)
          .retry(url, fileName),
      icon: const Icon(Symbols.refresh),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.data,
    this.strikeThrough = false,
    this.color,
  });

  final BulkDownloadStatus data;
  final bool strikeThrough;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      data.fileName,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: color,
        decoration: strikeThrough ? TextDecoration.lineThrough : null,
      ),
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
