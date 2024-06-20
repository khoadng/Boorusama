// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:collection/collection.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';

class DownloadTile extends StatelessWidget {
  const DownloadTile({
    super.key,
    required this.data,
    this.thumbnails,
    this.fileSizes,
    required this.onRetry,
    required this.onResume,
    required this.onPause,
  });

  final DownloadStatus data;
  final Map<String, String>? thumbnails;
  final Map<String, int>? fileSizes;
  final VoidCallback onRetry;
  final Function(String url) onResume;
  final void Function(String url) onPause;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: thumbnails.toOption().fold(
                  () => Card(
                    color: context.colorScheme.tertiaryContainer,
                    child: const Icon(
                      Symbols.image,
                      color: Colors.white,
                    ),
                  ),
                  (t) => _Thumbnail(url: t[data.url]),
                ),
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
                        DownloadDone d when d.alreadyExists => Chip(
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
                      fileSizes.toOption().fold(
                            () => const SizedBox.shrink(),
                            (fs) => fs[data.url] != null && fs[data.url]! > 0
                                ? Chip(
                                    backgroundColor:
                                        context.colorScheme.tertiaryContainer,
                                    visualDensity: const ShrinkVisualDensity(),
                                    label: Text(
                                      filesize(
                                        fs[data.url],
                                        1,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                    ],
                  ),
                ),
                switch (data) {
                  DownloadInitializing _ => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(data: data.fileName),
                      trailing: const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  DownloadQueued _ => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(data: data.fileName),
                      subtitle: const Text('Queued', maxLines: 1),
                    ),
                  DownloadInProgress d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      trailing: IconButton(
                        onPressed: () => onPause(d.url),
                        icon: const Icon(
                          Symbols.pause,
                          fill: 1,
                        ),
                      ),
                      title: _Title(data: data.fileName),
                      subtitle: LinearPercentIndicator(
                        lineHeight: 2,
                        percent: d.progress < 0 ? 0 : d.progress,
                        animateFromLastPercent: true,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        animation: true,
                        trailing: Text(
                          '${(d.progress * 100).floor()}%',
                        ),
                      ),
                    ),
                  DownloadPaused d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      trailing: IconButton(
                        onPressed: () => onResume(d.url),
                        icon: const Icon(
                          Symbols.play_arrow,
                          fill: 1,
                        ),
                      ),
                      title: _Title(data: data.fileName),
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
                  DownloadFailed d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(data: data.fileName),
                      subtitle: const Text('Failed', maxLines: 1),
                      trailing: _RetryButton(
                        url: d.url,
                        fileName: d.fileName,
                      ),
                    ),
                  DownloadCanceled d => ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(
                        vertical: -4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: _Title(
                        data: data.fileName,
                        strikeThrough: true,
                        color: context.theme.hintColor,
                      ),
                      subtitle: const Text('Canceled', maxLines: 1),
                      trailing: _RetryButton(
                        url: d.url,
                        fileName: d.fileName,
                      ),
                    ),
                  DownloadDone d => ListTile(
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
                      title: _Title(data: data.fileName),
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

class DownloadTileBuilder extends StatelessWidget {
  const DownloadTileBuilder({
    super.key,
    this.fileSize,
    this.networkSpeed,
    this.timeRemaining,
    required this.url,
    required this.builder,
    this.thumbnailUrl,
    this.onCancel,
    this.siteUrl,
  });

  final String? thumbnailUrl;
  final int? fileSize;
  final double? networkSpeed; // in MB/s
  final Duration? timeRemaining;
  final String url;
  final Widget Function(String)? builder;
  final void Function()? onCancel;
  final String? siteUrl;

  @override
  Widget build(BuildContext context) {
    final fileSizeText =
        fileSize != null && fileSize! > 0 ? filesize(fileSize, 1) : null;
    final networkSpeedText = networkSpeed.toOption().fold(
          () => null,
          (s) => switch (s) {
            <= 0 => '-- MB/s',
            >= 1 => '${s.round()} MB/s',
            _ => '${(s * 1000).round()} kB/s'
          },
        );
    final timeRemainingText = timeRemaining.toOption().fold(
          () => null,
          (t) => _durationToTime(t),
        );
    final extensionText = sanitizedExtension(url);

    final infoText = [
      extensionText,
      fileSizeText,
      networkSpeedText,
      timeRemainingText,
    ].whereNotNull().join(' • ');

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: thumbnailUrl.toOption().fold(
                  () => SizedBox(
                    height: 60,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (siteUrl != null)
                      PostSource.from(siteUrl!).whenWeb(
                        (source) => BooruLogo(
                          source: source,
                          width: 18,
                          height: 18,
                        ),
                        () => const SizedBox.shrink(),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          infoText,
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
                    if (onCancel != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: const ShrinkVisualDensity(),
                        ),
                        onPressed: onCancel,
                        child: const Text('Cancel'),
                      )
                    else
                      const SizedBox(
                        height: 32,
                      ),
                  ],
                ),
                builder?.call(url) ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _durationToTime(Duration duration) {
  // 00:00:00 format
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class RawDownloadTile extends StatelessWidget {
  const RawDownloadTile({
    super.key,
    required this.fileName,
    required this.subtitle,
    required this.url,
    required this.trailing,
    this.strikeThrough = false,
    this.color,
  });

  final String fileName;
  final Widget subtitle;
  final String url;
  final Widget trailing;
  final bool strikeThrough;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // don't use ListTile here because our trailing is very custom
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(
                data: fileName,
                strikeThrough: strikeThrough,
                color: color,
              ),
              subtitle,
            ],
          ),
        ),
        const SizedBox(width: 4),
        trailing,
      ],
    );
  }
}

class BulkDownloadTile extends ConsumerWidget {
  const BulkDownloadTile({
    super.key,
    required this.data,
  });

  final DownloadStatus data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final thumbnails = ref.watch(bulkDownloadThumbnailsProvider);
    final fileSizes = ref.watch(bulkDownloadFileSizeProvider);

    return DownloadTile(
      data: data,
      thumbnails: thumbnails,
      fileSizes: fileSizes,
      onRetry: () => ref
          .read(bulkDownloaderManagerProvider(config).notifier)
          .retry(data.url, data.fileName),
      onResume: (url) =>
          ref.read(bulkDownloaderManagerProvider(config).notifier).resume(url),
      onPause: (url) =>
          ref.read(bulkDownloaderManagerProvider(config).notifier).pause(url),
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
