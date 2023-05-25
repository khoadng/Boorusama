import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/downloads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
