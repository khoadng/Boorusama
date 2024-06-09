// Package imports:
import 'package:equatable/equatable.dart';

sealed class DownloadStatus extends Equatable {
  const DownloadStatus(
    this.url,
    this.fileName,
  );

  final String url;
  final String fileName;
}

final class DownloadInitializing extends DownloadStatus {
  const DownloadInitializing(
    super.url,
    super.fileName,
  );

  @override
  List<Object?> get props => [];
}

final class DownloadQueued extends DownloadStatus {
  const DownloadQueued(
    super.url,
    super.fileName,
  );

  @override
  List<Object?> get props => [];
}

final class DownloadInProgress extends DownloadStatus {
  const DownloadInProgress(
    super.url,
    super.fileName,
    this.progress,
  );

  final double progress;

  @override
  List<Object?> get props => [progress];
}

final class DownloadPaused extends DownloadStatus {
  const DownloadPaused(
    super.url,
    super.fileName,
    this.progress,
  );

  final double progress;

  @override
  List<Object?> get props => [progress];
}

final class DownloadDone extends DownloadStatus {
  const DownloadDone(
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

final class DownloadFailed extends DownloadStatus {
  const DownloadFailed(
    super.url,
    super.fileName,
  );

  @override
  List<Object?> get props => [];
}

final class DownloadCanceled extends DownloadStatus {
  const DownloadCanceled(
    super.url,
    super.fileName,
  );

  @override
  List<Object?> get props => [];
}
