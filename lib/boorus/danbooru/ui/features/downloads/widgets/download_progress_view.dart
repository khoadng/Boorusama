// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
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
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState, int>(
              selector: (state) => state.totalCount,
              builder: (context, count) {
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: const Text('download.bulk_download_total_count').tr(),
                  trailing: AnimatedFlipCounter(
                    value: count,
                    duration: const Duration(milliseconds: 1000),
                  ),
                );
              },
            ),
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState, int>(
              selector: (state) => state.doneCount,
              builder: (context, count) {
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: const Text('download.bulk_download_done_count').tr(),
                  trailing: AnimatedFlipCounter(value: count),
                );
              },
            ),
            BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
              buildWhen: (previous, current) =>
                  previous.downloadedSize != current.downloadedSize ||
                  previous.estimateDownloadSize != current.estimateDownloadSize,
              builder: (context, state) {
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: const Text('Downloaded size / Total size'),
                  trailing: Text(
                    '${filesize(state.downloadedSize, 1)} / ${filesize(state.estimateDownloadSize, 1)}',
                  ),
                );
              },
            ),
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                List<FilteredOutPost>>(
              selector: (state) => state.filteredPosts,
              builder: (context, filteredPosts) {
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title:
                      const Text('download.bulk_download_hidden_censored_count')
                          .tr(),
                  trailing: AnimatedFlipCounter(
                    value: filteredPosts
                        .where(
                          (e) => e.reason == FilteredReason.censoredTag,
                        )
                        .toList()
                        .length,
                  ),
                );
              },
            ),
            BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                List<FilteredOutPost>>(
              selector: (state) => state.filteredPosts,
              builder: (context, filteredPosts) {
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: const Text(
                    'download.bulk_download_hidden_banned_count',
                  ).tr(),
                  trailing: AnimatedFlipCounter(
                    value: filteredPosts
                        .where(
                          (e) => e.reason == FilteredReason.bannedArtist,
                        )
                        .toList()
                        .length,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => context
                    .read<BulkImageDownloadBloc>()
                    .add(const BulkImagesDownloadCancel()),
                child: const Text('Cancel'),
              ),
            ),
            WarningContainer(
              contentBuilder: (context) => const Text(
                'download.bulk_download_stay_on_screen_request',
              ).tr(),
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
                                  .subtitle1!
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
