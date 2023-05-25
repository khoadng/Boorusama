// Package imports:
import 'package:equatable/equatable.dart';

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
  const BulkDownloadDone(
    super.url,
    super.fileName,
    this.path, {
    this.alreadyExists = false,
  });

  final String path;
  final bool alreadyExists;

  @override
  List<Object?> get props => [path, alreadyExists];
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
