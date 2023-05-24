// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
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

    return Card(
      color: Theme.of(context).colorScheme.background,
      child: switch (data) {
        BulkDownloadInitializing d => ListTile(
            leading: _Thumbnail(url: thumbnails[d.url]),
            title: Text(basename(data.url)),
            trailing: const CircularProgressIndicator.adaptive(),
          ),
        BulkDownloadQueued d => ListTile(
            leading: _Thumbnail(url: thumbnails[d.url]),
            title: Text(basename(data.url)),
            subtitle: const Text('Queued'),
          ),
        BulkDownloadInProgress d => ListTile(
            leading: _Thumbnail(url: thumbnails[d.url]),
            trailing: IconButton(
                onPressed: () => print('object'),
                icon: const Icon(Icons.pause)),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                basename(d.url),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
        BulkDownloadDone d => ListTile(
            leading: _Thumbnail(url: thumbnails[d.url]),
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
            title: Text(basename(data.url), maxLines: 1),
          ),
      },
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
