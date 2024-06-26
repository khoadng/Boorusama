// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';

class DownloadOptions extends Equatable with DownloadMixin {
  const DownloadOptions({
    required this.onlyDownloadNewFile,
    required this.storagePath,
    this.postPerPage = 200,
  });

  const DownloadOptions.defaultOptions()
      : onlyDownloadNewFile = true,
        storagePath = '',
        postPerPage = 200;

  DownloadOptions copyWith({
    bool? onlyDownloadNewFile,
    String? storagePath,
    int? postPerPage,
  }) =>
      DownloadOptions(
        onlyDownloadNewFile: onlyDownloadNewFile ?? this.onlyDownloadNewFile,
        storagePath: storagePath ?? this.storagePath,
        postPerPage: postPerPage ?? this.postPerPage,
      );

  final bool onlyDownloadNewFile;
  @override
  final String storagePath;
  final int postPerPage;

  @override
  List<Object?> get props => [
        onlyDownloadNewFile,
        storagePath,
        postPerPage,
      ];
}
