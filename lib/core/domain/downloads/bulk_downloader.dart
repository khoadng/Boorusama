// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'types.dart';

sealed class BulkDownloadStatus extends Equatable {
  const BulkDownloadStatus(this.url);

  final String url;
}

final class BulkDownloadInitializing extends BulkDownloadStatus {
  const BulkDownloadInitializing(super.url);

  @override
  List<Object?> get props => [];
}

final class BulkDownloadQueued extends BulkDownloadStatus {
  const BulkDownloadQueued(super.url);

  @override
  List<Object?> get props => [];
}

final class BulkDownloadInProgress extends BulkDownloadStatus {
  const BulkDownloadInProgress(String url, this.progress) : super(url);

  final double progress;

  @override
  List<Object?> get props => [progress];
}

final class BulkDownloadDone extends BulkDownloadStatus {
  const BulkDownloadDone(super.url, this.path);

  final String path;

  @override
  List<Object?> get props => [];
}

abstract class BulkDownloader {
  Future<void> enqueueDownload({
    required String url,
    String? path,
    required DownloadFileNameBuilder fileNameBuilder,
  });

  Future<void> cancelAll();

  Stream<BulkDownloadStatus> get stream;
}

class QueueData extends Equatable {
  const QueueData(this.itemId, this.size);

  final String itemId;
  final int size;

  @override
  bool? get stringify => false;

  @override
  String toString() => itemId;

  @override
  List<Object?> get props => [itemId];
}

class DownloadData2 extends Equatable {
  const DownloadData2(
    this.itemId,
    this.path,
    this.fileName,
  );

  final String itemId;
  final String path;
  final String fileName;

  @override
  List<Object?> get props => [itemId, path, fileName];
}
