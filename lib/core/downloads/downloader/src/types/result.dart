// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'error.dart';

class DownloadTaskInfo extends Equatable {
  const DownloadTaskInfo({
    required this.path,
    required this.id,
  });

  final String path;
  final String id;

  @override
  List<Object?> get props => [path, id];
}

sealed class DownloadResult {
  const DownloadResult();
}

final class DownloadSuccess extends DownloadResult {
  const DownloadSuccess(this.info);

  final DownloadTaskInfo info;
}

final class DownloadFailure extends DownloadResult {
  const DownloadFailure(this.error);

  final DownloadError error;
}
