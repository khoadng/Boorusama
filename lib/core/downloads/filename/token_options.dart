// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/dart.dart';

class DownloadFilenameTokenOptions extends Equatable {
  const DownloadFilenameTokenOptions({
    required this.downloadUrl,
    required this.fallbackFilename,
    required this.format,
    this.metadata,
  });

  final String downloadUrl;
  final String fallbackFilename;
  final String format;
  final Map<String, String>? metadata;

  @override
  List<Object?> get props => [downloadUrl, fallbackFilename, format, metadata];
}

extension DownloadFilenameTokenOptionsX on DownloadFilenameTokenOptions {
  int? get index => metadata?['index']?.toIntOrNull();
}
