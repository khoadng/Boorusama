// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/pages/downloads/widgets/bulk_download_tile.dart';
import 'package:boorusama/boorus/core/pages/option_dropdown_button.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';

enum BulkDownloadFilter {
  all,
  pending,
  inProgress,
  completed,
  failed,
}

final bulkDownloadFilterProvider =
    StateProvider.autoDispose<BulkDownloadFilter>((ref) {
  return BulkDownloadFilter.all;
});

final bulkDownloadFilteredProvider =
    Provider.autoDispose<List<BulkDownloadStatus>>((ref) {
  final filter = ref.watch(bulkDownloadFilterProvider);
  final state = ref.watch(
      bulkDownloadStateProvider.select((value) => value.downloadStatuses));

  return switch (filter) {
    BulkDownloadFilter.all => state.values.toList(),
    BulkDownloadFilter.pending =>
      state.values.whereType<BulkDownloadQueued>().toList(),
    BulkDownloadFilter.inProgress =>
      state.values.whereType<BulkDownloadInProgress>().toList(),
    BulkDownloadFilter.completed =>
      state.values.whereType<BulkDownloadDone>().toList(),
    BulkDownloadFilter.failed =>
      state.values.whereType<BulkDownloadFailed>().toList(),
  };
});

class DownloadInProgressView extends ConsumerWidget {
  const DownloadInProgressView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bulkDownloadStateProvider);
    final status = ref.watch(bulkDownloadManagerStatusProvider);
    final data = ref.watch(bulkDownloadFilteredProvider);
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
                .map((e) => Chip(
                      label: Text(e.toString().replaceAll('_', ' ')),
                      shape: const StadiumBorder(side: BorderSide()),
                    ))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Builder(builder: (context) {
            final selectedFilter = ref.watch(bulkDownloadFilterProvider);
            return OptionDropDownButton<BulkDownloadFilter>(
              value: selectedFilter,
              onChanged: (value) {
                if (value == null) return;
                ref.read(bulkDownloadFilterProvider.notifier).state = value;
              },
              items: BulkDownloadFilter.values
                  .map((value) => DropdownMenuItem<BulkDownloadFilter>(
                        value: value,
                        child: Text(value.name.sentenceCase),
                      ))
                  .toList(),
            );
          }),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => BulkDownloadTile(
                data: data[index],
              ),
            ),
          ),
        ),
        if ((data.isNotEmpty && data.all((t) => t is BulkDownloadDone)) ||
            status == BulkDownloadManagerStatus.cancel)
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
