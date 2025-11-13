// Package imports:
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../settings/types.dart';
import 'metadata.dart';

class DownloadOptions extends Equatable {
  const DownloadOptions({
    required this.url,
    required this.filename,
    this.metadata,
    this.skipIfExists,
    this.headers,
    this.path,
    this.folderName,
  });

  factory DownloadOptions.fromSettings(
    Settings settings, {
    required BooruConfigDownload config,
    required String url,
    required String filename,
    Map<String, String>? headers,
    DownloaderMetadata? metadata,
    String? folderName,
    String? customPath,
  }) {
    final path = switch (customPath) {
      // User provided a custom path
      final String path => path,
      // No custom path, use config or settings
      null => switch (config.location) {
        // Config specified location
        final String location when location.isNotEmpty => location,
        // Fallback to settings
        _ => settings.downloadPath,
      },
    };

    return DownloadOptions(
      url: url,
      filename: filename,
      headers: headers,
      metadata: metadata,
      skipIfExists: settings.downloadFileExistedBehavior.skipDownloadIfExists,
      path: switch (path) {
        final String p when p.isNotEmpty => join(p, folderName),
        _ => null,
      },
      folderName: folderName,
    );
  }

  final String url;
  final String filename;
  final DownloaderMetadata? metadata;
  final bool? skipIfExists;
  final Map<String, String>? headers;
  final String? path;
  final String? folderName;

  @override
  List<Object?> get props => [
    url,
    filename,
    metadata,
    skipIfExists,
    headers,
    path,
    folderName,
  ];
}
