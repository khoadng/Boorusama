// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';

class DownloadOptions extends Equatable with DownloadMixin {
  const DownloadOptions({
    required this.onlyDownloadNewFile,
    required this.storagePath,
    this.postPerPage = 200,
    this.ignoreBlacklistedTags = false,
  });

  const DownloadOptions.defaultOptions()
      : onlyDownloadNewFile = true,
        storagePath = '',
        ignoreBlacklistedTags = true,
        postPerPage = 200;

  DownloadOptions copyWith({
    bool? onlyDownloadNewFile,
    String? storagePath,
    int? postPerPage,
    bool? ignoreBlacklistedTags,
  }) =>
      DownloadOptions(
        onlyDownloadNewFile: onlyDownloadNewFile ?? this.onlyDownloadNewFile,
        storagePath: storagePath ?? this.storagePath,
        postPerPage: postPerPage ?? this.postPerPage,
        ignoreBlacklistedTags:
            ignoreBlacklistedTags ?? this.ignoreBlacklistedTags,
      );

  final bool onlyDownloadNewFile;
  @override
  final String storagePath;
  final int postPerPage;
  final bool ignoreBlacklistedTags;

  @override
  List<Object?> get props => [
        onlyDownloadNewFile,
        storagePath,
        postPerPage,
        ignoreBlacklistedTags,
      ];
}
