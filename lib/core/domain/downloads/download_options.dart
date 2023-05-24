// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';

class DownloadOptions extends Equatable with DownloadMixin {
  const DownloadOptions({
    required this.onlyDownloadNewFile,
    required this.storagePath,
  });

  DownloadOptions copyWith({
    bool? onlyDownloadNewFile,
    String? storagePath,
  }) =>
      DownloadOptions(
        onlyDownloadNewFile: onlyDownloadNewFile ?? this.onlyDownloadNewFile,
        storagePath: storagePath ?? this.storagePath,
      );

  final bool onlyDownloadNewFile;
  @override
  final String storagePath;

  @override
  List<Object?> get props => [
        onlyDownloadNewFile,
        storagePath,
      ];
}
