// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/ui/features/downloads/widgets/download_completed_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/downloads/widgets/download_empty_tag_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/downloads/widgets/download_error_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/downloads/widgets/download_progress_view.dart';
import 'package:boorusama/boorus/danbooru/ui/features/downloads/widgets/download_tag_selection_view.dart';

class BulkDownloadPage extends StatefulWidget {
  const BulkDownloadPage({
    super.key,
  });

  @override
  State<BulkDownloadPage> createState() => _BulkDownloadPageState();
}

class _BulkDownloadPageState extends State<BulkDownloadPage> {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
        BulkImageDownloadStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('download.bulk_download').tr(),
              automaticallyImplyLeading:
                  status != BulkImageDownloadStatus.downloadInProgress,
            ),
            body: BlocSelector<BulkImageDownloadBloc, BulkImageDownloadState,
                BulkImageDownloadStatus>(
              selector: (state) => state.status,
              builder: (context, status) => _buildBody(status),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BulkImageDownloadStatus status) {
    switch (status) {
      case BulkImageDownloadStatus.initial:
        return const DownloadEmptyTagView();
      case BulkImageDownloadStatus.dataSelected:
        return const DownloadTagSelectionView();
      case BulkImageDownloadStatus.downloadInProgress:
        return const DownloadProgressView();
      case BulkImageDownloadStatus.failure:
        return const DownloadErrorView();
      case BulkImageDownloadStatus.done:
        return BlocBuilder<BulkImageDownloadBloc, BulkImageDownloadState>(
          builder: (context, state) {
            return DownloadCompletedView(
              doneCount: state.doneCount,
              filteredPosts: state.filteredPosts,
              downloaded: state.downloaded,
            );
          },
        );
    }
  }
}
