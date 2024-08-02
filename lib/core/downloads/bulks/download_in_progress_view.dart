// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

final bulkDownloadFilterProvider =
    StateProvider.autoDispose<DownloadFilter>((ref) {
  return DownloadFilter.all;
});

final bulkDownloadFilteredProvider = Provider.autoDispose
    .family<List<DownloadStatus>, BooruConfig>((ref, config) {
  final filter = ref.watch(bulkDownloadFilterProvider);
  final state = ref.watch(bulkDownloadStateProvider(config)
      .select((value) => value.downloadStatuses));

  return switch (filter) {
    DownloadFilter.all => state.values.toList(),
    DownloadFilter.pending => state.values.whereType<DownloadQueued>().toList(),
    DownloadFilter.paused => state.values.whereType<DownloadPaused>().toList(),
    DownloadFilter.inProgress =>
      state.values.whereType<DownloadInProgress>().toList(),
    DownloadFilter.completed => state.values.whereType<DownloadDone>().toList(),
    DownloadFilter.failed => state.values.whereType<DownloadFailed>().toList(),
  };
});

final bulkDownloadFailedProvider = Provider.autoDispose
    .family<List<DownloadFailed>, BooruConfig>((ref, config) {
  final state = ref.watch(bulkDownloadStateProvider(config)
      .select((value) => value.downloadStatuses));

  return state.values.whereType<DownloadFailed>().toList();
});

class DownloadInProgressView extends ConsumerWidget {
  const DownloadInProgressView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final state = ref.watch(bulkDownloadStateProvider(config));
    final status = ref.watch(bulkDownloadManagerStatusProvider);
    final data = ref.watch(bulkDownloadFilteredProvider(config));
    final selectedTags = ref.watch(bulkDownloadSelectedTagsProvider);

    final failed = ref.watch(bulkDownloadFailedProvider(config));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (failed.isNotEmpty)
            BooruPopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 'retry_all':
                    ref
                        .read(bulkDownloaderManagerProvider(config).notifier)
                        .retryAll();
                    break;
                }
              },
              itemBuilder: {
                'retry_all': Text('Retry ${failed.length} failed downloads'),
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: context.colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BulkDownloadIndicator(
                  title: filesize(state.estimatedDownloadSize, 1),
                  subtitle: 'download.bulk_download_total_count'.tr(),
                ),
                SizedBox(
                  child: VerticalDivider(
                    color: context.theme.hintColor,
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
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            context.theme.colorScheme.surfaceContainerHighest,
                        label: Text(e.replaceUnderscoreWithSpace()),
                        shape: const StadiumBorder(side: BorderSide()),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Builder(builder: (context) {
              final selectedFilter = ref.watch(bulkDownloadFilterProvider);
              return OptionDropDownButton(
                alignment: AlignmentDirectional.centerStart,
                value: selectedFilter,
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(bulkDownloadFilterProvider.notifier).state = value;
                },
                items: DownloadFilter.values
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.name.sentenceCase),
                        ))
                    .toList(),
              );
            }),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => BulkDownloadTile(
                  data: data[index],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if ((data.isNotEmpty && data.all((t) => t is DownloadDone)) ||
                    status == BulkDownloadManagerStatus.cancel)
                  FilledButton(
                    onPressed: () => ref
                        .read(bulkDownloaderManagerProvider(config).notifier)
                        .done(),
                    child:
                        const Text('download.bulk_download_done_confirm').tr(),
                  )
                else
                  FilledButton(
                    onPressed: () => ref
                        .read(bulkDownloaderManagerProvider(config).notifier)
                        .cancelAll(),
                    child: const Text('download.bulk_download_cancel').tr(),
                  ),
              ],
            ),
          ),
        ],
      ),
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
          Flexible(
            child: Text(
              subtitle.toUpperCase(),
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.theme.hintColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
