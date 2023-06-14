// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';

class BulkDownloadStateNotifier extends Notifier<BulkDownloadState> {
  @override
  BulkDownloadState build() {
    ref.listen(
      bulkDownloadManagerStatusProvider,
      (previous, next) {
        if (next == BulkDownloadManagerStatus.initial) {
          ref.invalidateSelf();
        }
      },
    );

    ref.listen(
      bulkDownloadDataProvider,
      (previous, next) {
        next.whenData((value) {
          updateDownloadStatus(url: value.url, status: value);
        });
      },
    );

    return BulkDownloadState.initial();
  }

  void addDownloadSize(int fileSize) {
    state = state.copyWith(
      estimatedDownloadSize: state.estimatedDownloadSize + fileSize,
    );
  }

  void updateDownloadStatus({
    required String url,
    required BulkDownloadStatus status,
  }) {
    state = state.copyWith(
      downloadStatuses: {
        ...state.downloadStatuses,
        url: status,
      },
    );
  }

  void updateDownloadToInitilizingState(
    String url,
  ) {
    updateDownloadStatus(
      url: url,
      status: BulkDownloadInitializing(
        url,
        state.downloadStatuses[url]!.fileName,
      ),
    );
  }
}
