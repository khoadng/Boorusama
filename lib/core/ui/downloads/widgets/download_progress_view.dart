// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/downloads/filtered_out_post.dart';
import 'package:boorusama/core/ui/warning_container.dart';

class DownloadProgressView extends StatelessWidget {
  const DownloadProgressView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context
            .read<BulkImageDownloadBloc>()
            .add(const BulkImagesDownloadCancel());

        return true;
      },
      child: SingleChildScrollView(
        child: Column(
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
                  BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                      int>(
                    selector: (state) => state.downloadedSize,
                    builder: (context, state) {
                      return _DownloadIndicator(
                        title: filesize(state, 1),
                        subtitle: 'download.bulk_download_done_count'.tr(),
                      );
                    },
                  ),
                  BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                      int>(
                    selector: (state) => state.estimateDownloadSize,
                    builder: (context, state) {
                      return _DownloadIndicator(
                        title: filesize(state, 1),
                        subtitle: 'download.bulk_download_total_count'.tr(),
                      );
                    },
                  ),
                  const SizedBox(
                    child: VerticalDivider(
                      indent: 5,
                      endIndent: 5,
                      thickness: 2,
                    ),
                  ),
                  BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                      int>(
                    selector: (state) => state.doneCount,
                    builder: (context, state) {
                      return _DownloadIndicator(
                        title: state.toString(),
                        subtitle: 'download.bulk_download_done_count'.tr(),
                      );
                    },
                  ),
                  BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                      int>(
                    selector: (state) => state.totalCount,
                    builder: (context, state) {
                      return _DownloadIndicator(
                        title: state.toString(),
                        subtitle: 'download.bulk_download_total_count'.tr(),
                      );
                    },
                  ),
                ],
              ),
            ),
            WarningContainer(
              contentBuilder: (context) => const Text(
                'download.bulk_download_stay_on_screen_request',
              ).tr(),
            ),
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                List<String>>(
              selector: (state) => state.selectedTags,
              builder: (context, selectedTags) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: selectedTags
                        .map(
                          (e) => Chip(label: Text(e.replaceAll('_', ' '))),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
              buildWhen: (previous, current) =>
                  previous.doneCount != current.doneCount ||
                  previous.totalCount != current.totalCount,
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CircularPercentIndicator(
                    progressColor: Theme.of(context).colorScheme.primary,
                    lineWidth: 10,
                    animation: true,
                    percent: state.percentCompletion,
                    animateFromLastPercent: true,
                    radius: 75,
                    center: Text(
                      state.totalCount != 0
                          ? '${(state.percentCompletion * 100).floor()}%'
                          : '...',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                  ),
                );
              },
            ),
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                List<FilteredOutPost>>(
              selector: (state) => state.filteredPosts,
              builder: (context, filteredPosts) {
                return ExpansionTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('download.bulk_download_hidden').tr(),
                  trailing: Text(
                    filteredPosts.length.toString(),
                  ),
                  children: [
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      title: const Text(
                        'download.bulk_download_hidden_censored',
                      ).tr(),
                      trailing: Text(
                        filteredPosts
                            .where(
                              (e) =>
                                  e.reason == FilteredReason.censoredTag.name,
                            )
                            .toList()
                            .length
                            .toString(),
                      ),
                    ),
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      title: const Text(
                        'download.bulk_download_hidden_banned',
                      ).tr(),
                      trailing: Text(
                        filteredPosts
                            .where(
                              (e) =>
                                  e.reason == FilteredReason.bannedArtist.name,
                            )
                            .toList()
                            .length
                            .toString(),
                      ),
                    ),
                  ],
                );
              },
            ),
            BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
              buildWhen: (previous, current) =>
                  previous.options != current.options ||
                  previous.duplicate != current.duplicate,
              builder: (context, state) {
                return state.options.onlyDownloadNewFile
                    ? ExpansionTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'download.bulk_download_duplicate',
                        ).tr(),
                        trailing: Text(
                          state.duplicate.toString(),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'download.bulk_download_found_duplicate'
                                  .tr()
                                  .replaceAll('{}', state.duplicate.toString()),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              },
            ),
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState, bool>(
              selector: (state) => state.allDownloadCompleted,
              builder: (context, allDone) {
                return allDone
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<BulkImageDownloadBloc>()
                              .add(const BulkImageDownloadSwitchToResutlView()),
                          child:
                              const Text('download.bulk_download_done_confirm')
                                  .tr(),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<BulkImageDownloadBloc>()
                              .add(const BulkImagesDownloadCancel()),
                          child:
                              const Text('download.bulk_download_cancel').tr(),
                        ),
                      );
              },
            ),
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState, String>(
              selector: (state) => state.message,
              builder: (context, state) {
                return state.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              state,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ).tr(),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<BulkImageDownloadBloc>()
                                  .add(const BulkImageDownloadReset()),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadIndicator extends StatelessWidget {
  const _DownloadIndicator({
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
