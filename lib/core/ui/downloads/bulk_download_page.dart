// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_completed_view.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_empty_tag_view.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_error_view.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_progress_view.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_tag_selection_view.dart';

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
    if (!isMobilePlatform()) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('download.bulk_download').tr(),
              const SizedBox(
                width: 6,
              ),
              Chip(
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                label: const Text(
                  'BETA',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const Center(
          child: Text('Only supported in mobile version'),
        ),
      );
    }

    return BlocSelector<BulkDownloadManagerBloc, BulkDownloadManagerState,
        BulkDownloadManagerStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const Text('download.bulk_download').tr(),
                  const SizedBox(
                    width: 6,
                  ),
                  Chip(
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    label: const Text(
                      'BETA',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              automaticallyImplyLeading:
                  status != BulkDownloadManagerStatus.downloadInProgress,
            ),
            body: BlocSelector<BulkDownloadManagerBloc,
                BulkDownloadManagerState, BulkDownloadManagerStatus>(
              selector: (state) => state.status,
              builder: (context, status) => _buildBody(status),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BulkDownloadManagerStatus status) {
    switch (status) {
      case BulkDownloadManagerStatus.initial:
        return const DownloadEmptyTagView();
      case BulkDownloadManagerStatus.dataSelected:
        return const DownloadTagSelectionView();
      case BulkDownloadManagerStatus.downloadInProgress:
        return const DownloadProgressView();
      case BulkDownloadManagerStatus.failure:
        return const DownloadErrorView();
      case BulkDownloadManagerStatus.done:
        return BlocBuilder<BulkDownloadManagerBloc, BulkDownloadManagerState>(
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
