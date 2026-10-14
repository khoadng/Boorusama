// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'error.dart';

class DownloadTaskInfo extends Equatable {
  const DownloadTaskInfo({
    required this.path,
    required this.id,
    this.metadataSkipped = false,
  });

  final String path;
  final String id;

  /// The destination does not accept the metadata file, so only the media is
  /// saved.
  final bool metadataSkipped;

  DownloadTaskInfo withMetadataSkipped() =>
      DownloadTaskInfo(path: path, id: id, metadataSkipped: true);

  @override
  List<Object?> get props => [path, id, metadataSkipped];
}

sealed class DownloadResult {
  const DownloadResult();
}

enum DownloadCompletionSource { network, cache, alreadyPresent }

final class DownloadEnqueued extends DownloadResult {
  const DownloadEnqueued(this.info);

  final DownloadTaskInfo info;
}

final class DownloadCompleted extends DownloadResult {
  const DownloadCompleted(
    this.info, {
    required this.source,
  });

  final DownloadTaskInfo info;
  final DownloadCompletionSource source;
}

extension DownloadResultMetadataSkipped on DownloadResult {
  DownloadResult withMetadataSkipped() => switch (this) {
    DownloadEnqueued(:final info) => DownloadEnqueued(
      info.withMetadataSkipped(),
    ),
    DownloadCompleted(:final info, :final source) => DownloadCompleted(
      info.withMetadataSkipped(),
      source: source,
    ),
    final result => result,
  };
}

final class DownloadSkipped extends DownloadResult {
  const DownloadSkipped(this.info);

  final DownloadTaskInfo info;
}

final class DownloadFailure extends DownloadResult {
  const DownloadFailure(this.error);

  final DownloadError error;
}
