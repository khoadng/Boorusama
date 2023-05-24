// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_empty_tag_view.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_tag_selection_view.dart';
import 'widgets/download_in_progress_view.dart';

class BulkDownloadPage extends ConsumerWidget {
  const BulkDownloadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bulkDownloadManagerStatusProvider);

    ref.listen(
      bulkDownloadSelectedTagsProvider,
      (previous, next) {
        // this is a hack to keep the state of selected tags
      },
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('download.bulk_download').tr(),
        ),
        body: switch (state) {
          BulkDownloadManagerStatus.initial => const DownloadEmptyTagView(),
          // ListView.builder(
          //     itemCount: 10,
          //     itemBuilder: (context, index) => Card(
          //       color: Theme.of(context).colorScheme.background,
          //       child: ListTile(
          //         leading: BooruImage(imageUrl: thumbnails[index] ?? ''),
          //         trailing: IconButton(
          //             onPressed: () => print('object'),
          //             icon: Icon(Icons.pause)),
          //         title: Padding(
          //           padding: const EdgeInsets.only(bottom: 12),
          //           child: Text(
          //             basename('JASDLFJALKKLAJSKDLFJAKLSJFKL'),
          //             maxLines: 1,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //         ),
          //         subtitle: LinearPercentIndicator(
          //           lineHeight: 2,
          //           percent: 0.5,
          //           animateFromLastPercent: true,
          //           padding: EdgeInsets.symmetric(horizontal: 4),
          //           animation: true,
          //           trailing: Text(
          //             '${(0.6 * 100).floor()}%',
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          BulkDownloadManagerStatus.dataSelected =>
            const DownloadTagSelectionView(),
          BulkDownloadManagerStatus.downloadInProgress =>
            const DownloadInProgressView(),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
