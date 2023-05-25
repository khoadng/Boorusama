// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/ui/booru_image.dart';

class BulkDownloadTile extends ConsumerWidget {
  const BulkDownloadTile({
    super.key,
    required this.data,
  });

  final BulkDownloadStatus data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnails = ref.watch(bulkDownloadThumbnailsProvider);
    final fileSizes = ref.watch(bulkDownloadFileSizeProvider);

    return Card(
      color: Theme.of(context).colorScheme.background,
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
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            label: const Text(
                              'File exists',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        _ => const SizedBox.shrink(),
                      },
                      Chip(
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        label: Text(extension(data.url)),
                      ),
                      Chip(
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
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
                      trailing: const CircularProgressIndicator(),
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
                              .read(bulkDownloaderManagerProvider.notifier)
                              .pause(d.url),
                          icon: const Icon(Icons.pause)),
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
                              .read(bulkDownloaderManagerProvider.notifier)
                              .resume(d.url),
                          icon: const Icon(Icons.play_arrow)),
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
                  BulkDownloadFailed _ => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(data: data),
                      subtitle: const Text('Failed', maxLines: 1),
                    ),
                  BulkDownloadCanceled _ => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(
                        data: data,
                        strikeThrough: true,
                        color: Theme.of(context).hintColor,
                      ),
                      subtitle: const Text('Canceled', maxLines: 1),
                    ),
                  BulkDownloadDone d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                        horizontal: -4,
                      ),
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      trailing: const Icon(
                        Icons.download_done,
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
