// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_empty_tag_view.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_tag_selection_view.dart';
import 'widgets/download_in_progress_view.dart';

class BulkDownloadPage extends ConsumerWidget {
  const BulkDownloadPage({
    super.key,
  });

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
        body: SafeArea(
          child: switch (state) {
            BulkDownloadManagerStatus.initial => const DownloadEmptyTagView(),
            BulkDownloadManagerStatus.dataSelected =>
              const DownloadTagSelectionView(),
            BulkDownloadManagerStatus.downloadInProgress ||
            BulkDownloadManagerStatus.cancel =>
              const DownloadInProgressView(),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
