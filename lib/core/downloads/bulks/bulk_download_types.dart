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

  final Map<String, BulkDownloadStatus> downloadStatuses;
  final int estimatedDownloadSize;

  factory BulkDownloadState.initial() => const BulkDownloadState(
        downloadStatuses: {},
      );

  BulkDownloadState copyWith({
    Map<String, BulkDownloadStatus>? downloadStatuses,
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
  int get doneCount => downloadStatuses.values
      .fold(0, (a, b) => b is BulkDownloadDone ? a + 1 : a);
}
