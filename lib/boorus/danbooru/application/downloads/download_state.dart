// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'download_bloc.dart';

class DownloadState<T> extends Equatable {
  const DownloadState({
    required this.totalCount,
    required this.doneCount,
    required this.queueCount,
    required this.duplicate,
    required this.estimateDownloadSize,
    required this.downloadedSize,
    required this.filtered,
    required this.downloadQueue,
    required this.downloaded,
    required this.allDownloadCompleted,
    required this.didFetchAllPage,
    required this.errorMessage,
    required this.storagePath,
    required this.status,
  });

  factory DownloadState.initial() => const DownloadState(
        totalCount: 0,
        doneCount: 0,
        queueCount: 0,
        duplicate: 0,
        estimateDownloadSize: 0,
        downloadedSize: 0,
        filtered: [],
        downloadQueue: [],
        downloaded: [],
        allDownloadCompleted: false,
        didFetchAllPage: false,
        errorMessage: '',
        storagePath: '',
        status: DownloadStatus.notStarted,
      );

  final int totalCount;
  final int doneCount;
  final int queueCount;
  final int duplicate;
  final int estimateDownloadSize;
  final int downloadedSize;
  final List<T> filtered;
  final List<QueueData> downloadQueue;
  final List<DownloadImageData> downloaded;
  final bool allDownloadCompleted;
  final bool didFetchAllPage;
  final String errorMessage;
  final String storagePath;
  final DownloadStatus status;

  DownloadState<T> copyWith({
    int? totalCount,
    int? doneCount,
    int? queueCount,
    int? duplicate,
    int? estimateDownloadSize,
    int? downloadedSize,
    List<T>? filtered,
    List<QueueData>? downloadQueue,
    List<DownloadImageData>? downloaded,
    bool? allDownloadCompleted,
    bool? didFetchAllPage,
    String? errorMessage,
    String? storagePath,
    DownloadStatus? status,
  }) =>
      DownloadState(
        totalCount: totalCount ?? this.totalCount,
        doneCount: doneCount ?? this.doneCount,
        queueCount: queueCount ?? this.queueCount,
        duplicate: duplicate ?? this.duplicate,
        estimateDownloadSize: estimateDownloadSize ?? this.estimateDownloadSize,
        downloadedSize: downloadedSize ?? this.downloadedSize,
        filtered: filtered ?? this.filtered,
        downloadQueue: downloadQueue ?? this.downloadQueue,
        downloaded: downloaded ?? this.downloaded,
        allDownloadCompleted: allDownloadCompleted ?? this.allDownloadCompleted,
        didFetchAllPage: didFetchAllPage ?? this.didFetchAllPage,
        errorMessage: errorMessage ?? this.errorMessage,
        storagePath: storagePath ?? this.storagePath,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [
        totalCount,
        doneCount,
        queueCount,
        duplicate,
        estimateDownloadSize,
        downloadedSize,
        filtered,
        downloadQueue,
        downloaded,
        allDownloadCompleted,
        didFetchAllPage,
        errorMessage,
        storagePath,
        status,
      ];
}

class QueueData extends Equatable {
  const QueueData(this.itemId, this.size);

  final int itemId;
  final int size;

  @override
  bool? get stringify => false;

  @override
  String toString() => '$itemId';

  @override
  List<Object?> get props => [itemId, size];
}

class DownloadImageData extends Equatable {
  const DownloadImageData({
    required this.absolutePath,
    required this.relativeToPublicFolderPath,
    required this.fileName,
  });

  final String absolutePath;
  final String relativeToPublicFolderPath;
  final String fileName;

  @override
  List<Object?> get props =>
      [absolutePath, relativeToPublicFolderPath, fileName];
}
