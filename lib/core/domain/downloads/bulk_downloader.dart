// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'types.dart';

sealed class BulkDownloadStatus extends Equatable {
  const BulkDownloadStatus(this.url, this.fileName);

  final String url;
  final String fileName;
}

final class BulkDownloadInitializing extends BulkDownloadStatus {
  const BulkDownloadInitializing(super.url, super.fileName);

  @override
  List<Object?> get props => [];
}

final class BulkDownloadQueued extends BulkDownloadStatus {
  const BulkDownloadQueued(super.url, super.fileName);

  @override
  List<Object?> get props => [];
}

final class BulkDownloadInProgress extends BulkDownloadStatus {
  const BulkDownloadInProgress(super.url, super.fileName, this.progress);

  final double progress;

  @override
  List<Object?> get props => [progress];
}

final class BulkDownloadPaused extends BulkDownloadStatus {
  const BulkDownloadPaused(super.url, super.fileName, this.progress);

  final double progress;

  @override
  List<Object?> get props => [progress];
}

final class BulkDownloadDone extends BulkDownloadStatus {
  const BulkDownloadDone(super.url, super.fileName, this.path);

  final String path;

  @override
  List<Object?> get props => [path];
}

final class BulkDownloadFailed extends BulkDownloadStatus {
  const BulkDownloadFailed(super.url, super.fileName);

  @override
  List<Object?> get props => [];
}

final class BulkDownloadCanceled extends BulkDownloadStatus {
  const BulkDownloadCanceled(super.url, super.fileName);

  @override
  List<Object?> get props => [];
}

abstract class BulkDownloader {
  Future<void> enqueueDownload({
    required String url,
    String? path,
    required DownloadFileNameBuilder fileNameBuilder,
  });

  Future<void> pause(String url);
  Future<void> resume(String url);

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
