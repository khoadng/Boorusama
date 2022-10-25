// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/core/ui/info_container.dart';
import 'package:boorusama/core/ui/warning_container.dart';

class DownloadProgressView extends StatelessWidget {
  const DownloadProgressView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState, int>(
            selector: (state) => state.totalCount,
            builder: (context, count) {
              return ListTile(
                visualDensity: VisualDensity.compact,
                title: const Text('Total'),
                trailing: AnimatedFlipCounter(value: count),
              );
            },
          ),
          BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState, int>(
            selector: (state) => state.doneCount,
            builder: (context, count) {
              return ListTile(
                visualDensity: VisualDensity.compact,
                title: const Text('Done'),
                trailing: AnimatedFlipCounter(value: count),
              );
            },
          ),
          BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
              List<FilteredOutPost>>(
            selector: (state) => state.filteredPosts,
            builder: (context, filteredPosts) {
              return ListTile(
                visualDensity: VisualDensity.compact,
                title: const Text('Hidden (censored tags)'),
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
                  "Hidden (removed at the artist's request)",
                ),
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
          BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState, int>(
            selector: (state) => state.totalCount,
            builder: (context, totalCount) {
              return totalCount > 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: BlocSelector<BulkImageDownloadBloc,
                          BulkImageDownloadState, int>(
                        selector: (state) => state.doneCount,
                        builder: (context, doneCount) {
                          return CircularPercentIndicator(
                            radius: 75,
                            lineWidth: 15,
                            animation: true,
                            animateFromLastPercent: true,
                            circularStrokeCap: CircularStrokeCap.round,
                            percent: doneCount / totalCount,
                            center: Text(
                              '${(doneCount / totalCount * 100).floor()}%',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          InfoContainer(
            contentBuilder: (context) => const Text(
              "Some images might be hidden and won't be downloaded",
            ),
          ),
          WarningContainer(
            contentBuilder: (context) => const Text(
              'Please stay on this screen until all files are downloaded',
            ),
          ),
        ],
      ),
    );
  }
}
