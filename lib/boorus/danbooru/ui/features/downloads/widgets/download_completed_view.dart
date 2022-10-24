// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';

class DownloadCompletedView extends StatelessWidget {
  const DownloadCompletedView({
    super.key,
    required this.doneCount,
    required this.filteredPosts,
    required this.downloaded,
  });

  final int doneCount;
  final List<FilteredOutPost> filteredPosts;
  final List<DownloadImageData> downloaded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$doneCount images downloaded',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(fontWeight: FontWeight.w900),
                      ),
                      if (filteredPosts.isNotEmpty)
                        Text(
                          '${filteredPosts.length} images skipped',
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(fontWeight: FontWeight.w900),
                        ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = downloaded[index];

                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        data.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      subtitle: Text(
                        data.relativeToPublicFolderPath,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      leading: Text(
                        (index + 1).toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    );
                  },
                  childCount: downloaded.length,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ElevatedButton(
            onPressed: () => context
                .read<BulkImageDownloadBloc>()
                .add(const BulkImageDownloadReset()),
            child: const Text('Download more'),
          ),
        ),
      ],
    );
  }
}
