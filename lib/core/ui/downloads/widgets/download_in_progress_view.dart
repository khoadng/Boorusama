// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/ui/downloads/widgets/bulk_download_tile.dart';
import 'package:boorusama/functional.dart';

class DownloadInProgressView extends ConsumerWidget {
  const DownloadInProgressView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bulkDownloadStateProvider);
    final data = state.downloadStatuses.values.toList();
    final selectedTags = ref.watch(bulkDownloadSelectedTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 50,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BulkDownloadIndicator(
                title: filesize(state.estimatedDownloadSize, 1),
                subtitle: 'download.bulk_download_total_count'.tr(),
              ),
              const SizedBox(
                child: VerticalDivider(
                  indent: 5,
                  endIndent: 5,
                  thickness: 2,
                ),
              ),
              BulkDownloadIndicator(
                title: state.doneCount.toString(),
                subtitle: 'download.bulk_download_done_count'.tr(),
              ),
              BulkDownloadIndicator(
                title: state.downloadStatuses.length.toString(),
                subtitle: 'download.bulk_download_total_count'.tr(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: selectedTags
                .map(
                    (e) => Chip(label: Text(e.toString().replaceAll('_', ' '))))
                .toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => BulkDownloadTile(
              data: data[index],
            ),
          ),
        ),
        if (data.all((t) => t is BulkDownloadDone))
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(bulkDownloaderManagerProvider.notifier).done(),
              child: const Text('download.bulk_download_done_confirm').tr(),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(bulkDownloaderManagerProvider.notifier).cancelAll(),
              child: const Text('download.bulk_download_cancel').tr(),
            ),
          ),
      ],
    );
  }
}

class BulkDownloadIndicator extends StatelessWidget {
  const BulkDownloadIndicator({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          Text(
            subtitle.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
