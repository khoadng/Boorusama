// Package imports:
import 'package:equatable/equatable.dart';

class DownloadOptions extends Equatable {
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
  final String storagePath;

  @override
  List<Object?> get props => [
        onlyDownloadNewFile,
        storagePath,
      ];
}
