// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';

enum BulkDownloadManagerStatus {
  initial,
  dataSelected,
  downloadInProgress,
  cancel,
  failure,
  done,
}

class BulkDownloadState extends Equatable {
  const BulkDownloadState({
    required this.downloadStatuses,
    this.estimatedDownloadSize = 0,
  });

  factory BulkDownloadState.initial() => const BulkDownloadState(
        downloadStatuses: {},
      );

  final Map<String, DownloadStatus> downloadStatuses;
  final int estimatedDownloadSize;

  BulkDownloadState copyWith({
    Map<String, DownloadStatus>? downloadStatuses,
    int? doneCount,
    int? estimatedDownloadSize,
  }) =>
      BulkDownloadState(
        downloadStatuses: downloadStatuses ?? this.downloadStatuses,
        estimatedDownloadSize:
            estimatedDownloadSize ?? this.estimatedDownloadSize,
      );

  @override
  List<Object?> get props => [downloadStatuses, estimatedDownloadSize];
}

extension BulkDownloadStateX on BulkDownloadState {
  int get doneCount =>
      downloadStatuses.values.fold(0, (a, b) => b is DownloadDone ? a + 1 : a);
}
